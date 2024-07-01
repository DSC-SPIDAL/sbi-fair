

# CosmoFlow
Link to the application: 
https://portal.nersc.gov/project/m3363/

References: 

- https://arxiv.org/abs/1808.04728


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir cosmoflow
    cd cosmoflow
    mkdir output
    ```

3. Get the datasets for training

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.py ${SBI_FAIR_DIR}/datasets/cosmoflow/datasets.yaml cosmoUniverse_2019_05_4parE_tf_v2_mini
    ```
    > You can use any of the following datasets:
    > -  cosmoUniverse_2019_05_4parE_tf_v2_mini
    > -  cosmoUniverse_2019_05_4parE_tf_v2
    

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://github.com/sparticlesteve/cosmoflow-benchmark for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/cosmoflow
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./cosmoUniverse_2019_05_4parE_tf_v2_mini/default:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} cosmoflow run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/cosmoflow
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./cosmoUniverse_2019_05_4parE_tf_v2_mini/default:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/cosmoflow/cosmoflow.sif
    ```

### Results
The outputs of the run will be available in `./output`.