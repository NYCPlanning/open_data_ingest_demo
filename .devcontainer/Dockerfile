FROM python:3.13-slim

# install git
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt

# install ingest
RUN python -m pip install -r /tmp/requirements.txt
