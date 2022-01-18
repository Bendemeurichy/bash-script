#!/bin/bash
#gebruikersnamen
#Thibaud Collyn

syntax() {
    echo "Syntaxis: gebruikersnamen naam -i -m <int> -M <int> [woordenlijst]" >&2
    exit 1
}

opt_i=0
opt_m=0
opt_M=0

while getopts ":im:M:" opt;do
    case $opt in
        i) opt_i=1;;
        m) opt_m=$(($OPTARG-1));;
        M) opt_M=$(($OPTARG+1));;
        *) syntax
    esac
done
shift $(($OPTIND-1))

file=${2:-/dev/stdin}

if [[ $# -lt 1 || $# -gt 2 ]];then
    syntax
elif [[ ! -r $file ]];then
    echo "gebruikersnamen: bestand \"$file\" bestaat niet of is onleesbaar" >&2
    exit 2
fi

pattern=$(echo $1|tr -d " ."|sed "s/./&\?/g")
temp=$(mktemp)

if [[ opt_i -eq 0 ]];then
    egrep "^$pattern$" "$file" > $temp
else
    egrep -i "^$pattern$" "$file" > $temp
fi
if [[ opt_m -ne 0 ]];then
    sed -i "/^\(.\)\{1,$opt_m\}$/Id" $temp
fi
if [[ opt_M -ne 0 ]];then
    sed -i "/^\(.\)\{$opt_M,\}$/Id" $temp
fi
if [[ ! -s $temp ]];then
    echo "gebruikersnamen: geen gebruikersnamen gevonden voor \"$1\"" >&2
    exit 3
fi

cat $temp|sort