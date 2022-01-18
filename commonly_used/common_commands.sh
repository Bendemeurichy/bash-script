sed -i "s/regex/subst/g" inputfile #overwrite input file

echo -n "text" #echo without newline

egrep -v "regex" #grep lines not matching regex

n=$(printf %02d $n) #add leading zeros if var is not 2char wide

sort -o inputfile outputfile #sort whitout writing output to stdout

sed -i "1,/regex/!d" inputfile #delete lines untill pattern 

sed -n "linenumber"p inputfile #print out llinenumber

dirname var #the name of the directory of the var

basenmae var #filename of the var

pwd #name of the current working directory

echo "$(egrep "^(.){$ikleiner}[aouei].*$" length.txt)" > length.txt #grep same input output
