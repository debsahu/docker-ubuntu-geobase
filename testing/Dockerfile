FROM ghcr.io/debsahu/docker-ubuntu-geobase:ubuntugis as builder

# Python dependencies that require compilation
COPY requirements.txt .
ENV export CPLUS_INCLUDE_PATH /usr/include/gdal
ENV export C_INCLUDE_PATH /usr/include/gdal
RUN python -m pip install cython numpy -c requirements.txt \
    && python -m pip install GDAL==$(gdal-config --version) \
    && python -m pip install --no-cache-dir fiona rasterio shapely opencv-python scipy scikit-image scikit-learn pandas matplotlib geopandas seaborn earthpy \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && pip uninstall cython --yes

# ------ Second stage
# Start from a clean image
FROM ubuntu:20.04 as final

# Install some required runtime libraries from apt
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        libfreexl1 libxml2 libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

# Install the previously-built shared libaries from the builder image
COPY --from=builder /usr/local /usr/local
RUN ldconfig