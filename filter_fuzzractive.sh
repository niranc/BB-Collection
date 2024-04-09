#!/bin/bash

for file in $(find ./|grep ffuf_http |grep -v "_tmp\|_final\|_list")
do
	cat $file |jq -r '.results | .[]| "\(.url),\(.status),\(.words),\(.redirectlocation)"'| anew ${file}_tmp
	rm $file
	cat ${file}_tmp |cut -d"," -f3|anew ${file}_list
	MAX_OCCURENCE=3
	for number in $(cat ${file}_list)
	do
		ACT_OCCURENCE=$(cat ${file}_tmp|grep $number|wc -l)
		if [ "$MAX_OCCURENCE" -gt "$ACT_OCCURENCE" ]; then
		    cat ${file}_tmp|grep $number|cut -d "," -f1|anew ${file}_final
		fi
	done	
done
