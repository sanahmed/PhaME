Docker
#######

To bypass the installation steps, we have provided a docker [image](https://stackoverflow.com/questions/23735149/what-is-the-difference-between-a-docker-image-and-a-container) for PhaME. To run PhaME from a docker image, follow these steps:

1. Install .. _Docker: https://docs.docker.com/install/


2. Download the latest PhaME image from [quay.io](https:quay.io/)

    .. code-block:: console

        $ docker pull quay.io/biocontainers/phame:1.0.3--0


3. Check if the image is correctly downloaded by running the provided test:
    
    .. code-block:: console

        $ docker run --rm quay.io/biocontainers/phame:1.0.3--0 phame -h
        $ docker run --rm quay.io/biocontainers/phame:1.0.3--0 phame -vcheck

4. Run your own data using docker. A step by step guide
    - Create a folder to mount onto your docker

    .. code-block:: console
    
        $ mkdir -p phame_analysis_folder

    
    - Create a `refdir` folder with complete genomes within `phame_analysis_folder`

          This folder will contain fasta files representing complete genomes.

          .. code-block:: console
          
            $ cd phame_analysis_folder
            $ mkdir -p refdir

        Copy or download genomes and their gff files (if needed) onto this folder.

    - Create a `workdir` folder within the `phame_analysis_folder`.
        This folder will have all the intermediate and final outputs of the analysis including input contigs and reference.

        .. code-block:: console
        
            $ mkdir -p workdir

    - Create a control file.
        All the inputs and parameters of a PhaME analysis is set in the control file. Using the provided template create a control file with apprpriate parameters and save it in the `phame_analysis_foler`.

    - Run the analysis using docker.

    .. code-block:: console
    
        $ docker run --rm -v $(pwd)/phame_analysis_folder:/data migun/phame src/phame /data/ecoli.ctl
        $ git clone https://github.com/mshakya/phame_examples.git
        $ docker run --rm -v $(pwd)/phame_examples:/data migun/phame-1 perl src/phame /data/ecoli/ecoli.ctl


