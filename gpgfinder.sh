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

KeyServer0=""

if [[ "$@" =~ "--keyserver=" ]]; then
    KeyServer0=$(echo "$Scratch" | awk -F "--keyserver=" '{print $2}'| awk '{print $1}')
fi
KeyServer1=$(echo "hkps://keys.mailvelope.com")
KeyServer2=$(echo "https://keyserver.ubuntu.com")
KeyServer3=$(echo "https://pgp.mit.edu")


if [ "$UserAddress" = "" ];then
    helpus
fi

# http://www.shellhacks.com/en/RegEx-Find-Email-Addresses-in-a-File-using-Grep
#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"

#Get a List of all Email Addresses with Grep
#Execute the following command to extract a list of all email addresses from a given file :
#$ grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" file.txt

hkps://keys.mailvelope.com
if [ "$KeyServer0" != "" ];then
    gpg --auto-key-locate clear,"{$KeyServer0}" --locate-external-keys "${UserAddress}"
fi
    gpg --auto-key-locate clear,"{$KeyServer1}" --locate-external-keys "${UserAddress}"
    gpg --auto-key-locate clear,"{$KeyServer2}" --locate-external-keys "${UserAddress}"
    gpg --auto-key-locate clear,"{$KeyServer3}" --locate-external-keys "${UserAddress}"

