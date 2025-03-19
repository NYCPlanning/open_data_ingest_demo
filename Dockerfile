FROM jupyter/base-notebook
USER root
RUN apt update && apt install git -y
USER 1000

COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
