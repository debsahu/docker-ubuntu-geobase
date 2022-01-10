FROM ubuntu:20.04

ENV TZ=America/Detroit
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update \
    && apt-get install -y software-properties-common wget build-essential \
       checkinstall git \
    && add-apt-repository ppa:ubuntugis/ppa \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160 \
    && apt-get update \
	&& apt-get remove -y python3 python3.8 libpython3-stdlib libpython3.8-minimal \
	   libpython3.8-stdlib python3-minimal python3.8-minimal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends libreadline-gplv2-dev libffi-dev libncursesw5-dev \
    libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CPUS 4
ENV PYTHON_VERSION 3.9.9
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --enable-optimizations \
    && make -j ${CPUS} \
    && make altinstall \
    && make install

RUN pip3.9 install numpy \
    && pip3.9 install GDAL==$(gdal-config --version) \
    && pip3.9 install --no-cache-dir fiona rasterio shapely opencv-python scipy scikit-image \
       scikit-learn pandas matplotlib geopandas seaborn earthpy

COPY requirements.txt .
RUN pip3.9 install --no-cache-dir -r requirements.txt

LABEL org.opencontainers.image.source=https://github.com/debsahu/docker-ubuntu-geobase/tree/ubuntugis
LABEL org.opencontainers.image.version=ubuntugis