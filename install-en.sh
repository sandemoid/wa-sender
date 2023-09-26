#!/bin/bash
# Author: M Ali <onesender.id@gmail>

# wajib root
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run this script with root accessd"
    echo " sudo bash install.sh"
    exit
fi


echo "Script to install OneSender"
echo "(Version 2.1.16)"
echo ""
echo ""
read -p "Press 'y' to continue: " lanjut

if [[ $lanjut != "y" ]]; then
  exit
fi


echo ""
echo "Please select the install menu:"
echo " 1) Install new instance"
echo " 2) Add new config / install secondary instance"
echo ""
read -p " Selected menu: " MODE_INSTALL
echo ""
if [[ $MODE_INSTALL == 1 ]]; then
  echo "Install new instance"
elif [[ $MODE_INSTALL == 2 ]]; then
  echo "install secondary instance"
else
  exit
fi

echo "Please fill in the following data:"
echo ""
echo "=============================== "
echo "1. SETTING DATABASE"
read -p "   MySQL Database : " MYSQL_DATABASE
read -p "   MySQL User     : " MYSQL_USER
read -p "   MySQL Password : " MYSQL_PASSWORD

while ! mysql -u$MYSQL_USER -p$MYSQL_PASSWORD  -e ";" ; do
  echo "MySQL user or password is incorrect"
  echo ""
  read -p "   MySQL Database : " MYSQL_DATABASE
  read -p "   MySQL User     : " MYSQL_USER
  read -p "   MySQL Password : " MYSQL_PASSWORD
done

CEK_DB=`mysqlshow --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}| grep -v Wildcard | grep -o ${MYSQL_DATABASE}`
if [ "$CEK_DB" == "${MYSQL_DATABASE}" ]; then
  echo ""
  echo "   DATABASE EXIST."
  echo "   Do you want to delete the database ${MYSQL_DATABASE}? default no"
  read -p "   (y) Yes (n) no : " MYSQL_CONFIRM_DELETE
  if [ "$MYSQL_CONFIRM_DELETE" == "y" ]; then
    echo ""
    echo "   - Delete database ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE ${MYSQL_DATABASE};"
    echo "   - Create database ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo ""
  fi
else
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo ""
  echo "   - Database ${MYSQL_DATABASE} created"
  echo ""
fi

PORT=3000

echo ""
echo "=============================== "
echo "2. App setting"
echo "   Enter the application's sequence number. For example: 1."
read -p "   Number         : " NOMOR

if ! [[ "$NOMOR" =~ ^[0-9]+$ ]] ; 
 then exec >&2; echo "error: Not a number"; exit 1
fi
PORT=$(($PORT + $NOMOR))


echo ""
echo "Review Setting "
echo "=============================== "
echo "Mysql User     : $MYSQL_USER"
echo "Mysql Pass     : $MYSQL_PASSWORD"
echo "Mysql Database : $MYSQL_DATABASE"
echo "App number     : $NOMOR"
echo "App port       : $PORT"

FUNC_INSTALL_APLIKASI () {
  OLD_ONESENDER_DIR="/opt/onesender_$(date +%H-%M)"
  ONESENDER_DIR="/opt/onesender"
  ONESENDER_RESOURCE_DIR="/opt/onesender/resources"
  ONESENDER_APP="/opt/onesender/onesender-x86_64"
  ONESENDER_BINARY="onesender-x86_64"


  ONESENDER_CONFIG="/opt/onesender/config_${NOMOR}.yaml"

  INIT_SERVER="/etc/systemd/system/onesender@.service"

  #if [ -d "$ONESENDER_DIR" ]; then
  #  mv $ONESENDER_DIR $OLD_ONESENDER_DIR
  #fi

  echo "- Buat file /opt/onesender"
  mkdir $ONESENDER_DIR
  cp -r ./resources $ONESENDER_RESOURCE_DIR
  cp "./${ONESENDER_BINARY}" $ONESENDER_APP
  cp ./install.sh /opt/onesender/install.sh
  chmod +x $ONESENDER_APP

echo "app:
  sync_contacts: true
  wamd_session_path: /opt/onesender/whatsapp_${NOMOR}.session
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

echo "[Unit]
Description=onesender Multi device Service

[Service]
Type=simple
ExecStart=/opt/onesender/$ONESENDER_BINARY --config=/opt/onesender/config_%i.yaml
Wants=network.target
After=syslog.target network-online.target
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
" > $INIT_SERVER

}

FUNC_INSTALL_SETTING() {
  ONESENDER_CONFIG="/opt/onesender/config_${NOMOR}.yaml"
  echo "app:
  sync_contacts: true
  wamd_session_path: /opt/onesender/whatsapp_${NOMOR}.session
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
}


if [[ $MODE_INSTALL == 1 ]]; then
  FUNC_INSTALL_APLIKASI
elif [[ $MODE_INSTALL == 2 ]]; then
  FUNC_INSTALL_SETTING
fi

$ONESENDER_APP --config=/opt/onesender/config_${NOMOR}.yaml --install


echo ""
echo "- Install init script"
systemctl daemon-reload
systemctl enable "onesender@${NOMOR}"
sleep 3
echo ""
echo "- Activate server"
systemctl start "onesender@${NOMOR}"
sleep 3

echo ""
echo "Installation done"
echo "Application #$NOMOR is already running automatically."
echo "Please open following link:"
echo " http://localhost:300$NOMOR/"
echo ""

echo "To run the application, use the following command:"
echo "$ sudo systemctl start onesender@${NOMOR}"
echo ""
echo "To stop the application, use the following command:"
echo "$ sudo systemctl stop onesender@${NOMOR}"
