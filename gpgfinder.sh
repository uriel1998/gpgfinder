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
    echo "gpgfinder --email=emailaddress --file=file"
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

if [[ "$@" =~ "--file=" ]]; then
    ContactsFile=$(echo "$Scratch" | awk -F "--file=" '{print $2}'| awk '{print $1}' )
    if [ ! -f "${ContactsFile}" ];then
        echo "Contacts File Not a File"
        exit 99
    fi
fi

#KeyServer4=$(echo "hkps://keyserver.pgp.com")
#KeyServer3=$(echo "hkps://pgp.mit.edu")
KeyServer2=$(echo "hkps://keyserver.ubuntu.com")
KeyServer1=$(echo "hkps://keys.mailvelope.com")
KeyServer0=$(echo "hkps://keys.openpgp.org")


MyEmails=$(grep EMAIL "${ContactsFile}" | grep -v no-reply | grep -v @nowhere.invalid | grep -v example | awk -F ':' '{print $2}' | sort | uniq | tr -cd "[:print:]\n")


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

while read -r line; do 
    #gpg --auto-key-locate clear,hkps://keys.mailvelope.com --locate-external-keys aackswriter@gmail.com
    #gpg --auto-key-locate clear,hkps://keys.mailvelope.com --locate-external-keys ${line}
    # Okay, maybe this needs to run as a subshell?
    result=1
    if [ "$KeyServer0" != "" ];then
        echo "Checking for ${line} at ${KeyServer0}"
        gpg --auto-key-locate clear,"${KeyServer0}" --locate-external-keys "${line}"
        result=$?
    fi
    if [ $result != 0 ];then
        echo "Checking for ${line} at ${KeyServer1}"
        #gpg --auto-key-locate clear,hkps://pgp.mit.edu --locate-external-keys steven@stevesaus.com
        gpg --auto-key-locate clear,"${KeyServer1}" --locate-external-keys "${line}"
        result=$?
        if [ $result != 0 ];then
            echo "Checking for ${line} at ${KeyServer2}"
            gpg --auto-key-locate clear,"${KeyServer2}" --locate-external-keys "${line}"
        fi
    fi
    # slowing so I don't flood
    echo "###################################Pausing to avoid flooding ########"
    sleep 10

done <<< "${MyEmails}"
IFS=$SAVEIFS
