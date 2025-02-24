include (maks/vars.mak)
include (maks/roundtrip.mak)

all:  latency-single test-run

bash:
	docker run --name ecal-$@ --rm -it -v `pwd`/../:/ecal ecal-src-build:${VER} /bin/bash

latency-single:
	cd ..
	${RUN_CMD} --name ecal-$@-common -d --rm -v `pwd`/../:/ecal ecal-src-build:${VER} /ecal/build/bin/ecal_sample_latency_server
	${EXEC_CMD} ecal-$@-common /ecal/build/bin/ecal_sample_latency_client
	${STOP_CMD} ecal-$@-common

passwdless: sender-pl receiver-pl echo-pl

sender-pl receiver-pl echo-pl:
	$(eval NAME := $(subst -pl,,$@))
	echo "${${NAME}_password}" > /tmp/.${NAME}.pwd
	ssh-copy-id ${${NAME}_user}@${${NAME}} < /tmp/.${NAME}.pwd

test-deploy: deploy-sender deploy-receiver deploy-echo

deploy-sender deploy-receiver deploy-echo:
	mkdir -p ../logs
	$(eval NAME := $(subst deploy-,,$@))
	scp ../deploy.sh ../image-build-number.txt ${${NAME}_user}@${${NAME}}:~/
	${SSH} ${${NAME}_user}@${${NAME}} '~/deploy.sh ${NAME}' | tee ../logs/remote${NAME}.log &

# run echo first and then the receiver followed by sender on same or another machine
receiver sender echo:
	echo "${$@_password}" > /tmp/.$@.pwd
	mkdir -p ~/ecal/logs
	rm -f ~/ecal/logs/$@.log
	~/ecal/setupRoute.sh < /tmp/.$@.pwd
	${RUN_CMD} --name ecal-$@-common -i ${NETWORK} ${DEBUG_PARAMS} --rm -v ~/ecal/:/ecal -v ~/ecal/logs:/logs ecal-install:${VER} /ecal/network/run-common.sh $@

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
