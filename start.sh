#!/bin/sh

update() {
    echo "$(date) ---- $*"
    cd "$*"
    STATUS="$(boar status)"
    STATUS="${STATUS:-no status}"
    echo "$STATUS"
    if boar ci $OPTIONS -m "changed from ${CONTAINERNAME}:\n${STATUS}"; then
        boar update $OPTIONS
    else
        boar update $OPTIONS
        boar ci $OPTIONS -m "changed from ${CONTAINERNAME}:\n${STATUS}"
    fi
}

if test "${BOAR_REPO}" != ${BOAR_REPO//BOAR_USER/}; then
    export BOAR_REPO=${BOAR_REPO//BOAR_USER/$BOAR_USER}
fi

if test "${BOAR_REPO}" != ${BOAR_REPO//BOAR_HOST/}; then
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
        while ! boar update -q; do "$(date) **** ERROR in ${P}"; done
    fi
done

echo "==== initialized, starting service"
echo "$(date) ---- startup, update all"
for f in /data/*; do
    update "$f"
done
while true; do
    echo "$(date) ---- setup watches"
    unset p
    (
        inotifywait -t ${TIMEOUT:-600} -r --format '%w' -e modify,attrib,move,create,delete /data/*;
        echo -n $? > /tmp/result.$$
    ) | while read p; do
        update "$p"
    done
    res=$(cat /tmp/result.$$)
    rm /tmp/result.$$
    if test $res -eq 2; then
        echo "$(date) ---- timeout, update all"
        for f in /data/*; do
            update "$f"
        done
    fi
done
