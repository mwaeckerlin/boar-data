FROM ubuntu
MAINTAINER mwaeckerlin
ENV TERM xterm

ENV BOAR_USER "boar"
ENV BOAR_GROUP "boar"
ENV BOAR_SOURCE "https://bitbucket.org/mats_ekberg/boar/downloads/boar.16-Nov-2012.tar.gz"
ENV LANG "en_US.UTF-8"

WORKDIR /opt
RUN apt-get update
RUN apt-get -y install cron python wget mcrypt language-pack-en
RUN wget -O- ${BOAR_SOURCE} | tar xz

ADD boar /usr/local/bin/boar
ADD start.sh /start.sh
ADD cronjob.sh /etc/cron.hourly/sync-boar
WORKDIR /data

CMD /start.sh

VOLUME /data
