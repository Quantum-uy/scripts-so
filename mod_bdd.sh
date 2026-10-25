#!/bin/bash
# Módulo: Gestión de base de datos (remoto vía SSH) — v2.0

BDD_HOST="192.168.10.11"
BDD_USER="mateoadmin"
BDD_KEY="/home/adminmateo/.ssh/id_rsa_backup"
SSH_TIMEOUT=5

bdd_ssh() {
    ssh -i "$BDD_KEY" -o ConnectTimeout=$SSH_TIMEOUT "$BDD_USER@$BDD_HOST" "$1" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${ROJO}Error: no se pudo conectar al servidor BDD ($BDD_HOST).${NC}"
        return 1
    fi
}

estado_mysql() {
    echo ""
    echo -e "${CYAN}Estado de MySQL en $BDD_HOST:${NC}"
    bdd_ssh "sudo systemctl status mysql --no-pager -l"
}

listar_bases() {
    echo ""
    echo -e "${CYAN}Bases de datos:${NC}"
    bdd_ssh "sudo mysql -e 'SHOW DATABASES;'"
}

listar_tablas() {
    read -p "Base de datos: " bd
    if [ -z "$bd" ]; then
        echo -e "${ROJO}Error: debe indicar una base de datos.${NC}"
        return
    fi
    echo ""
    bdd_ssh "sudo mysql -e 'USE \`$bd\`; SHOW TABLES;'"
}

ejecutar_consulta() {
    read -p "Base de datos: " bd
    if [ -z "$bd" ]; then
        echo -e "${ROJO}Error: debe indicar una base de datos.${NC}"
        return
    fi
    read -p "Consulta SQL (solo SELECT): " consulta
    if [ -z "$consulta" ]; then
        echo -e "${ROJO}Error: debe ingresar una consulta.${NC}"
        return
    fi
    consulta_upper=$(echo "$consulta" | tr '[:lower:]' '[:upper:]')
    if [[ ! "$consulta_upper" =~ ^SELECT ]]; then
        echo -e "${ROJO}Error: por seguridad, solo se permiten consultas SELECT.${NC}"
        return
    fi
    bdd_ssh "sudo mysql -e 'USE \`$bd\`; $consulta'"
}

ver_usuarios_mysql() {
    echo ""
    echo -e "${CYAN}Usuarios de MySQL:${NC}"
    bdd_ssh "sudo mysql -e 'SELECT User, Host FROM mysql.user;'"
}

ver_tamano_bases() {
    echo ""
    echo -e "${CYAN}Tamaño de las bases de datos:${NC}"
    bdd_ssh "sudo mysql -e \"SELECT table_schema AS 'Base de datos', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Tamaño (MB)' FROM information_schema.tables GROUP BY table_schema ORDER BY SUM(data_length + index_length) DESC;\""
}

menu_bdd() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE BASE DE DATOS ---${NC}"
        echo "1) Estado de MySQL"
        echo "2) Listar bases de datos"
        echo "3) Listar tablas de una base"
        echo "4) Ejecutar consulta SQL (solo SELECT)"
        echo "5) Ver usuarios de MySQL"
        echo "6) Ver tamaño de bases de datos"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) estado_mysql ;;
            2) listar_bases ;;
            3) listar_tablas ;;
            4) ejecutar_consulta ;;
            5) ver_usuarios_mysql ;;
            6) ver_tamano_bases ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
