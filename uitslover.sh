
#! /bin/bash
panic(){
  echo $1 >&2; exit $2
}
Check_Base_Case(){
  if [[ ! $1 -eq 0 ]];then
      panic "Syntaxis: uitslover -EGOT" 1
  fi
}
E="0";G="0";O="0";T="0"
while getopts ":EGOT" opt; do
case ${opt} in
  E ) # process option e
      Check_Base_Case $E
      E="1"
    ;;
  G ) # process option g
      Check_Base_Case $G
      G="1"
    ;;
  O ) # process option o
      Check_Base_Case $O
      O="1"
    ;;
  T ) # process option t
      Check_Base_Case $T
      T="1"
    ;;
  * ) #process error's
      panic "Syntaxis: uitslover -EGOT" 1
    ;;
esac
done
shift $((OPTIND - 1)) #shift naar eerste niet optie argument
if [[ ! $# -eq 0 ]];then
  panic "Syntaxis: uitslover -EGOT" 1
fi
if [[ $((E+G+O+T)) -lt 2 ]];then
  panic "uitslover: minder dan twee awards opgegeven" 2
fi
#cat emmy.txt|sort -t$'\t' -k1,1 > emmys.txt
#cat grammy.txt|sort -t$'\t' -k1,1 > grammys.txt
#cat oscar.txt|sort -t$'\t' -k1,1 > oscars.txt
#cat tony.txt|sort -t$'\t' -k1,1 > tonys.txt
#join -1 1 -2 1 -3 1 -4 1 -t$'\t' <(sort emmy.txt) <(sort grammy.txt) <(sort oscar.txt) <(sort tony.txt)
echo "NAAM ACTEUR    EMMY" >> emmyhead.txt
echo "===========    ====" >> emmyhead.txt
cat emmy.txt >> emmyhead.txt
echo "NAAM ACTEUR    GRAMMY" >> grammyhead.txt
echo "===========    ======" >> grammyhead.txt
cat grammy.txt >> grammyhead.txt
echo "NAAM ACTEUR    OSCAR" >> oscarhead.txt
echo "===========    =====" >> oscarhead.txt
cat oscar.txt >> oscarhead.txt
echo "NAAM ACTEUR    TONY" >> tonyhead.txt
echo "===========    ====" >> tonyhead.txt
cat tony.txt >> tonyhead.txt
cat emmy.txt|cut -d$'\t' -f1 >> namen
cat grammy.txt|cut -d$'\t' -f1 >> namen
cat oscar.txt|cut -d$'\t' -f1 >> namen
cat tony.txt|cut -d$'\t' -f1 >> namen
echo "NAAM ACTEUR" >> namen6
echo "===========" >> namen6
cat namen|sort|uniq >> namen6

if [[ $E -eq 1 ]];then
join -1 1 -2 1 -t$'\t' <(sort namen6) <(sort emmyhead.txt) >namen2
else
cat namen6 > namen2
fi
if [[ $G -eq 1 ]];then
join -1 1 -2 1 -t$'\t' <(sort namen2) <(sort grammyhead.txt) >namen3
else
cat namen2 > namen3
fi
if [[ $O -eq 1 ]];then
join -1 1 -2 1 -t$'\t' <(sort namen3) <(sort oscarhead.txt) >namen4
else
cat namen3 > namen4
fi
if [[ $T -eq 1 ]];then
join -1 1 -2 1 -t$'\t' <(sort namen4) <(sort tonyhead.txt) >namen5
else
cat namen4 > namen5
fi
#cat namen5
var=$(grep -n "NAAM ACTEUR" namen5|sed "s/:.*//")
awk -v x=$var 'NR==0||NR==x' namen5; awk -v x=$var 'NR>=1 && NR!=x' namen5
rm emmyhead.txt grammyhead.txt oscarhead.txt tonyhead.txt namen namen6