#!/usr/bin/env bash
#Ben De Meurichy 23/12/2021

syntax(){
    echo "Syntax: christmas [-m] [-n integer] [-s integer] FILE" >&2
}

#options
n=1
s=$(echo "15")
m=0
while getopts ":n:s:m" opt;do
    case $opt in
        n)
            if [[ $OPTARG =~ ^[1-9][0-9]*$ ]];then
                n=$OPTARG
            else
                syntax
                exit 2
            fi
            ;;
        m)
            m=1
            ;;
        s)
            if [[ $OPTARG =~ ^[1-9][0-9]*$ ]];then
                s=$OPTARG
            else
                syntax
                exit 3
            fi
            ;;
        \?)
            syntax
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

#error handling

if [[ $# -ne 1 ]];then
    syntax
    exit 4
fi

#search

file=$(echo $1|sed "s/^.*\/\([^/]*\)$/\1/g")

fdir=$(echo $1|sed "s/\(.*\)\/[^/]*$/\1/g")

if [[ ! -d $fdir ]] || [[ ! -e $fdir ]];then
    exit 0
else
    cd $fdir
fi

if [[ ! -f $file ]];then
    exit 0
fi


g=0
touch asci.txt
search(){
    header=$(sed -n 1p "$file")
    key1=$(echo $header|cut -d " " -f 1)
    key2=$(echo $header|cut -d " " -f 2)
    key3=$(echo $header|cut -d " " -f 3)
    
    
    if [[ $key1 == "print" ]];then
        for ((i=0; i<$n; i++));do
            sed -n $((i+2))p "$file" >> asci.txt
        done
    fi

    if [[ $key2 =~ ^[0-9]*$ ]];then
    
        for ((k=0; k < $key2; k++)); do
            dir=$(pwd)
            parentdir=$(dirname "$dir") #https://koenwoortman.com/bash-script-get-current-directory/
            if [[ ! -d $parentdir ]] || [[ ! -e $parentdir ]];then
                g=$(echo $s)

            else
                mv asci.txt "$parentdir"
                cd $parentdir
            fi
        done
    else
        if [[ ! -d $key2 ]];then
            g=$s
        else
            mv asci.txt $key2
            cd $key2
        fi
    fi

    if [[ ! -f $key3 ]] || [[ ! -r $key3 ]];then
        g=$s
    else
    file=$key3
    fi


i=1
k=0
}


while [[ $g -le $s ]];do
    search
    g=$((++g))
done

cat asci.txt|while read line;do
    if [[ m -eq 1 ]];then
        echo "$line"|rev
    else
        echo "$line"
    fi
done

rm asci.txt