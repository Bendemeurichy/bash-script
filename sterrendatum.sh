#!/usr/bin/env bash
#Ben De Meurichy 23/12/2021

syntax(){
    echo "Syntaxis: sterrendatum [-n] [-s teken] [jaar [maand [dag]]]" >&2
    exit 1
}

#options
n=0
s=.
while getopts ":ns:" opt;do
    case $opt in
        n)
            n=1
            ;;
        s)
            s=$OPTARG
            ;;
        \?)
            syntax
            ;;
    esac
done

shift $((OPTIND-1))

#error handling

if [[ $# -gt 3 ]];then
    syntax
fi

#date calculating

year=${1:-$(date +"%Y")}
month1=$(echo "${2:-$(date +"%m")}")
day1=$(echo "${3:-$(date +"%d")}")
    
month=$(printf "%02d" $month1)
day=$(printf "%02d" $day1) 

if [[ n -eq 0 ]];then
    if [[ $year =~ ^2 ]];then
        h=$(echo "$year"|cut -c 2)
        echo "$((h+1))${year: -2}$month$s$day"
    else
        echo "${year: -2}$month$s$day"
    fi
else
    dayssince=$(date -d "$year/$month/$day" +"%j"|sed -r 's/0*([0-9]*)/\1/')
    partofyear=$(((($dayssince-1) * 100) / ($(date -d "$year/12/31" "+%j"))))
    if [[ ${#partofyear} -eq 1 ]];then
    echo "$year$s"0"$partofyear"
    else
    echo "$year$s$partofyear"
    fi
fi