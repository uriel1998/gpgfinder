#!/bin/bash

########################################################################
# This is the overarching file that should be executed
########################################################################

########################################################################
# Declarations
########################################################################

declare Scratch
declare CSVFile
#MyTempFile=$(mktemp)
MyTempFile=$PWD/temp.txt
Scratch="$@"


########################################################################
# Help String
########################################################################

function helpus() {
	echo "control.sh [ --file=contacts.csv ] [ --keyserver=keyserver ]"
	exit
}


########################################################################
# Parse the arguments
########################################################################

if [[ "$@" =~ "--help" ]]; then
	helpus
fi

if [[ "$@" =~ "--file=" ]]; then
	CSVFile=$(echo "$Scratch" | awk -F "--file=" '{print $2}'| awk '{print $1}' )
	if [ ! -f "$CSVFile" ];then
		helpus
	fi
fi

if [[ "$@" =~ "--keyserver=" ]]; then
	KeyServer=$(echo "$Scratch" | awk -F "--keyserver=" '{print $2}'| awk '{print $1}')
else
	KeyServer=$(echo "pgp.mit.edu")
fi

########################################################################
# Parse CSV File
########################################################################

$PWD/csvparser.sh "$CSVFile" | grep -v "^###" > "$MyTempFile"

########################################################################
# Read from tempfile and search on KeyServer
########################################################################

while read line; do

	FN=$(echo "$line" | awk -F ";" '{ print $1 }')
	LN=$(echo "$line" | awk -F ";" '{ print $2 }')
	EM=$(echo "$line" | awk -F ";" '{ print $3 }')	
	$PWD/gpgfinder.sh --firstname="$FN" --lastname="$LN" --email="$EM" --keyserver="$KeyServer"

done <"$MyTempFile"



rm "$MyTempFile"