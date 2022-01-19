#!/usr/bin/env bash
#Ben De MEurichy
#!/usr/bin/env bash

syntax(){
    echo "Syntax: spotify-code [-b <color>] [-f <color>] [-l] ID" >&2
    exit 1
}

#options
b="black"
f="white"
l=0

while getopts ":b:f:l" opt;do
    case "$opt" in
        b)
        b="$OPTARG"
        ;;
        f)
        f="$OPTARG"
        ;;
        l)
        l=1
        ;;
        *)
            syntax
    esac
done
shift $((OPTIND-1))

#error handling
if [[ $# -ne 1 ]];then
    echo "Syntax: spotify-code [-b <color>] [-f <color>] [-l] ID" >&2
    exit 2
fi

if [[ ! "$1" =~ ^0[0-7]{10}7[0-7]{10}0$ ]];then
    echo "Syntax: spotify-code [-b <color>] [-f <color>] [-l] ID" >&2
    exit 3
fi 
#solution script

if [[ "$l" -eq 1 ]];then
    echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"420\" height=\"110\" version=\"1.1\">"
    echo "<rect width=\"420\" height=\"110\" fill=\"$b\" rx=\"10\" />"
else
    echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"360\" height=\"110\" version=\"1.1\">"
    echo "<rect width=\"360\" height=\"110\" fill=\"$b\" rx=\"10\" />"
fi

temp=$(mktemp)
echo "$1" |sed "s/./&\n/g" >$temp

for ((i=0; i<23;i++));do
    ci=$(sed -n "$((i+1))"p "$temp")
    h=$((20+10*ci))
    x=$((10+15*i))
    y=$(((110-h)/2))

    echo "<rect width=\"10\" height=\"$h\" x=\"$x\" y=\"$y\" fill=\"$f\" rx=\"5\" />"
done
if [[ $l -eq 1 ]];then
echo "<circle cx=\"385\" cy=\"55\" r=\"25\" fill=\"$f\" />"
echo "<polygon points=\"375,70 400,55 375,40\" fill=\"$b\" />"
fi
echo "</svg>"
