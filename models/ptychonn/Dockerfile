# Install the model using scif recipe 
FROM python:3.12-slim as builder
RUN apt update
RUN apt-get -y install git
RUN pip install scif
COPY install /install
COPY recipes /recipes
COPY helpers /helpers
RUN pip install -r /install/install_requirements.txt
RUN scif install /recipes/000_install.scif
RUN scif install /recipes/001_apps.scif

FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-runtime
COPY /install/app_requirements.txt .
RUN conda install -y mpi4py
RUN pip install -r app_requirements.txt
RUN pip install scif

COPY --from=builder /scif /scif
ENTRYPOINT ["scif"]
CMD ["shell"]
