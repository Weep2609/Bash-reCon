#!/bin/bash

red="\e[1;31m"
yellow="\e[1;33m"
cyan="\e[1;36m"
green="\e[1;32m"
end="\e[0m"
pwd=$(pwd)

option() {
	echo -e $red"\n	  /(__M__)\\"
	echo -e $red"	 /, ,   , ,\\"
	echo -e $red"	/' ' 'V' ' '\\"  
	printf $cyan"\nUsage:\n"$end 
	printf $yellow"\t./batsub.sh "
	printf $red"-d or -l "$end
	printf $yellow"<single/list> "$end
	printf $red"-o "$end
	printf $yellow"<output> "$end
	printf $red"-s "$end
	printf $red"-r \n"$end
	
	printf $yellow"\t./batsub.sh "
	printf $red"-d "$end
	printf $yellow"<target> "$end
	printf $red"-o "$end
	printf $yellow"<output> "$end
	printf $red"-w "$end
	printf $yellow"<wordlist> "$end
	printf $red"-b\n\n"$end
	
	printf $red"-h	"
	printf $green"Show the program usage\n\n"$end
	printf $cyan"Options:\n\n"$end
	printf $red"-d	"$end
	printf $green"Single target\n"$end
	printf $red"-l	"$end	
	printf $green"List target\n"$end
	printf $red"-w	"$end	
	printf $green"Wordlist for brute force\n"$end
	printf $red"-o	"$end
	printf $green"Output\n"$end
	printf $red"-s	"$end
	printf $green"Get subdomain by findomain, assetfinder, subfinder\n"$end
	printf $red"-r	"$end
	printf $green"Recursive subdomain (find deep more)\n"$end
	printf $red"-b	"$end
	printf $green"Brute force subdomain\n"$end

}

sub() {
	if [ -n "$list" ]; then
		printf $cyan"Target:\n"$end
		printf $red"\n$(cat $list)\n"$end
		printf "$yellow\n- - - - - Starting findomain... - - - - -\n$end"
		./Tools/findomain -f $list -q | ./Tools/anew $out
		printf "$yellow\n- - - - - Starting assetfinder... - - - - -\n\n$end"
		cat $list | ./Tools/assetfinder --subs-only | ./Tools/anew $out
		printf "$yellow\n- - - - - Starting subfinder... - - - - -\n\n$end"
		./Tools/subfinder -dL $list -silent | ./Tools/anew $out
		printf $yellow"\nDone!\n"$end
		printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
		printf "$cyan\nFound $end" 
		printf "$red$(cat $out| wc -l)$end"
		printf "$cyan subdomain$end"
		printf "$cyan\nOutput saved to $end"
		printf "$red$pwd/$out$end"
		printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
	elif [ -n "$domain" ]; then
		printf $cyan"Target:\n"$end
		printf $red"\t$domain\n"$end
		printf "$yellow\n- - - - - Starting findomain... - - - - -\n$end"
		./Tools/findomain -t $domain -q | ./Tools/anew $out
		printf "$yellow\n- - - - - Starting assetfinder... - - - - -\n\n$end"
		echo $domain | ./Tools/assetfinder --subs-only | ./Tools/anew $out
		printf "$yellow\n- - - - - Starting subfinder... - - - - -\n\n$end"
		./Tools/subfinder -d $domain -silent | ./Tools/anew $out
		printf $yellow"\nDone!\n"$end
		printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
		printf "$cyan\nFound $end" 
		printf "$red$(cat $out| wc -l)$end"
		printf "$cyan subdomain$end"
		printf "$cyan\nOutput saved to $end"
		printf "$red$pwd/$out$end"
		printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
	fi
}

