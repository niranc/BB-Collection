# BB-Collection
Small collection of my BB scripts for enum and exploit
## dnsenum.sh
Inspired by Trickest scripts, thanks guys you're doing a well job,
### What
dnsenum.sh is passive script for dns enum of a file of wildcard domains
### When
Start enum with it. output is your target dns
### How
``` ./dnsenum.sh wildcards.txt ```
with 
```
$cat wildcards.txt
dns1.dtd
dns2.dtd
```

## activeenum_ua
### What
Actively scan dns, grab webservers, open ports, crawl websites and launch xray and dalfox
### When
After dns enum :)
### How
``` ./activeenum_ua.sh file_dns.txt "User-Agent: yeswehack"```

## fuzzeractive.sh
### What
Fuzzeractive is a script using ffuf on steroids for a complete webservers.txt file (yes) - It parallelizes a ffuf using up to 9 threads and saves (all) the results. The final script allows sorting and keeping only the interesting results.
### When
When you have a webserver.txt file
### How
``` ./fuzzeractive.sh ./webservers.txt "UserAgent: yeswehack" ```

## filter_fuzzeractive.sh
### What
Read fuzzeractive.sh output and extract the rarest endpoints
### When
Launch it after previous script - need fuff_http outputs
### How
``` ./filterfuffresult.sh ```

# Good luck!



