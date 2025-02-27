FROM python:3.13-slim

# install git
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# install ingest
RUN python -m pip install git+https://github.com/NYCPlanning/data-engineering@main