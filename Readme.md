# Evaluating Ecal

## Introduction

## Build

### Variables

    VER=focal
    server=simfarm14
    server_user=abnsharm
    server_password=labview===
    client=simfarm15
    client_user=abnsharm
    client_password=labview===

OR whatever you set in Makefile

### Building source and the docker images

    make images
    # this will create image ecal-base:${VER}.

    make build
    # this will build the sources and then install it to create image ecal-src-build:${VER}
    # in case you see message "... uptodate" run as below
    make -B build

    # run a latency test for both server and client on the same machine.
    make latency-single

    # deploy this source and docker images to the ${server} and ${client}.
    make deploy-test

    # -run, -stop, -logs targets do the relevant function for server|client
    make (server|client)-(run|stop|logs)

    # sets up passwdless communication with server and client over ssh
    make passwdless

## Network Tests

### Roundtrip test
This test creates a sender, receiver and an echo container running on respective systems.
Sender sends packets to echo server. echo server sends the received packets to receiver.
Change to the directory *test*.

    # \*-bash, deploy-\*, \*-stop, \*-logs, \*-run do respective actions for "\*=(sender|receiver|echo)"

## Local Tests
