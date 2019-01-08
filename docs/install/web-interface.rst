Web-interface.
####################################

Step by step guide to run PhaME using web interface in a local machine. Docker and git is required.

1. clone the repo 

.. code-block:: console

    git clone git@github.com:LANL-Bioinformatics/phame-api.git


2. create a `.postegres` file within the cloned directory `phame_api01/.envs/.local/.postgres`, and add following lines to it.

.. code-block:: console

    # PostgreSQL
    # ------------------------------------------------------------------------------
    POSTGRES_HOST=postgres
    POSTGRES_PORT=5432
    POSTGRES_DB=phame_api01
    POSTGRES_USER=<user>
    POSTGRES_PASSWORD=<postgres_password>


4. cd to the project root  directory `phame_api`

.. code-block:: console

    cd phame_api

5. Create docker containers.

.. code-block:: console

    docker-compose build

6. start docker

.. code-block:: console

    docker-compose up -d

7. `docker-compose run --rm web /bin/bash -c "python -c  'import database; database.init_db()'"` to initialize the database.

.. code-block:: console

    docker-compose run --rm web /bin/bash -c "python -c  'import database; database.init_db()'"


8. If all went well, you can go to open http://localhost to access the phame web-interface.