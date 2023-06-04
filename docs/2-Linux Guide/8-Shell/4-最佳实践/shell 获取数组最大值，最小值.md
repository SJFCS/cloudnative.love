```bash
declare -a indexlist
indexlist=(1610553600 1610208000 1610121600 1610467200 1610294400 1610380800)
minDate=${indexlist[0]}
for i in ${indexlist[@]};do 
    if [[ ${minDate} -gt $i ]];then 
         minDate=$i
    fi 
done 
 
 
maxDate=${indexlist[0]}
for i in ${indexlist[@]};do 
    if [[ ${minDate} -lt $i ]];then 
         maxDate=$i
    fi 
done 
```