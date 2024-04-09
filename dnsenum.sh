#!/bin/bash
# Strongly inspired by the Trickest scripts, thank you for the great work. I highly recommend your platform.

# Grab a scop file (with all wildcards)

installation () {
	mkdir -p dnstools
	#Install massdns
	git clone https://github.com/blechschmidt/massdns.git dnstools/massdns
	cd dnstools/massdns
	make
	sudo make install
	cd ../..

	#Install puredns
	wget https://github.com/d3mondev/puredns/releases/download/v2.1.1/puredns-Linux-amd64.tgz
	tar zxvf puredns-Linux-amd64.tgz -C ./dnstools
	rm puredns-Linux-amd64.tgz

	#Install resolvers trickest
	git clone https://github.com/trickest/resolvers dnstools/resolvers
	#Install resolvers six2dez
	wget https://raw.githubusercontent.com/six2dez/resolvers_reconftw/main/resolvers.txt
	mv resolvers.txt dnstools/resolvers/resolvers_sid2dez.txt
	#Merge resolvers.txt
	cat ./dnstools/resolvers/res*.txt | anew ./dnstools/resolvers.txt

	#Dowdload dns bruteforce lists
	wget https://localdomain.pw/subdomain-bruteforce-list/all.txt.zip
	unzip all.txt.zip -d dnstools/
	rm all.txt.zip
	wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/combined_subdomains.txt
	mv combined_subdomains.txt dnstools/all2.txt

	#install mksub
	wget https://gist.githubusercontent.com/six2dez/a307a04a222fab5a57466c51e1569acf/raw
	mv raw ./dnstools/mksub_list.txt
	wget https://github.com/trickest/mksub/releases/download/v1.1.1/mksub-1.1.1-linux-amd64.zip
	unzip mksub-1.1.1-linux-amd64.zip
	mv mksub-1.1.1-linux-amd64 ./dnstools/mksub
	rm mksub-1.1.1-linux-amd64.zip

	#install vita
	wget https://github.com/junnlikestea/vita/releases/download/0.1.16/vita-0.1.16-x86_64-unknown-linux-musl.tar.gz
	tar -xvf vita-0.1.16-x86_64-unknown-linux-musl.tar.gz
	mv vita-0.1.16-x86_64-unknown-linux-musl/vita dnstools/
	rm -rf vita-0.1.16-x86_64-unknown-linux-musl*

	#install findomain
	wget https://github.com/Findomain/Findomain/releases/download/9.0.4/findomain-linux.zip
	unzip findomain-linux.zip
	chmod +x findomain
	mv findomain ./dnstools/findomain
	rm findomain-linux.zip

	#install subfinder
	wget https://github.com/projectdiscovery/subfinder/releases/download/v2.6.4/subfinder_2.6.4_linux_amd64.zip
	unzip subfinder_2.6.4_linux_amd64.zip
	mv subfinder ./dnstools/
	rm *.zip

	#install dsieve
	wget https://github.com/trickest/dsieve/releases/download/v1.2.0/dsieve-1.2-linux-amd64.zip
	unzip *.zip
	mv dsieve-1.2-linux-amd64 dnstools/dsieve
	rm dsieve*.zip

	#install alterx
	wget https://raw.githubusercontent.com/projectdiscovery/alterx/main/permutations.yaml
	mv permutations.yaml dnstools/permutations.yaml
	wget https://github.com/projectdiscovery/alterx/releases/download/v0.0.4/alterx_0.0.4_linux_amd64.zip
	unzip alterx*.zip
	mv alterx dnstools/alterx
	rm README.md && rm LICENSE && rm alterx*.zip
}

DIR="./dnstools/"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
	:
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Installation of dnstools"
  installation
fi


mkdir -p output

SECURITYTRAILS="" #use your's

THREADS=200

process () { 
	domain=$1
	mkdir output/$domain
	mkdir output/$domain/dns

  #you can use all.txt instead it's 34M subdomains but very long
	./dnstools/puredns bruteforce ./dnstools/all2.txt $domain --threads $THREADS --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/passive_bruteforce.txt

	./dnstools/vita --all -d $domain > ./output/$domain/dns/passive_vita.txt
	curl --silent --url https://api.securitytrails.com/v1/domain/$domain/subdomains --header "apikey: $SECURITYTRAILS" | jq -r '.subdomains | join(\n)' | sed 's/$/. $domain/' | tee ./output/$domain/dns/passive_securitytrails.txt
	curl -s https://jldc.me/anubis/subdomains/$domain | jq '.[]' | sed 's/"//g' |anew output/$domain/dns/passive_jldc.txt
	./dnstools/subfinder -config /root/.config/subfinder/provider-config.yaml -domain $domain -output output/$domain/dns/passive_subfinder.txt

	./dnstools/mksub -d $domain -w ./dnstools/mksub_list.txt -o ./output/$domain/dns/tmp_mksub_list.txt
	./dnstools/puredns resolve ./output/$domain/dns/tmp_mksub_list.txt $domain --threads $THREADS --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/passive_mksub_dns.txt

	./dnstools/findomain --quiet --config ./dnstools/findomain.config.json --target $domain --unique-output ./output/$domain/dns/passive_findomain.txt

	cat ./output/$domain/dns/passive_* | anew ./output/$domain/dns/passive_dns.txt

	./dnstools/puredns resolve ./output/$domain/dns/passive_dns.txt --threads $THREADS  --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/active_dns.txt

	./dnstools/dsieve -top 300 -if ./output/$domain/dns/active_dns.txt -f 3 -o ./output/$domain/dns/dsieve3.txt
	./dnstools/alterx -config ./dnstools/permutations.yaml -enrich -list ./output/$domain/dns/dsieve3.txt -output ./output/$domain/dns/alterx3.txt

	./dnstools/dsieve -top 300 -if ./output/$domain/dns/active_dns.txt -f 4 -o ./output/$domain/dns/dsieve4.txt
	./dnstools/alterx -config ./dnstools/permutations.yaml -enrich -list ./output/$domain/dns/dsieve4.txt -output ./output/$domain/dns/alterx4.txt

	./dnstools/dsieve -top 300 -if ./output/$domain/dns/active_dns.txt -f 5 -o ./output/$domain/dns/dsieve5.txt
	./dnstools/alterx -config ./dnstools/permutations.yaml -enrich -list ./output/$domain/dns/dsieve5.txt -output ./output/$domain/dns/alterx5.txt

	./dnstools/puredns resolve ./output/$domain/dns/alterx3.txt --threads $THREADS --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/active_dns_2.txt
	./dnstools/puredns resolve ./output/$domain/dns/alterx4.txt --threads $THREADS --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/active_dns_3.txt
	./dnstools/puredns resolve ./output/$domain/dns/alterx5.txt --threads $THREADS --resolvers ./dnstools/resolvers.txt --resolvers-trusted ./dnstools/resolvers/resolvers-trusted.txt -w ./output/$domain/dns/active_dns_4.txt

	cat ./output/$domain/dns/active_dns* | grep ".$domain" | anew ./output/$domain/dns.txt
}

dns=$(cat $1)

for nameserver in $dns
	do
		process "$nameserver"
		wait
	done
