#!/usr/bin/env python3
from collections import namedtuple
import os
import sys
import subprocess
import shlex
import shutil
from pathlib import Path
import argparse

import yaml

PATH = Path(__file__).parent.absolute()


class Loader(object):
    loader_name = "undefined"

    def __init__(self, path):
        self.path = path
        self.workdir = path

    def build(self, force=False):
        return True

    @property
    def is_built(self):
        return True

    @property
    def is_defined(self):
        return False

    @property
    def is_available(self):
        return True

    def remove(self):
        pass

    def build(self, force=False):
        if self.is_built:
            if force:
                self.remove()
            else:
                return True

        return self._build()

    def run(self, dataset, output_dir, gpu_switch="cpu"):
        cmd = self._get_run_cmd(dataset, output_dir, gpu_switch)
        print(cmd)
        result = subprocess.run(
            cmd, shell=True, capture_output=False, text=True, cwd=output_dir
        )
        return result.returncode == 0


class ApptainerLoader(Loader):
    loader_name = "Apptainer"
    gpu_switch = {"cpu": "", "gpu": "--nv"}

    def __init__(self, path):
        path = Path(path)
        if not path.is_dir():
            TypeError("Only directory accepted for Apptainer")
        self.path = path
        self.workdir = path

    @property
    def container_name(self):
        return self.path.parent.name + "-loader.sif"

    @property
    def is_built(self):
        return (self.path / self.container_name).exists()

    @property
    def is_defined(self):
        return (self.path / "Apptainer.def").exists()

    @property
    def is_available(self):
        return shutil.which("apptainer") is not None

    def remove(self):
        (self.path / self.container_name).unlink()

    def _build(self):
        p = subprocess.run(
            ["apptainer", "build", self.container_name, "Apptainer.def"],
            cwd=self.workdir,
        )
        return p.returncode == 0

    def _get_run_cmd(self, dataset, output_dir, gpu_switch="cpu"):
        """Command to run to execute app"""
        cmd = f"apptainer run {self.gpu_switch[gpu_switch]} -B {dataset}:/input/dataset -B {output_dir}:/output {self.path / self.container_name}"
        return cmd


class DockerLoader(Loader):
    loader_name = "Docker"
    gpu_switch = {"cpu": "", "gpu": "--runtime=nvidia --gpus all"}

    def __init__(self, path):
        path = Path(path)
        if not path.is_dir():
            TypeError("Only directory accepted for Docker")
        self.path = path / "loader"
        self.workdir = path / "loader"

    @property
    def container_name(self):
        return self.path.parent.name + "-loader"

    @property
    def is_built(self):
        result = subprocess.run(
            ["docker", "images", "-q", self.container_name],
            capture_output=True,
            text=True,
        )
        return result.stdout.strip() != ""

    def _get_run_cmd(self, dataset, output_dir, gpu_switch="cpu"):
        """Command to run to execute loader"""
        cmd = f"docker run {self.gpu_switch[gpu_switch]} -v {dataset}:/input/dataset -v {output_dir}:/output {self.container_name} /input/dataset"
        return cmd

    @property
    def is_defined(self):
        return (self.path / "Dockerfile").exists()

    @property
    def is_available(self):
        return shutil.which("docker") is not None

    def remove(self):
        pass  # TODO: implement, for now this is only used for build process, it will be replaced anyway

    def _build(self):
        p = subprocess.run(
            ["apptainer", "build", self.container_name, "Apptainer.def"],
            cwd=self.workdir,
        )
        return p.returncode == 0


class ScriptLoader(Loader):
    loader_name = "Script"

    def __init__(self, path):
        path = Path(path)
        if not path.is_file():
            TypeError("Only files accepted as scripts")
        self.path = path
        self.workdir = path

    def _get_run_cmd(self, dataset, output_dir, gpu_switch="cpu"):
        """Command to run to execute app"""
        cmd = f"{self.path} {dataset}"
        return cmd

    @property
    def is_defined(self):
        return self.path.exists()

    def _build(self):
        return True


def load_dataset_config(file_path):
    with open(file_path, "r") as file:
        return yaml.safe_load(file)


Dataset = namedtuple("Dataset", ("name", "split", "url", "alias", "processing"))


def initialize_loader(loader_path):
    # Check if we have any loaders defined and available
    # Start with Docker, Apptainer then script (shell, python file etc.)
    available_loader = None
    any_defined = False
    for loader_class in [DockerLoader, ApptainerLoader, ScriptLoader]:
        try:
            loader = loader_class(loader_path)
        except TypeError as e:
            print(f"Skipping {loader_class.__name__} because of {e}")
            continue

        print("available", loader, loader.is_defined)
        if loader.is_defined:
            any_defined = True
            if loader.is_available:
                loader.build()
                available_loader = loader
                break
            else:
                print(f"{loader.loader_name} defined, but unavailable")

    if any_defined and available_loader is None:
        raise ValueError("Unable to initialize any defined loader")
    print(loader, available_loader)
    return available_loader


loader_stages = ("preprocess", "process", "postprocess")


def find_split_urls(base_path, datasets, dataset_name, split_name=None):
    result = []
    for dataset in datasets:
        # Only selected ones
        if dataset_name and dataset["name"] != dataset_name:
            continue
        # Get processing definitions
        processing_dict = {}
        for stage in loader_stages:
            loader_path = dataset.get(stage)
            if loader_path is not None:
                loader = initialize_loader(base_path / loader_path)
            else:
                loader = None
            print(stage, ":", loader_path, loader)
            processing_dict[stage] = loader
        for split in dataset["data_files"]:
            if split_name and split["split"] != split_name:
                continue
            # Override with split specific definitions if present
            for stage in loader_stages:
                loader_path = split.get(stage)
                if loader_path is not None:
                    loader = initialize_loader(base_path / loader_path)
                    processing_dict[stage] = loader

            if isinstance(split["url"], dict):
                urls = split["url"]
            else:
                alias = split["url"].split("/")[-1]
                urls = {alias: split["url"]}

            result.extend(
                [
                    Dataset(
                        dataset["name"],
                        split["split"],
                        url,
                        alias,
                        processing_dict,
                    )
                    for alias, url in urls.items()
                ]
            )
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Load dataset and specified split based on datasets.yaml"
    )
    parser.add_argument("datasets_file", type=str, help="Path to datasets.yaml")
    parser.add_argument(
        "dataset_name", type=str, nargs="?", help="Dataset name", default=None
    )
    parser.add_argument(
        "split_name", type=str, nargs="?", help="Split name", default=None
    )

    args = parser.parse_args()

    datasets_file = args.datasets_file
    dataset_name = args.dataset_name
    split_name = args.split_name

    parent_directory = Path(datasets_file).resolve().parent
    dataset_config = load_dataset_config(datasets_file)
    for dataset, split, url, fname, loaders_dict in find_split_urls(
        parent_directory, dataset_config, dataset_name, split_name
    ):
        download_directory = (Path(".") / dataset / split).absolute()
        download_directory.mkdir(parents=True, exist_ok=True)
        file_path = download_directory / fname

        if file_path.exists():
            print(f"File '{file_path}' exists, skipping download")
        else:
            subprocess.run(["wget", "-O", str(file_path), url], check=True)

        for stage in loader_stages:

            loader = loaders_dict.get(stage)
            if loader:
                print(f"Executing {stage} loader")
                ok = loader.run(file_path, download_directory)
                if not ok:
                    print(f"{stage} loader failed")
                    exit(1)


if __name__ == "__main__":
    main()
