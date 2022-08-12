FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC
RUN apt update

RUN apt install -y build-essential  make cmake git pkg-config wget protobuf-compiler  libprotobuf-c-dev capnproto libhdf5-dev libprotoc-dev libacl1-dev libncurses5-dev libcurl4-openssl-dev patchelf python3-pip

RUN apt install -y  vim gdb mlocate

RUN updatedb

CMD /bin/bash
