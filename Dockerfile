FROM ubuntu:focal

#RUN dpkg --configure -a 
#RUN apt-get clean
#RUN apt-get autoremove
#RUN apt install apt-util
#RUN apt-get remove libappstream4
#RUN apt-get purge apt-show-versions

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC
RUN apt update

RUN apt install -y build-essential

RUN apt install -y make cmake

RUN apt install -y make git

RUN apt install -y protobuf-compiler  libprotobuf-c-dev 

RUN apt install -y wget 

#RUN wget https://download.qt.io/new_archive/qt/5.7/5.7.0/qt-opensource-linux-x64-5.7.0.run
#RUN chmod +x *.run

#RUN ./qt-opensource-linux-x64-5.7.0.run

RUN apt install -v capnproto
RUN apt-get install -y libhdf5-dev

RUN apt install -y libprotoc-dev

#on focal
RUN apt install -y libacl1-dev libncurses5-dev pkg-config libcurl4-openssl-dev 

RUN apt install -y vim gdb mlocate 
RUN updatedb

CMD /bin/bash
