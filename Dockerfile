# This is the Dockefile to build PhaME

############################# Base Docker Image ################################

FROM continuumio/miniconda3

############################# MAINTAINER #######################################

MAINTAINER Migun Shakya <migun@lanl.gov>

############################# METADATA #######################################

LABEL version="1.0.1"
LABEL software="PhaME"
LABEL description="Phylogenetic Analysis and Molecular Evolution"
LABEL website="https://github.com/mshakya/PhaME"
LABEL tags="genomics"

############################# INSTALLATION #####################################

RUN conda config --add channels r
RUN	conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN	conda config --add channels bioconda
RUN conda install -c bioconda phame 
# RUN sh test/TestAll.sh
#############################ENVIRONMENT#####################################
