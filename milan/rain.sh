

syntax() {
    echo "Syntaxis: stats [-s START] [-e EIND] STAD [FILE]" 1>&2
    exit 1
}

s=0
e=0
while getopts ":s:e:" opt
    do
    case "$opt" in
        s)
        if [[ "$OPTARG" =~ ^[1-9][0-9]* ]];then
            s="$OPTARG"
        else
            echo "stats: ongeldige periode" 1>&2
            exit 3
        fi
        ;;
        e)
        if [[ "$OPTARG" =~ ^[1-9][0-9]* ]];then
            e="$OPTARG"
        else
            echo "stats: ongeldige periode" 1>&2
            exit 3
        fi
        ;;
        ?)
        syntax
        ;;
    esac
done
shift $((OPTIND - 1))
# check number of arguments
if [[ $# -ne 1 && $# -ne 2 ]]
then
    syntax
fi

FILE=${2:-/dev/stdin}
stad=$1
# check if files are readable
if [[ ! -z $(echo "$FILE") ]];then
    if [[ ! -f "$FILE" || ! -r "$FILE" ]]
    then
        echo "$(basename $0): het opgegeven bestand bestaat niet of is niet leesbaar" 1>&2
        exit 2
    fi
fi

if [[ $s -eq 0 ]];then
    s=$(egrep "$stad" $FILE | head -1 | cut -d ',' -f2)
fi
if [[ $e -eq 0 ]];then
    e=$(egrep "$stad" $FILE | tail -1 | cut -d ',' -f2)
fi
if [[ $e -gt $s ]];then
    echo "stats: ongeldige periode" 1>&2
            exit 3
fi

if ! egrep -q "$s" $FILE || ! egrep -q "$e" $FILE ;then
    echo "$(basename $0): geen data voor de opgegeven periode" 1>&2
    exit 4
fi
#Print
egrep "$stad" $FILE | sed -n "/$s/,/$e/p" > newfile.txt
count=$(cat newfile.txt | wc -l)
min=$(cat newfile.txt | sort -t ',' -k3n | head -1 | cut -d ',' -f3)
max=$(cat newfile.txt | sort -t ',' -k3n | tail -1 | cut -d ',' -f3)
echo "CITY: $stad"
echo "COUNT: $count"
echo "MIN: $min"
echo "MAX: $max"
rm newfile.txt