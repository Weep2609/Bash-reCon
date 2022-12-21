#!/bin/bash
# This script written by weep2609

############################
# Notes:
# Beginner
############################

option=$1
domain=$2

passive() {
	
	echo ""
	echo "#################### Subdomain enumeration ####################"
	echo ""
	echo "Passive enumeration"
	echo "[+] Starting findomain..."
	local findomain=$(./Tools/findomain -t $domain -u $domain/raw-sub.txt)
	echo "[-] Found $(cat ./$domain/raw-sub.txt | wc -l) subdomain"
	
	
	echo "[+] Extracting sub-domains to crt.sh from certificates..."
	local crt=$(curl -s "https://crt.sh/?q=%25.$domain" | grep -oE "[\.a-zA-Z0-9-]+\.$domain" | sort -u | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $crt subdomain"
	
	
	echo "[+] Extracting sub-domains to rapiddns from certificates..."
	local rapidDNS=$(curl -s "https://rapiddns.io/subdomain/$domain?full=1" | grep -oE "[\.a-zA-Z0-9-]+\.$domain" | sort -u | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $rapidDNS subdomain"
	
	
	echo "[+] Starting assetfinder..."
	local assetfinder=$(assetfinder --subs-only $domain | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $assetfinder subdomain"
	
	
	echo "[+] Starting subfinder..."
	local subfinder=$(./Tools/subfinder -d $domain -silent | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $subfinder subdomain"
	
	
	echo "[+] Extracting sub-domain from jldc free api"
	local jldc=$(curl https://jldc.me/anubis/subdomains/$domain | jq -r ".[]" | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $jldc subdomain"	
	
	
	echo "[+] Starting gau..."
	local gau=$(./Tools/gau --subs $domain | cut -d "/" -f 3 | sort -u | ./Tools/anew $domain/raw-sub.txt | wc -l)
	echo "[-] Found $gau subdomain"
	
	
	local total=$(cat ./$domain/raw-sub.txt | sort -u | wc -l)
	echo ""
	echo "..............................."
	echo "Total of all subdomains: $total"
	echo "..............................."
}

active() {
	echo ""
	echo "Active enumeration"
	echo ""
	./Tools/massdns/scripts/subbrute.py ./Lists-DNS/subdomains-top1million-110000.txt $domain \
	| ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -w ./$domain/massdns_output.txt
	
	sub=$(sed 's/A.*//' ./$domain/massdns_output.txt | sed 's/CN.*//' | sed 's/\..$//' | ./Tools/anew $domain/raw-sub.txt | wc -l)
	
	#Third lever subdomains
	for domain in $(cat ./$domain/raw-sub.txt | grep -P "(\.[\w-]+){3}$" | rev | cut -d '.' -f 3,2,1 | rev | sort -u)
	do
		echo ""
		echo "*********************************************************"
		echo "[+] Starting massdns with $domain ..." 
		echo "*********************************************************"
		echo ""
		./Tools/massdns/scripts/subbrute.py ./Lists-DNS/subdomains-top1million-110000.txt $domain \
		| ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -w ./$domain/Third_subdomains.txt
		
		third=$(sed 's/A.*//' ./$domain/Third_subdomains.txt | sed 's/CN.*//' | sed 's/\..$//' | ./Tools/anew $domain/raw-sub.txt | wc -l)
	done
	
	#Fourth lever subdomains
	for domain in $(cat ./$domain/raw-sub.txt | grep -P "(\.[\w-]+){4}$" | rev | cut -d '.' -f 4,3,2,1 | rev | sort -u)
	do
		echo ""
		echo "*********************************************************"
		echo "[+] Starting massdns with $domain ..." 
		echo "*********************************************************"
		echo ""
		./Tools/massdns/scripts/subbrute.py ./Lists-DNS/subdomains-top1million-110000.txt $domain \
		| ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -w ./$domain/Fourth_subdomains.txt
		
		fourth=$(sed 's/A.*//' ./$domain/Fourth_subdomains.txt | sed 's/CN.*//' | sed 's/\..$//' | ./Tools/anew $domain/raw-sub.txt | wc - l)
	done
	
	#Fifth lever subdomains
	for domain in $(cat ./$domain/raw-sub.txt | grep -P "(\.[\w-]+){5}$" | rev | cut -d '.' -f 5,4,3,2,1 | rev | sort -u)
	do
		echo ""
		echo "*********************************************************"
		echo "[+] Starting massdns with $domain ..." 
		echo "*********************************************************"
		echo ""
		./Tools/massdns/scripts/subbrute.py ./Lists-DNS/subdomains-top1million-110000.txt $domain \
		| ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -w ./$domain/Fifth_subdomains.txt
		
		fifth=$(sed 's/A.*//' ./$domain/Fifth_subdomains.txt | sed 's/CN.*//' | sed 's/\..$//' | ./Tools/anew $domain/raw-sub.txt | wc -l)
	done
	echo "**********************************************"
	echo " [+] Found subdomains from brute force: $sub"
	echo " [+] Found third lever subdomains: $third"	
	echo " [+] Found fourth lever subdomains: $fourth"
	echo " [+] Found fifth lever subdomains: $fifth"
	echo "**********************************************"
}


permutations() {
	echo ""
	echo "[+] Starting domains/subdomains generate permutations with dnsgen..."
	echo ""
	./Tools/dnsgen -w ./Lists-DNS/permutations_lists.txt ./$domain/raw-sub.txt \
	| ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -w permutations_output.txt
	permutations=$(sed 's/A.*//' ./$domain/permutations_subdomains.txt | sed 's/CN.*//' | sed 's/\..$//' | ./Tools/anew $domain/raw-sub.txt | wc -l)
	
	echo "#####################################################"
	echo "[+] Found subdomains from permutations: $permutations"
	echo "#####################################################"
}


main() {
if [ -z "$domain" ]; then
   	echo "Usage:   ./subtool.sh [option] [domain]"
   	echo "Example: ./subtool.sh --passive tesla.com"
   	echo ""
   	echo "OPTION:"
   	echo "-pA,     --passive            Find subdomains from crt.sh, findomain, assetfinder, jldc, findomain, rappiddns" 
   	echo "-ac,     --active             Find subdomains by Brute force with massdns (third lever, fourth lever, fifth lever subdomain)"
   	echo "-pE,     --permutations       Find subdomains by generate permutations with dnsgen"
   	echo "-a,      --all                Auto find subdomains (passive > active > permutations)"
   	echo ""
   	echo "NOTE:"
   	echo "********* THE STEP-BY-STEP GUIDE *********"
   	echo ""
   	echo "Step 1: Run passive enumeration subdomains"
   	echo "Step 2: Run active enumeration subdomains"
   	echo "Step 3: Subdomains generate permutations"
   	exit 1
else
	echo "Target: $domain"
	
fi

if [ ! -d "$domain" ]; then
	mkdir ./$domain
fi

case "$option" in
	"-pA"|"--passive")
		passive $domain
		exit 0
		;;
	"-ac"|"--active")
		active $domain
		exit 0
		;;
	"-pE"|"--permutations")
		permutations $domain
		exit 0
		;;
	"-a"|"--all")
		passive $domain
		active $domain
		permutations $domain
		exit 0
		;;
esac

}
main $domain


