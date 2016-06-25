#!/bin/bash

if test -z "$SESSIONS"; then
    echo "set SESSION variable to sessions and pathes to checkout";
    exit 1;
fi;
! test -e /root/log || rm /root/log;
ln -sf /dev/stdout /root/log;
for session in ${SESSIONS}; do
    P=${session##*/}
    P=${P:-$session}
    if ! test -d /data/${P}; then
        boar --repo=/boar $session
    fi
done
cron -fL7
