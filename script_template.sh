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
            if[[ "$OPTARG" =~ "$NatGetal" ]];then
                a="$OPTARG"
            else
                syntax()
            fi
        ;;
        b)
            if[[ "$OPTARG" =~ "$NatGetal" ]];then
                b="$OPTARG"
            else
                syntax()
            fi
        ;;
        c)
            if[[ "$OPTARG" =~ "$NatGetal" ]];then
                b="$OPTARG"
            else
                syntax()
            fi
        ;;
        *)
            syntax()
    esac
done
shift $((OPTIND-1))

#error handling

#solution script