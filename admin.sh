#!/bin/bash
# Script de administración del servidor — SiGeRU
# Versión 1.0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/mod_usuarios.sh"
source "$SCRIPT_DIR/mod_grupos.sh"
source "$SCRIPT_DIR/mod_backup.sh"
source "$SCRIPT_DIR/mod_red.sh"
source "$SCRIPT_DIR/mod_bdd.sh"
source "$SCRIPT_DIR/mod_firewall.sh"
source "$SCRIPT_DIR/mod_logs.sh"

menu_principal() {
    while true; do
        echo ""
        echo "========================================"
        echo "   ADMINISTRACIÓN DEL SERVIDOR - SiGeRU"
        echo "========================================"
        echo "1) Gestión de usuarios"
        echo "2) Gestión de grupos"
        echo "3) Gestión de backups"
        echo "4) Gestión de red"
        echo "5) Gestión de base de datos"
        echo "6) Gestión de firewall"
        echo "7) Gestión de logs del sistema"
        echo "0) Salir"
        echo "========================================"
        read -p "Seleccione una opción: " opcion

        case $opcion in
            1) menu_usuarios ;;
            2) menu_grupos ;;
            3) menu_backup ;;
            4) menu_red ;;
            5) menu_bdd ;;
            6) menu_firewall ;;
            7) menu_logs ;;
            0) echo "Saliendo..."; exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    done
}

menu_principal
