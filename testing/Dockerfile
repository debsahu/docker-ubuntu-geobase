FROM ghcr.io/debsahu/docker-ubuntu-geobase:ubuntugis

# Python dependencies that require compilation
COPY requirements.txt .
RUN pip3.9 install cython numpy -c requirements.txt \
    && pip3.9 install GDAL==$(gdal-config --version) \
    && pip3.9 install --no-cache-dir fiona rasterio shapely opencv-python scipy scikit-image scikit-learn pandas matplotlib geopandas seaborn earthpy \
    && pip3.9 install --no-cache-dir -r requirements.txt \
    && pip3.9 uninstall cython --yes