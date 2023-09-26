#!/bin/bash
# Author: M Ali <onesender.id@gmail.com>

# wajib root
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run this script with root accessd"
    echo " sudo bash install-master.sh"
    exit
fi


echo "Install OneSender Instance"
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

PORT=3000

echo ""
echo "------------------------------------------------- "
echo "1. APP SETTINGS"
echo "   This is OneSender instance number?. Example: 1"
read -p "   Number         : " NOMOR

if ! [[ "$NOMOR" =~ ^[0-9]+$ ]] ; 
 then exec >&2; echo "error: Not a number"; exit 1
fi
PORT=$(($PORT + $NOMOR))

ONESENDER_DIR="/opt/onesender-${NOMOR}"

if [ -d "$ONESENDER_DIR" ]; then
  echo ""
  echo "An error occured:"
  echo "Folder '${ONESENDER_DIR}' already exists"
  echo ""
  echo ""
  exit 1
fi


echo ""
echo "------------------------------------------------- "
echo "2. DATABASE SETTING"
read -p "   MySQL Database : " MYSQL_DATABASE
read -p "   MySQL User     : " MYSQL_USER
read -p "   MySQL Password : " MYSQL_PASSWORD

while ! mysql -u$MYSQL_USER -p$MYSQL_PASSWORD  -e ";" ; do
  echo "Wrong MySQL user or password"
  echo ""
  read -p "   MySQL Database : " MYSQL_DATABASE
  read -p "   MySQL User     : " MYSQL_USER
  read -p "   MySQL Password : " MYSQL_PASSWORD
done

CEK_DB=`mysqlshow --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}| grep -v Wildcard | grep -o ${MYSQL_DATABASE}`
if [ "$CEK_DB" == "${MYSQL_DATABASE}" ]; then
  echo ""
  echo "   DATABASE EXISTS."
  echo "   Do you want to delete and recreate database: '${MYSQL_DATABASE}'? default no"
  echo "   If not sure? press 'n' "
  read -p "   (y) Yes (n) no : " MYSQL_CONFIRM_DELETE
  if [ "$MYSQL_CONFIRM_DELETE" == "y" ]; then
    echo ""
    echo "   - Delete database ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE ${MYSQL_DATABASE};"
    echo "   - Recreate database ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo ""
  fi
else
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo ""
  echo "   - Database ${MYSQL_DATABASE} created"
  echo ""
fi



echo ""
echo "Review Setting "
echo "------------------------------------------------- "
echo "Mysql User      : $MYSQL_USER"
echo "Mysql Pass      : $MYSQL_PASSWORD"
echo "Mysql Database  : $MYSQL_DATABASE"
echo "Number Aplikasi : $NOMOR"
echo "Port Aplikasi   : $PORT"
echo ""
echo ""
echo ""

read -p "Press y to continue! " lanjut2


if [[ $lanjut2 != "y" ]]; then
  exit
fi


FUNC_INSTALL_APLIKASI () {
  MASTER_ONESENDER_DIR="/opt/onesender-master"
  MASTER_ONESENDER_RESOURCE_DIR="/opt/onesender-master/resources"
  MASTER_ONESENDER_APP="/opt/onesender-master/onesender-x86_64"

  
  ONESENDER_RESOURCE_DIR="${ONESENDER_DIR}/resources"
  ONESENDER_APP="${ONESENDER_DIR}/onesender-${NOMOR}"
  ONESENDER_CONFIG="${ONESENDER_DIR}/config_${NOMOR}.yaml"
  ONESENDER_SESSION="${ONESENDER_DIR}/whatsapp_${NOMOR}.session"
  ONESENDER_INIT_SCRIPT="/etc/systemd/system/onesender${NOMOR}.service"
  ONESENDER_BINARY="onesender-${NOMOR}"
  ONESENDER_SERVICE_NAME="onesender${NOMOR}.service"

  if [ ! -d "$MASTER_ONESENDER_DIR" ]; then
    echo ""
    echo "An error occured:"
    echo "Folder '${MASTER_ONESENDER_DIR}' not exists"
    exit
  fi

  if [ -d "$ONESENDER_DIR" ]; then
    echo ""
    echo "An error occured:"
    echo "Folder '${ONESENDER_DIR}' already exists"
    exit
  fi


  echo "Create child folder: /opt/onesender-${NOMOR}"
  mkdir $ONESENDER_DIR
  echo "DONE"
  echo ""
  cp -r $MASTER_ONESENDER_RESOURCE_DIR $ONESENDER_RESOURCE_DIR

  ln -s $MASTER_ONESENDER_APP $ONESENDER_APP
  echo "Create child symlink to master app: ${ONESENDER_APP} -> ${MASTER_ONESENDER_APP}"
  echo "DONE"
  echo ""

  echo ""
  echo "Create config file: ${ONESENDER_CONFIG}"
echo "app:
  sync_contacts: true
  wamd_session_path: ${ONESENDER_SESSION}
database:
  connection: mysql
  host: 127.0.0.1
  name: $MYSQL_DATABASE
  password: $MYSQL_PASSWORD
  port: 3306
  user: $MYSQL_USER
  prefix: os${NOMOR}_
server:
  port: $PORT
" > $ONESENDER_CONFIG
  echo "DONE"
  echo ""


echo "Create init script: ${ONESENDER_INIT_SCRIPT}"
echo "[Unit]
Description=onesender number ${NOMOR} Service

[Service]
Type=simple
ExecStart=$ONESENDER_APP --config=$ONESENDER_CONFIG
ExecStop=killall -w $ONESENDER_BINARY
Restart=on-failure
RestartSec=10
KillMode=process


[Install]
WantedBy=multi-user.target
" > $ONESENDER_INIT_SCRIPT
systemctl daemon-reload
echo "DONE"
echo ""

echo "Start service"
systemctl enable "${ONESENDER_SERVICE_NAME}"
sleep 1
systemctl start "${ONESENDER_SERVICE_NAME}"
sleep 3

echo ""
echo "INSTALLATION DONE"
echo "Please open this link: http://localhost:${PORT}/"
echo ""

echo "To start this instance please run:"
echo "$ sudo systemctl start ${ONESENDER_SERVICE_NAME}"
echo ""
echo "To stop service please run:"
echo "$ sudo systemctl stop ${ONESENDER_SERVICE_NAME}"

}

FUNC_INSTALL_APLIKASI