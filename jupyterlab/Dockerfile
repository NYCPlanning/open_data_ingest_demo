FROM jupyter/base-notebook
USER root
RUN apt update && apt install git -y
USER 1000

RUN rm -r /home/jovyan/work
COPY ./templates /home/jovyan/templates
COPY ./requirements.txt /tmp/requirements.txt
COPY ./Readme.md /home/jovyan/
COPY ./*.ipynb /home/jovyan/
RUN pip install -r /tmp/requirements.txt
