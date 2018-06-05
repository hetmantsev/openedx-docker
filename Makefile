.PHONY: all android configure build update migrate assets up daemon

USERID ?= $$(id -u)
EDX_PLATFORM_SETTINGS ?= universal.production
DOCKER_COMPOSE_RUN = docker-compose run --rm
DOCKER_COMPOSE_RUN_OPENEDX = $(DOCKER_COMPOSE_RUN) -e USERID=$(USERID) -e SETTINGS=$(EDX_PLATFORM_SETTINGS)
ifneq ($(EDX_PLATFORM_PATH),)
	DOCKER_COMPOSE_RUN_OPENEDX += --volume="$(EDX_PLATFORM_PATH):/openedx/edx-platform"
endif

DOCKER_COMPOSE_RUN_LMS = $(DOCKER_COMPOSE_RUN_OPENEDX) -p 8000:8000 lms
DOCKER_COMPOSE_RUN_CMS = $(DOCKER_COMPOSE_RUN_OPENEDX) -p 8001:8001 cms

all: configure update migrate assets daemon

##################### Bootstrapping

configure:
	./configure

update:
	docker-compose pull

##################### Running

up:
	docker-compose up

daemon:
	docker-compose up -d && \
	echo "Daemon is up and running"

stop:
	docker-compose stop

#################### Deploying to docker hub

build:
	# We need to build with docker, as long as docker-compose cannot push to dockerhub
	docker build -t regis/openedx:latest -t regis/openedx:ginkgo openedx/
	docker build -t regis/openedx-forum:latest -t regis/openedx-forum:ginkgo forum/
	docker build -t regis/openedx-xqueue:latest -t regis/openedx-xqueue:ginkgo xqueue/

push:
	docker push regis/openedx:ginkgo
	docker push regis/openedx:latest
	docker push regis/openedx-forum:ginkgo
	docker push regis/openedx-forum:latest
	docker push regis/openedx-xqueue:ginkgo
	docker push regis/openedx-xqueue:latest

dockerhub: build push
