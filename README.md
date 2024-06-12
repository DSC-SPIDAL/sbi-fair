# SBI-FAIR Repository

## About

The SBI-FAIR repository hosts metadata for surrogate AI models and datasets,
facilitating their use and reuse by providing a unified interface for training,
evaluation, and deployment.

## Repository aims and organization 

This repository aims to:

1. Offer a consistent interface for reproducible training, evaluation, 
    and deployment of surrogate models.
2. Provide Docker and Apptainer container definitions for each surrogate model, 
    and reusable scripts and SCIF recipes to build derivatives (for example to use in specialized environments such as HPC clusters)
3. Facilitate dataset access by referencing external URLs for downloads and providing 
    loaders (as scripts or Docker containers) for datasets requiring post-processing or generation 
    from referenced data.
4. Supply patches to ensure models conform to the unified interface.


The repository does not store datasets or models' code but focuses on modifications 
needed for standardization. Orchestration is to be handled by external tools like [`cloudmesh`](https://cloudmesh.github.io/cloudmesh-manual/), [`SABATH`](https://github.com/icl-utk-edu/sabath/), or [`MLCube`](https://mlcommons.org/en/mlcube/).

## Models and examples
Currently the following surrogate models have at least training implemented. Here are the detailed instructions how
to build containers and run the training using the provided examples:
- [AutoPhasenNN](models/autophasenn/README.md)
- [CaloGAN](models/calogan/README.md)
- [CosmoFlow](models/cosmoflow/README.md)
- [Nanoconfinement](models/nanoconfinement/README.md)
- [PtychoNN](models/ptychonn/README.md)

## General instructions
The documentation about the repository structure and the general examples
how to build and execute the models that may be usefull for integration with
other tools will be provided [here](docs/README.md)