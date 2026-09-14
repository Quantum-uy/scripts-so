#!/bin/bash
# Módulo: Gestión de base de datos (remoto vía SSH al servidor BDD)

BDD_HOST="192.168.10.11"
BDD_USER="mateoadmin"
BDD_KEY="/home/adminmateo/.ssh/id_rsa_backup"

bdd_ssh() {
    ssh -i "$BDD_KEY" "$BDD_USER@$BDD_HOST" "$1"
}

estado_mysql() {
    echo ""
    bdd_ssh "sudo systemctl status mysql --no-pager -l"
}

listar_bases() {
    echo ""
    echo "Bases de datos:"
    bdd_ssh "sudo mysql -e 'SHOW DATABASES;'"
}

listar_tablas() {
    read -p "Base de datos: " bd
    echo ""
    bdd_ssh "sudo mysql -e 'USE $bd; SHOW TABLES;'"
}

ejecutar_consulta() {
    read -p "Base de datos: " bd
    read -p "Consulta SQL: " consulta
    bdd_ssh "sudo mysql -e 'USE $bd; $consulta'"
}

ver_usuarios_mysql() {
    echo ""
    echo "Usuarios de MySQL:"
    bdd_ssh "sudo mysql -e 'SELECT User, Host FROM mysql.user;'"
}

menu_bdd() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE BASE DE DATOS ---"
        echo "1) Estado de MySQL"
        echo "2) Listar bases de datos"
        echo "3) Listar tablas de una base"
        echo "4) Ejecutar consulta SQL"
        echo "5) Ver usuarios de MySQL"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) estado_mysql ;;
            2) listar_bases ;;
            3) listar_tablas ;;
            4) ejecutar_consulta ;;
            5) ver_usuarios_mysql ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
