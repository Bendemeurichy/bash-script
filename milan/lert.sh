syntax() {
    echo "Syntaxis: $(basename $0) [-d <drempelwaarde>] [-t] [-c] <naam> <userdir> <tokendir>" 1>&2
    exit 1
}

d=3
t=0
c=0
while getopts ":d:tc" opt
    do
    case "$opt" in
        t)
        t=1
        ;;
        c)
        c=1
        ;;
        d)
        d="$OPTARG"
        ;;
        ?)
        syntax
        ;;
    esac
done
shift $((OPTIND - 1))
# check number of arguments
if [[ $# -ne 3 ]]
then
    syntax
fi

positief="$1"
userdir="$2"
tokendir="$3"
# check threshold
if [[ ! "$d" =~ ^[1-9][0-9]*$ ]]
then
    echo "$(basename $0): ongeldige drempelwaarde" 1>&2
    exit 2
fi
# check if directories are readable
if [[ ! -d "${userdir}" || ! -d "${tokendir}" ]]
then
    echo "$(basename $0): ongeldig pad" 1>&2
    exit 3
fi
# check if user exists
if [ ! -r "${userdir}/${username}.txt" ]
then
    echo "$(basename $0): de opgegeven naam is niet gevonden" 1>&2
    exit 4
fi

positief=$1
userdir=$2
tokendir=$3

usertokens=$(find ./$userdir -type f -name "$positief.txt")
cat $usertokens | while read line
    do
        tFILE=$(find ./$tokendir -type f -name "*$line*")
            cat $tFILE | while read line2
            do
                echo $line2 $line >> tokens.txt
            done
    done
cat tokens.txt | sort | cut -d ' ' -f1 | uniq | while read line ; do
    temp=$(cat tokens.txt | sort | egrep "$line" | tr -d '\n' | sed "s/$line//g" | sed -re "s/^.(.*)/\1/" |sed "s/ /, /g")
    wc=$(echo $temp | wc -w)
    if [[ $wc -ge $d ]]; then
    
        if [[ $t -eq 1 && $c -eq 1 ]];then
            echo $line \($wc\): $temp
        elif [[ $t -eq 1 ]];then
            echo ${line}: $temp
        elif [[ $c -eq 1 ]];then
            echo $line \($wc\)
        else
            echo $line
        fi
    fi
done
rm tokens.txt



