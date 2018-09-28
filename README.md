## Phylogenetic and Molecular Evolution (PhaME) analysis tool

[![Build Status](https://travis-ci.org/mshakya/PhaME.svg?branch=master)](https://travis-ci.org/mshakya/PhaME)
[![Waffle.io - Columns and their card count](https://badge.waffle.io/mshakya/PhaME-1.svg?columns=all)](https://waffle.io/mshakya/PhaME-1)
[![Documentation Status](https://readthedocs.org/projects/phame/badge/?version=latest)](https://phame.readthedocs.io/en/latest/?badge=latest)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io/recipes/phame/README.html)

Given a reference, PhaME extracts SNPs from complete genomes, draft genomes and/or reads. 
Uses SNP multiple sequence alignment to construct a phylogenetic tree. 
Provides evolutionary analyses (genes under positive selection) using CDS SNPs.


## Installing PhaME

PhaME can be installed using conda. If you do not have anaconda or miniconda installed, please do so. Installation of miniconda or anaconda is rather straight forward. See [here](https://conda.io/miniconda.html). After installtion of conda, add channels for bioconda and conda-forge using:
  
    $ conda config --add channels r
    $ conda config --add channels defaults
    $ conda config --add channels conda-forge
    $ conda config --add channels bioconda

Then simply run:

    conda install phame

We do recommend creating a separate conda environment for PhaME. You can create a conda environment by:

    $ conda create -n my_env
    $ conda install phame -n my_env

To get the latest version of PhaME, one can use "git" to obtain the package:

    $ git clone https://github.com/mshakya/PhaME.git
    $ cd PhaME
    $ ./INSTALL.sh

However, ./INSTALL.sh is no longer supported. We recommend using bioconda to install all dependencies of PhaME and the `git clone` the repository to use the latest PhaME.

## CITATION

From raw reads to trees: Whole genome SNP phylogenetics across the tree of life.

Sanaa Afroz Ahmed, Chien-Chi Lo, Po-E Li, Karen W Davenport, Patrick S.G. Chain

bioRxiv doi: http://dx.doi.org/10.1101/032250

--------------------------------------------------------------
## Contact

[Migun Shakya](mailto:migun@lanl.gov)

--------------------------------------------------------------
## ACKNOWLEDGEMENTS
This project is funded by U.S. Defense Threat Reduction Agency [R-00059-12-0 and R-00332-13-0 to P.S.G.C.].

--------------------------------------------------------------
## Copyright

Los Alamos National Security, LLC (LANS) owns the copyright to EDGE, which it identifies internally as LA-XX-XX-XXX. The license is BSD-3. See LICENSE for the full text.