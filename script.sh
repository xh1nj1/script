#!/bin/bash

echo -e """
 \n   X H I N J I\n
"""

read -p '[?] Your target? ' TARGET
read -p '[?] Save outputs? ' OUTPUT

mkdir -p $OUTPUT && cd $OUTPUT

echo -e "\n================="
echo "[!] target set as:" $TARGET
echo "[!] output directory set as:" $OUTPUT

recconnaisance(){
subenum(){
	echo -e "\n=================="
	echo -e "subdomain enumeration started\n"

	echo -e "[+] subfinder started enumeration" && subfinder -d $TARGET -all -cs -recursive 2>/dev/null | anew subdomain.txt
	echo -e "[+] assetfinder started enumeration" && assetfinder -subs-only $TARGET | anew subdomain.txt
	echo -e "[+] sublist3r started enumeration" && sublist3r -d $TARGET --no-color 2>/dev/null | anew subdomain.txt
	}

crawl(){
	echo -e "\n=================="
	echo -e "crawling (passive/active) started\n"

	echo -e "[+] katana started crawling (passive)" && cat subdomain.txt | katana -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | anew url.txt
	echo -e "[+] katana started crawling (active)" && cat subdomain.txt | katana -d 5 -f qurl | anew url.txt
	echo -e "[+] katana started crawling (active)" && cat url.txt | katana -d 5 -f qurl | anew url.txt
	echo -e "[+] waybackurls started crawling (passive)" && cat subdomain.txt | waybackurls | anew url.txt
	echo -e "[+] gau started crawling (passive)" && cat subdomain.txt | gau | anew url.txt
	echo -e "[+] urlfinder started crawling (passive)" && cat subdomain.txt | urlfinder | anew url.txt
	}

}

paramine(){
	echo -e "\n================="
	echo -e "paramining started\n"

	echo -e "[+] paramspider started paramining" && paramspider -l subdomain.txt | cat result/* | qsreplace | anew param.txt | rm -rf result
	echo -e "[+] extracting params from url.txt" && cat url.txt | grep '?' | grep '=' | anew param.txt
}

extract(){
	echo -e "\n=================="
	echo -e "filtering all for different intention\n"

	echo -e "[+] filtering LFI params"
	echo -e "[+] filtering Open Redirect params"
	echo -e "[+] filtering XSS params"
	echo -e "[+] filtering SQLi params"
	echo -e "[+] filtering CRLF"
	echo -e "[+] filtering Parameter Pollution"
	echo -e "[+] filtering SSTi"
	echo -e "[+] filtering IDOR"
	echo -e "[+] filtering Path Traversal"

	echo -e "\n=================="
	mkdir -p interesting && cd interesting
	echo -e "unsanitized params (interesting)" && cat ../param.txt | kxss | grep -oP '^URL: \K\S+' | sed 's/=.*/=/' | anew unfiltered.txt
	echo -e "reflecting params (inetersting)" && cat ../param.txt | Gxss | anew reflecting.txt
	cd ..
}

recconnaisance
subenum
crawl
