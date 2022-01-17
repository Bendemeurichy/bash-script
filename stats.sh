#!/usr/bin/env bash
#Ben De Meurichy 16/01/2022
#buienradar

#start- en eindtijdstip
s=0
e=0

#getopts
isGetal="^[0-9]*$"

while getopts ":s:e:" opt;do
    case $opt in
        s)
            if [[ "$OPTARG" =~ $isGetal ]];then
                s="$OPTARG"
            else
                echo "stats: ongeldige periode" >&2
                exit 3
            fi
        ;;
        e)
            if [[ "$OPTARG" =~ $isGetal ]];then
                e=$OPTARG
            else
                echo "stats: ongeldige periode" >&2
                exit 3
            fi
            ;;
        *)
            echo "Syntaxis: stats [-s START] [-e EIND] STAD [FILE]" >&2
            exit 1
    esac
done
shift $((OPTIND-1))

#error handling

if [[ "$#" -gt "2" ]] || [[ "$#" -lt 1 ]];then 
    echo "Syntaxis: stats [-s START] [-e EIND] STAD [FILE]" >&2
    exit 1
fi

file=${2:--}

if [[ ! -z "$2" ]];then
    if [[ ! -f "$2" || ! -r "$2" ]];then
        echo "stats: het opgegeven bestand bestaat niet of is niet leesbaar" >&2
        exit 2
    fi
fi

if [[ "$e" -ne 0 && "$s" -ne 0 ]];then
    if [[ "$e" -lt "$s" ]];then
        echo "stats: ongeldige periode" >&2
        exit 3
    fi
fi

#oplossing oef

CityM=$(mktemp)
grep "$1" "$file" >"$CityM"
sort -t"," -k2nr -o "$CityM" "$CityM"

largest=$(cat $CityM|head -n 1|cut -d "," -f2)
smallest=$(cat $CityM|tail -n 1|cut -d "," -f2)

if [[ "$e" -ne 0 && "$s" -ne 0 ]];then
    if [[ "$s" -lt "$smallest" && "$e" -lt "$smallest" ]];then
        echo "stats: geen data voor de opgegeven periode" >&2
        exit 4
    fi
fi

if [[ "$s" -ne 0 ]];then
    if [[ "$s" -gt "$largest" ]];then
        echo "stats: geen data voor de opgegeven periode" >&2
        exit 4
    fi
    sed -i "1,/"$s"/!d" "$CityM"
fi

sort -t"," -k2n -o "$CityM" "$CityM"
if [[ "$e" -ne 0 ]];then
    sed -i "1,/"$e"/!d" $CityM
fi

Count=$(cat "$CityM"|wc -l)
Stad=$1
MIN=$(cat "$CityM"|sort -t "," -k3n|head -n 1|cut -d "," -f 3)
MAX=$(cat "$CityM"|sort -t "," -k3n|tail -n 1|cut -d "," -f 3)
echo "CITY: $Stad"
echo "COUNT: $Count"
echo "MIN: $MIN"
echo "MAX: $MAX"