# INTEGRAL OSA including Python and HEASoft (with pyXSpec)


[![Docker Pulls](https://img.shields.io/docker/pulls/integralsw/osa-python.svg)](https://hub.docker.com/repository/docker/integralsw/osa-python/)

this is a version of the [official OSA docker](https://gitlab.astro.unige.ch/savchenk/osa-docker/), but with recent python version.

heasoft needs to be re-built with python, hence the image built may take a while.

to test 

```bash
$ make pull
$ make test
```
