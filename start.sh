#!/bin/bash

export SESSIONS=${SESSIONS:-$(boar list | sed -n 's, ([0-9]* revs),,p')}

! test -e /root/log || rm /root/log;
ln -sf /dev/stdout /root/log;
cd /data
for session in ${SESSIONS}; do
    P=${session##*/}
    P=${P:-$session}
    if ! test -d /data/${P}; then
        echo "$(date) ==== Checkout ${P}"
        boar co ${session} ${P}
        cd /data/${P}
        echo "$(date) ==== Update ${P}"
        while ! boar update; do "$(date) **** ERROR"; done
    fi
done
echo "==== initialized, starting service"
cron -fL7
