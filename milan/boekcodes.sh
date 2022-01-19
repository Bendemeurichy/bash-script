hardlink=$0
padnaam=$1
if [[ "$hardlink" == "boekcodes.sh" ]];then
    while read line 
        do
            FILE=$(echo $line | cut -d ':' -f1)
            lineindex=$(echo $line | cut -d ':' -f2)
            wordindex=$(echo $line | cut -d ':' -f3)
            word=$(find $1 -type f -name "$FILE" -exec cat {} \; | sed -n ${lineindex}p | sed "s/^ *//g"| cut -d ' ' -f${wordindex})
            echo -n "$word " >> file.txt      
        done <<< $(cat $2)
        cat file.txt | sed "s/ $//"
        rm file.txt
else
    shift
    echo $@ | sed "s/ /\n/g" | while read line
    do 
        line=$(echo $line | sed 's/[]$*.\^()|+?{}\[]/\\&/g')
        format=$(egrep -nR " $line " books | head -1 | sed "s/.*\///g" | tr -s ' ')
        file=$(echo "$format" | sed -re "s/^(([^:]*:)+).*/\1/g")
        woord=$(echo "$format" | sed -re "s/^(([^:]*:)+)(.*)/\3/g"|sed -re "s/("$line")(.*)/\1/g" | wc -w)
        echo "${file}${woord}"
    done
fi