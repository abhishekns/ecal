VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

# Name of text file containing build number.
IMAGE_BUILD_NUMBER = image-build-number.txt
MIN_VER = $$(cat $(IMAGE_BUILD_NUMBER))

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

push: ${BUILD_NUMBER_FILE}
	docker tag ecal-base:${VER} ${REGISTRY}/dtots/ecal-base:${VER}.${MIN_VER}
	docker tag ecal-src-build:${VER} ${REGISTRY}/dtots/ecal-src-build:${VER}.${MIN_VER}
	docker push ${REGISTRY}/dtots/ecal-base:${VER}.${MIN_VER}
	docker push ${REGISTRY}/dtots/ecal-src-build:${VER}.${MIN_VER}
# Include build number rules.
include buildnumber.mak

# run client first and then the server on same or another machine
server client:
	mkdir -p logs
	./setupRoute.sh
	docker run --name ecal-$@-common -d ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-src-build:${VER} /ecal/run-$@.sh
#ethlab-8881
server=simfarm14
client=simfarm15
server_user=abnsharm
server_password=labview===
client_user=abnsharm
client_password=labview===

passwdless:
	echo "${client_password}" > /tmp/.client.pwd
	echo "${server_password}" > /tmp/.server.pwd
	ssh-copy-id ${client_user}@${client}
	ssh-copy-id ${server_user}@${server} < /tmp/.server.pwd

deploy-test: deploy-client deploy-server

deploy-client deploy-server:
	mkdir -p logs
	$(eval NAME := $(subst deploy-,$@))
	scp ../deploy.sh ../image-build-number.txt ${${NAME}_user}@${${NAME}}:~/
	ssh -n ${${NAME}_user}@${${NAME}} '~/deploy.sh ${NAME}' | tee logs/remote${NAME}.log &

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
