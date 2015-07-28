ckan-docker
===========

Developing and deploying CKAN with Docker, an http://appcivico.com/ implementation.

# this is a fork of https://github.com/ckan/ckan-docker but with some different directories and configuration.

# Intro

Dockerfiles, Docker-compose service definition to develop & deploy CKAN, Postgres, Solr & datapusher using Docker.

Docker containers included:

- CKAN (should work with any version 2.x)
- Postgres (Postgres 9.3 and PostGIS 2.1, CKAN datastore & spatial extension supported)
- Solr (4.10.1, custom schemas & spatial extension supported)
- Docker-compose (to manage run containers on developts)
- Data into a diferent directory (to store Postgres data & CKAN FileStore & Solr separately)
- Bash script to make config and build directories after instances run.


Other contrib containers:

- Nginx (1.7.6 official) as a caching reverse proxy
- Datapusher configured to work with the CKAN instance


# Requirements

|Name			|Version		|Comment										|
|:--------------|:-------------:|:----------------------------------------------|
|Docker			|>= 1.3 		|works with Boot2docker 1.3						|
|Docker-compose		|>= 1.1.0 		|on the host or with Dockerfile provided		|
|OS				|any linux 		|as long as you can run Docker 1.3				|



# Reference

## Structure

	├── Dockerfile (CKAN Dockerfile)
	├── README.md
	├── _etc (config copied to /etc)
	│   ├── apache2
	│   ├── ckan
	│   ├── cron.d
	│   ├── my_init.d
	│   ├── postfix
	│   └── supervisor
	├── _service-provider (any service provider such as datapusher)
	│   └── datapusher
	├── _solr
	│   └── schema.xml (version specific & custom schema)
	├── _src (CKAN source code & extensions)
	│   ├── ckan
	│   └── ckanext-...
    ├── source-codes/ with zip tarballs for ckan 2.4 and pages
	├── docker
	│   ├── ckan
	│   ├── data
	│   ├── compose
	│   ├── nginx
	│   ├── insecure_key (baseimage insecure SSH key)
	│   ├── postgres
	│   └── solr
	└── docker-compose.yml (CKAN services definition)


### Directories

_the content from the directories prefixed with `_` need to be edited / configured as required before building the Dockerfiles._

#### _etc
contains configuration files that are copied to /etc in the container. see _etc/README

#### _solr
contains your custom Solr schema (for your version of CKAN, & extensions installed). see _solr/README

#### _src
contains your packages source code (CKAN & extensions). see _src/README

#### _service-provider
contains any service providers (e.g. datapusher) with their Dockerfiles. see _service-provider/README.

#### docker
contains the Dockerfiles and any supporting files

#### source-codes

containers ckan 2.4 and ckanext-pages

### Files

#### Dockerfiles

The Dockerfiles are currently based on `phusion/baseimage:0.9.16`.

