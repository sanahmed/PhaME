## Phylogenetic and Molecular Evolution (PhaME) analysis tool

[![Build Status](https://travis-ci.org/mshakya/PhaME.svg?branch=master)](https://travis-ci.org/mshakya/PhaME)
[![Waffle.io - Columns and their card count](https://badge.waffle.io/mshakya/PhaME-1.svg?columns=all)](https://waffle.io/mshakya/PhaME-1)
[![Documentation Status](https://readthedocs.org/projects/phame/badge/?version=latest)](https://phame.readthedocs.io/en/latest/?badge=latest)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io/recipes/phame/README.html)
[![docker](https://quay.io/repository/biocontainers/phame/status)](https://quay.io/repository/biocontainers/phame)
![phame-downloads](https://anaconda.org/bioconda/phame/badges/downloads.svg)

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
[Patrick Chain](mailto:pchain@lanl.gov)

--------------------------------------------------------------
## ACKNOWLEDGEMENTS
This project is funded by U.S. Defense Threat Reduction Agency [R-00059-12-0 and R-00332-13-0 to P.S.G.C.].

--------------------------------------------------------------
## Copyright

Copyright (2018).  Triad National Security, LLC. All rights reserved.
 
This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos National 
Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S. Department of Energy/National 
Nuclear Security Administration.
 
All rights in the program are reserved by Triad National Security, LLC, and the U.S. Department of Energy/National 
Nuclear Security Administration. The Government is granted for itself and others acting on its behalf a nonexclusive, 
paid-up, irrevocable worldwide license in this material to reproduce, prepare derivative works, distribute copies to 
the public, perform publicly and display publicly, and to permit others to do so.

This is open source software; you can redistribute it and/or modify it under the terms of the GPLv3 License. If software 
is modified to produce derivative works, such modified software should be clearly marked, so as not to confuse it with 
the version available from LANL. Full text of the [GPLv3 License](https://github.com/LANL-Bioinformatics/PhaME/blob/master/LICENSE) can be found in the License file in the main development 
branch of the repository.
