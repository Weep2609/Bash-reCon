#!/bin/bash
# This script written by weep2609

############################
# Notes:
# ./Tools/gau --subs domain.com | cut -d "/" -f 3 | sort -u
# amass enum -active -brute -d domain.com
# ./Tools/SubDomainizer/SubDomainizer.py -u https://domain.com | grep domain.com
# curl -s -I -L "https://twitter.com/" | grep -Ei '^Content-Security-Policy:' | sed "s/;/;\\n/g" | grep "twitter.com"
############################




passive() {
	echo "Target: $1"
	echo ""
	echo "#################### step 1: Subdomain enumeration ####################"
	echo ""
	echo "Passive enumeration"
	echo "[+] Starting findomain..."
	local findomain=$(./Tools/findomain -t $1 -u $1/raw-sub.txt | wc -l)
	echo "[-] Found $findomain subdomain"
	
	
	echo "[+] Extracting sub-domains to crt.sh from certificates..."
	local crt=$(curl -s "https://crt.sh/?q=%25.$1" | grep -oE "[\.a-zA-Z0-9-]+\.$1" | sort -u | ./Tools/anew $1/raw-sub.txt | wc -l)
	echo "[-] Found $crt subdomain"
	
	
	echo "[+] Extracting sub-domains to rapiddns from certificates..."
	local rapidDNS=$(curl -s "https://rapiddns.io/subdomain/$1?full=1" | grep -oE "[\.a-zA-Z0-9-]+\.$1" | sort -u | ./Tools/anew $1/raw-sub.txt | wc -l)
	echo "[-] Found $rapidDNS subdomain"
	
	
	echo "[+] Starting assetfinder..."
	local assetfinder=$(assetfinder --subs-only $1 | ./Tools/anew $1/raw-sub.txt | wc -l)
	echo "[-] Found $assetfinder subdomain"
	
	
	echo "[+] Starting subfinder..."
	local subfinder=$(./Tools/subfinder -d odesli.co -silent | ./Tools/anew $1/raw-sub.txt | wc -l)
	echo "[-] Found $subfinder subdomain"
	
	
	echo "[+] Extracting sub-domain from jldc free api"
	local jldc=$(curl https://jldc.me/anubis/subdomains/$1 | jq -r ".[]" | ./Tools/anew $1/raw-sub.txt | wc -l)
	echo "[-] Found $jldc subdomain"	
	
	
	
	local total=$(cat ./$1/raw-sub.txt | sort -u | wc -l)
	echo ""
	echo "..............................."
	echo "Total of all subdomains: $total"
	echo "..............................."
}

active() {
	echo "Active enumeration"
	
}

alive() {
	echo ""
	echo "#################### step 2: find alive hosts ####################"
	echo ""
	echo "[+] Probing for live hosts..."
	echo "[+] Starting httprobe..."
	cat ./$1/raw-sub.txt | sort -u | ./Tools/httprobe -c 50 -t 3000 >> ./$1/alive.txt
	url=$(cat ./$1/alive.txt | wc -l)
	echo ""
	echo "..............................."
	echo "Total of alive hosts: $url"	
	echo "..............................."
}


main() {
if [ -z "$1" ]; then
   	echo "Usage:   ./subtool.sh domain"
   	echo "Example: ./subtool.sh tesla.com" 
   	exit 1
else
	mkdir ./$1
fi

passive $1
alive $1
}
main $1



