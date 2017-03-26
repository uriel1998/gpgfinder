#!/bin/bash

########################################################################
# Requires awk
# gpgfinder --email=emailaddress [ --firstname=firstname --lastname=lastname ] [ --keyserver=keyserver ]
#
# Default Keyserver is pgp.mit.edu
#
# Currently only adds key to keychain if email and full name match
# Not case sensitive
########################################################################

########################################################################
# Declarations
########################################################################

declare UserAddress
declare KeyServer
declare FirstName
declare LastName
declare FullName
Scratch="$@"
# ToDo - use this to make it know where to output match queries.
declare TerminalOutput=1

########################################################################
# Help String
########################################################################

function helpus() {
	echo "gpgfinder --email=emailaddress [ --firstname=firstname --lastname=lastname ] [ --keyserver=keyserver ]"
	exit
}

function pass_back_a_string() {
	local localvar
	
	localvar=$(echo "$1" | awk '{print tolower($0)}')
	localvar=$(echo "$localvar" | awk '{gsub(/^ +| +$/,"")} {print $0}')
	echo "$localvar"
}


########################################################################
# Parse the arguments
########################################################################

if [[ -t 0 || -t 1 ]]; then 
	TerminalOutput=1
fi

if [[ "$@" =~ "--help" ]]; then
	helpus
fi

if [[ "$@" =~ "--email=" ]]; then
	UserAddress=$(echo "$Scratch" | awk -F "--email=" '{print $2}'| awk '{print $1}' )
fi
UserAddress=$(pass_back_a_string "$UserAddress")


if [[ "$@" =~ "--firstname=" ]]; then
	FirstName=$(echo "$Scratch" | awk -F "--firstname=" '{print $2}'| awk '{print $1}')
fi
if [[ "$@" =~ "--lastname=" ]]; then
	LastName=$(echo "$Scratch" | awk -F "--lastname=" '{print $2}'| awk '{print $1}')
fi

FullName=$(echo "$FirstName $LastName")
FullName=$(pass_back_a_string "$FullName")

if [[ "$@" =~ "--keyserver=" ]]; then
	KeyServer=$(echo "$Scratch" | awk -F "--keyserver=" '{print $2}'| awk '{print $1}')
else
	KeyServer=$(echo "pgp.mit.edu")
fi

if [ "$UserAddress" = "" ];then
	helpus
fi

# http://www.shellhacks.com/en/RegEx-Find-Email-Addresses-in-a-File-using-Grep
#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"

#Get a List of all Email Addresses with Grep
#Execute the following command to extract a list of all email addresses from a given file :
#$ grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" file.txt


########################################################################
# Search via WGET or CURL to defined repositories
########################################################################

		UserAddress=${UserAddress//$'\n'/} # Remove all newlines.
		s_reply=$(wget -q -O - http://"$KeyServer":11371/pks/lookup?search="$UserAddress" | grep -m 1 -A 3 pub)



#			for curl use this line for first match only 
#			s_reply=$(curl -s http://pgp.mit.edu:11371/pks/lookup?search=$testingemail | grep -h -m 1 -A 1 pub)
#			for curl use this line for all matches 
#			I want to get this up and running first, so I'm not implementing this yet.
#			s_num_returns=$(echo "$s_reply" | grep -c pub )
#			s_reply=$(curl -s http://pgp.mit.edu:11371/pks/lookup?search=$testingemail | grep pub)

#			pub  2048R/<a href="/pks/lookup?op=get&amp;search=0xE54D0B93DD2F731F">DD2F731F</a> 2012-10-17 <a href="/pks/lookup?op=vindex&amp;search=0xE54D0B93DD2F731F">Steven Saus &lt;steven.saus@gmail.com&gt;</a>
#                               Steven Saus &lt;stevesaus@stevesaus.com&gt;
			
						
			s_short_key=$(echo "$s_reply" | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')
			s_full_key=$(echo "$s_reply" | awk -F 'search=' '{print $2}' | awk -F '">' '{print $1}')
			s_date=$(echo "$s_reply" | awk -F '>' '{print $3}' | awk -F '<' '{print $1}')
			s_name=$(echo "$s_reply" | awk -F '>' '{print $4}' | awk -F '&' '{print $1}')
			s_email=$(echo "$s_reply" | awk -F ';' '{print $4}' | awk -F '&' '{print $1}')
			
			if [ "$s_short_key" == "" ]; then
				echo "No match for $UserAddress found at $KeyServer"
			else
				#echo "$s_short_key"
				# We want to use full keys as indicated by some other security person elsewhere 
				# to avoid collisions
				#echo "$s_full_key"
				#echo "$s_name" 
				#echo "$s_email"

				s_name=$(pass_back_a_string "$s_name")
				s_email=$(pass_back_a_string "$s_email")


				# matching primary address and name variable

				match=0

				if [[ "$UserAddress" == "$s_email" ]];then
					((match++))
				fi
				if [[ "$FullName" == "$s_name" ]];then
					((match++))
				fi
				
				case $match in
					1) echo "### Partial Match Found for $UserAddress" 
						echo "### Partial matching with user input not yet implemented"
					
					;;
					2) echo "### Full Match Found; Adding Key To Keychain" 
						returncode=$(gpg --keyserver hkp://"$KeyServer" --recv-keys "$s_full_key")
						echo "$returncode"
					;;
					*);;
				esac
			fi

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