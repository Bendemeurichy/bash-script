syntax() {
    echo "$(basename $0) [-ahs] [-c <int>] [-d <file>]" 1>&2
    exit 1
}

a=0
d=${HOME}/computergebruikUgent/milan/.birthdays
s=0
c=7
h=0
while getopts ":ac:d:hs" opt
    do
    case "$opt" in
        a)
        a=1
        ;;
        c)
        if [[ ! "$OPTARG" =~ ^[1-9][0-9]*$ ]]
        then
            syntax 
        else
            c="$OPTARG"
        fi
        ;;
        d)
            if [[ ! -f "$OPTARG" || ! -r "$OPTARG" ]];then
                echo "birthdays: cannot access database 'unknown'" 1>&2
                exit 2
            else
                d="${OPTARG}"
            fi
            ;;
        h)
            h=1
        ;;
        s)
            s=1
        ;;
        ?)
        syntax
        ;;
    esac
done
shift $((OPTIND - 1))
# check number of arguments
if [[ ! -z $(echo "$d") ]];then
    if [[ ! -f "$d" || ! -r "$d" ]]
    then
        echo "$(basename $0): bestand \"$d\" bestaat niet of is onleesbaar" 1>&2
        exit 2
    fi
fi

c=$((c*86400))
current_date=$(date '+%s')
einddatum=$((current_date+${c}))

cat $d | while read line ; do
    convert=$(echo $line | sed -re "s/([0-9][0-9][0-9][0-9]) ([0-9]?[0-9]) ([0-9]?[0-9]).*/2022-\2-\3/g")
    datum=$(date -d "${convert}" "+%s")
    if [[ ${datum} -ge ${current_date} && ${datum} -lt ${einddatum} ]];then
        if [[ $a -eq 1 ]];then
            getage=$(echo "$line" | sed -re "s/([0-9][0-9][0-9][0-9]) ([0-9]?[0-9]) ([0-9]?[0-9]).*/\1-\2-\3/g")
            sec=$(date -d "${getage}" "+%s")
            age=$((((current_date-sec)/31556952)+1))
            stringage=$(echo "age ${age}, ")
        fi
        if [[ $h -eq 0 ]];then
            echo "$line" | sed -re "s/([0-9][0-9][0-9][0-9]) ([0-9]?[0-9]) ([0-9]?[0-9]) (.*)/\4 (${stringage}\3\/\2\/2022)/g"
        else
            days=$((((datum-current_date)/86400)+1))
            echo "$line" | sed -re "s/([0-9][0-9][0-9][0-9]) ([0-9]?[0-9]) ([0-9]?[0-9]) (.*)/\4 (${stringage}in ${days} days)/g"
        fi
    fi
done >> file.txt

if [[ $s -eq 1 ]];then
    cat file.txt | sed -re "s/([a-z]) ([^0-9])/\1#\2/Ig" | sort -t ' ' -k4nr | sed -re "s/#/ /g"
fi
cat file.txt
