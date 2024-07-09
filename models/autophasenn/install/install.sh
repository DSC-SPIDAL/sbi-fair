#!/bin/bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

PROJECT_DIR="autoPhaseNN"

mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"
# Doing that instead of clone to limit the fetch to relevent commit

git init; git remote add origin https://github.com/YudongYao/AutoPhaseNN
git fetch --depth 1 --filter=blob:limit=10M origin 3375cf98206a83f329faaf4c74eed924f3f4a2fe
git checkout FETCH_HEAD

git apply /install/autophasenn.patch

cp -r TF2 ${SCIF_APPROOT}/autophasenn