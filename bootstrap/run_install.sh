#!/bin/bash

VARS="REGION_DNS ANSIBLE_REPO PUPPET_REPO CHEF_REPO ENVIRONMENT INSTALLER GIT_URL GIT_SUFFIX AWS_INSTALL HOSTNAME REBOOT"

show_vars () {
    echo -e "\nThe following variables are set\n"
    for var in ${VARS}
    do
        value=$(eval echo '$'$var)
        echo ${var}=${value}
    done

    echo -e "\nIs this OK? [yN]\c"
    read ans
    if [ "${ans}" != "y" -a "${ans}" != "Y" ]
    then
	echo "Ok, thanks anyway"
	exit
    fi
}

user=$(id -un)

if [ "${user}" != "root" ]
then
    echo "Error: This script should only be run as root"
    exit 1
fi

config=/etc/build_custom_config

if [ ! -f ${config} ]
then
    touch ${config}
else
    . ${config}
fi

for var in ${VARS}
do
    value=$(eval echo '$'$var)
    echo -e "Set ${var} [${value}] \c"
    read newval
    if [ "${newval}" != "" ]
    then
        export ${var}=${newval}
        sed -i '/'^${var}='/d' ${config}
        echo "${var}=${newval}" >> ${config}
    fi
done

show_vars

curl http://aws.naecl.co.uk/public/build/bootstrap/install.sh > /root/install.sh
chmod +x /root/install.sh
/root/install.sh
