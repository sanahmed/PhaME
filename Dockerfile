# This is the Dockefile to build PhaME

############################# Base Docker Image ################################

FROM ubuntu:16.04

############################# MAINTAINER #######################################

MAINTAINER Migun Shakya <migun@lanl.gov>

############################# METADATA #######################################

LABEL version="1.0"
LABEL software="PhaME"
LABEL description="Phylogenetic Analysis and Molecular Evolution"
LABEL website="https://github.com/mshakya/PhaME-1"
LABEL tags="genomics"

############################# INSTALLATION #####################################

RUN apt-get -y update --fix-missing
RUN apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 \
	libxrender1 git curl make gcc gfortran g++ grep unzip cmake libcurl4-gnutls-dev \
	ocl-icd-opencl-dev mpich doxygen libssl-dev
RUN apt-get -y upgrade
RUN apt-get clean
RUN mkdir -p /opt && cd /opt
RUN	git clone https://github.com/mshakya/PhaME-1.git
RUN ls
RUN gcc -v
RUN cmake --version
RUN cd PhaME-1 && ls && ./INSTALL.sh
