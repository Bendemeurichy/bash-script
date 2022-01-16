#!/usr/bin/env bash

#Ben De Meurichy 16/12/2021

#standaard syntax error

syntax() {

    echo "Syntaxis: format [-w breedte] [-u|-l] FASTA" >&2

}

#opties

u=0
l=0
w=80
while getopts ":uw:l" opt; do
    case $opt in
        u)
            u=1
            ;;
        l)
            l=1
            ;;
        w)
            if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
                w=$OPTARG
            else
                syntax
                exit 3
            fi
            ;;
        \?)
            syntax
            exit 1
    esac
done

shift $((OPTIND-1))

#error handling

if [[ $u -eq 1 && $l -eq 1 ]];then
    syntax
    exit 2
fi

if [[ ! $# -eq 1 ]] || [[ ! -f $1 || ! -r $1 ]];then
    syntax
    exit 4
fi

#verwerking tekst

cat $1 |tr -d "[ \n]" | sed "s/\(>seq\)/\n\1/g"|sed "s/\(>seq[0-9]*\)/\1\n/g"|sed -r '/^\s*$/d'|sed "s/\(.\{$w\}\)/\1\n/g" >temp.txt

if [ $u -eq 1 ];then
    cat temp.txt |tr "a-z" "A-Z" >final.txt
    sed -i "s/SEQ/seq/g" final.txt
    cat final.txt
    rm final.txt
elif [ $l -eq 1 ];then
    cat temp.txt |tr "A-Z" "a-z"
else
    cat temp.txt
fi

rm temp.txt

