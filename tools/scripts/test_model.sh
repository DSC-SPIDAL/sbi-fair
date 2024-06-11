#!/bin/bash

apptainer_mounts() {
    local _APPT_MOUNTS=''
    for mount in ${MOUNTS}; do
        _APPT_MOUNTS="${_APPT_MOUNTS} --bind ${mount}"
    done
    echo ${_APPT_MOUNTS}
}

docker_mounts() {
    local _DOCK_MOUNTS=''
    for mount in ${MOUNTS}; do
        _DOCK_MOUNTS="${_DOCK_MOUNTS} --volume ${mount}"
    done
    echo ${_DOCK_MOUNTS}
}

build_docker() {
    pushd ${SURROGATE_DIRECTORY}
    ./build_docker.sh
    popd
}

build_apptainer() {
    pushd ${SURROGATE_DIRECTORY}
    ./build_apptainer.sh
    popd
}

run_apptainer() {
    if $USE_GPU; then
        GPU_SWITCH='--nv'
    else
        GPU_SWITCH=''
    fi
    APPT_MOUNTS=$(apptainer_mounts)
    echo "Executing ${APP} using apptainer."
    echo "Mounts: ${APPT_MOUNTS}"
    SECONDS=0
    echo "==========================================================="
    apptainer run ${GPU_SWITCH} --app ${APP} ${APPT_MOUNTS} ${SURROGATE_DIRECTORY}/${SURROGATE_NAME}.sif
    echo "==========================================================="
    echo "Done: ${SECONDS}s"
    echo "==========================================================="
}

run_docker() {
    if $USE_GPU; then
        GPU_SWITCH='--runtime=nvidia --gpus all'
    else
        GPU_SWITCH=''
    fi
    VOLUME_MOUNTS=$(docker_mounts)
    echo
    echo "Executing ${APP} using docker."
    echo "Mounts: ${VOLUME_MOUNTS}"
    SECONDS=0
    echo "==========================================================="
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SURROGATE_NAME} run ${APP}
    echo "==========================================================="
    echo "Done: ${SECONDS}s"
    echo "==========================================================="
}

run() {
    OUTPUT_DIR_APPT=${OUTPUT_DIR}/appt
    OUTPUT_DIR_DOCK=${OUTPUT_DIR}/dckr
    if $USE_DOCKER; then
        mkdir -p ${OUTPUT_DIR_DOCK}
        if $MOUNT_MODEL; then
            MODEL_MOUNT=${OUTPUT_DIR_DOCK}/model:/input/model
        else
            MODEL_MOUNT=''
        fi
        MOUNTS="${DATASET_MOUNT} ${MODEL_MOUNT} ${OUTPUT_DIR_DOCK}:/output ${OPTIONS_FILE}:/input/options.yaml"
        run_docker
    fi
    if $USE_APPTAINER; then
        mkdir -p ${OUTPUT_DIR_APPT}
        if $MOUNT_MODEL; then
            MODEL_MOUNT=${OUTPUT_DIR_APPT}/model:/input/model
        else
            MODEL_MOUNT=''
        fi
        MOUNTS="${DATASET_MOUNT} ${MODEL_MOUNT} ${OUTPUT_DIR_APPT}:/output ${OPTIONS_FILE}:/input/options.yaml"
        run_apptainer
    fi
}

USE_APPTAINER=true
USE_DOCKER=true
USE_GPU=true
BUILD=true

usage() {
    echo "Usage: $0 [--no-apptainer] [--no-docker] [--no-gpu] SURROGATE_DIRECTORY TRAIN_DATASET TEST_DATASET [APPS]"
    echo "  --no-apptainer  Disable Apptainer"
    echo "  --no-docker     Disable Docker"
    echo "  --no-gpu        Disable GPU"
    echo "  --no-build      Don't rebuild images"
    echo "  [APPS]          Which apps (train, evaluate, run) to run, default only train"
    exit 1
}

while [[ "$1" == --* ]]; do
    case "$1" in
    --no-apptainer)
        USE_APPTAINER=false
        shift
        ;;
    --no-docker)
        USE_DOCKER=false
        shift
        ;;
    --no-gpu)
        USE_GPU=false
        shift
        ;;
    --no-build)
        BUILD=false
        shift
        ;;
    *) usage ;;
    esac
done

# Check for mandatory arguments
if [ "$#" -lt 3 ]; then
    usage
fi

# Assign mandatory arguments to variables
SURROGATE_DIRECTORY=$1
TRAIN_DATASET=$2
TEST_DATASET=$3
APPS="${@:4}"
APPS="${APPS:-train}"

# Display the parsed values (for debugging purposes)
echo "USE_APPTAINER: $USE_APPTAINER"
echo "USE_DOCKER:    $USE_DOCKER"
echo "USE_GPU:       $USE_GPU"
echo "BUILD:         $BUILD"
echo "SURROGATE_DIRECTORY: $SURROGATE_DIRECTORY"
echo "TRAIN_DATASET:       $TRAIN_DATASET"
echo "TEST_DATASET:        $TEST_DATASET"
echo "APPS:                $APPS"

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

SURROGATE_DIRECTORY="${1}"
TRAIN_DATASET=$(realpath "${2}")
TEST_DATASET=$(realpath "${3}")

set -e # Exit on any error

_TMP_NAME=$(basename "${SURROGATE_DIRECTORY}")
SURROGATE_NAME=${_TMP_NAME,,} # lowercase

# Build the containers
if $BUILD; then
    $USE_APPTAINER && build_apptainer
    $USE_DOCKER && build_docker
fi

## Setup the output dir
TRAIN_HASH=$(md5sum <<<"${TRAIN_DATASET}" | head -c 8)
TEST_HASH=$(md5sum <<<"${TEST_DATASET}" | head -c 8)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="${SURROGATE_NAME}_${TRAIN_HASH}_${TEST_HASH}_${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"
OUTPUT_DIR=$(realpath "${OUTPUT_DIR}")
# Quick runs
echo 'epochs: 2' >test_options.yaml

OPTIONS_FILE=$(realpath test_options.yaml)

for APP in $APPS; do 
    case ${APP} in
        train)
            DATASET_MOUNT="${TRAIN_DATASET}:/input/train_dataset ${TEST_DATASET}:/input/test_dataset"
            MOUNT_MODEL=false # Ends in output
            run
            ;;
        evaluate)
            DATASET_MOUNT=${TRAIN_DATASET}:/input/test_dataset
            MOUNT_MODEL=true
            run
            ;;
        run)
            DATASET_MOUNT=${TEST_DATASET}:/input/test_dataset
            MOUNT_MODEL=true
            run
            ;;
    esac
done
