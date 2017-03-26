#!/bin/bash

# Reference to counting characters 
# http://stackoverflow.com/questions/16679369/count-occurrences-of-char-in-string-using-bash

	# test for encoding
	#file -i google.csv
	#iconv -f UTF16LE google.csv -o googleout.csv
	
	# if argv < 2, assign divider as , otherwise use $2
	div=,
	
	# test for file with $1
	
	
	#header row - number of columns there should be.
	numcols=$(head -n 1 $1 | grep -o $div | wc -l)
	echo $numcols
	numcols=$numcols-$(head -n 1 $1 | grep -o \" | wc -l)
	read
	while read line; do
		str=$(echo "$line")
		linecols=$(echo $str | grep -o $div | wc -l)
		while [ "$linecols" -lt "$numcols" ]; do
		#if [ "$linecols" != "$numcols" ]; then
			read line
			str=$(echo $str $line)
			linecols=$(echo $str | grep -o $div | wc -l)


			# how many cols

			
			echo "$linecols $numcols BOOGER"
			
			
			#echo $line | grep -c \"
		done
		echo "$str"
	done <$1
