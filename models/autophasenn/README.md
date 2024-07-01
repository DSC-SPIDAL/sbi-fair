

# AutoPhaseNN
Link to the application: 
https://github.com/YudongYao/AutoPhaseNN

References: 

- https://doi.org/10.1038/s41524-022-00803-w


## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir autophasenn
    cd autophasenn
    mkdir output
    ```

3. Get the datasets for training
    > The AutoPhaseNN dataset (a list of files) requires processing (downloading data and upscaling). 
    > The loading script will build and use the Docker container that is provided in the repository 
    > to do so.

    > Instead of the whole dataset you may want to load some sample files for testing.
    > If so, before running the loading script create a shorter list of files for downloading:
    > ```bash
    > mkdir -p aicdi/default
    > wget -q -O - https://github.com/YudongYao/AutoPhaseNN/raw/3375cf98206a83f329faaf4c74eed924f3f4a2fe/TF2/aicdi_data.txt | head -n 300 > aicdi/default/aicdi_data.txt
    > ```

    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.py ${SBI_FAIR_DIR}/datasets/autophasenn/datasets.yaml aicdi
    ```

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    echo 'gpu_num: 1' >> options.yaml 
    echo 'train_size: 100' >> options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository https://github.com/YudongYao/AutoPhaseNN for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/autophasenn
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./aicdi/default:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} autophasenn run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/autophasenn
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./aicdi/default:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/autophasenn/autophasenn.sif
    ```

### Results
The outputs of the run will be available in `./output`.