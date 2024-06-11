

# Nanoconfinement
Link to the application: 
https://nanohub.org/resources/nanoconfinement

References: 

- https://doi.org/10.1016/j.jocs.2020.101107


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir nanoconfinement
    cd nanoconfinement
    mkdir output
    ```

3. Get the datasets for training

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.sh ${SBI_FAIR_DIR}/datasets/nanoconfinement/datasets.yaml nanoconfinement_4050
    ```
    

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://github.com/softmaterialslab/nanoconfinement-md for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/nanoconfinement
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./nanoconfinement_4050/train/data_dump_density_preprocessed_train.pk:/input/train_dataset -v ./nanoconfinement_4050/test/data_dump_density_preprocessed_test.pk:/input/test_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} nanoconfinement run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/nanoconfinement
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./nanoconfinement_4050/train/data_dump_density_preprocessed_train.pk:/input/train_dataset --bind ./nanoconfinement_4050/test/data_dump_density_preprocessed_test.pk:/input/test_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/nanoconfinement/nanoconfinement.sif
    ```

### Results
The outputs of the run will be available in `./output`.