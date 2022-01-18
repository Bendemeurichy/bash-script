#!/usr/bin/env bash

syntax(){
    echo "Syntaxis" >&2
    exit 1
}

NatGetal="^[0-9]*$"

#options
opt_a=0
opt_b=0
opt_c=0

while getopts ":a:b:c:" opt;do
    case "$opt" in
        a)
        #optiona
        a=
        ;;
        b)
        #optionb
        b=
        ;;
        c)
        #optionc
        c=
        ;;
        *)
            syntax()
    esac
done
shift $((OPTIND-1))

#error handling

#solution script