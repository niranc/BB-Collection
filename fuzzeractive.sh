#!/bin/bash
echo "[i] working with webservers.txt file : "$1" using usseragent "$2

mkdir -p $(pwd)/output
mkdir -p $(pwd)/output/ffuf
mkdir -p $(pwd)/"output/ffuf/ffuf_http:"
mkdir -p $(pwd)/"output/ffuf/ffuf_https:"


process_webservers () {
	file=$(cat $(pwd)/$1)
	nb_lines=$(cat $(pwd)/$1|wc -l)
	
	############################################
	#Determine nombre de thread pour traiter tous les webservers
	MAXPARA=9
	for ((i=MAXPARA; i>=1; i--))
	do
		#echo "i:"$i
		div=$(($nb_lines % $i))
		if [ "$div" -eq "0" ]; then
			echo "[+] Use "$i" threads in parallel";
			MAXPARA=$i
			break;
		fi
	done
	#echo "final: maxparallel:"$MAXPARA
	#############################################
	
	
	index=0
	for webserver in $file
	do
		((i=i%MAXPARA)); ((i++==0)) && wait
		echo "[$index/$nb_lines] Launching fuff with "$webserver" as a webserver and "$2" as a user agent"
		ffuf -r -w /data/OneListForAll-2.4.1.1/onelistforallmicro.txt -u $webserver/FUZZ -H "$2" -o ./output/ffuf/ffuf_$webserver -fw 1,0 -noninteractive -s -sa -t 20 &
		index=$(($index+1))
	done
}
process_webservers "$1" "$2"

#ffuf webserver usergent
