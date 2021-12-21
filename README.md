# docker-ubuntu-geobase

To use this image, include this line in your Dockerfile:

```
FROM ghcr.io/debsahu/docker-ubuntu-geobase:3.9-slim-buster
```

or

Docker:

```
$ docker pull ghcr.io/debsahu/docker-ubuntu-geobase:3.9-slim-buster
```

## Features

- Based on 3.9-slim-buster
- Python 3.9.x
- GDAL 3.4.0

## Usage

- Check the testing folder

```
FROM ghcr.io/debsahu/docker-ubuntu-geobase:3.9-slim-buster as builder

# Python dependencies that require compilation
ENV export CPLUS_INCLUDE_PATH /usr/include/gdal
ENV export C_INCLUDE_PATH /usr/include/gdal
RUN python -m pip install cython numpy -c requirements.txt \
    && python -m pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal" \
    && python -m pip install --no-binary --no-cache-dir fiona rasterio shapely opencv-python scipy scikit-image scikit-learn pandas matplotlib geopandas seaborn earthpy -r requirements.txt \
    && pip uninstall cython --yes

# ------ Second stage
# Start from a clean image
FROM python:3.9-slim-buster as final

# Install some required runtime libraries from apt
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        libfreexl1 libxml2 libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

# Install the previously-built shared libaries from the builder image
COPY --from=builder /usr/local /usr/local
RUN ldconfig
```
