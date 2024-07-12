

# CaloFlow
Link to the application: 
https://gitlab.com/claudius-krause/caloflow

References: 
- https://doi.org/10.1103/PhysRevD.107.113003
- https://arxiv.org/abs/2106.05285
- https://doi.org/10.1103/PhysRevD.107.113004
- https://arxiv.org/abs/2110.11377


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir caloflow
    cd caloflow
    mkdir output
    ```

3. Get the datasets for training

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.py ${SBI_FAIR_DIR}/datasets/caloflow/datasets.yaml caloflow_eplus
    ```
    > You can use any of the following datasets:
    > -  caloflow_eplus
    > -  caloflow_gamma
    > -  caloflow_piplus
    

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml
    # We need to have a particle name matching the dataset
    echo 'particle_type: eplus' >> options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://gitlab.com/claudius-krause/caloflow.git for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/caloflow
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./caloflow_eplus/default:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} caloflow run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/caloflow
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./caloflow_eplus/default:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/caloflow/caloflow.sif
    ```

### Results
The outputs of the run will be available in `./output`.