#!/bin/bash
#birthdays
#Thibaud Collyn

opt_a=0
opt_c=7
opt_d=~/.birthdays
opt_h=0
opt_s=0

while getopts ":ac:d:hs" opt;do
    case $opt in
        a) opt_a=1;;
        c) opt_c=$OPTARG;;
        d) opt_d=$OPTARG;;
        h) opt_h=1;;
        s) opt_s=1;;
        *) echo "birthdays [-ahs] [-c <int>] [-d <file>]" >&2
            exit 1
    esac
done
shift $(($OPTIND-1))

if [[ ! -e $opt_d || ! -r $opt_d ]];then
    echo "birthdays: cannot access database '$opt_d'" >&2
    exit 2
fi

date=$(date=$(date '+%Y-%m-%d'))
Udate=$(date -d "$date" +%s)
Umax=$(($Udate+($opt_c*24*60*60)))
year=$(date +"%Y")

temp=$(mktemp)

cat $opt_d|while read line;do
    bday=$(echo "$line"|cut -d" " -f2,3|tr " " "-"|sed "s/^/$year-/")
    Ubday=$(date -d "$bday" "+%s")
    ddmmyyyy=$(echo $bday|sed "s/^\([^-]*\)-\([^-]*\)-\([^-]*\)$/\3\/\2\/\1/")
    name=$(echo $line|sed "s/^[^ ]* [^ ]* [^ ]* \(.*\)$/\1/")
    if [[ $Ubday -ge $Udate && $Ubday -le $Umax ]];then
        byear=$(echo $line|cut -d" " -f1)
        age=$(($year-$byear))
        days=$(((Ubday-Udate)/86400))
        if [[ $opt_a -eq 0 && $opt_h -eq 0 ]];then
            echo "$Ubday $name ($ddmmyyyy)"
        elif [[ $opt_a -eq 1 && $opt_h -eq 0 ]];then
            echo "$Ubday $name (age $age, $ddmmyyyy)"
        elif [[ $opt_a -eq 0 && $opt_h -eq 1 ]];then
            if [[ $Ubday -eq Udate ]];then
                echo "$Ubday $name (today)"
            elif [[ $Ubday -eq $((Udate+86400)) ]];then
                echo "$Ubday $name (tomorrow)"
            else
                echo "$Ubday $name (in $days days)"
            fi
        elif [[ $opt_a -eq 1 && $opt_h -eq 1 ]];then
            if [[ $Ubday -eq Udate ]];then
                echo "$Ubday $name (age $age, today)"
            elif [[ $Ubday -eq $((Udate+86400)) ]];then
                echo "$Ubday $name (age $age, tomorrow)"
            else
                echo "$Ubday $name (age $age, in $days days)"
            fi
        fi
    fi
done > $temp

if [[ $opt_s -eq 1 ]];then
    cat $temp|sort -t" " -k1n|cut -d" " -f2-
else
    cat $temp|cut -d" " -f2-
fi
