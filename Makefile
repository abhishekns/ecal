
all: images


images: ecal-base

ecal-base:
	docker build -t $@:jammy .

build:
	docker run --name ecal-$@ -it -v `pwd`:/ecal ecal-base:jammy /ecal/build.sh
	docker commit ecal-$@ ecal-$@:jammy
	docker rm ecal-$@

run:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-build:jammy /bin/bash
