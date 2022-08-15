VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

all:  latency-single test-run

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`:/ecal ecal-src-build:${VER} /bin/bash

latency-single:
	docker run --name ecal-$@-common -d --rm -v `pwd`:/ecal ecal-src-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

#ethlab-8881
sender=simfarm14
sender_user=abnsharm
sender_password=labview===

receiver=
receiver_user=abnsharm
receiver_password=labview===

echo=simfarm15
echo_user=abnsharm
echo_password=labview===

test-deploy: deploy-sender deploy-receiver deploy-echo

deploy-sender deploy-receiver deploy-echo:
	mkdir -p logs
	$(eval NAME := $(subst deploy-,,$@))
	scp ../deploy.sh ../image-build-number.txt ${${NAME}_user}@${${NAME}}:~/
	ssh -n ${${NAME}_user}@${${NAME}} '~/deploy.sh ${NAME}' | tee logs/remote${NAME}.log &


# run echo first and then the receiver followed by sender on same or another machine
receiver sender echo:
	mkdir -p logs
	./setupRoute.sh
	docker run --name ecal-$@-common -d ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`:/ecal -v `pwd`/logs:/logs ecal-src-build:${VER} /ecal/test/run-common.sh $@

passwdless:
	echo "${sender_password}" > /tmp/.sender.pwd
	echo "${echo_password}" > /tmp/.echo.pwd
	ssh-copy-id ${sender_user}@${sender} < /tmp/.sender.pwd
	ssh-copy-id ${echo_user}@${echo} < /tmp/.echo.pwd

test-run: echo-test receiver-test sender-test

receiver-run sender-run echo-run:
	$(eval NAME := $(subst -run,$@))
	mkdir -p logs
	rm -f logs/${NAMe}.log
	ssh ${${NAME}_user}@${${NAME}} 'cd ~/ecal/test && make ${NAME} '
	sleep 3

test-stop: echo-stop receiver-stop sender-stop

sender-stop receiver-stop echo-stop:
	$(eval NAME := $(subst -stop,,$@))
	ssh ${${NAME}_user}@${${NAME}} 'docker stop ecal-${NAME}-common 2>&1 > /dev/null'

test-logs: sender-logs receiver-logs echo-logs

sender-logs receiver-logs echo-logs:
	$(eval NAME := $(subst -logs,,$@))
	ssh ${${NAME}_user}@${${NAME}} 'tail -f ~/ecal/logs/$@.log'

list:
	@grep '^[^#[:space:]].*:' Makefile
