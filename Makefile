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
	docker run --name ecal-$@ -i -v `pwd`:/ecal ecal-base:${VER} /ecal/build.sh
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
	docker run --name ecal-$@-common -d ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-src-build:${VER} /ecal/run-$@.sh

SERVER=ethlab-8881
CLIENT=simfarm15
server_user=root
server_password=labview===
client_user=abnsharm
client_password=labview===

passwdless:
	echo "${client_password}" > /tmp/.client.pwd
	echo "${server_password}" > /tmp/.server.pwd
	ssh-copy-id ${client_user}@${CLIENT}
	ssh-copy-id ${server_user}@${SERVER} < /tmp/.server.pwd

test-deploy:
	mkdir -p logs
	scp deploy.sh ${client_user}@${CLIENT}:~/
	scp deploy.sh ${server_user}@${SERVER}:~/
	ssh -n ${client_user}@${CLIENT} '~/deploy.sh client' | tee logs/remoteClientSetup.log &
	ssh -n ${server_user}@${SERVER} '~/deploy.sh server' | tee logs/remoteServerSetup.log

remote-clean:
	ssh ${client_user}@${CLIENT} rm -rf ecal
	ssh ${server_user}@${SERVER} rm -rf ecal

test:
	mkdir -p logs
	rm -f logs/client.log logs/server.log
	ssh ${client_user}@${CLIENT} -p ${client_password} 'cd ~/ecal && make client ' > logs/client.log
	ssh ${server_user}@${SERVER} -p ${server_password} 'cd ~/ecal && make server' > logs/server.log

list:
	@grep '^[^#[:space:]].*:' Makefile
