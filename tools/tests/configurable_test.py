import os
import subprocess
import pytest
import yaml
import time
from pathlib import Path

TOOLS_PATH = Path(__file__).parents[1].absolute()


class ContainerSystem(object):
    def __init__(self, surrogate_path):
        self.surrogate_path = surrogate_path
        self.workdir = surrogate_path

    def run(self, test_config, output_dir, input_dir, gpu_switch):
        with open(output_dir / "options.yaml", "w") as fh:
            yaml.dump(test_config["options"], fh)
        cmd = self.get_cmd(test_config, output_dir, input_dir, gpu_switch)
        print(cmd)
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result


class Apptainer(ContainerSystem):
    system_name = "Apptainer"
    gpu_switch = {"cpu": "", "gpu": "--nv"}

    def build_cmd(self):
        return self.surrogate_path / "build_apptainer.sh"

    @property
    def container_name(self):
        return self.surrogate_path.name + ".sif"

    def exists(self):
        return (self.surrogate_path / self.container_name).exists()

    def get_cmd(self, test_config, output_dir, input_dir, gpu_switch):
        """Command to run to execute app"""
        app = test_config["app"]
        input_mounts = " ".join(
            [f"-B {input_dir}/{mount}" for mount in test_config["dataset"]["mounts"]]
        )

        cmd = f"apptainer run --app {app} {self.gpu_switch[gpu_switch]} {input_mounts} -B {output_dir}:/output -B {output_dir}/options.yaml:/input/options.yaml {self.surrogate_path / self.container_name}"
        return cmd


class Docker(ContainerSystem):
    system_name = "Docker"
    gpu_switch = {"cpu": "", "gpu": "--runtime=nvidia --gpus all"}

    def build_cmd(self):
        return self.surrogate_path / "build_docker.sh"

    @property
    def container_name(self):
        return self.surrogate_path.name

    def exists(self):
        result = subprocess.run(
            ["docker", "images", "-q", self.container_name],
            capture_output=True,
            text=True,
        )
        return result.stdout.strip() != ""

    def get_cmd(self, test_config, output_dir, input_dir, gpu_switch):
        """Command to run to execute app"""
        app = test_config["app"]
        input_mounts = " ".join(
            [f"-v {input_dir}/{mount}" for mount in test_config["dataset"]["mounts"]]
        )

        cmd = f"docker run {self.gpu_switch[gpu_switch]} {input_mounts} -v {output_dir}:/output -v {output_dir}/options.yaml:/input/options.yaml {self.container_name} run {app}"
        return cmd


@pytest.fixture(scope="session")
def surrogate_path(model_repo, surrogate_name):
    return model_repo / surrogate_name


@pytest.fixture(scope="session")
def rebuild(request):
    return request.config.getoption("rebuild")


_spec_map = {"docker": Docker, "apptainer": Apptainer}


@pytest.fixture(scope="session")
def container(container_system, surrogate_path):
    return _spec_map[container_system](surrogate_path)


@pytest.fixture(scope="session")
def test_config(surrogate_path, test_config_name):
    test_config_file = surrogate_path / "tests" / test_config_name
    test_config_file = test_config_file.with_suffix(".yaml")
    if not test_config_file.exists():
        pytest.skip(
            f"Test config {test_config_name} does not exists for {surrogate_path}"
        )
    with open(test_config_file, "r") as file:
        return yaml.safe_load(file)


@pytest.fixture(scope="session")
def dataset(test_config, data_repo, tmp_path_factory):
    input_dataset = test_config["dataset"]["source"].split("/")
    dataset_config = data_repo / input_dataset[0] / "datasets.yaml"
    output_dir = tmp_path_factory.mktemp("data")
    result = subprocess.run(
        [TOOLS_PATH / "scripts" / "load_dataset.py", dataset_config, input_dataset[1]],
        capture_output=True,
        text=True,
        cwd=output_dir,
    )
    assert result.returncode == 0, f"Dataset loading failed: {result.stderr}"

    return output_dir / input_dataset[1]


@pytest.fixture(scope="session")
def build_container(rebuild, container):
    if rebuild or not container.exists():
        # Build the container
        result = subprocess.run(
            [container.build_cmd()],
            capture_output=True,
            text=True,
            cwd=container.workdir,
        )
        assert (
            result.returncode == 0
        ), f"{container.system_name} build failed: {result.stderr}"
    else:
        print(
            f"Reusing existing {container.system_name} container: {container.container_name}"
        )
    return container


@pytest.mark.parametrize("gpu_switch", ["gpu", "cpu"])
def test_container(
    dataset, build_container, gpu_switch, test_config, tmp_path, benchmark
):
    # Run the application
    result = benchmark(build_container.run, test_config, tmp_path, dataset, gpu_switch)
    # start_time = time.time()
    # end_time = time.time()
    msgname = (
        f"{build_container.system_name}({build_container.container_name}, {gpu_switch})"
    )
    assert result.returncode == 0, f"{msgname} run failed: {result.stderr}"
