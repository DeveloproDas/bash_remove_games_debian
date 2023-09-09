#!/bin/bash

# List all packages, takes all which contain the word game and exclude libraries.
listPackages=$(dpkg -l | grep -i game | grep -v lib)

# Takes ever line from listPackages to become them as an array.
readarray -t listLines <<< "$listPackages"

# -z parameter check if the string is empty.
# If yes, clean the array to start from the first position.
if [[ -z $listPackages ]]; then
    listLines=()
fi

parameters=($@)

function removeG_help {
    echo -e "\n removeGames.sh help (Debian Distro)\n"
    echo -e "   - Without parameters it looks for packages that are games to unistall them.\n"
    echo -e "   - It is possible to add more packages if it is needed or all games weresn't unistalled.\n"
    echo -e "   - Example without parameters: ./removeGames.sh\n"
    echo -e "   - Example with parameters: ./removeGames.sh <packagesName> ... <packagesName>\n"
}

function removeG_ {
    if [[ -z $listLines ]]; then
        echo -e "\nThere are not games to remove.\n"
        exit 0    
    fi
    # for i in "${listLines[@]}"; do # To check if the packages were appended rightly.
    #         echo "$i"
    # done
    for pkg in "${listLines[@]}"; do
        echo "$pkg"
    done
    echo -e "\nAbove packets will be removed.\n"
    read -r -N 1 -p "Do you want to continue? yes(y) - no(n): " opt
    echo
    case $opt in
        y)
            if [[ $errorCode -eq 0 ]]; then # Do not execute if any package is not found.
                for line in "${listLines[@]}"; do #Every line was store in listLines.
                    listLine=($line) #Every line is turn into array separeted by space.
                    echo "Removing ${listLine[1]} ..."
                    apt-get --yes purge ${listLine[1]} > /dev/null 2>&1 #Removing and don't print out
                    #wait #Wait the process until finish
                    errorCode=$?
                    if [[ $errorCode -eq 0 ]]; then #If it succeeded unistalling, print message.
                        echo "${listLine[1]} remove successfully"
                    else
                        echo "Error trying to remove ${listLine[1]}"
                        echo "Error code: $errorCode"
                    fi
                done
            fi
            ;;
        n)
            echo "Exit without removing."
            ;;
        *)
            echo "Wrong value. Run it again."
    esac
    
}

function appendPkg() {
    for moreg in "$@"; do
        listLines[${#listLines[@]}]=$(dpkg -l | grep -i "$moreg")
        errorCode=$?
        if [[ $errorCode -ne 0 ]]; then # Different to 
            echo -e "\nPackage $moreg not found.\n"
            exit 1
        fi
    done
}

if [[ $# -eq 0 ]]; then
    removeG_
elif [[ $# -eq 1 && ${parameters[0]} == "--help" ]]; then
    removeG_help
elif [[ $# -gt 0 ]]; then
    appendPkg "$@"
    removeG_
else
    echo "Incorrect parameters"
fi