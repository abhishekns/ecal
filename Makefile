
all: images


images: ecal-base

ecal-base:
	docker build -t $@:jammy .

build:
	docker run --name ecal-$@ -it -v `pwd`:/ecal ecal-base:jammy /ecal/build.sh
	docker commit ecal-$@ ecal-$@:jammy
	docker rm ecal-$@

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-build:jammy /bin/bash

latency-single:
	docker run --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-build:jammy /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

list:
	@grep '^[^#[:space:]].*:' Makefile
