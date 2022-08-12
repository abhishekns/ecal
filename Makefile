VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

all: images


images: ecal-base

ecal-base:
	docker build -t $@:${VER} .

build:
	docker run --name ecal-$@ -it -v `pwd`:/ecal ecal-base:${VER} /ecal/build.sh
	docker commit ecal-$@ ecal-$@:${VER}
	docker rm ecal-$@

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-src-build:${VER} /bin/bash

latency-single:
	docker run --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-src-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

push: images build 
	docker tag ecal-src-build:${VER} ${REGISTRY}/dtots/ecal-src-build:${VER}
	docker push ${REGISTRY}/dtots/ecal-src-build:${VER}

# run client first and then the server on same or another machine
server client:
	mkdir -p logs
	./setupRoute.sh
	docker run --name ecal-$@-common -it ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-src-build:${VER} /ecal/run-$@.sh

SERVER=ethlab-8881
CLIENT=simfarm15
server_user=root
server_password=labview===
client_user=abnsharm
client_password=labview===

test-deploy: push
	ssh ${client_user}@${CLIENT} 'curl https://raw.githubusercontent.com/abhishekns/ecal/master/deploy.sh client | bash ' &
	ssh ${server_user}@${SERVER} 'curl https://raw.githubusercontent.com/abhishekns/ecal/master/deploy.sh server | bash '

test: test-deploy
	mkdir -p logs
	rm -f logs/client.log logs/server.log
	ssh ${client_user}@${CLIENT} 'cd ~/ecal && make client ' > logs/client.log
	ssh ${server_user}@${SERVER} 'cd ~/ecal && make server' > logs/server.log

list:
	@grep '^[^#[:space:]].*:' Makefile
