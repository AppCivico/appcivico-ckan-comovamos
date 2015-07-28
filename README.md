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
1. `./unzip-sources.sh`    # decompress source code into the correct paths
1. `./build-images.sh`     # build the Dockerfiles (go take a coffee)
1. `./generate-configs.sh` # generate ckan.ini and copy an who.ini
1. `docker-compose up`     # with Docker-compose or Vagrant

---
## Running commands inside the container

The simplest thing to do is to use the `docker exec` command, for example:

	docker exec -it NAME_OF_CONTAINER /bin/bash

## Managing Docker images & containers

You should use docker-compose to manage your containers & images, this will ensure they are started/stopped in order

If you want to quickly remove all untagged images:

	docker images -q --filter "dangling=true" | xargs docker rmi

If you want to quickly remove all stopped containers

	docker rm $(docker ps -a -q)
---

# Sources
- [Docker](https://www.docker.com)
- [Docker-compose](http://docs.docker.com/compose/)
