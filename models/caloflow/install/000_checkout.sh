#!/bin/bash
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit

git init; git remote add origin https://gitlab.com/claudius-krause/caloflow.git
git fetch --depth 1 --filter=blob:limit=10M origin 92ce1eb251eac4aba7e81c5a193e849a19449b03
git checkout FETCH_HEAD
cd ..