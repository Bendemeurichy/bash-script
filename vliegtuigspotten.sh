#!/usr/bin/env bash
#Ben De Meurichy 17/12/2021

#3rd file or stdin
bestand=${3:--}

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
    case "$opt" in
        n)
            if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
                n=$OPTARG
            else
                syntax
            fi
        ;;
        d)
            if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
                d=$OPTARG
            else
                syntax
            fi
        ;;
        c)
            c=1
        ;;
        \?)
            syntax
    esac
done

shift $((OPTIND-1))

#error handling

if [[ ! $1 =~ ^[+-]?1?[0-8]?[0-9].?[0-9]*$ ]] || [[ ! $2 =~ ^[+-]?[1-9]?[0-9].?[0-9]*$ ]];then
    echo "airplanes: invalid coordinates" >&2
    exit 2
fi

if [[ -e $3 ]];then
    if [[ ! -r $3 || ! -f $3 ]];then
    echo "airplanes: cannot acces '$3'" >&2
    exit 3
    fi
fi

#distance and files
cat $bestand|python3 distance $1 $2 >total.txt

cat total.txt|cut -d ";" -f 18 >distance.txt
cat total.txt|cut -d ";" -f 2 >callsign.txt
cat total.txt|cut -d ";" -f 3 >country.txt

if [[ $c -eq 1 && $d -ne 0 && $n -ne 0 ]];then
    cat distance.txt|while read line;do
        if [[ $line -le $b ]];then
            sed -i -n "$inc"p distance.txt
            sed -i -n "$inc"p callsign.txt
            sed -i -n "$inc"p country.txt
        fi
    done
    paste -d " " callsign.txt country.txt distance.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/\([^ ]*)\)/(\1/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1|head -n "$n"

elif [[ $c -eq 1 && $d -ne 0 ]];then
    cat distance.txt|while read line;do
        if [[ $line -le $b ]];then
            sed -i -n "$inc"p distance.txt
            sed -i -n "$inc"p callsign.txt
            sed -i -n "$inc"p country.txt
        fi
    done
    paste -d " " callsign.txt country.txt distance.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/\([^ ]*)\)/(\1/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1

elif [[ $c -eq 1 && $n -ne 0 ]];then
    paste -d " " callsign.txt country.txt distance.txt >temp.txt
    sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
    sed -i "s/\([^ ]*)\)/(\1/g" temp.txt
    cat temp.txt|sort -t ":" -k2n -k1|head -n "$n"
elif [[ $d -ne 0 && $n -ne 0 ]];then
    cat distance.txt|while read line;do
        if [[ $line -le $b ]];then
            sed -i -n "$inc"p distance.txt
            sed -i -n "$inc"p callsign.txt
            sed -i -n "$inc"p country.txt
        fi
    done
    paste -d " " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1|head -n "$n"
elif [[ $c -eq 1 ]];then
    paste -d " " callsign.txt country.txt distance.txt >temp.txt
        sed -i "s/ \([0-9]*\)$/): \1 km/g" temp.txt
        sed -i "s/\([^ ]*)\)/(\1/g" temp.txt
        cat temp.txt|sort -t ":" -k2n -k1

elif [[ $d -ne 0 ]];then
     cat distance.txt|while read line;do
        if [[ $line -le $b ]];then
            sed -i -n "$inc"p distance.txt
            sed -i -n "$inc"p callsign.txt
            sed -i -n "$inc"p country.txt
        fi
    done
    paste -d ": " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1|head -n "$n"
elif [[ $n -ne 0 ]];then
    paste -d " " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1|head -n "$n"
else
    paste -d " " callsign.txt distance.txt >temp.txt
    cat temp.txt|sed "s/ \([0-9]*\)$/: \1 km/g"|sort -t ":" -k2n -k1
fi

rm temp.txt
rm distance.txt
rm total.txt
rm callsign.txt
rm country.txt