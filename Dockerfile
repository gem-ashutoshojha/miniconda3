FROM ashutoshojha5/alpine-glibc:master

LABEL maintainer="Anaconda, Inc"

ENV PATH /opt/conda/bin:$PATH

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py312_24.7.1-0
ARG SHA256SUM=33442cd3813df33dcbb4a932b938ee95398be98344dff4c30f7e757cd2110e4f

# hadolint ignore=DL3018
RUN \
    apk update && apk upgrade && \
    addgroup -S anaconda && \
    adduser -D -u 10151 anaconda -G anaconda && \
    apk add -q --no-cache bash procps && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${SHA256SUM}  miniconda.sh" > miniconda.sha256 && \
    if ! sha256sum -cs miniconda.sha256; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.sha256 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    chown -R anaconda:anaconda /opt && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

USER  anaconda
ENV HOME=/home/anaconda

RUN conda config --add channels conda-forge ; \
    conda install --yes -c conda-forge mamba ; \
    ln -s /opt/conda/lib/libarchive.so /opt/conda/lib/libarchive.so.13 || true ; \
    pip install --upgrade --no-cache-dir setuptools wheel pyyaml

CMD ["/bin/bash"]
