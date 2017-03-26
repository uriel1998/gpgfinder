#!/bin/bash

# csv.awk from http://lorance.freeshell.org/csv/ where it's in the
# public domain

# Reference to counting characters 
# http://stackoverflow.com/questions/16679369/count-occurrences-of-char-in-string-using-bash

	# test for encoding
	#file -i google.csv
	#iconv -f UTF16LE google.csv -o googleout.csv
	
	#default divider is a comma for CSV
	div=,
	
	
	if [ ! -f "$1" ]; then
		exit
	fi
 	
	#header row - number of columns there should be.
	numcols=$(head -n 1 $1 | grep -o $div | wc -l)
	echo $numcols
	if [ $numcols = 86 ];then
		CSVType=$(head -n 1 $1 | awk -f csv.awk | awk -F"|"  '{print $30}')
		if [ "$CSVType" == "E-mail 1 - Value" ];then
			echo "Google Contacts CSV export detected"
		fi
	fi

	

# column 1 and 29 for Google Contacts CSV export
	while read line; do
		str=$(echo "$line")
		linecols=$(echo $str | grep -o $div | wc -l)
		#echo "$linecols"
		#echo "$str"
		if [ $linecols == $numcols ] || [[ $str =~ ^\" ]];then
			Name=$(echo "$line" | awk -f csv.awk | awk -F"|"  '{print $2}')
			Email=$(echo "$line" | awk -f csv.awk | awk -F"|"  '{print $30}')	
			# Testing for header line
			if [ "$Name" != "Name" ]; then			
				if [ "$Email" != "" ]; then
				echo "$Name"
				echo "$Email"
				fi
			fi
		fi

	done <$1
