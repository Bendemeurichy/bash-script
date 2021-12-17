#https://dodona.ugent.be/nl/courses/809/series/9152/activities/236678563/#
#!/bin/bash
#Ben De Meurichy 9/12/2021

#opties
touch opties.txt
while getopts ":cd:t" opt; do
  case $opt in
    c  ) # verwerk optie -c
        echo "c" >>opties.txt
         ;;
    d  ) # verwerk optie -d
if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
	echo "d" >>opties.txt
	drempel=$(echo $OPTARG)
else
	echo "coronalert: ongeldige drempelwaarde" >&2
    exit 2
    
fi
         # $OPTARG bevat argument van optie 
         ;;
    t  ) # verwerk optie -t
        echo "t" >>opties.txt
         ;;
    \? ) echo "Syntaxis: coronalert [-d <drempelwaarde>] [-t] [-c] <naam> <userdir> <tokendir>" >&2
         exit 1
  esac
done

shift $((OPTIND-1))

#error handling
path=$(echo "$2/$1.txt")

if [[ $# -ne 3 ]];then
echo "Syntaxis: coronalert [-d <drempelwaarde>] [-t] [-c] <naam> <userdir> <tokendir>" >&2
exit 1
elif [[ ! -d $2 || ! -d $3 ]];then
echo "coronalert: ongeldig pad" >&2
exit 3
elif [[ ! -f "$path" ]];then
echo "coronalert: de opgegeven naam is niet gevonden" >&2
exit 4
fi

#zoeken van risicocontacten

cat "$path" >sleutels.txt

cat sleutels.txt|while read line;do
find $3 -type f -name $line >> keys.txt
done

touch namen.txt
cat keys.txt|sort|uniq|while read line;do
cat $line >>namen.txt
done

cat namen.txt|sort|uniq -c|tr -d "[ \t]"|sed "s/^\([0-9]\+\)[A-Z][a-z]*$/\1/g" >repeats.txt

cat namen.txt|sort|uniq|sed "s/ *//g">namen2.txt

cat namen2.txt|while read line;do
touch besmettingen.txt
cat keys.txt|while read file;do
egrep -l "$line" $file >>besmettingen.txt
done

besmetting=$(cat besmettingen.txt|sed "s/ *$//g"|sed "s/^.*\/\([^/]*\)$/\1/g")
echo $besmetting
rm besmettingen.txt
done >risicokeys.txt

cat risicokeys.txt|sed "s/ \+/,/g" >risicokeys2.txt


cat risicokeys2.txt|while read line; do 
    tr , $'\n' < <(printf -- "%s" "$line") | sort | tr $'\n' , | sed "s/,$/\n/";
done >sortedrisicokeys.txt
cat sortedrisicokeys.txt|sed "s/,/, /g" >sortedkeys.txt

#minstens 3 contacten
inc=1
touch risico.txt
touch drempelkeys.txt
touch drempelrepeats.txt
cat repeats.txt|while read line;do
        if [[ "$line" -ge "3" ]];then
            sed -n "$inc"p namen2.txt >>risico.txt
            sed -n "$inc"p sortedkeys.txt >>drempelkeys.txt
            sed -n "$inc"p repeats.txt >>drempelrepeats.txt
        fi
        inc=$((++inc))
    done

#resultaat met opties


touch result.txt
touch temp.txt
increment=1
if [ $(grep -c "d" opties.txt) -eq 1 ] && [ $(grep -c "c" opties.txt) -eq 1 ] && [ $(grep -c "t" opties.txt) -eq 1 ];then
    paste -d " " namen2.txt repeats.txt sortedkeys.txt >>temp.txt
    cat repeats.txt|while read line;do
        if [[ "$line" -ge "$drempel" ]];then
            sed -n "$increment"p temp.txt >>result.txt
        fi
        increment=$((++increment))
    done
    sed -i "s/^\([A-Z][a-z]*\) \([0-9]*\) \(.*\)$/\1 (\2): \3/g" result.txt
    cat result.txt
    rm temp.txt

elif [ $(grep -c "d" opties.txt) -eq 1 ] && [ $(grep -c "c" opties.txt) -eq 1 ];then
     paste -d " " namen2.txt repeats.txt >>temp.txt
    cat repeats.txt|while read line;do
        if [[ "$line" -ge "$drempel" ]];then
            sed -n "$increment"p temp.txt >>result.txt
        fi
        increment=$((++increment))
    done
    sed -i "s/^\([A-Z][a-z]*\) \([0-9]*\)$/\1 (\2)/g" result.txt
    cat result.txt
    rm temp.txt

elif [ $(grep -c "d" opties.txt) -eq 1 ] && [ $(grep -c "t" opties.txt) -eq 1 ];then
     paste -d " " namen2.txt sortedkeys.txt >>temp.txt
    cat repeats.txt|while read line;do
        if [[ "$line" -ge "$drempel" ]];then
            sed -n "$increment"p temp.txt >>result.txt
        fi
        increment=$((++increment))
    done
    sed -i "s/^\([A-Z][a-z]*\) \(.*\)$/\1: \3/g" result.txt
    cat result.txt
    rm temp.txt

elif [ $(grep -c "t" opties.txt) -eq 1 ] && [ $(grep -c "c" opties.txt) -eq 1 ];then
    paste -d " " risico.txt drempelrepeats.txt drempelkeys.txt >result.txt
    sed -i "s/^\([A-Z][a-z]*\) \([0-9]*\) \(.*\)$/\1 (\2): \3/g" result.txt
    cat result.txt

elif [ $(grep -c "c" opties.txt) -eq 1 ];then
    paste -d " " risico.txt drempelrepeats.txt >result.txt
    sed -i "s/^\([A-Z][a-z]*\) \([0-9]*\)$/\1 (\2)/g" result.txt
    cat result.txt

elif [ $(grep -c "t" opties.txt) -eq 1 ];then
    paste -d " " risico.txt drempelkeys.txt >result.txt
    sed -i "s/^\([A-Z][a-z]*\) \(.*\)$/\1: \2/g" result.txt
    cat result.txt

elif [ $(grep -c "d" opties.txt) -eq 1 ];then
    
    cat repeats.txt|while read line;do
        if [[ "$line" -ge "$drempel" ]];then
            sed -n "$increment"p namen2.txt >>result.txt
        fi
        increment=$((++increment))
    done
    cat result.txt

else
    cat risico.txt
fi

rm drempelrepeats.txt
rm drempelkeys.txt
rm risico.txt
rm result.txt
rm sortedrisicokeys.txt
rm risicokeys.txt
rm risicokeys2.txt
rm repeats.txt
rm keys.txt
rm sleutels.txt
rm namen.txt
rm namen2.txt
rm opties.txt