[Read this to find out more about phusion baseimage](https://phusion.github.io/baseimage-docker/)

##### CKAN Dockerfile
The app container runs the following services

- Apache
- Postfix
- Supervisor
- Cron

##### Postgres Dockerfile
The database container runs Postgres 9.3 and PostGIS 2.1.
It supports the [datastore](http://docs.ckan.org/en/latest/maintaining/datastore.html) & [ckanext-spatial](https://github.com/ckan/ckanext-spatial)

##### Data Dockerfile
It exposes two volumes to store the Postgres data `($PGDATA)` & CKAN FileStore AND Solr. This means you can recreate / app containers without losing your data.

##### Solr Dockerfile
The Solr container runs version 4.10.1. This can easily be changed by customising SOLR_VERSION in the Dockerfile.

By detault the `schema.xml` of the upstream version (2.3) is copied in the container. This can be overriden at runtime by mounting it as a volume.
This default path of the volume is `<path to>/_src/ckan/ckan/config/solr/schema.xml` so it mounts the schema corresponding to your version of CKAN.

The container is cross version compatible. You need mount the appropriate `schema.xml` as a volume, or build a child image, which will copy the `schema.xml` next to your Dockerfile.

Read the [ckanext-spatial documentation](http://docs.ckan.org/projects/ckanext-spatial/en) to add the required fields to your Solr schema if you use ckanext-spatial

#### docker-compose.yml
Defines the set of services required to run CKAN. Read the [docker-compose.yml reference](http://docs.docker.com/compose/yml/) to understand and edit.

---
# Usage for deploy a new instance

1. Clone this repo and walk into the home directory.
2. Clone the datapusher in `_service-provider`
3. Set the full path of the volumes in docker-compose.yml
4. Run `up` with Docker-compose or Vagrant


## Using Docker-compose (recommended)

#### Option 1: Docker-compose is installed on the Docker host
_If you have it installed, just type_

	docker-compose up

#### Option 2: Using the docker-compose container
_Otherwise, you can use the container provided_

Build the Docker-compose container

	docker build --tag="dockercompose_container" docker/compose

Run it

	docker run -it -d --name="dockercompose-ckan" -p 2375 -v /var/run/docker.sock:/tmp/docker.sock -v $(pwd):/src dockercompose_container

_In the Docker-compose container docker-compose won't work with relative path, because the mount namespace is different, you need to change the relative path to absolute path_

for example, change the `./`:

	volumes:
	    - ./_src:/usr/lib/ckan/default/src

to an absolute path  to you ckan-docker directory: `/Users/username/git/ckan/ckan-docker/`

	volumes:
	    - /Users/username/git/ckan/ckan-docker/_src:/usr/lib/ckan/default/src

Build & Run the services defined in `docker-compose.yml`

	docker exec -it dockercompose-ckan docker-compose up

If you are using boot2docker, add entries in your hosts file e.g. `192.168.59.103  ckan.localdomain`

You can now access CKAN at http://ckan.localdomain:8080/ (Apache) & http://ckan.localdomain/ (Ngnix)

## Using Vagrant

Build & run

	vagrant up --provider=docker --no-parallel

You can now access CKAN at http://localhost:8080/ (Apache)

You can also SSH inside the container if you have left the `--enable-insecure-key` option in the run command.

	vagrant ssh ckan

SSH insecure key can be disabled by removing the `--enable-insecure-key` option from the run command.

---
## Running commands inside the container

The simplest thing to do is to use the `docker exec` command, for example:

	docker exec -it src_ckan_1 /bin/bash

You can also SSH inside the container if you have left the `--enable-insecure-key` option in the run command.

	ssh -i docker/insecure_key -p 2222 root@ckan.localdomain

SSH insecure key can be disabled by removing the `--enable-insecure-key` option from the run command.

## Managing Docker images & containers

You should use docker-compose to manage your containers & images, this will ensure they are started/stopped in order

If you want to quickly remove all untagged images:

	docker images -q --filter "dangling=true" | xargs docker rmi

If you want to quickly remove all stopped containers

	docker rm $(docker ps -a -q)

---
## Developing CKAN

### Using paster serve instead of apache for development
CKAN container starts Apache2 by default and the `ckan.site_url` port is set to `8080` in `50_configure`.
You can override that permanently in the `custom_options.ini`, or manually in the container, for instance if you want to use paster in a development context.

Example (`paster serve --reload` in debug mode):

	docker exec -it src_ckan_1 /bin/bash
	supervisorctl stop apache2
	sed -i -r 's/debug = false/debug = true/' $CKAN_CONFIG/$CONFIG_FILE
	sed -i -r 's/ckan.localdomain:8080/ckan.localdomain:5000/' $CKAN_CONFIG/$CONFIG_FILE
	$CKAN_HOME/bin/paster serve --reload $CKAN_CONFIG/$CONFIG_FILE

### Frontend development
Front end development is also possible (see [Frontend development guidelines](http://docs.ckan.org/en/latest/contributing/frontend/))

Install frontend dependencies:

	docker exec -it src_ckan_1 /bin/bash
	apt-get update
	apt-get install -y nodejs npm
	ln -s /usr/bin/nodejs /usr/bin/node
	source $CKAN_HOME/bin/activate
	cd $CKAN_HOME/
	npm install nodewatch less@1.3.3

Both examples show that development dependencies should only be installed in the containers when required. Since they are not part of the `Dockerfile` they do not persist and only serve the purpose of development. When they are no longuer needed the container can be rebuilt allowing to test the application in a production-like state.

---

# Sources
- [Docker](https://www.docker.com)
- [Docker-compose](http://docs.docker.com/compose/)
- [Vagrant Docker provider](https://docs.vagrantup.com/v2/docker/index.html)
