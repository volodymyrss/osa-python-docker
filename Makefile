OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt)
ISDC_REF_CAT_VERSION?=42.0
PYTHON_VERSION=3.6.6
HEASOFT_VERSION=6.22

OSA_IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}
IMAGE_TAG=${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}-heasoft-$(HEASOFT_VERSION)-python-$(PYTHON_VERSION)

IMAGE_BASE?=integralsw/osa-python27

IMAGE?=$(IMAGE_BASE):$(IMAGE_TAG)
IMAGE_LATEST?=$(IMAGE_BASE):latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE) 
	docker build --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg python_version=$(PYTHON_VERSION) --build-arg heasoft_version=$(HEASOFT_VERSION) . -t $(IMAGE_LATEST) 

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 

#Dockerfile: Dockerfile.j2
#	j2 -e 'OSA_VERSION="$(OSA_IMAGE_TAG)"' Dockerfile.j2 -d -o Dockerfile
