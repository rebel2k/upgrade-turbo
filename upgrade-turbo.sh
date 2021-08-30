#!/bin/bash
# upgradeTurbo script - Christophe Sperandio - 2021/08/30

VERSION=""
URL=""
DIR=/opt/local/bin

usage(){
    echo "Run upgrade-turbo.sh VERSION_TO_UPGRADE_TO"
    echo "example: ./upgrade-turbo.sh 8.3.0"
}

download_script(){
    echo "Downloading the upgrade script..."
    cd ${DIR} # go to working dir, by default: /opt/local/bin
    read -p "Are you using a proxy to connect to the internet on this Turbonomic instance (y/n)? " CONT
    if [[ "${CONT}" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        read -p "What is the proxy name or IP and port you use? (if you need authentication, you can include login and password in the address - example: https://login:password@proxy.server.com:8080) " P_NAME_PORT
        echo " "
        OUT=$(curl -O --proxy ${P_NAME_PORT} -s -o /dev/null -w "%{http_code}" ${URL})
    else
        OUT=$(curl -O -s -o /dev/null -w "%{http_code}" ${URL})
    fi
    # check if curl downloaded properly
    if [[ ${OUT} != "200" ]]; then
        echo "Downloading fail, please, try again"
        exit 1
    else
        chmod +x onlineUpgrade.sh
    fi
    cd - # go back to the previous directory
}

run_upgrade(){
    cd ${DIR}
    echo "Running upgrade..."
    ./onlineUpgrade.sh ${VERSION}
    cd -
}

if [[ $# -eq 0 || -z "$1" ]]; then # if there's no argument passed
    usage
elif [[ $1 =~ ^8\.[0-9]\.[0-9]$ ]]; then # the argument is OK and it's a valid version 8.x.y
    VERSION=$1
    URL=https://download.vmturbo.com/appliance/download/updates/${VERSION}/onlineUpgrade.sh
    echo "Upgrading Turbonomic to version ${VERSION}"
    download_script
    run_upgrade
else # any other case
    usage
fi