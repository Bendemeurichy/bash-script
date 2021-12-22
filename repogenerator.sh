#!/usr/bin/env bash
#Ben De Meurichy 22/12/2021

syntax(){
    echo "Syntaxis: repogen [-b <string>] [-c <integer>] [-m] dirname" >&2
    exit 1
}

#options
c=3
b=master
m=0

while getopts ":c:b:m" opt;do 
case $opt in
    c)
        if [[ $OPTARG =~ ^[0-9]*$ ]];then
            c=$OPTARG
        else
            syntax
        fi
            ;;
    b)
        if [[ -z $OPTARG ]];then
            syntax
        else
            b=$OPTARG
        fi
            ;;
    m)
        m=1
        ;;
    \?)
        syntax
        ;;
    esac
done
shift $((OPTIND-1))

#error handling
if [[ -e $1 ]] && [[ -d $1 ]];then
    echo "repogen: bestandsnaam bestaat reeds" >&2
    exit 2
fi

if [[ $# -ne 1 ]];then
    syntax
fi

#make repo
reponame=$1

git init -q $reponame
cd $reponame
touch README.md
git add README.md
git commit --quiet -m  "initial commit"
if [[ ! $b = "master" ]];then
git checkout -q -b "$b"
fi

for ((i = 1 ; i <= "$c" ;i++));do
    wget -q -O message.txt "http://whatthecommit.com/index.txt"
    message=$(cat message.txt|head -n 1)
    echo "$i) $message" >>README.md
    git add .
    git commit --quiet -m "$message"
    rm message.txt
done

if [[ $m -eq 1 ]];then
    git checkout -q master
    git merge -q $b
fi