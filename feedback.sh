#!/usr/bin/env bash
#Ben De Meurichy 16/01/2022
#https://dodona.ugent.be/nl/courses/186/series/2083/activities/235452497/#

studentname=$1
answers=$2

#error handling if file is not found

pdfseparate "$answers" answers%d.pdf

temp=$(mktemp)
temp2=$(mktemp)
studentfiles=$(mktemp)
studentpdf=$(mktemp)
pagenumbers=$(mktemp)
missingfiles=$(mktemp)

find . -name "answers*.pdf" >$temp
sort -Vo "$temp" "$temp"
fileAmount=$(cat "$temp"|wc -l)

for ((i= 1 ;i<="$fileAmount";i++));do
    pdftotext answers"$i".pdf answers"$i".txt
done
shaStudent=$(echo "$studentname"|shasum|sed "s/ -$//g")

egrep -rwl "$shaStudent" . >$studentfiles
first=$(head -n 1 $studentfiles)
totnum=$(head -n 1 $first|cut -d "/" -f 2)
filesnum=$(cat "$studentfiles"| wc -l)

if [[ ! -s "$studentfiles" ]];then
    echo "feedback: geen pagina's gevonden" >&2
    exit 1
elif [[ "$filesnum" -ne "$totnum" ]];then
    k=1
    cat $studentfiles|while read line;do
        cat "$line"|head -n 1| cut -d " " -f 3|cut -d "/" -f 1|sed "s/^ //g" 
    done >>$pagenumbers
fi

seq $totnum >seqnum.txt
grep -Fxvf "$pagenumbers" seqnum.txt >$missingfiles

cat $missingfiles|while read line;do
    echo "feedback: pagina "$line"/"$totnum" niet gevonden" >&2
done

cat $studentfiles|while read line;do
    pdfName=$(echo "$line"|sed "s/.txt/.pdf/g")
    find . -path "$pdfName"
done >>$studentpdf

tr "\n" " " <$studentpdf >$temp2
sed -i "s/ $//g" "$temp2"
files=$(cat $temp2)

pdfunite $files "$studentname".pdf

rm answers*
rm seqnum.txt