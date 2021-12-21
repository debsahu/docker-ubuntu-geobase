FROM ubuntu:20.04

ENV TZ=America/Detroit
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev \
    curl libcurl4-openssl-dev lbzip2 libopenjp2-7-dev libzstd-dev libdeflate-dev libjpeg-turbo-progs \
    sqlite3 libtiff-dev nghttp2 libgeotiff-dev proj-bin cmake wget ca-certificates \
    unzip pkg-config libfreexl-dev libxml2-dev nasm libpng-dev libgeos-dev \
    libtool automake sqlite3 libtiff5-dev libjpeg8-dev libjpeg-turbo8-dev
RUN apt-get update \
    && apt-get remove -y python3 python3.8 libpython3-stdlib libpython3.8-minimal libpython3.8-stdlib python3-minimal python3.8-minimal

ENV CPUS 4
WORKDIR /tmp

ENV PYTHON_VERSION 3.9.9
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --enable-optimizations \
    && make -j ${CPUS} \
    && make altinstall \
    && make install

ENV GDAL_SHORT_VERSION 3.4.0
ENV GDAL_VERSION 3.4.0
RUN wget -q https://download.osgeo.org/gdal/${GDAL_SHORT_VERSION}/gdal-${GDAL_VERSION}.tar.gz
RUN tar -xzf gdal-${GDAL_VERSION}.tar.gz && cd gdal-${GDAL_SHORT_VERSION} && \
    ./configure \
    --disable-debug \
    --prefix=/usr/local \
    --disable-static \
    --with-curl \
    --with-geos \
    --with-geotiff \
    --with-hide-internal-symbols=yes \
    --with-libtif \
    --with-jpeg \
    --with-png \
    --with-openjpeg \
    --with-sqlite3 \
    --with-proj \
    --with-rename-internal-libgeotiff-symbols=yes \
    --with-rename-internal-libtiff-symbols=yes \
    --with-threads=yes \
    --with-webp \
    --with-zstd \
    --with-libdeflate \
    && echo "building GDAL ${GDAL_VERSION}..." \
    && make -j${CPUS} && make --quiet install

RUN ldconfig

ENV CPLUS_INCLUDE_PATH /usr/include/gdal
ENV C_INCLUDE_PATH /usr/include/gdal
RUN pip3.9 install numpy \
    && pip3.9 install GDAL==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal" \
    && pip3.9 install --no-cache-dir fiona rasterio shapely opencv-python scipy scikit-image scikit-learn pandas matplotlib geopandas seaborn earthpy

COPY requirements.txt .
RUN pip3.9 install --no-cache-dir -r requirements.txt