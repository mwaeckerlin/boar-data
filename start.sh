#!/bin/bash

update() {
    echo "$(date) ---- $*"
    cd "$*"
    STATUS="$(boar status)"
    if boar ci -q -m "changed from ${CONTAINERNAME}:\n${STATUS:-no status}"; then
        boar update -q
    else
        boar update -q
        boar ci -q -m "changed from ${CONTAINERNAME}:\n${STATUS:-no status}"
    fi
    chmod -R +rw .
}

if [[ $BOAR_REPO =~ BOAR_USER ]]; then
    export BOAR_REPO=${BOAR_REPO//BOAR_USER/$BOAR_USER}
fi

if [[ $BOAR_REPO =~ BOAR_HOST ]]; then
    export BOAR_REPO=${BOAR_REPO//BOAR_HOST/$BOAR_HOST}
fi

if ! test -f ~/.ssh/id_rsa.pub; then
    if test -n "${SSH_PUBKEY}" -a -n "${SSH_PRIVKEY}"; then
        test -d ~/.ssh || mkdir ~/.ssh
        echo "${SSH_PUBKEY}" > ~/.ssh/id_rsa.pub
        echo "${SSH_PRIVKEY}" > ~/.ssh/id_rsa
        chmod go= ~/.ssh/id_rsa
    else
        echo | ssh-keygen -qb ${KEYSIZE} -N ""; echo;
    fi
    cat > ~/.ssh/config <<EOF
Host ${BOAR_HOST}
  HostName ${BOAR_HOST}
  User ${BOAR_USER}
  Port ${BOAR_PORT}
  StrictHostKeyChecking no
EOF
    ssh-keyscan -H ${BOAR_HOST} >> ~/.ssh/known_hosts;
    echo "*** SSH-Public-Key, add to ${BOAR_HOST}'s ~${BOAR_USER}/.ssh/authorized_keys:"
    cat ~/.ssh/id_rsa.pub
fi

export SESSIONS=${SESSIONS:-$(boar list | sed -n 's, ([0-9]* revs),,p')}

for session in ${SESSIONS}; do
    P=${session##*/}
    P=${P:-$session}
    if ! test -d "/data/${P}"; then
        while ! test -d "/data/${P}"; do
            echo "$(date) ==== Checkout ${P}"
            cd /data
            boar co "${session}" "${P}"
        done
        cd "/data/${P}"
        echo "$(date) ==== Update ${P}"
        while ! boar update; do "$(date) **** ERROR in ${P}"; done
    fi
    echo "$(date) ==== Fix Permissions ${P}"
    chmod -R +rw "/data/${P}"
done

echo "==== initialized, starting service"
echo "$(date) ---- startup, update all"
for f in /data/*; do
    update "$f"
done
while true; do
    echo "$(date) ---- setup watches"
    unset p
    inotifywait -t ${TIMEOUT:-600} -r --format '%w' -e modify,attrib,move,create,delete /data/* |
        while read p; do
            update "$p"
        done
    if test ${PIPESTATUS[0]} -eq 2; then
        echo "$(date) ---- timeout, update all"
        for f in /data/*; do
            update "$f"
        done
    fi
done
