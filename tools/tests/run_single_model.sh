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
    echo "Usage: $0 <surrogate_name> <cpu/gpu> <container_system>"
    exit 1
}

# Check if the correct number of arguments are passed
if [ "$#" -ne 3 ]; then
    usage
fi

SURROGATE_NAME=$1
GPU_SWITCH=$2
CONTAINER_SYSTEM=$3

# Run pytest with tests from this script directory, disable benchmark
pytest ${DIR} -k ${GPU_SWITCH} --container-systems ${CONTAINER_SYSTEM} \
    --surrogates ${SURROGATE_NAME} --benchmark-disable 
