#!/bin/bash

cd "${PROJECT_DIR}"
PATCH=/install/{{cookiecutter.project_slug}}.patch
[[ -f "${PATCH}" ]] && git apply "${PATCH}"
