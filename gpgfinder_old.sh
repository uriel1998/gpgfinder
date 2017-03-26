#!/bin/bash

########################################################################
# To parse e-mail addresses from exported CSV/VCF address books, search
# GPG keyservers for matches, then import the address into the keyring
#
# Requires zenity/wenity
# Requires awk

#can csvkit (in source) deal with it? https://github.com/onyxfish/csvkit.git
# or uncsv? https://github.com/tamentis/uncsv.git


################################################################################
# Declarations
################################################################################

define Csvfile
define rawfile
#define our tempfile
Tempaddy=$(mktemp)


################################################################################
# Parse command line options
################################################################################

parse_commandline(){
	ARCHIVENAME="$1"
	shift
	# Now "$@" contains all of the arguments except for the first
}

################################################################################
# Parse the inputfile, determine what kind it is.
# Should end up with FN, LN, EMAIL1, EMAIL2
#
################################################################################


# http://www.shellhacks.com/en/RegEx-Find-Email-Addresses-in-a-File-using-Grep
#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"

#Get a List of all Email Addresses with Grep
#Execute the following command to extract a list of all email addresses from a given file :
#$ grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" file.txt

# Get the filename
rawfile=$(zenity --title="Choose the CSV/VCF file to check" --file-selection);echo $rawfile

# Parse out the parts of it.  We're assuming Google exported files here.

file=$(basename $rawfile)
extension=${file##*.}
if [ "$file" == "$extension" ]; then
	# This is a fail condition
	extension=""
fi
filename=${file%.*}
dir=$(dirname $rawfile)

# Goal here is to convert all into email \n FName \n #########

case $extension in
	'csv|CSV') 
	'vcf|VCF')
	*) #fail condition
		;;

	esac


################################################################################
# Parse CSV
################################################################################

		# This is problematic, because Google adds extra crap in here.  The descriptions and such are REALLY problematic.
		# And the google csv is UTF16LE, not UTF8. So disabled for the nonce	
		if [ 'echo $filename | tr [:upper:] [:lower:]' =  'echo "google" | tr [:upper:] [:lower:]' ]; then 
			#cat $file | awk -F ',' '{print $1,$29}' > $tempaddy		
		elseif [ 'echo $filename | tr [:upper:] [:lower:]' =  'echo "outlook" | tr [:upper:] [:lower:]' ]; then 
			#cat $file | awk -F ',' '{print $1 $2   $15}'
		fi
		;;


################################################################################
# Parse VCF
################################################################################

		echo "######" > $tempaddy  #Yes, i'm initializing a temp file. Also gives us a good start hook
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
							echo "#########" >> $tempaddy
						;;
					esac
				;;
			esac	
		done <contacts.vcf
		;;


################################################################################
# Search via WGET or CURL to defined repositories
################################################################################


		testingemail=${line//$'\n'/} # Remove all newlines.
			s_reply=$(wget -q -O - http://pgp.mit.edu:11371/pks/lookup?search=$testingemail | grep -h -m 1 -A 1 pub)

#			for curl use this line
#			s_reply=$(curl -s http://pgp.mit.edu:11371/pks/lookup?search=$testingemail | grep -h -m 1 -A 1 pub)

			pub  2048R/<a href="/pks/lookup?op=get&amp;search=0xE54D0B93DD2F731F">DD2F731F</a> 2012-10-17 <a href="/pks/lookup?op=vindex&amp;search=0xE54D0B93DD2F731F">Steven Saus &lt;steven.saus@gmail.com&gt;</a>
                               Steven Saus &lt;stevesaus@stevesaus.com&gt;
			
						
			s_key=$(echo "$s_reply" | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')
			s_name=$(echo "$s_reply" | awk -F '>' '{print $4}' | awk -F '&' '{print $1}')
			s_email=$(echo "$s_reply" | awk -F ';' '{print $4}' | awk -F '&' '{print $1}')
			
			# get name from 2nd line, see if matches.  
			# from first line, get key, date, also get name.  See if that name matches
			# present data to user.
3.  Use first match
4.  Add 0x to beginning of match
5.  Add to keychain

gpg --keyserver hkp://pgp.mit.edu --recv-keys 0xDD2F731F



echo "test" | gpg -ase -r 0xDD2F731F | gpg

			
################################################################################
# Read our tempfile
################################################################################

			
while read line; do   
	#using case to match nicely
	case "$line" in   
		"######"*)
			read line;  #this gets our email line
	
			#match some shit here
		;;
	esac	
done <$tempaddy


################################################################################
# Cleanup
################################################################################

# clean up temp file
rm -f $tempaddy

################################################################################
# Main
################################################################################




################################################################################
# Example returned data
################################################################################

#</pre><hr /><pre>
#pub  2048R/<a href="/pks/lookup?op=get&amp;search=0xE54D0B93DD2F731F">DD2F731F</a> 2012-10-17 <a href="/pks/lookup?op=vindex&amp;search=0xE54D0B93DD2F731F">Steven Saus &lt;steven.saus@gmail.com&gt;</a>
#                               Steven Saus &lt;stevesaus@stevesaus.com&gt;
#                               Steven Saus (WSU) &lt;steven.saus@wright.edu&gt;
#                               Uriel Wheeler (SL) &lt;uriel.wheeler@gmail.com&gt;
#                               Steven Saus (Non-Gmail) &lt;steven@stevesaus.com&gt;
#                               Steven Saus (AInk Business) &lt;steven@alliterationink.com&gt;
#                               [user attribute packet]
#</pre>			