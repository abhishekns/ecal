VER=focal

REGISTRY = rnd-builds.repos.natinst.com
NETWORK = --ipc=host --pid=host --network=host
#NETWORK =

DEBUG_PARAMS = --cap-add=SYS_PTRACE --security-opt seccomp=unconfined

# Name of text file containing build number.
IMAGE_BUILD_NUMBER = image-build-number.txt
MIN_VER = $$(cat $(IMAGE_BUILD_NUMBER))

SSH = ssh -t

HOSTNAME := $(shell hostname)