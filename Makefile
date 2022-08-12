VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

#define NW_DEVICE if you want to run server or client
NW_DEVICE=enp6s0

all: images


images: ecal-base

ecal-base:
	docker build -t $@:${VER} .

build:
	docker run --name ecal-$@ -it -v `pwd`:/ecal ecal-base:${VER} /ecal/build.sh
	docker commit ecal-$@ ecal-$@:${VER}
	docker rm ecal-$@

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-build:${VER} /bin/bash

latency-single:
	docker run --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

route:
	NW_DEVICE=${NW_DEVICE} ./setupRoute.sh

server client:
	mkdir -p logs
	docker run --name ecal-$@-common -it ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-build:${VER} /bin/bash
	#/ecal/run-$@.sh

test:  route server client


list:
	@grep '^[^#[:space:]].*:' Makefile
