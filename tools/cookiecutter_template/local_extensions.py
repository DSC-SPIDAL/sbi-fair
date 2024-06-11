from cookiecutter.utils import simple_filter
from jinja2.exceptions import TemplateRuntimeError

import yaml
from pathlib import Path


@simple_filter
def from_yaml(path):
    p = Path(path)
    if not p.exists():
        raise TemplateRuntimeError(f"File {p} does not exists")

    with open(p) as fh:
        data = yaml.safe_load(fh)
    return data


@simple_filter
def absolute_path(path):
    return Path(path).absolute()
