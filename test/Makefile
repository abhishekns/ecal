VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

SSH = ssh -t

all:  latency-single test-run

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`/../:/ecal ecal-src-build:${VER} /bin/bash

latency-single:
	cd ..
	docker run --name ecal-$@-common -d --rm -v `pwd`/../:/ecal ecal-src-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	docker exec ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	docker stop ecal-$@-common

#ethlab-8881
sender=simfarm14
sender_user=abnsharm
sender_password=labview===

receiver=simfarm14
receiver_user=abnsharm
receiver_password=labview===

echo=simfarm15
echo_user=abnsharm
echo_password=labview===

passwdless:
	echo "${sender_password}" > /tmp/.sender.pwd
	echo "${echo_password}" > /tmp/.echo.pwd
	ssh-copy-id ${sender_user}@${sender} < /tmp/.sender.pwd
	ssh-copy-id ${echo_user}@${echo} < /tmp/.echo.pwd

test-deploy: deploy-sender deploy-receiver deploy-echo

deploy-sender deploy-receiver deploy-echo:
	mkdir -p ../logs
	$(eval NAME := $(subst deploy-,,$@))
	scp ../deploy.sh ../image-build-number.txt ${${NAME}_user}@${${NAME}}:~/
	${SSH} ${${NAME}_user}@${${NAME}} '~/deploy.sh ${NAME}' | tee ../logs/remote${NAME}.log &

# run echo first and then the receiver followed by sender on same or another machine
receiver sender echo:
	mkdir -p ~/ecal/logs
	rm -f ~/ecal/logs/${NAME}.log
	~/ecal/setupRoute.sh
	docker run --name ecal-$@-common -i ${NETWORK} ${DEBUG_PARAMS} --rm -v ~/ecal/:/ecal -v ~/ecal/logs:/logs ecal-src-build:${VER} /ecal/test/run-common.sh $@

test-run: receiver-run echo-run sender-run

receiver-run sender-run echo-run:
	$(eval NAME := $(subst -run,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'cd ~/ecal/test && make ${NAME} '
	sleep 3

test-stop: echo-stop receiver-stop sender-stop

sender-stop receiver-stop echo-stop:
	$(eval NAME := $(subst -stop,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'docker stop ecal-${NAME}-common 2>&1 > /dev/null'

sender-bash receiver-bash echo-bash:
	$(eval NAME := $(subst -bash,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'docker run --name ecal-${NAME}-bash -it ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`/ecal/:/ecal -v `pwd`/ecal/logs:/logs ecal-src-build:${VER} /bin/bash'


test-logs: sender-logs receiver-logs echo-logs

sender-logs receiver-logs echo-logs:
	$(eval NAME := $(subst -logs,,$@))
	${SSH} ${${NAME}_user}@${${NAME}} 'tail -f ~/ecal/logs/$@.log'

list:
	@grep '^[^#[:space:]].*:' Makefile
