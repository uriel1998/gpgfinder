#!/bin/bash
tempaddy=$(mktemp)
		while read line; do   
			#using case to match nicely
			case "$line" in   
				"FN:"*)
					read line;
					tmpfn=$(echo "$line" | cut -d ":" -f 2 | awk -F ';' '{print $2" "$1}')					
					read line;
					tmpemail=$(echo "$line" | sed 's/"\(.*\)"/\1/g' | awk -F ':' '{print $2}')		
					case $tmpemail in
						*"@"*) #vaguely legit email format
							if [ "$tmpfn" != " " ]; then
								tmpfn=${tmpfn//$'\n'/} # Remove all newlines.
							else
								tmpfn="No Name Provided"
							fi
							tmpemail=${tmpemail//$'\n'/} # Remove all newlines.
							tmpemail=${tmpemail//[[:space:]]/}
							echo "$tmpemail" >> $tempaddy
							echo "$tmpfn" >> $tempaddy
							echo "@@@@@" >> $tempaddy
						;;
					esac
				;;
			esac	
		done < contacts.vcf
