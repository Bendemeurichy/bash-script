#! usr/bin/bash

syntax() {
        echo "Syntaxis: covid [-d DATUM] [-p] PLAATS [FILE]" 1>&2
}
d=0
p=0

while getopts ":d:p" opt ; do
        case $opt in
                p)
                        p=1 ;;
                d)
                        if [[ $OPTARG =~ ^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$ ]] ; then
                                d=$OPTARG
                        else
                                echo "covid: ongeldige datum" 1>&2
                                exit 3
                        fi ;;
                \?)
                        syntax
                        exit 1
        esac
done
shift $((OPTIND - 1))

FILE=${2:-/dev/stdin}

if [[ $# -ne 1 && $# -ne 2 ]];then
    syntax
    exit 1
fi

if [[ ! -f $FILE || ! -r $FILE ]];then
    echo "covid: het opgegeven bestand bestaat niet of is niet leesbaar" 1>&2
    exit 2
fi

if [[ $d -eq 0 ]];then
    d=$(cat $FILE | tail -1 | cut -d ',' -f1)
    
fi

if ! egrep -q "$d" $FILE || ! egrep -q "$1" $FILE ;then
    echo "covid: geen data voor de opgegeven periode" 1>&2
    exit 4
fi
regio=$1

# berekeken opnames
#date #-begindag #einddag
opnamesf () {

    begindatum=$(date --date="${1} $2 day" +%Y-%m-%d)
    einddatum=$(date --date="${1} $3 day" +%Y-%m-%d)
    opnames=$(egrep "$regio" $FILE | sed -n "/$begindatum/,/$einddatum/p"| egrep -v "$einddatum" | \
    cut -d "," -f4 | tr '\n' '+' | sed "s/+$/\n/g" | bc)
    echo "$opnames"
}
# berekeken opnames laatste 7 dagen
opnames1=$(opnamesf "$d" "-6" "+1") 
# berekeken opnames eerste 7 dagen
opnames2=$(opnamesf "$d" "-20" "-13")
#Hospitalisatietrend bereken
trend=$(echo "scale=2 ; ($opnames1 / $opnames2 - 1)*100" | bc)

if [[ $p -eq 0 ]];then
    echo "REGIO    : $regio"
else
    echo "PROVINCIE: $regio"
fi
    echo "DATUM    : $d"
    echo "OPNAMES  : $opnames1"
if [[ $opnames1 -gt $opnames2 ]];then
    trend=$(echo $trend | sed -re "s/^-*(.*)/+\1% (stijgend)/")
else
    trend=$(echo $trend | sed -re "s/-*(.*)/-\1% (dalend)/")
fi

if [[ -z $opnames1  || -z $opnames2 ]];then
    echo "TREND    : onbepaald"
else
    echo "TREND    : $trend"
fi

