#!/bin/bash

for f in /data/*; do
    cd $f
    if boar ci -q; then
        boar update -q
    else
        boar update -q
        boar ci -q
    fi    
done
