omgekeerd () {
     reverse=$(echo $1 | rev | tr 'AGTC' 'TCAG')
    echo "$reverse"
}
seq="$2"
seqlen=${#seq}
paling=""
langstePalindroom () {
    for (( i=0; i < ${seqlen}; i++)); do
        for (( j=1 ; j <= $((seqlen-i)) ; j++));do
            woord=${seq:$i:$j}
            reverse=$(omgekeerd $woord)
            if [[ "$reverse" == "$woord" ]];then
                if [[ ${#woord} -gt ${#paling} ]];then
                    paling=$woord
                fi
            fi
        done
    done
    echo $paling
}

if [[ "$1" == "omgekeerd" ]];then
    omgekeerd $2
elif [[ "$1" == "langstePalindroom" ]];then
    langstePalindroom $2
else
    echo "Ongeldige functie" 1>&2
    exit 1
fi


