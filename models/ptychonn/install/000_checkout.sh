#!/bin/bash
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit

git init; git remote add origin https://github.com/Presciman/PtychoNN-torch
git fetch --depth 1 --filter=blob:limit=10M origin 61e0475abb258c6fbdc1fdf4e9f7961b8e20085f
git checkout FETCH_HEAD