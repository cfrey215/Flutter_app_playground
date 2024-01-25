FROM ubuntu:20.04 as base_installation_android

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install keyboard-configuration -y
RUN apt install xfce4 xfce4-goodies -y
RUN apt install xvfb -y

ENV DISPLAY :99

WORKDIR /root
ADD . .
RUN chmod a+x display.sh

# CMD { bash display.sh; }