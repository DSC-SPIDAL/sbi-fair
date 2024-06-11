{% set metadata = cookiecutter.__metadata_file_path | from_yaml  %}

# {{ metadata.name }}
Link to the application: 
{{ metadata.homepage }}

References: 
{% for url in metadata.references %}
- {{ url }}
{% endfor %}

## How to use (training)
### Setup and download dataset
1. Get the SBI-FAIR repository 
    ```bash
    git clone --depth 1 https://github.com/DSC-SPIDAL/sbi-fair
    SBI_FAIR_DIR=${PWD}/sbi-fair
    ```

2. Create a directory for downloading datasets and store results
    ```bash
    mkdir {{ cookiecutter.project_slug }}
    cd {{ cookiecutter.project_slug }}
    mkdir output
    ```

3. Get the datasets for training
{% set dataset_file, dataset_name = metadata.datasets[0].split('/') %}
    ```bash
    ${SBI_FAIR_DIR}/tools/scripts/load_dataset.sh ${SBI_FAIR_DIR}/datasets/{{ dataset_file }}/datasets.yaml {{ dataset_name }}
    ```
    {% if metadata.datasets|length > 1 %}
    > You can use any of the following datasets:
    {% for dataset in metadata.datasets %}
    > - `dataset.split('/')[1]
    {% endfor %}
    {% endif %}

4. Create a file with parameters 
    ```bash
    # Few epochs for testing
    echo 'epochs: 2' > options.yaml 
    ```
    We will update the list of available options here, in the meantime please
    refer to the original repository {{ metadata.repository.url }} for the list of all options.

### Using Docker
1. Build Docker container
    ```bash
    cd ${SBI_FAIR_DIR}/models/{{ cookiecutter.project_slug }}
    ./build_docker.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--runtime=nvidia --gpus all' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='-v ./{{ dataset_name }}/default:/input/train_dataset -v ./output:/output -v ./options.yaml:/input/options.yaml'
    docker run ${GPU_SWITCH} ${VOLUME_MOUNTS} {{ cookiecutter.project_slug }} run train
    ```

### Using Apptainer
1. Build Apptainer container
    ```bash
    cd ${SBI_FAIR_DIR}/models/{{ cookiecutter.project_slug }}
    ./build_apptainer.sh
    cd - # Go back to results directory 
    ```

2. Run Training 
    ```bash
    GPU_SWITCH='--nv' # or '' for CPU workloads
    # Mount the directories with the dataset
    VOLUME_MOUNTS='--bind ./{{ dataset_name }}/default:/input/train_dataset --bind ./output:/output --bind ./options.yaml:/input/options.yaml'
    apptainer run --app train ${GPU_SWITCH} ${VOLUME_MOUNTS} ${SBI_FAIR_DIR}/models/{{ cookiecutter.project_slug }}/{{ cookiecutter.project_slug }}.sif
    ```

### Results
The outputs of the run will be available in `./output`.