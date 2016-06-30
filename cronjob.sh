#!/bin/bash

echo "$(date) ==== $0"
for f in /data/*; do
    echo "$(date) ---- $f"
    cd $f
    if boar ci -q; then
        boar update -q
    else
        boar update -q
        boar ci -q
    fi    
done 2>&1 >> /root/log
