#!/bin/bash
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit

git init; git remote add origin https://github.com/hep-lbdl/CaloGAN
git fetch --depth 1 --filter=blob:limit=10M origin 1adb7ab745f038af8b0e56d1396f839dc6435584
git checkout FETCH_HEAD
cd ..