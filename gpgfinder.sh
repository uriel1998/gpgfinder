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
declare ContactsFile
Scratch="$@"
# ToDo - use this to make it know where to output match queries.

########################################################################
# Help String
########################################################################

function helpus() {
    echo "gpgfinder --email=emailaddress --file=file [ --keyserver=keyserver ]"
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


if [[ "$@" =~ "--help" ]]; then
    helpus
fi

if [[ "$@" =~ "--email=" ]]; then
    UserAddress=$(echo "$Scratch" | awk -F "--email=" '{print $2}'| awk '{print $1}' )
    UserAddress=$(pass_back_a_string "$UserAddress")
fi

if [[ "$@" =~ "--file=" ]]; then
    ContactsFile=$(echo "$Scratch" | awk -F "--file=" '{print $2}'| awk '{print $1}' )
    if [ ! -f "${ContactsFile}" ];then
        echo "Contacts File Not a File"
        exit 99
    fi
fi


KeyServer0=""

if [[ "$@" =~ "--keyserver=" ]]; then
    KeyServer0=$(echo "$Scratch" | awk -F "--keyserver=" '{print $2}'| awk '{print $1}')
fi

KeyServer1=$(echo "hkps://keys.mailvelope.com")
KeyServer2=$(echo "https://keyserver.ubuntu.com")
KeyServer3=$(echo "https://pgp.mit.edu")

if [ -n "${UserAddress}"];then
    if [ "$KeyServer0" != "" ];then
        gpg --auto-key-locate clear,"{$KeyServer0}" --locate-external-keys "${UserAddress}"
    fi
    gpg --auto-key-locate clear,"{$KeyServer1}" --locate-external-keys "${UserAddress}"
    gpg --auto-key-locate clear,"{$KeyServer2}" --locate-external-keys "${UserAddress}"
    gpg --auto-key-locate clear,"{$KeyServer3}" --locate-external-keys "${UserAddress}"
fi

MyEmails=$(grep EMAIL "${ContactsFile}" | grep -v no-reply | grep -v @nowhere.invalid | awk -F ':' '{print $2}' | sort | uniq )

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

while read -r line; do 
    echo -e "${line}"
    line=""
done < "${MyEmails}"
IFS=$SAVEIFS
