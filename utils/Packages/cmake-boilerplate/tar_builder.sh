#!/bin/bash

if [ -d $1/Packages/libqemu/ ]; then
    echo "Directory libqemu exist"
    cd libqemu/* 
    git submodule init 
    git submodule update
fi