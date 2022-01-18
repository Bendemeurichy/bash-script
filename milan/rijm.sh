cat $1 | sed "s/[^A-Za-z ]//g" | sed 's/^[ \t]*//;s/[ \t]*$//g' | sed -re "s/.* //g" | while read line 
do
    if egrep -i -q "^$line.*[1-9]" "$2" ; then
        egrep -i "^$line " "$2" | sed 's/^[ \t]*//;s/[ \t]*$//g' | egrep -io "(( [A-Z]+[1-9][^1-9]*$)|( [A-Z]+$))" | tr -d "[0-9]" | \
        tr -d ' ' >> file.txt
    else
        egrep -i "^$line " "$2" | sed "s/^$line//g" | tr -d ' ' >> file.txt
    fi
done

declare -A seen
declare -a alphabet
alphabet=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
i=0
while read line ; do
    if [ -n "${seen[$line]}" ];then
        echo -n "${seen[$line]}"
    else
        seen[$line]=${alphabet[i]}
        echo -n "${seen[$line]}"
        i=$((i+1))
    fi

done <<< $(cat file.txt)
rm file.txt

