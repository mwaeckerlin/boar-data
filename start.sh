#!/bin/bash

if test -z "$SESSIONS"; then
    echo "set SESSION variable to sessions and pathes to checkout";
    exit 1;
fi;
! test -e /root/log || rm /root/log;
ln -sf /dev/stdout /root/log;
cd /data
for session in ${SESSIONS}; do
    P=${session##*/}
    P=${P:-$session}
    if ! test -d /data/${P}; then
        boar co ${session} ${P}
    fi
done
if test -e /etc/cron.hourly/sync-boar; then
    mv /etc/cron.hourly/sync-boar /etc/cron.hourly/sync-boar.bak
fi
sleep infinity
#cron -fL7