recursive() {
	rec=$(cat $out | rev | cut -d '.' -f 3,2,1 | rev | sort \
| uniq -c | sort -nr | grep -v '1 ' | head -n 10 && cat $out \
| rev | cut -d '.' -f 4,3,2,1 | rev | sort | uniq -c | sort -nr | grep -v '1 ' | head -n 10)
	printf $yellow"\n\n- - - - - Find recursive subdomains - - - - -"$end
	printf $cyan"\n$rec\n\n"$end
	for i in $( (cat $out | rev | cut -d '.' -f 3,2,1 | rev | sort \
| uniq -c | sort -nr | grep -v '1 ' | head -n 10 && cat $out \
| rev | cut -d '.' -f 4,3,2,1 | rev | sort | uniq -c | sort -nr | grep -v '1 ' | head -n 10) | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f2)
	do
		./Tools/findomain -t $i -q | ./Tools/anew $out
		echo $i | ./Tools/assetfinder --subs-only | ./Tools/anew $out
		./Tools/subfinder -d $i -silent | ./Tools/anew $out
	done
	printf $yellow"\nDone!\n"$end
	printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
	printf "$cyan\nFound $end" 
	printf "$red$(cat $out| wc -l)$end"
	printf "$cyan subdomain$end"
	printf "$cyan\nOutput saved to $end"
	printf "$red$pwd/$out$end"
	printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
}

brute() {
	if [ -z $wordlist ]; then
		echo -e $cyan"\nError. Missing wordlist file to brute file"$end
		printf $cyan"Please use -h option to show the program usage message!"$end
		exit 0
	fi
	printf $cyan"\nTarget: "$end
	printf $red"$domain\n"$end
	printf $cyan"Wordlist: "
	printf $red"$wordlist\n"$end
	printf $yellow"\n- - - - - Starting massdns - - - - -\n\n"$end
	./Tools/massdns/scripts/subbrute.py $wordlist $domain | ./Tools/massdns/bin/massdns -r ./Tools/massdns/lists/resolvers.txt -t A -o S -q -w ./massdns.txt && cat ./massdns.txt | sed 's/A.*//' | sed 's/CN.*//' | sed 's/\..$//' | tee $out && rm massdns.txt
	printf $yellow"\nDone!\n"$end
	printf "$green\n- - - - - - - - - - - - - - - - - - - - -"
	printf "$cyan\nFound $end" 
	printf "$red$(cat $out| wc -l)$end"
	printf "$cyan subdomain$end"
	printf "$cyan\nOutput saved to $end"
	printf "$red$pwd/$out$end"
	printf "$green\n- - - - - - - - - - - - - - - - - - - - -"

}

while getopts ":l:o:d:w:srbh" opt; do
	case $opt in
		l)
			list=$OPTARG
			if [ -z "$list" ]; then
				printf $cyan"Option error:"$end
				printf $red"\n\t-l	"$end	
				printf $cyan"This option is missing parameter"$end
				printf $cyan"\n\tPlease use -h option to show the program usage message!"$end
				exit
			fi
			;;
		o)
			out=$OPTARG
			if [ -z "$out" ]; then
				printf $cyan"Option error:"$end
				printf $red"\n\t-o	"$end	
				printf $cyan"This option is missing parameter"$end
				printf $cyan"\n\tPlease use -h option to show the program usage message!"$end
				exit
			fi
			;;
		d)
			domain=$OPTARG
			if [ -z "$domain" ]; then
				printf $cyan"Option error:"$end
				printf $red"\n\t-d	"$end	
				printf $cyan"This option is missing parameter"$end
				printf $cyan"\n\tPlease use -h option to show the program usage message!"$end
				exit
			fi
			;;
		w)
			wordlist=$OPTARG
			if [ -z "$wordlist" ]; then
				printf $cyan"Option error:"$end
				printf $red"\n\t-d	"$end	
				printf $cyan"This option is missing parameter"$end
				printf $cyan"\n\tPlease use -h option to show the program usage message!"$end
				exit
			fi
			;;
		s)
			sub $domain $out | sub $list $out
			;;
		r)	
			recursive $out
			;;
		b)
			brute $wordlist $domain $out 
			;;
		h)
			option
			exit
			;;
		*)
			printf $cyan"Usage:\n"$end 
			printf $yellow"\t./batsub.sh "
			printf $red"-d "$end
			printf $yellow"<single target> "$end
			printf $red"-o "$end
			printf $yellow"<output> "$end
			printf $red"-s\n"$end
			
			printf $yellow"\t./batsub.sh "
			printf $red"-l "$end
			printf $yellow"<list target> "$end
			printf $red"-o "$end
			printf $yellow"<output> "$end
			printf $red"-s\n\n"$end
			printf $cyan"\tPlease use -h option to show the program usage message!"$end
			exit
			;;
	esac
done
