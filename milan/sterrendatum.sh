#! /usr/bin/bash

syntax() {
        echo "Syntaxis: sterrendatum [-n] [-s teken] [jaar [maand [dag]]]" 1>&2
}
n=0
s=.
while getopts ":ns:" opt ; do
        case $opt in
                n)
                    n=1
                    ;;
                s)
                    s=$OPTARG
                    ;;

                \?)
                        syntax
                        exit 1
        esac
done
shift $((OPTIND - 1))

if [ $# -gt 3 ];then
    syntax
    exit 1
fi

# proces dates
jaar=${1:-$(date +"%Y")}
maand=$(printf "%02d" "${2:-$(date +"%m")}")
dag=$(printf "%02d" "${3:-$(date +"%d")}")
datum=$(echo ${jaar}${s}${maand}${s}${dag})

isleap() { 
   year=$1
   (( !(year % 4) && ( year % 100 || !(year % 400) ) )) &&
      echo "leap"
}

if [[ $n -eq 0 ]];then
    if [[ ${jaar:0:1} -gt 1 ]];then
        jaartal=$(echo "${jaar:1:1}+1" | bc) 
         
    fi
    echo $datum | sed -re "s/[0-9][0-9]([0-9][0-9]).(.*)/$jaartal\1\2/g"   
else
    aantaldagen=$(date -d "$(echo $datum | tr "${s}" "-")" +'%j' | sed "s/^0//" | sed "s/$/-1/g" | bc )
    totaaldagen=365
    checkleap=$(isleap $jaar)
    if [[ "$checkleap" == "leap" ]];then
        totaaldagen=366
    fi
    xx=$(((aantaldagen * 100)/totaaldagen))
    xx=$(printf "%02d" $xx)
    echo "${jaar}${s}${xx}"
fi


