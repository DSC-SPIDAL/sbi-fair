FROM python:3.12-slim
RUN apt-get update
RUN apt-get -y install wget patch
COPY install /install
RUN pip install -r /install/requirements.txt
RUN echo `which wget`
RUN /install/install.sh
ENTRYPOINT /install/load.sh 
