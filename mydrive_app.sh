#!/bin/bash

# VARIABEL MASUK SERVER
SERVER_USER="k5drive"
SERVER_IP="127.0.0.1"
SERVER_DIR="/files"

clear
echo -e "${BLUE}==================================================${NC}"
echo -e "${CYAN}          DATABASE SERVER AUTHENTICATION          ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "${CYAN} Connecting to    : $SERVER_IP ${NC}"
echo -e "${CYAN} User             : $SERVER_USER ${NC}"
echo -e "${BLUE}--------------------------------------------------${NC}"
# read -s = secret (untuk pass)
read -s -p " Enter Password: " SERVER_PASS
echo ""

# ============================================ warna teks
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
MAGENTA='\e[35m'
NC='\e[0m' # Reset

# ============================================ desain timing teks
hacker_text() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n -e "${CYAN}${text:$i:1}${NC}"
        sleep 0.03
    done
    echo ""
}
transisi2() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n -e "${YELLOW}${text:$i:1}${NC}" # kalau loading
        sleep 0.03
    done
    echo ""
}
transisi3() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n -e "${GREEN}${text:$i:1}${NC}" # kalau berhasil
    done
    echo ""
}
transisi4() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n -e "${RED}${text:$i:1}${NC}" # kalau gagal
    done
}

# =========================================== masuk ke program
transisi3 " [+] Authentication accepted (Password Saved)"
sleep 1


hacker_text " Entering the server..."
sleep 1
hacker_text " All activities are recorded..."
sleep 1
clear

echo -e "${CYAN}"
echo " _____    _  _____  _    ____    _  ____  _____ "
echo " |  _ \  / \ |_ _| / \  | __ )  / \| ___|| ____|"
echo " | | | |/ _ \ | | / _ \ |  _ \ / _ \___ \| _| "
echo " | |_| / ___ \| |/ ___ \| |_ )/ ___ \___)| |___ "
echo " |____/_/   \_\_/_/   \_\____/_/   \____/|_____|"
echo -e "${NC}"

menu_bantuan() {
	echo -e "${BLUE}==================================================${NC}"
	echo -e "	    ${CYAN}MYDRIVE CLI - CLIENT APP${NC}               "
	echo -e "          ${CYAN}Secure File Storage by Kel 5${NC}            "
	echo -e "${BLUE}==================================================${NC}"
	echo -e " Status Koneksi      : ${GREEN}TERHUBUNG${NC}"
	echo -e " User aktif (Lokal)  : ${GREEN}$USER${NC}"
	echo -e "--------------------------------------------------"
	echo " Panduan Perintah:"
	echo " - list     : Melihat daftar file di Drive (Server)"
	echo " - local    : Melihat daftar file di PC (Lokal)"
	echo " - upload   : Mengunggah file"
	echo " - download : Mengunduh file"
	echo " - delete   : Menghapus file di Drive (Server)"
	echo " - baca     : Membuka isi file"
	echo " - edit     : Mengedit file teks"
	echo " - bantuan  : Menampilkan menu"
	echo " - exit     : Keluar dari aplikasi"
	echo "=================================================="
	echo ""
}

menu_bantuan
# ========================================== PROGRAM UTAMA LOOPING
while true; do
    echo ""
    echo -e -n "${BLUE}MyDrive-Client~$ ${NC}"
    read input
    cmd=($input)

    case "${cmd[0]}" in
        list)
            transisi2 "[+]Mengambil daftar file dari server..."
            # sshpass untuk menggunakan password yang disimpan di RAM
            sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "ls $SERVER_DIR/"
            ;;
        local)
            transisi3 "[+] Daftar file di komputer lokal:"
            ls
            ;;
        upload)
            if [ -z "${cmd[1]}" ]; then
                transisi4 "[-] Error: Masukkan nama file (Contoh: upload tugas.pdf)"
            elif [ ! -f "${cmd[1]}" ]; then
                transisi4 "[-] Error: File '${cmd[1]}' tidak ditemukan di PC kamu."
            else
                transisi2 "$[] Mengunggah '${cmd[1]}' ke server..."
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "put \"${cmd[1]}\" $SERVER_DIR/"
                transisi3 "[v] Upload selesai!"
            fi
            ;;
        download)
            if [ -z "${cmd[1]}" ]; then
                transisi4 "[-] Error: Masukkan nama file (Contoh: download data.txt)"
            else
                transisi2 "[+] Mengunduh '${cmd[1]}' dari server..."
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "get $SERVER_DIR/\"${cmd[1]}\""
                transisi3 "[v] Download selesai dan disimpan di PC lokal!"
            fi
            ;;
        delete)
            if [ -z "${cmd[1]}" ]; then
                transisi4 "[-] Error: Masukkan nama file"
            else
                transisi2 "[+] Menghapus file di server..."
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "rm $SERVER_DIR/\"${cmd[1]}\""
                transisi3 "[v] Perintah hapus dikirim!"
            fi
            ;;
        baca)
            if [ -z "${cmd[1]}" ]; then
                transisi4 "[-] Error: Masukkan nama file yang ingin dibaca (Contoh: baca catatan.txt)"
            else
                transisi2 "[+] Mengambil file dari server untuk dibaca..."
                # Export file to dictionary temp lokal
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "get $SERVER_DIR/\"${cmd[1]}\" /tmp/mydrive_temp_read" > /dev/null 2>&1

                if [ -f /tmp/mydrive_temp_read ]; then
                    echo "--------------------------------------------------"
                    cat /tmp/mydrive_temp_read
                    echo -e "\n--------------------------------------------------"
                    # Menghapus file sementara
                    rm /tmp/mydrive_temp_read
                else
                    transisi4 "[-] Error: File '${cmd[1]}' tidak ditemukan di server."
                fi
            fi
            ;;
        edit)
            if [ -z "${cmd[1]}" ]; then
                transisi4 "[-] Error: Masukkan nama file (Contoh: edit catatan.txt)"
            else
                transisi2 "[+] Menyiapkan editor..."
                # Mencoba mengunduh file. jika tidak ada, sftp akan gagal tapi proses lanjut
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "get $SERVER_DIR/\"${cmd[1]}\" /tmp/mydrive_temp_edit" > /dev/null 2>&1

                # Menjalankan nano di lokal
                nano /tmp/mydrive_temp_edit

                transisi2 "[+] Menyimpan perubahan ke server..."
                # IMport file yang sudah diedit ke server
                sshpass -p "$SERVER_PASS" sftp -q $SERVER_USER@$SERVER_IP <<< "put /tmp/mydrive_temp_edit $SERVER_DIR/\"${cmd[1]}\"" > /dev/null 2>&1

                # Menghapus file sementara
                rm /tmp/mydrive_temp_edit
                transisi3 "[v] Perubahan file '${cmd[1]}' berhasil disimpan!"
            fi
            ;;

	bantuan)
	    menu_bantuan
	    ;;
        exit)
            transisi2 "Keluar dari MyDrive App. Sampai jumpa!"
            # Mengosongkan password sebelum keluar
            SERVER_PASS=""
            break
            ;;
        *)
            if [ ! -z "${cmd[0]}" ]; then
                transisi4 "[-] Perintah tidak dikenal. Ketik perintah sesuai panduan."
            fi
            ;;
    esac
done
