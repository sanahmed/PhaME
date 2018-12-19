Conda
############################

PhaME can be installed using [conda](https://conda.io/docs/index.html). If you do not have anaconda or miniconda installed, please do so. Installation of miniconda or anaconda is rather straight forward. After installtion of conda, add channels for bioconda and conda-forge using:
 
 .. code-block:: console
 
    $ conda config --add channels r
    $ conda config --add channels defaults
    $ conda config --add channels conda-forge
    $ conda config --add channels bioconda


Then simply run

.. code-block:: console

    conda install phame

We recommend creating a separate conda environment for PhaME. You can create a conda environment by:

.. code-block:: console

    $ conda create -n my_env
    $ conda install phame -n my_env
