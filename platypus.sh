#!/usr/bin/env bash
#Ben De Meurichy 23/12/2021

#syntax error

syntax(){
    echo "Syntax: platypus [file]" >&2
    exit 1
}

bestand=${1:--}

#error handling

if [[ $# -gt 1 ]];then
    syntax
fi

if [[ ! -z $(echo "$1") ]];then
    if [[ ! -f $1 ]] || [[ ! -r $1 ]];then
        echo "platypus: could not read file \"$1\"" >&2
        exit 2
    fi
fi

#solution
touch solution.txt

cat $bestand| while read line;do
    woord=$(echo $line|sed "s/^[^ ]* *\([^ ]*\)$/\1/g")
    teller1=$(echo $line| sed "s/^\([^/][0-9]*\)\/[^/]*/\1/g")
    noemer=$(echo $line|sed "s/^[^/]*\/\([^ ]*\) *[^ ]*$/\1/g")

    if [[ $noemer -ne ${#woord} ]];then
        factor=$(echo "${#woord} / $noemer"|bc)
        teller=$(echo "$teller1 * $factor"|bc)
    else
        teller=$(echo $teller1)
    fi
    if [[ $teller =~ ^-.*$ ]];then
        echo "${woord: $teller}" >>solution.txt
    else
        echo "${woord:0:$teller}" >>solution.txt
    fi
done

cat solution.txt|tr -d "\n"

rm solution.txt