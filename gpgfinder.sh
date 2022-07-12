#!/bin/bash

########################################################################
# Requires grep
# gpgfinder -f [VCF contact file]
#
# Looks across multiple keyservers
#
########################################################################

declare ContactsFile

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
KeyServer3="hkps://pgp.mit.edu"
KeyServer2="hkps://keyserver.ubuntu.com"
KeyServer1="hkps://keys.mailvelope.com"
KeyServer0="hkps://keys.openpgp.org"


function help() {
    echo "gpgfinder -f [VCF file]"
    exit
}

function pass_back_a_string() {
    local localvar
    
    localvar=$(echo "$1" | awk '{print tolower($0)}')
    localvar=$(echo "$localvar" | awk '{gsub(/^ +| +$/,"")} {print $0}')
    echo "$localvar"
}

KnownKeys=$(gpg --list-keys | grep uid | grep -v revoked | grep -v expired | grep @ | awk -F '<' '{print $2}'| awk -F '>' '{print $1}')


########################################################################
# Parse the arguments
########################################################################

while [ $# -gt 0 ]; do
option="$1"
    case $option in
        -h)
            help
            exit
            ;;
        -f)
            shift
            ContactsFile="${1}"
            shift
            ;;
        *)
            if [ -f "${1}" ];then
                ContactsFile="$1"
            fi
            shift
            ;;
    esac
    
done


if [ ! -f "${ContactsFile}" ];then
    echo "Contacts File Not a File"
    exit 99
fi



MyEmails=$(grep EMAIL "${ContactsFile}" | grep -v no-reply | grep -v @nowhere.invalid | grep -v example | awk -F ':' '{print $2}' | sort | uniq | tr -cd "[:print:]\n")


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

while read -r line; do 
    #gpg --auto-key-locate clear,hkps://keys.mailvelope.com --locate-external-keys aackswriter@gmail.com
    #gpg --auto-key-locate clear,hkps://keys.mailvelope.com --locate-external-keys ${line}
    # Okay, maybe this needs to run as a subshell?
    if [[ "$KnownKeys" == *"$line"* ]]; then
        echo "$line is a known key."
    else
        

        result=1
        echo "Checking for ${line} at ${KeyServer0}"
        gpg --auto-key-locate clear,"${KeyServer0}" --locate-external-keys "${line}"
        result=$?
        if [ $result != 0 ];then
            echo "Checking for ${line} at ${KeyServer1}"
            #gpg --auto-key-locate clear,hkps://pgp.mit.edu --locate-external-keys steven@stevesaus.com
            gpg --auto-key-locate clear,"${KeyServer1}" --locate-external-keys "${line}"
            result=$?
            if [ $result != 0 ];then
                echo "Checking for ${line} at ${KeyServer2}"
                gpg --auto-key-locate clear,"${KeyServer2}" --locate-external-keys "${line}"
                result=$?
                if [ $result != 0 ];then
                    echo "Checking for ${line} at ${KeyServer3}"
                    gpg --auto-key-locate clear,"${KeyServer3}" --locate-external-keys "${line}"
                    result=$?
                    if [ $result != 0 ];then
                        echo "${line}" >> "${SCRIPT_DIR}"/match_no.txt
                    else
                        echo "${line}" >> "${SCRIPT_DIR}"/match_yes.txt
                    fi
                else
                    echo "${line}" >> "${SCRIPT_DIR}"/match_yes.txt
                fi
            else
                echo "${line}" >> "${SCRIPT_DIR}"/match_yes.txt
            fi
        else
            echo "${line}" >> "${SCRIPT_DIR}"/match_yes.txt
        fi
    fi
done <<< "${MyEmails}"
IFS=$SAVEIFS
