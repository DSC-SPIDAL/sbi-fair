

# PtychoNN
Link to the application: 
https://www.anl.gov/psc/ptychonn-uses-neural-networks-for-faster-xray-imaging

References: 

- https://doi.org/10.1063/5.0013065

- https://github.com/mcherukara/PtychoNN


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir ptychonn
    cd ptychonn
    mkdir output
    ```

3. Get the datasets for training

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.sh ${SBI_FAIR_DIR}/datasets/ptychonn/datasets.yaml ptychonn_20191008_39
    ```
    

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://github.com/Presciman/PtychoNN-torch for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/ptychonn
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./ptychonn_20191008_39/default:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} ptychonn run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/ptychonn
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./ptychonn_20191008_39/default:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/ptychonn/ptychonn.sif
    ```

### Results
The outputs of the run will be available in `./output`.