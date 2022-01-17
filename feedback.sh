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
filesnotfound=$(mktemp)

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
echo $totnum


<<v
tr "\n" " " <$studentfiles >$temp2
sed -i "s/ $//g" "$temp2"
files=$(cat $temp2)
pddfunite $files "$studentname".pdf
v