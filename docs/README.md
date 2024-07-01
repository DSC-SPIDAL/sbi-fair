# General instructions
## Datasets
The available datasets are stored in `datasets/${NAME}/datasets.yaml`. This file
can provide different datasets with different splits, such as default, train, test, validate and sample.
Datasets are stored externally and each split has a `url` that can be used
to download the specified split. 

If the dataset requires processing it has a Docker or Apptainer containers
in the `loader` directory or `loader.sh` script. The entrypoints are set so they take the files downloaded
from the `url` mounted at `/input/dataset`. For example to build and run Docker based loader:

The example script to load the datasets from the `datasets.yaml`t hat can be used for testing to load is here:
`tools/scripts/load_dataset.py`. It can be used to download and process specific dataset and split
or all datasets in the file:

```bash
# Load all datasets 
./tools/scripts/load_dataset.py datasets/cosmoflow/datasets.yaml
# Load single dataset
./tools/scripts/load_dataset.py datasets/cosmoflow/datasets.yaml cosmoUniverse_2019_05_4parE_tf_v2_mini
# Load specific split
./tools/scripts/load_dataset.py datasets/cosmoflow/datasets.yaml cosmoUniverse_2019_05_4parE_tf_v2_mini default
```

For manual loading download the data from the provided URL and if necessary process the downloaded file using 
docker container:
```bash
docker build -t ${DATASET_NAME}-loader
docker run -v ./output:/output -v ${DOWNLOADED_FILE}:/input/dataset ${DATASET_NAME}-loader
```
or loader script
```bash
cd ${DOWNLOAD_DIRECTORY}
loader.sh ${DOWNLOADED_FILE}
```

## Running
The containers can provide 3 entry points (apps): `train`, `evaluate`, `run`. 
This is accomplished through [SCIF](https://sci-f.github.io/) mechanism 
(either build-in in Apptainer or through separate module in Docker containers)
The datasets, options, model are provided as mounted volumes.

You can test the models using provided test script that will run the model apps
using default parameters and train for only two epochs.
To run models in different context (such as benchmarking) and change 
the options you can build and run it using individual commands.

### Testing script
To build and test containers using single command you can use the provided 
test script `tools/scripts/test_model.sh`. By default It will build both Docker and Apptainer
container and run the train app using GPU against provided dataset:
```bash
# Test dataset is only used if running evaluate app
Usage: ../tools/scripts/test_model.sh [--no-apptainer] [--no-docker] [--no-gpu] SURROGATE_DIRECTORY TRAIN_DATASET TEST_DATASET [APPS]
  --no-apptainer  Disable Apptainer
  --no-docker     Disable Docker
  --no-gpu        Disable GPU
  --no-build      Don't rebuild images
  [APPS]          Which apps (train, evaluate, run) to run, default only train
```

For example to run the nanoconfinement surrogate:

```bash
mkdir nanoconfinement_test && cd nanoconfinement_test
# Download the example dataset
../tools/scripts/load_dataset.py ../datasets/nanoconfinement/datasets.yaml 
# Test both docker and apptainer using GPU and run train and evaluate apps
../tools/scripts/test_model.sh ../models/nanoconfinement nanoconfinement_4050/train/data_dump_density_preprocessed_train.pk nanoconfinement_4050/test/data_dump_density_preprocessed_test.pk train evaluate
```

The test script uses the default options for each model and trains them only for two epochs.

### Building the model containers
Currently the build step requires additional steps, such as processing the 
Apptainer template and making common helper scripts available for building
the container. To build the containers please use scripts provided for each model 
`build_docker.sh` and `build_apptainer.sh`

### Apptainer
```bash
GPU_SWITCH='--nv' # or '' for CPU workloads
# Training
APP=train
apptainer run ${GPU_SWITCH} --app ${APP} --bind ${TRAIN_DATASET}:/input/train_dataset --bind ${OUTPUT_DIR}:/output --bind options.yaml:/input/options.yaml ${SURROGATE_NAME}.sif

# Testing
APP=evaluate
apptainer run ${GPU_SWITCH} --app ${APP} --bind ${TEST_DATASET}:/input/test_dataset --bind ${TRAINED_MODEL} --bind ${OUTPUT_DIR}:/output --bind options.yaml:/input/options.yaml ${SURROGATE_NAME}.sif

# Running trained model
APP=run
apptainer run ${GPU_SWITCH} --app ${APP} --bind ${INPUT_DATASET}:/input/input_dataset --bind ${TRAINED_MODEL} --bind ${OUTPUT_DIR}:/output --bind options.yaml:/input/options.yaml ${SURROGATE_NAME}.sif
```

### Docker

Similarly for Docker. Instead of `--bind` use `--volume` and use the following pattern:

```bash
GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
VOLUME_MOUNTS='...'
docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SURROGATE_NAME} run ${APP}
```