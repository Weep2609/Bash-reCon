# batsub
Find subdomains from findomain, subfinder, assetfinder, massdns

## Install
```
git clone https://github.com/Weep2609/Bash-reCon.git
```
## Usage
Find subdomain
```
./batsub.sh -d or -l <single/list> -o <output> -s -r
```
Brute force subdomain
```
./batsub.sh -d <target> -o <output> -w <wordlist> -b
```
## OPTION:
```
-d      Single target                                                                                                                              
-l      List target                                                                                                                                
-w      Wordlist for brute force                                                                                                                   
-o      Output                                                                                                                                     
-s      Get subdomain by findomain, assetfinder, subfinder                                                                                         
-r      Recursive subdomain (find deep more)                                                                                                       
-b      Brute force subdomain
```



