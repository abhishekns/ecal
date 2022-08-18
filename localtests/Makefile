VER = focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

# localhost or any other machine where all of the below tests will run
target=simfarm14
target_user=abnsharm
target_password=labview===

#ethlab-8881
sender=${target}
sender_user=${target_user}
sender_password=${target_password}

receiver=${target}
receiver_user=${target_user}
receiver_password=${target_password}

echo=${target}
echo_user=${target_user}
echo_password=${target_password}

HOSTNAME := $(shell hostname)

ifeq ("${target}", "${HOSTNAME}")
    SSH = ''
else
    SSH = ssh -t ${target_user}@${target}
endif

passwdless:
	echo "${sender_password}" > /tmp/.sender.pwd
	ssh-copy-id ${sender_user}@${sender} < /tmp/.sender.pwd

bash:
	${SSH} docker run --name ecal-$@ --rm -it -v `pwd`/../:/ecal ecal-install:${VER} /bin/bash

# run echo first and then the receiver followed by sender on same or another machine
receiver sender echo:
	mkdir -p ~/ecal/logs
	rm -f ~/ecal/logs/${NAME}.log
	~/ecal/setupRoute.sh
	docker run --name ecal-$@-common -i ${NETWORK} ${DEBUG_PARAMS} --rm -v ~/ecal/:/ecal -v ~/ecal/logs:/logs ecal-install:${VER} /ecal/localtests/run-common.sh $@

test-run: receiver-run echo-run sender-run

receiver-run sender-run echo-run:
	$(eval NAME := $(subst -run,,$@))
	${SSH} 'cd ~/ecal/localtests && make ${NAME}'
	sleep 3

test-stop: echo-stop receiver-stop sender-stop

sender-stop receiver-stop echo-stop:
	$(eval NAME := $(subst -stop,,$@))
	${SSH} 'docker stop ecal-${NAME}-common 2>&1 > /dev/null'

sender-bash receiver-bash echo-bash:
	$(eval NAME := $(subst -bash,,$@))
	${SSH} 'docker run --name ecal-${NAME}-bash -it ${NETWORK} ${DEBUG_PARAMS} --rm -v `pwd`/ecal/:/ecal -v `pwd`/ecal/logs:/logs ecal-install:${VER} /bin/bash'


test-logs: sender-logs receiver-logs echo-logs

sender-logs receiver-logs echo-logs:
	$(eval NAME := $(subst -logs,,$@))
	${SSH} 'tail -f ~/ecal/logs/$@.log'

list:
	@grep '^[^#[:space:]].*:' Makefile
