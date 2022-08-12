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
	docker commit ecal-$@ ecal-src-$@:${VER}
	docker rm ecal-$@

clean:
	rm -rf build

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-src-build:${VER} /bin/bash

latency-single:
	docker run --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-src-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

push: images
	docker tag ecal-base:${VER} ${REGISTRY}/dtots/ecal-base:${VER}
	docker tag ecal-src-build:${VER} ${REGISTRY}/dtots/ecal-src-build:${VER}
	docker push ${REGISTRY}/dtots/ecal-base:${VER}
	docker push ${REGISTRY}/dtots/ecal-src-build:${VER}

# run client first and then the server on same or another machine
server client:
	mkdir -p logs
	./setupRoute.sh
	docker run --name ecal-$@-common -d ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-src-build:${VER} /ecal/run-$@.sh

server=ethlab-8881
client=simfarm15
server_user=root
server_password=labview===
client_user=abnsharm
client_password=labview===

passwdless:
	echo "${client_password}" > /tmp/.client.pwd
	echo "${server_password}" > /tmp/.server.pwd
	ssh-copy-id ${client_user}@${client}
	ssh-copy-id ${server_user}@${server} < /tmp/.server.pwd

test-deploy: images build push
	mkdir -p logs
	scp deploy.sh ${client_user}@${client}:~/
	scp deploy.sh ${server_user}@${server}:~/
	ssh -n ${client_user}@${client} '~/deploy.sh client' | tee logs/remoteClientSetup.log &
	ssh -n ${server_user}@${server} '~/deploy.sh server' | tee logs/remoteServerSetup.log

remote-clean:
	ssh ${client_user}@${client} rm -rf ecal
	ssh ${server_user}@${server} rm -rf ecal

test-run:
	mkdir -p logs
	rm -f logs/client.log logs/server.log
	ssh ${client_user}@${client} 'cd ~/ecal && make client '
	sleep 5
	ssh ${server_user}@${server} 'cd ~/ecal && make server'

server-stop client-stop:
	$(eval NAME := $(subst -stop,,$@))
	ssh ${${NAME}_user}@${${NAME}} 'docker stop ecal-${NAME}-common 2>&1 > /dev/null'

test-stop: client-stop server-stop

server-logs:
	$(eval NAME := $(subst -logs,,$@))
	ssh ${${NAME}_user}@${${NAME}} 'tail -f ~/ecal/logs/publisher.log'

client-logs:
	$(eval NAME := $(subst -logs,,$@))
	ssh ${${NAME}_user}@${${NAME}} 'tail -f ~/ecal/logs/subscriber.log'

list:
	@grep '^[^#[:space:]].*:' Makefile
