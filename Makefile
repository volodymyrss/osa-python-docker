OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt)
ISDC_REF_CAT_VERSION?=42.0

OSA_IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}
IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}

IMAGE_BASE?=integralsw/osa-python27

IMAGE?=$(IMAGE_BASE):$(IMAGE_TAG)
IMAGE_LATEST?=$(IMAGE_BASE):latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build  . -t $(IMAGE) 
	docker build  . -t $(IMAGE_LATEST) 

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 

Dockerfile: Dockerfile.j2
	j2 -e 'OSA_VERSION="$(OSA_IMAGE_TAG)"' Dockerfile.j2 -d -o Dockerfile
