FROM mwaeckerlin/ubuntu-base
MAINTAINER mwaeckerlin
ENV TERM xterm

ENV TIMEOUT "600"
ENV BOAR_USER "boar"
ENV BOAR_HOST "boar"
ENV BOAR_PORT "22"
ENV BOAR_REPO "boar+ssh://BOAR_USER@BOAR_HOST/boar"
ENV BOAR_SOURCE "https://bitbucket.org/mats_ekberg/boar/downloads/boar.16-Nov-2012.tar.gz"
ENV LANG "en_US.UTF-8"
ENV SSH_PUBKEY ""
ENV SSH_PRIVKEY ""

WORKDIR /opt
RUN apt-get --no-install-recommends --no-install-suggests -y install openssh-client inotify-tools python wget mcrypt language-pack-en \
 && wget -O- ${BOAR_SOURCE} | tar xz \
 && apt-get autoremove --purge wget -y \
 && /cleanup.sh

ADD boar /usr/local/bin/boar
WORKDIR /data

RUN useradd -ms /bin/bash boar
USER boar
CMD /start.sh

VOLUME /data
