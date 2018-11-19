Using PhaME through a web-interface.
####################################

Step by step guide to run PhaME using web interface in a local machine. Docker and git is required.

1. clone the repo 

.. code-block:: console

    git clone


2. create a `.postegres` file within the cloned directory `phame_api01/.envs/.local/.postgres`, and add following lines to it.

.. code-block:: console

    # PostgreSQL
    # ------------------------------------------------------------------------------
    POSTGRES_HOST=postgres
    POSTGRES_PORT=5432
    POSTGRES_DB=phame_api01
    POSTGRES_USER=debug
    POSTGRES_PASSWORD=debug


4. cd to the project root  directory `phame_api01`

.. code-block:: console

    cd phame_api01

5. Create docker containers.

.. code-block:: console

    docker-compose build

6. start docker

.. code-block:: console

    docker-compose up

7. `docker-compose run --rm web /bin/bash -c "python -c  'import database; database.init_db()'"` to initialize the database.

.. code-block:: console

    docker-compose run --rm web /bin/bash -c "python -c  'import database; database.init_db()'"


8. If all went well, :sunglasses: you can go to localhost:8080 to see the phame webpage.