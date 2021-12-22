#!/usr/bin/env bash
#Ben De Meurichy 22/12/2021

syntax(){
    echo "Syntaxis: covid [-d DATUM] [-p] PLAATS [FILE]" >&2
    exit 1
}

d=0
p=0
while getopts ":pd:" opt; do
    case $opt in
        d)
            if [[ -z $OPTARG ]];then
                syntax
            elif [[ ! $OPTARG =~ ^20[0-2][0-9]-[01][0-9]-[0-3][0-9]$ ]];then
                echo "covid: ongeldige datum" >&2
                exit 3
            else
                d="$OPTARG"
            fi
        ;;
        p)
            p=1
        ;;
        \?)
            syntax
        ;;
    esac
done

shift $((OPTIND-1))

#error handling

if [[ ! -z $(echo $2) ]];then
    if [[ ! -r $2 ]] || [[ ! -f $2 ]];then
        echo "covid: het opgegeven bestand bestaat niet of is niet leesbaar" >&2
        exit 2
    fi

elif [[ $# -gt 2 ]] || [[ $# -lt 1 ]];then
    syntax

fi

#solution
bestand=${2:--}
touch regio.txt

plaats=$(echo $1)

#option p

if [[ p -eq 1 ]];then
    touch provincie.txt
    cut --complement -d "," -f3 $bestand >provincie.txt
        egrep ".*$plaats.*" provincie.txt >>provincie2.txt
        cat provincie2.txt|cut --complement -d "," -f2|sed "s/,/ /g" >regio.txt
    rm provincie.txt
else
    touch gewest.txt
    touch gewest2.txt
    cut --complement -d "," -f2 $bestand >gewest.txt
        egrep ".*$plaats.*" gewest.txt >>gewest2.txt
        awk -F "," '{a[$1]+=$3} END {for (i in a) print i,a[i]}' gewest2.txt >regio.txt
    rm gewest.txt
fi

sed -i "/^$/d" regio.txt
#region not found
if [[ ! -s regio.txt ]] || [[ $(grep -c "$d" regio.txt) -eq 0 ]];then
    echo "covid: geen data voor de opgegeven periode" >&2
    exit 4
fi

#option d

    if [[ $d -eq 0 ]]; then
        tail -21 regio.txt > date21.txt
    else
        line=$(grep -n "$d" regio.txt | cut -d ':' -f1)
        head -n $line regio.txt | tail -21 > date21.txt
        cat date21.txt|head -n 7 >begin.txt
        cat date21.txt|tail -n 7 >einde.txt
    fi
    sort -g date21.txt >final.txt
    
    cat final.txt|head -n 7 >begin.txt
    cat final.txt|tail -n 7 >einde.txt

p1=$(cat begin.txt|cut -d " " -f 2|sed "s/.*/& + /g"|tr -d "\n"|sed "s/ + $//g")
p2=$(cat einde.txt|cut -d " " -f 2|sed "s/.*/& + /g"|tr -d "\n"|sed "s/ + $//g")
noemer=$(echo "$p1"|bc)
teller=$(echo "$p2"|bc)

if [[ $(cat final.txt|wc -l) -lt 21 ]];then
    rtrend=$(echo "onbepaald")
else
trend1=$(echo "(($teller / $noemer) - 1)*100"|bc -l)

if [[ $trend1 =~ ^- ]]; then
trend=$(echo "$trend1" | cut -b 1,2)
roundtrend=$(echo $trend1 | awk '{print int($1-0.50)}')
rtrend=$(echo "$roundtrend" | bc | cut -b 1,2,3| sed "s%$%.00\% (dalend)%g")
else
rtrend=$(echo "$trend1" |cut -b 1,2,3|sed "s%^%+%g" | sed "s%$%00\% (stijgend)%g")
fi
fi

if [[ p -eq 1 ]];then
    echo "PROVINCIE: $plaats"
else
    echo "REGIO    : $plaats"
fi
echo "DATUM    : $(cat final.txt|tail -n 1|cut -d " " -f 1)"
echo "OPNAMES  : $teller"
if [[ $rtrend =~ ^-[0-9]* ]];then
    echo "TREND    : $rtrend"
elif [[ $rtrend = "onbepaald" ]];then
    echo "TREND    : $rtrend"
else
    echo "TREND    : $rtrend"
fi

rm *.txt