#!/bin/bash

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <path_to_datasets.yaml> [<dataset_name> [split_name]]"
    echo "Loads the dataset and specified split based on datasets.yaml"
    exit 1
fi

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)

DATASETS_FILE=$1
DATASET_NAME=$2
SPLIT_NAME=$3
#DATASET_DIRECTORY=$(realpath ${DATASET_NAME})

# Get the parent directory of the datasets.yaml
PARENT_DIRECTORY=$(realpath $(dirname "$DATASETS_FILE"))

# Get the URLsm these are dataset_name, split, url, alias lines
URLS=$("${DIR}"/get_dataset_url.py "$DATASETS_FILE" "$DATASET_NAME" "$SPLIT_NAME")

# Check if the Python script was successful
if [ $? -ne 0 ]; then
    echo "Failed to get the URLs for dataset '$DATASET_NAME' and split '$SPLIT_NAME'"
    exit 1
fi

# Check for the loader directory
LOADER_DIRECTORY="${PARENT_DIRECTORY}/loader"
if [ -d "$LOADER_DIRECTORY" ] && [ -f "${LOADER_DIRECTORY}/Dockerfile" ]; then
    IMAGE_NAME=$(basename "$PARENT_DIRECTORY")-loader
    IMAGE_NAME=${IMAGE_NAME,,} #lowercase

    # Build the Docker image
    docker build -t "$IMAGE_NAME" "$LOADER_DIRECTORY"
    if [ $? -ne 0 ]; then
        echo "Failed to build Docker image from '$LOADER_DIRECTORY/Dockerfile'"
        exit 1
    fi
fi
# Download each URL using wget
while read line; do
    IFS=' ' read -r DATASET SPLIT URL FNAME <<< "$line"
    DOWNLOAD_DIRECTORY=$(realpath -m "./${DATASET}/${SPLIT}")
    mkdir -p "${DOWNLOAD_DIRECTORY}"
    if [ -f "${DOWNLOAD_DIRECTORY}/${FNAME}" ]; then
        echo "File "${DOWNLOAD_DIRECTORY}/${FNAME}" exists, skipping download"
    else
        wget -O "${DOWNLOAD_DIRECTORY}/${FNAME}" "$URL"
        # Check if wget was successful
        if [ $? -ne 0 ]; then
            echo "Failed to download the file from '$URL'"
            exit 1
        fi

        echo "Downloaded the files from the URLs to '$DOWNLOAD_DIRECTORY'"
    fi

    # Run the loader container
    if [ -d "$LOADER_DIRECTORY" ] && [ -f "${LOADER_DIRECTORY}/Dockerfile" ]; then
        docker run --rm -v "${DOWNLOAD_DIRECTORY}/${FNAME}:/input/dataset" -v ${DOWNLOAD_DIRECTORY}:/output "$IMAGE_NAME" /input/dataset
        if [ $? -ne 0 ]; then
            echo "Failed to run Docker container '$IMAGE_NAME'"
            exit 1
        fi
        echo "Finished loading data using '$IMAGE_NAME'"
    # Run loader script
    elif [ -f "${PARENT_DIRECTORY}/loader.sh" ]; then
        (
            cd ${DOWNLOAD_DIRECTORY}
            "${PARENT_DIRECTORY}/loader.sh" "${DOWNLOAD_DIRECTORY}/${FNAME}"
        )
    fi

    

done <<< "$URLS"
