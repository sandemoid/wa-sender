#!/bin/bash
# Author: M Ali <onesender.id@gmail.com>

# wajib root
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run this script with root accessd"
    echo " sudo bash install-master.sh"
    exit
fi



echo "Install OneSender Master"
echo "(Version 2.1.3)"
echo ""
echo "Tested with:"
echo "- Native Ubuntu 20.04 "
echo "- Aapanel (ubuntu 20.04) "
echo ""
read -p "Press y to continue: " lanjut


if [[ $lanjut != "y" ]]; then
  exit
fi


FUNC_INSTALL_APLIKASI () {
  OLD_ONESENDER_DIR="/opt/onesender_$(date +%H-%M)"
  ONESENDER_DIR="/opt/onesender-master"
  ONESENDER_RESOURCE_DIR="/opt/onesender-master/resources"
  ONESENDER_APP="/opt/onesender-master/onesender-x86_64"
  ONESENDER_BINARY="onesender-x86_64"

  echo "- Create master dir ${ONESENDER_DIR}"
  mkdir $ONESENDER_DIR
  cp -r ../../resources $ONESENDER_RESOURCE_DIR
  cp "../../${ONESENDER_BINARY}" $ONESENDER_APP
  chmod +x $ONESENDER_APP

  echo "DONE"
}

FUNC_INSTALL_APLIKASI