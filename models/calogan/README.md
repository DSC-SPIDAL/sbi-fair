

# CaloGAN
Link to the application: 
https://github.com/hep-lbdl/CaloGAN

References: 
- https://doi.org/10.1103/PhysRevLett.120.042003
- https://doi.org/10.48550/arXiv.1705.02355


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir calogan
    cd calogan
    mkdir output
    ```

3. Get the datasets for training

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.py ${SBI_FAIR_DIR}/datasets/calogan/datasets.yaml calogan_eplus
    ```
    > You can use any of the following datasets:
    > -  calogan_eplus
    > -  calogan_gamma
    > -  calogan_piplus
    

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://github.com/hep-lbdl/CaloGAN for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/calogan
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    > At the moment the provided containers are likely to fail to using GPU with recent
    > systems due to CUDA incompatibilities. We are working to fix that.
    ```bash
    GPU_SWITCH='' # or '--runtime=nvidia --gpus all' for GPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./calogan_eplus/default/eplus.hdf5:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} calogan run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/calogan
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    > At the moment the provided containers are likely to fail to using GPU with recent
    > systems due to CUDA incompatibilities. We are working to fix that.
    ```bash
    GPU_SWITCH=''  # or '--nv' for GPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./calogan_eplus/default/eplus.hdf5:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/calogan/calogan.sif
    ```

### Results
The outputs of the run will be available in `./output`.