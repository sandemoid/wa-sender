#!/bin/bash
# Author: M Ali <onesender.id@gmail>

# wajib root
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run this script with root accessd"
    echo " sudo bash install.sh"
    exit
fi


echo "Skrip install OneSender"
echo "Multi instance/single"
echo "(Versi 2.1.3)"
echo ""
echo "Dapat digunakan untuk:"
echo "- Native Ubuntu 20.04 "
echo "- Aapanel (ubuntu 20.04) "
echo ""
read -p "Ketik y untuk melanjutkan: " lanjut

if [[ $lanjut != "y" ]]; then
  exit
fi


echo ""
echo "SILAHKAN PILIH MENU INSTALL:"
echo " 1) Install aplikasi"
echo " 2) Menambahkan file config"
echo ""
read -p " Pilihan menu: " MODE_INSTALL
echo ""
if [[ $MODE_INSTALL == 1 ]]; then
  echo "Install Aplikasi"
elif [[ $MODE_INSTALL == 2 ]]; then
  echo "Tambahkan file config"
else
  exit
fi

echo "Silahkan mengisi data-data berikut;"
echo ""
echo "=============================== "
echo "1. SETTING DATABASE"
read -p "   MySQL Database : " MYSQL_DATABASE
read -p "   MySQL User     : " MYSQL_USER
read -p "   MySQL Password : " MYSQL_PASSWORD

while ! mysql -u$MYSQL_USER -p$MYSQL_PASSWORD  -e ";" ; do
  echo "User atau password MySQL salah"
  echo ""
  read -p "   MySQL Database : " MYSQL_DATABASE
  read -p "   MySQL User     : " MYSQL_USER
  read -p "   MySQL Password : " MYSQL_PASSWORD
done

CEK_DB=`mysqlshow --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}| grep -v Wildcard | grep -o ${MYSQL_DATABASE}`
if [ "$CEK_DB" == "${MYSQL_DATABASE}" ]; then
  echo ""
  echo "   DATABASE SUDAH ADA."
  echo "   Apakah ada ingin menghapus database ${MYSQL_DATABASE}? default no"
  read -p "   (y) Yes (n) no : " MYSQL_CONFIRM_DELETE
  if [ "$MYSQL_CONFIRM_DELETE" == "y" ]; then
    echo ""
    echo "   - Hapus tabel ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE ${MYSQL_DATABASE};"
    echo "   - Membuat tabel ${MYSQL_DATABASE}"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo ""
  fi
else
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo ""
  echo "   - Database ${MYSQL_DATABASE} berhasil dibuat"
  echo ""
fi

PORT=3000

echo ""
echo "=============================== "
echo "2. SETTING APLIKASI"
echo "   Ketik nomor urutan aplikasi. Contoh: 1"
read -p "   Nomor          : " NOMOR

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
echo "Nomor Aplikasi : $NOMOR"
echo "Port Aplikasi  : $PORT"

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
echo "- Aktifkan server"
systemctl start "onesender@${NOMOR}"
sleep 3

echo ""
echo "INSTALASI SELESAI"
echo "Aplikasi #$NOMOR sudah berjalan secara otomatis."
echo "Silahkan buka link berikut:"
echo " http://localhost:300$NOMOR/"
echo ""

echo "Untuk menjalan aplikasi gunakan command berikut:"
echo "$ sudo systemctl start onesender@${NOMOR}"
echo ""
echo "Untuk menonaktifkan aplikasi gunakan command berikut:"
echo "$ sudo systemctl stop onesender@${NOMOR}"
