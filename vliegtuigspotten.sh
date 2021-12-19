#!/usr/bin/env bash
#Ben De Meurichy 17/12/2021

#standard syntax error
syntax(){
    echo "Syntaxis: airplanes [-n <integer>] [-d <integer>] [-c] longitude latitude [file]" >&2
    exit 1
}

#options
n=0
d=0
c=0
while getopts ":cn:d:" opt; do
case "${opt}" in
    n) # verwerk optie n
        if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
            n=$(echo "$OPTARG")
        else
            syntax
        fi
        ;;
    d) # verwerk optie d
        if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
            d=$(echo "$OPTARG")
        else 
            syntax
        fi
        ;;
    c) # verwerk optie c
        c=1
        ;;
    \?) 
        syntax
        ;;
esac
done

shift $((OPTIND-1))

#error handling
if [[ $# -lt 2 ]] || [[ $# -gt 3 ]];then
    syntax
fi

if [[ ! $1 =~ ^[+-]?1?[0-7]?[0-9].?[0-9]*$ ]] || [[ ! $2 =~ ^[+-]?[1-9]?[0-9].?[0-9]*$ ]];then
    echo "airplanes: invalid coordinates" >&2
    exit 2
fi

if [[ ! -z $(echo "$3") ]];then
    if [[ ! -r $3 ]] || [[ ! -f $3 ]];then
    echo "airplanes: cannot access '$3'" >&2
    exit 3
    fi
fi

touch distance.txt
touch callsign.txt
touch country.txt

#distance and files
#3rd file or stdin

bestand=${3:--}
cat $bestand|python3 distance $1 $2 >total.txt

cat total.txt|cut -d ";" -f 18 >distance1.txt
cat total.txt|cut -d ";" -f 2 >callsign1.txt
cat total.txt|cut -d ";" -f 3 >country1.txt
inc=1

if [[ $c -eq 1 && $d -ne 0 && $n -ne 0 ]];then
    cat distance1.txt|while read line;do
        if [[ $line -le $(echo $d) ]];then
            sed -n "$inc"p distance1.txt >>distance.txt
            sed -n "$inc"p callsign1.txt >>callsign.txt
            sed -n "$inc"p country1.txt >>country.txt
        fi
        inc=$((inc+1))
    done

    paste -d " " callsign.txt country.txt distance.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/^\([^ ]* \+\)\(.*)\)/\1(\2/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1|head -n "$n"

elif [[ $c -eq 1 && $d -ne 0 ]];then
    cat distance1.txt|while read line;do
        if [[ $(echo "$line") -le $(echo $d) ]];then
            sed -n "$inc"p distance1.txt >>distance.txt
            sed -n "$inc"p callsign1.txt >>callsign.txt
            sed -n "$inc"p country1.txt >>country.txt

        fi
        inc=$((inc+1))
    done

    paste -d " " callsign.txt country.txt distance.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/^\([^ ]* \+\)\(.*)\)/\1(\2/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1

elif [[ $c -eq 1 && $n -ne 0 ]];then
    paste -d " " callsign1.txt country1.txt distance1.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/^\([^ ]* \+\)\(.*)\)/\1(\2/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1|head -n "$n"
elif [[ $d -ne 0 && $n -ne 0 ]];then
    cat distance1.txt|while read line;do
        if [[ $line -le $(echo $d) ]];then
            sed -n "$inc"p distance1.txt >>distance.txt
            sed -n "$inc"p callsign1.txt >>callsign.txt
            sed -n "$inc"p country1.txt >>country.txt
        fi
        inc=$((inc+1))
    done
    paste -d " " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1|head -n "$n"
elif [[ $c -eq 1 ]];then
    paste -d " " callsign1.txt country1.txt distance1.txt >temp.txt
        sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
        sed -i "s/^\([^ ]* \+\)\(.*)\)/\1(\2/g" temp.txt
        cat temp.txt|sort -t ":" -k2n -k1

elif [[ $d -ne 0 ]];then
     cat distance1.txt|while read line;do
        if [[ $line -le $(echo $d) ]];then
            sed -n "$inc"p distance1.txt >>distance.txt
            sed -n "$inc"p callsign1.txt >>callsign.txt
            sed -n "$inc"p country1.txt >>country.txt
        fi
        inc=$((inc+1))
    done
    paste -d " " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1
elif [[ $n -ne 0 ]];then
    paste -d " " callsign1.txt distance1.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1|head -n "$n"
else
    paste -d " " callsign1.txt distance1.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1

fi

rm temp.txt
rm distance1.txt
rm total.txt
rm callsign1.txt
rm country1.txt
rm country.txt
rm callsign.txt
rm distance.txt