#!/bin/bash
isExistApp=`pgrep Web`
if [[ -n  $isExistApp ]]; then
    service eshop stop
fi
