#!/bin/bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

# Function to display usage
usage() {
    echo "Usage: $0 <surrogate_name> <cpu/gpu> <system_name> <container_system>"
    exit 1
}

# Check if the correct number of arguments are passed
if [ "$#" -ne 4 ]; then
    usage
fi

SURROGATE_NAME=$1
GPU_SWITCH=$2
SYSTEM_NAME=$3
CONTAINER_SYSTEM=$4

# Hashes to avoid name collisions when run in parallel
GIT_HASH=$(git rev-parse --short HEAD)
RANDOM_HASH=$(cat /dev/random | head -c 5 | base32 | tr '[:upper:]' '[:lower:]')

# Run pytest with tests from this script directory
pytest ${DIR} -k ${GPU_SWITCH} --container-systems ${CONTAINER_SYSTEM} \
    --surrogates ${SURROGATE_NAME} --benchmark-verbose \
    --benchmark-save=${GIT_HASH}_${RANDOM_HASH}_${SURROGATE_NAME}_${SYSTEM_NAME}_${GPU_SWITCH} \
    --benchmark-save-data \
    --benchmark-min-rounds=1
