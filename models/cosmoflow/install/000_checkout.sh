#!/bin/bash
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit

git init; git remote add origin https://github.com/sparticlesteve/cosmoflow-benchmark
git fetch --depth 1 --filter=blob:limit=10M origin 2262e6db7913de9f24f14578d5db3c76a1d01573
git checkout FETCH_HEAD
cd ..