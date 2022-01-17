#!/bin/bash
#Packet assembler
#Thibaud Collyn

opt_m=0
opt_p=0

#option handeling
while getopts ":m:p" opt;do
    case $opt in
        m) opt_m=$OPTARG;;
        p) opt_p=1;;
        \?) echo "Syntaxis: assembler [-p] [-m ID] FILE" >&2
            exit 1
    esac
done
shift $(($OPTIND-1))

if [[ $# -ne 1 ]];then
    echo "Syntaxis: assembler [-p] [-m ID] FILE" >&2
    exit 1
elif [[ ! -r $1 || ! -f $1 ]];then
    echo "assembler: onbestaand of onleesbaar bestand \"$1\"" >&2
    exit 2
fi

touch temp.txt
touch codes.txt
touch message.txt

if [[ $opt_m -eq 0 ]];then
    cat $1|tr "\t" ";"|cut -d";" -f1,3|sort -t";" -k1n|uniq -c|sed "s/^ *//g"|tr " " ";" > temp.txt
    if [[ $opt_p -eq 0 ]];then
        while read line;do
            echo "$line"|sed "s/^\([0-9]*\);\([0-9]*\);\([0-9]*\)$/\2: \1\/\3/"
        done < temp.txt
    else
        while read line;do
            frac=$(echo $line|cut -d";" -f1,3|tr ";" "/"|bc -l)
            percentage=$(printf %0.2f $(echo "$frac*100"|bc))
            start=$(echo "$line"|sed "s/^\([0-9]*\);\([0-9]*\);\([0-9]*\)$/\2: \1\/\3/")
            echo "$start ($percentage%)"
        done < temp.txt
    fi
else
    #Checks if opt_m exists in the input file
    cat $1|cut -d$'\t' -f1|sort -n|uniq > codes.txt
    c=0
    while read line;do
        if [[ $opt_m -eq $line ]];then
            c=1
        fi
    done < codes.txt
    if [[ $c -eq 0 ]];then
        echo "assembler: boodschap $opt_m is onbekend" >&2
        exit 3
    fi
    #Checks if the packages actually are complete
    egrep "^$opt_m" $1 > message.txt
    l=$(wc -l < message.txt)
    tot_pack=$(head -1 message.txt|cut -d$'\t' -f3)
    if [[ $l -ne $tot_pack ]];then
        echo "assembler: boodschap $opt_m is onvolledig" >&2
        exit 3
    elif [[ opt_p -eq 0 ]];then
        cat message.txt|sort -t$'\t' -k2n|cut -d$'\t' -f4
    elif [[ opt_p -eq 1 ]];then
        cat message.txt|sort -t$'\t' -k2n|cut -d$'\t' -f2,4|sed "s/^\([0-9]*\)\t/\1\. /g"
    fi
fi

rm temp.txt
rm codes.txt
rm message.txt
