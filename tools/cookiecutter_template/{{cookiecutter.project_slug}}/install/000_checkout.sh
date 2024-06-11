#!/bin/bash
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit
{% set metadata = cookiecutter.__metadata_file_path | from_yaml  %}
git init; git remote add origin {{ metadata.repository.url }}
git fetch --depth 1 --filter=blob:limit=10M origin {{ metadata.repository.commit }}
git checkout FETCH_HEAD
cd ..