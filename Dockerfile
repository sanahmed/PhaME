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

RUN conda install phame
# RUN sh test/TestAll.sh
#############################ENVIRONMENT#####################################
