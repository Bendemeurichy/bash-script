syntax() {
    echo "Syntax: $(basename $0) [-a <int>] [-b <int>] <int>:<int> <int>:<int>" 1>&2
    exit 1
}
a=0
b=0
while getopts ":a:b:" opt
    do
    case "$opt" in
        a)
        if [[ ! "$OPTARG" =~ ^[1-9][0-9]*$ ]] ;then
                syntax
            fi  
            a="$OPTARG"
            ;;
        b)
        if [[ ! "$OPTARG" =~ ^[1-9][0-9]*$ ]] ;then
                syntax
            fi
            b="$OPTARG" 
            ;;
        *)
        syntax ;;
    esac
done
shift $((OPTIND - 1))

# check number of arguments
if [[ $# -ne 2 ]] ;then
    syntax
fi
# read arguments
if [[ ! "$1" =~ ^[1-9][0-9]*:[1-9][0-9]*$ ]];then
    syntax
fi
if [[ ! "$2" =~ ^[1-9][0-9]*:[1-9][0-9]*$ ]];then
    syntax
fi

r1=$(echo $1 | cut -d ':' -f1)
k1=$(echo $1 | cut -d ':' -f2)
r2=$(echo $2 | cut -d ':' -f1)
k2=$(echo $2 | cut -d ':' -f2)

if [[ "$k1" -eq 0 || "$k2" -eq 0 || "$r1" -eq 0 || "$r2" -eq 0 ]];then
    echo "highlight: bad interval" >&2
    exit 2
fi
if [[ "$r1" -gt "$r2" ]];then
    echo "highlight: bad interval" >&2
    exit 2
elif [[ "$r1" -eq "$r2" ]];then
    if [[ "$k1" -gt "$k2" ]];then
        echo "highlight: bad interval" >&2
        exit 2
    fi
fi

before=$((r1-b))
after=$((r2+a))

if [[ ${before} -lt 1 ]];then
    before=1
fi

i=${before}
sed "${before},${after}!d" | while read line ; do
    if [[ $i -eq $r1  && $r2 -eq $i ]];then
        echo -e $(sed -re "s/^(.{$((k1-1))})/\1\\\\033[1m/g" -e "s/^(.{$((k2+7))})/\1\\\\033[0m/g" <<< $line)
    elif [[ $i -eq $r1 ]] ;then
        echo -e $(sed -re "s/^(.{$((k1-1))})/\1\\\\033[1m/g" <<< $line)
    elif [[ $i -eq $r2 ]];then
        echo -e "$(sed -re "s/(^.{$k2})(.*)/\1\\\\033[0m\2/g" <<< $line)"
    else
        echo $line 
    fi
    i=$((i+1))

done


#sed "${r1},${r2}!d" | sed "s/"
#echo "12345678901234567890" | ./homer.sh 1:5 1:12
#echo -e \033[1mVET\033[0m