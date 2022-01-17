syntax() {
    echo "Syntaxis: assembler [-p] [-m ID] FILE" 1>&2
    exit 1
}
m=0
p=0
while getopts ":m:p" opt
    do
    case "$opt" in
        p)
        p=1 ;;
        m)
        if [[ ! "$OPTARG" =~ ^[1-9][0-9]*$ ]] ;then
                syntax
            fi  
            m="$OPTARG" ;;
        \?)
        syntax ;;
    esac
done
shift $((OPTIND - 1))
# read arguments
FILE=$1
# check number of arguments
if [[ $# -ne 1 ]] ;then
    syntax
fi
# check if files are readable
if [[ ! -f $FILE || ! -r $FILE ]] ;then
    echo "assembler: onbestaand of onleesbaar bestand \"$FILE\"" 1>&2
    exit 2
fi
# check if code in file
if ! egrep -q "$m" $FILE ;then
    echo "assembler: boodschap ${m} is onbekend" 1>&2
    exit 3
fi

if [[ $m -eq 0 ]];then
    codes=$(cat $FILE | cut -f1,3 | sort -u)
        while read line
        do
            pakketten=$(echo $line| cut -d ' ' -f2)
            code=$(echo $line | cut -d ' ' -f1)
            stand=$(egrep "$code" "$FILE" | wc -l)
            
            if [[ $p -eq  1 ]];then
                percent=$(printf "%.2f\n" $(bc -l <<< "($stand / $pakketten)*100"))
                percent=$(echo " (${percent}%)")
            fi
            echo "${code}: ${stand}/${pakketten}${percent}"
        done <<< "${codes}"
else
    #check if code received all "packets"
    pakketten1=$(egrep "$m" $FILE| cut -f3 | head -1)
    stand1=$(egrep "$m" $FILE | cut -f1 | wc -l)
    if [[ "$stand1" -ne "$pakketten1" ]];then
        echo "assembler: boodschap ${m} is onvolledig" 1>&2
        exit 3
    fi
    
    if [[ $p -eq 1 ]];then
        egrep "$m" $FILE | cut -f2,4 | tr '\t' '.' | sort -n| sed -re 's/^([0-9]*\.)/\1 /g'
    else
        cat $FILE | egrep "$m" | sort -nk2 | cut -f4
    fi
fi
exit 0
    
  

