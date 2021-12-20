#!/usr/bin/env bash
#Ben De Meurichy 16/12/2021

#standard syntax error

syntax() {
    echo "Syntax: track [-b <int>] [-h <char>] [-n] FILE FRAME" >&2
}

#round

round() {
  echo $(printf %.0f $(echo "($1 + 0.5)/1" | bc))
}

#line function

repeat (){
    echo -n "$1"
    for ((i=0 ; i<$3 ; i++));do
        echo -n "$2"
    done
}

#options

b=20
h=$(echo "@")
n=0

while getopts ":b:h:n" opt; do
    case $opt in
        b)
            if [[ $OPTARG =~ ^[+-]?[1-9][0-9]*$ ]];then
                b=$((OPTARG+2))
            else
                syntax
                exit 2
            fi
            ;;
        h)
            if [[ $OPTARG =~ ^[^0-9]$ ]]; then
                h=$(echo "$OPTARG")
            else
                syntax
                exit 3
            fi
            ;;
        n)
            n=1
            ;;
        \?)
            syntax
            exit 1
    esac
done

shift $((OPTIND-1))

#error handling

if [[ $# -ne 2 ]];then
    syntax
    exit 1

elif [[ ! -f $1 || ! -r $1 ]];then
    syntax
    exit 4

elif [[ ! $2 =~ ^[+-]?[0-9][1-9]*$ ]] && [[ $2 -gt $(cat $1|wc -l) ]];then
    syntax
    exit 5

fi

#frame

frame=$(echo $2)

cat $1|tr "\t" " "| cut -d " " -f 1 --complement >atletes.txt
runners=$(cat atletes.txt|head -1|wc -w)

length=$(cat $1|tail -n 1|tr "\t" " "|cut -d " " -f 2)

#lichaam
houding=$((frame%3))

if [[ $houding -eq 0 ]];then
    hoofd=$(printf " $h/")
    lichaam=$(printf "/| ")
    benen=$(printf "/ \\")

elif [[ $houding -eq 1 ]];then
    hoofd=$(printf " $h ")
    lichaam=$(echo "-|-")
    benen=$(printf " | ")

elif [[ $houding -eq 2 ]];then
    hoofd=$(printf "\\$h ")
    lichaam=$(printf " |\\")
    benen=$(printf "/ \\")
fi

#print

echo "Runners: $runners, Length: $length, Frame: $frame"
repeat "+" "---+" "$b"
echo""

for ((k = 1 ; k <= $runners ; k++)); do

afstand=$(cat atletes.txt|sed -n "$((frame+1))"p|cut -d " " -f $k)
pos=$(echo "($b - 1)*($afstand/$length) "|bc -l)
blok=$(round $pos)


if [[ blok -eq 0 ]];then

    repeat "|$hoofd|" "   |" "$((b-2))"
    echo "###|"
    repeat "|$lichaam|" "   |" "$((b-2))"
    if [[ $n -eq 1 ]];then
        echo "#"$k"#|"
    else
        echo "###|"
    fi
    repeat "|$benen|" "   |" "$((b-2))"
    echo "###|"

elif [[ blok -eq $((b-1)) ]];then

    repeat "|###|" "   |" "$((b-2))"
    echo "$hoofd|"
    
    if [[ $n -eq 1 ]];then
        repeat "|#"$k"#|" "   |" "$((b-2))"
    else
        repeat "|###|" "   |" "$((b-2))"
    fi
    echo "$lichaam|"
    repeat "|###|" "   |" "$((b-2))"
    echo "$benen|"

else
    
    repeat "|###|" "   |" "$((blok-1))"
    repeat "$hoofd|" "   |" "$((b-blok-2))"
    echo "###|"
    if [[ $n -eq 1 ]];then
        repeat "|#"$k"#|" "   |" "$((blok-1))"
        repeat "$lichaam|" "   |" "$((b-blok-2))"
        echo "#"$k"#|"
    else
        repeat "|###|" "   |" "$((blok-1))"
        repeat "$lichaam|" "   |" "$((b-blok-2))"
        echo "###|"
    fi 

    repeat "|###|" "   |" "$((blok-1))"
    echo -n "$benen|"
    repeat "" "   |" "$((b-blok-2))"
    echo "###|"

fi

repeat "+" "---+" "$b"
echo ""
done

rm atletes.txt