from pathlib import Path
import subprocess
import pytest
import xml.etree.ElementTree as ET
import json

PATH = Path(__file__).parent.absolute()
MAIN_REPO = PATH.parents[1]
MODEL_REPO = MAIN_REPO / "models"
DATA_REPO = MAIN_REPO / "datasets"


def xml_to_dict(element):
    # Convert an XML element and its children to a dictionary
    if len(element) == 0:
        return element.text

    result = {}
    for child in element:
        child_result = xml_to_dict(child)
        if child.tag in result:
            if not isinstance(result[child.tag], list):
                result[child.tag] = [result[child.tag]]
            result[child.tag].append(child_result)
        else:
            result[child.tag] = child_result

    return result


def get_nvidia_info():
    nvidia_info = subprocess.run(
        ["nvidia-smi", "-x", "-q"], capture_output=True, text=True
    )
    nvidia_info_tree = ET.fromstring(nvidia_info.stdout)
    nvidia_info_dict = xml_to_dict(nvidia_info_tree)
    # Select necessary info
    selected = [
        "product_name",
        "product_brand",
        "product_architecture",
        "fb_memory_usage",
    ]
    for key in list(nvidia_info_dict["gpu"].keys()):
        if key not in selected:
            del nvidia_info_dict["gpu"][key]
    # del nvidia_info_dict[""]
    return nvidia_info_dict


def pytest_addoption(parser):
    parser.addoption(
        "--rebuild",
        action="store_true",
        default=False,
        help="Force rebuild of containers",
    )
    parser.addoption(
        "--tests",
        nargs="+",
        default=["all"],
        help="Which YAML parametrized tests (in model/*/tests) to run",
    )
    parser.addoption(
        "--surrogates",
        nargs="+",
        default=["all"],
        help="Define surrogates to test. Name must be present in MODEL_REPO",
    )
    parser.addoption(
        "--container-systems",
        nargs="+",
        choices=["docker", "apptainer"],
        default=["docker", "apptainer"],
        help="Which container system to use",
    )
    parser.addoption(
        "--model-repo",
        action="store",
        default=MODEL_REPO,
        help="Path to the surrogate models",
    )
    parser.addoption(
        "--data-repo",
        action="store",
        default=DATA_REPO,
        help="Path to the datasets",
    )


def pytest_generate_tests(metafunc):
    if "surrogate_name" in metafunc.fixturenames:
        surrogates = metafunc.config.getoption("surrogates")
        model_repo = metafunc.config.getoption("model_repo")
        print(surrogates)
        if "all" in surrogates:
            # Discover available surrogates
            surrogates = sorted(set([d.name for d in model_repo.glob("*")]))
        metafunc.parametrize("surrogate_name", surrogates, scope="session")
    if "test_config_name" in metafunc.fixturenames:
        tests = metafunc.config.getoption("tests")
        if "all" in tests:
            tests = sorted(set([f.stem for f in model_repo.glob("*/tests/*.yaml")]))
        metafunc.parametrize("test_config_name", tests, scope="session")
    if "container_system" in metafunc.fixturenames:
        container_systems = metafunc.config.getoption("container_systems")
        metafunc.parametrize("container_system", container_systems, scope="session")


@pytest.fixture(scope="session")
def model_repo(request):
    return request.config.getoption("model_repo")


@pytest.fixture(scope="session")
def data_repo(request):
    return request.config.getoption("data_repo")


def pytest_benchmark_update_machine_info(config, machine_info):
    machine_info["gpu"] = get_nvidia_info()
