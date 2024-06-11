#!/usr/bin/env python3
import yaml
import sys


def load_datasets(file_path):
    with open(file_path, "r") as file:
        return yaml.safe_load(file)


def find_split_urls(datasets, dataset_name, split_name=None):
    result = []
    for dataset in datasets:
        if not dataset_name or dataset["name"] == dataset_name:
            for split in dataset["data_files"]:
                if not split_name or split["split"] == split_name:
                    if isinstance(split["url"], dict):
                        urls = split["url"]
                    else:
                        alias = split["url"].split("/")[-1]
                        urls = {alias: split["url"]}

                    result.extend(
                        [
                            (dataset["name"], split["split"], url, alias)
                            for alias, url in urls.items()
                        ]
                    )
    return result


def main(file_path, dataset_name, split_name=None):
    datasets = load_datasets(file_path)
    urls = find_split_urls(datasets, dataset_name, split_name)

    if urls:
        for url in urls:
            print(" ".join(url))
    else:
        print(f"No URLs found for dataset '{dataset_name}'", file=sys.stderr)
        if split_name:
            print(f"and split '{split_name}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 4:
        print(
            "Usage: python get_dataset_url.py <path_to_datasets.yaml> [<dataset_name> [split_name]]"
        )
        sys.exit(1)

    file_path = sys.argv[1]

    dataset_name = None
    split_name = None
    l = len(sys.argv)
    if l > 2:
        dataset_name = sys.argv[2]
        if l > 3:
            split_name = sys.argv[3]

    main(file_path, dataset_name, split_name)
