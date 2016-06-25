FROM mwaeckerlin/boar
MAINTAINER mwaeckerlin

RUN apt-get update
RUN apt-get install -y cron
ADD start.sh /start.sh
ADD cronjob.sh /etc/cron.hourly/sync-boar
WORKDIR /data
CMD /start.sh

VOLUME /data
