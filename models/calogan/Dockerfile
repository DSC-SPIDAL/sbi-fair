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

FROM tensorflow/tensorflow:1.14.0-gpu

COPY /install/app_requirements.txt . 
RUN pip install -r app_requirements.txt
RUN pip install scif

COPY --from=builder /scif /scif
ENTRYPOINT ["/usr/local/bin/scif"]
CMD ["shell"]
