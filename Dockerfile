FROM ubuntu:18.04

MAINTAINER Andrew McKenzie <amckenz@gmail.com>
# Adapted from https://github.com/DaisukeMiyamoto/docker-neuron
# And from https://github.com/NeuralEnsemble/neuralensemble-docker/blob/master/simulation/Dockerfile

ARG NRN_VERSION="7.6.2"

WORKDIR /home

RUN apt-get update && \
      apt-get -y install sudo

#for root privileges https://stackoverflow.com/questions/25845538/how-to-use-sudo-inside-a-docker-container
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        locales \
        wget \
        gcc \
        g++ \
        build-essential \
        libncurses-dev \
        xfonts-100dpi \
        python \
        python-pip \
        libpython-dev \
        cython \
        openmpi-bin \
        openmpi-common \
        libopenmpi-dev \
        mpich \
        gnome-devel \
        libxext-dev \
        libx11-dev \
        zlib1g-dev \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get clean

RUN pip install --upgrade pip \
    && hash -r pip \
    && pip install neo \
    && pip install scipy \
    && pip install cython \
    && pip install numpy \
    && pip install lazyarray \
    && pip install matplotlib \
    && pip install ipython \
    && pip install jupyter

RUN mkdir neuron \
    && cd neuron \
    && wget https://www.neuron.yale.edu/ftp/neuron/versions/v7.6/${NRN_VERSION}/nrn-${NRN_VERSION}.tar.gz  \
    && wget https://neuron.yale.edu/ftp/neuron/versions/v7.6/iv-19.tar.gz

RUN cd neuron \
    && tar xvzf nrn-${NRN_VERSION}.tar.gz \
    && tar xvzf iv-19.tar.gz \
    && mv nrn-7.6 nrn \
    && mv iv-19 iv

RUN cd neuron/iv \
    && ./configure --prefix=`pwd` \
    && make \
    && make install

RUN cd neuron/nrn \
    && ./configure --prefix=`pwd` --with-iv=/home/neuron/iv --with-nrnpython=/usr/bin/python --with-paranrn --enable-static=yes \
    && make \
    && make install

ENV LANG en_US.utf8
ENV PATH $PATH:/home/neuron/nrn

COPY jupyter_notebook_config.py /etc/jupyter/
COPY examples /home/examples

USER root

#Allow python to be run in external python scripts https://neurojustas.wordpress.com/2018/03/27/tutorial-installing-neuron-simulator-with-python-on-ubuntu-linux/
RUN cd /home/neuron/nrn/src/nrnpython \
    && python setup.py install \
    && chown -R docker /home

EXPOSE 8888
USER docker

CMD jupyter notebook
