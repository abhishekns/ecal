include maks/vars.mak
include maks/client-server.mak
include maks/docker.mak
include maks/roundtrip.mak

all: images build image-install

images: ecal-base

ecal-base:
	${BUILD_CMD} -t $@:${VER} .

build:
	${RUN_CMD} --name ecal-$@ -i -v `pwd`:/ecal ecal-base:${VER} /ecal/build.sh
	${COMMIT_CMD} ecal-$@ ecal-install:${VER}
	${REMOVE_CMD} ecal-$@

image-install:
	$(eval NAME := $(subst image-,,$@))
	${INSTALL_CMD} --build-arg OSVER=${VER} -t ecal-${NAME}:${VER} .

clean:
	rm -rf build

latency-single:
	${RUN_CMD} --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-install:${VER} /ecal/build/bin/ecal_sample_latency_server
	${EXEC_CMD} ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	${STOP_CMD} ecal-$@-common

push: ${BUILD_NUMBER_FILE}
	${TAG_CMD} ecal-install:${VER} ${REGISTRY}/dtots/ecal-install:${VER}.${MIN_VER}
	${PUSH_CMD} ${REGISTRY}/dtots/ecal-install:${VER}.${MIN_VER}

# Include build number rules.
include maks/buildnumber.mak

# run client first and then the server on same or another machine
server client:
	mkdir -p logs
	./setupRoute.sh
	${RUN_CMD} --name ecal-$@-common -d ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-install:${VER} /ecal/run-$@.sh

bash:
	${RUN_CMD} --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-install:${VER} /bin/bash

passwdless:
	echo "${client_password}" > /tmp/.client.pwd
	echo "${server_password}" > /tmp/.server.pwd
	ssh-copy-id ${client_user}@${client}
	ssh-copy-id ${server_user}@${server} < /tmp/.server.pwd

deploy-test: deploy-client deploy-server

deploy-client deploy-server:
	mkdir -p logs
	$(eval NAME := $(subst deploy-,,$@))
	scp ./deploy.sh ./image-build-number.txt ${${NAME}_user}@${${NAME}}:~/
	${SSH} -n ${${NAME}_user}@${${NAME}} '~/deploy.sh ${NAME}' | tee logs/remote${NAME}.log &

remote-clean:
	${SSH} ${client_user}@${client} rm -rf ecal
	${SSH} ${server_user}@${server} rm -rf ecal

test-run:
	mkdir -p logs
	rm -f logs/client.log logs/server.log
	${SSH} ${client_user}@${client} 'cd ~/ecal && make client '
	sleep 5
	${SSH} ${server_user}@${server} 'cd ~/ecal && make server'

server-stop client-stop:
	$(eval NAME := $(subst -stop,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'docker stop ecal-${NAME}-common 2>&1 > /dev/null'

test-stop: client-stop server-stop

server-logs client-logs:
	$(eval NAME := $(subst -logs,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'tail -f ~/ecal/logs/${NAME}.log'

list:
	@grep '^[^#[:space:]].*:' Makefile
