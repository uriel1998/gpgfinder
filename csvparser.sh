#!/bin/bash


########################################################################
# This simply pulls full names and e-mail addresses from addressbooks
# Currently implemented
# Google Contacts CSV export
########################################################################


# csv.awk from http://lorance.freeshell.org/csv/ where it's in the
# public domain

# Reference to counting characters 
# http://stackoverflow.com/questions/16679369/count-occurrences-of-char-in-string-using-bash

	# test for encoding
	#file -i google.csv
	#iconv -f UTF16LE google.csv -o googleout.csv


########################################################################
# Declarations
########################################################################
	#default divider is a comma for CSV
	div=,
	declare MyFile
	MyTempFile=$(mktemp)

	
	if [ ! -f "$1" ]; then
		exit
	fi


########################################################################
# Check for encoding 
# Google is UTF16LE, and that's not going to work for us
# we want UTF-8
########################################################################
EncodingA=$(file -i "$1" | awk -F "charset=" '{print $2}')
case "$EncodingA" in
	"utf-16le") 
		iconv -sc -f UTF16LE "$1" -o "$MyTempFile"
		MyFile="$MyTempFile"	
		;;
	"utf-8")
		MyFile="$1"
		;;
	*);;
esac
	




 	
	#header row - number of columns there should be.
	numcols=$(head -n 1 "$MyFile" | grep -o $div | wc -l)
	#echo $numcols
	if [ $numcols = 86 ];then
		CSVType=$(head -n 1 "$MyFile" | awk -f csv.awk | awk -F"|"  '{print $30}')
		if [ "$CSVType" == "E-mail 1 - Value" ];then
			echo "### Google Contacts CSV export detected"
		fi
	fi

	

# column 1 and 29 for Google Contacts CSV export
# Using columns 3 & 5 for name (FN, LN) to deal with names like C.S.A and the like
	while read line; do
		str=$(echo "$line")
		linecols=$(echo $str | grep -o $div | wc -l)
		#echo "$linecols"
		#echo "$str"
		if [ $linecols == $numcols ] || [[ $str =~ ^\" ]];then
			Name=$(echo "$line" | awk -f csv.awk | awk -F"|"  '{print $3 ";" $5}')
			Email=$(echo "$line" | awk -f csv.awk | awk -F"|"  '{print $30}')	
			# Testing for header line
			header=$(echo "$Name" | grep -c "Name")
			if [ $header = 0 ]; then			
				if [ "$Email" != "" ]; then
					if [[ "$Email" == ?*@?*.?* ]];then
						echo "$Name;$Email" 
					fi
				fi
			fi
		fi

	done <"$MyFile"

rm "$MyTempFile"
