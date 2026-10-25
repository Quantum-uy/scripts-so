#!/bin/bash
# Módulo: Gestión de logs del sistema — v2.0

ver_logs_recientes() {
    read -p "Cantidad de líneas (default 50): " lineas
    lineas=${lineas:-50}
    echo -e "${CYAN}Últimas $lineas líneas del journal:${NC}"
    journalctl -n "$lineas" --no-pager
}

logs_por_servicio() {
    read -p "Servicio (ej: ssh, mysql, apache2): " servicio
    if [ -z "$servicio" ]; then
        echo -e "${ROJO}Error: debe indicar un servicio.${NC}"
        return
    fi
    read -p "Cantidad de líneas (default 30): " lineas
    lineas=${lineas:-30}
    echo -e "${CYAN}Logs de '$servicio' (últimas $lineas líneas):${NC}"
    journalctl -u "$servicio" -n "$lineas" --no-pager
}

logs_errores() {
    echo ""
    echo -e "${CYAN}Errores recientes del sistema:${NC}"
    journalctl -p err -n 30 --no-pager
}

ver_auth_log() {
    echo ""
    echo -e "${CYAN}Últimos 30 eventos de autenticación:${NC}"
    tail -30 /var/log/auth.log
}

uso_disco() {
    echo ""
    echo -e "${CYAN}Uso de disco:${NC}"
    df -h
    echo ""
    echo -e "${CYAN}Espacio usado por logs:${NC}"
    journalctl --disk-usage
}

buscar_por_fecha() {
    echo ""
    read -p "Fecha inicio (YYYY-MM-DD): " desde
    read -p "Fecha fin (YYYY-MM-DD): " hasta
    if [ -z "$desde" ] || [ -z "$hasta" ]; then
        echo -e "${ROJO}Error: debe indicar ambas fechas.${NC}"
        return
    fi
    echo -e "${CYAN}Logs del $desde al $hasta:${NC}"
    journalctl --since "$desde" --until "$hasta" --no-pager | tail -100
}

menu_logs() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE LOGS ---${NC}"
        echo "1) Ver logs recientes"
        echo "2) Logs por servicio"
        echo "3) Ver solo errores"
        echo "4) Ver log de autenticación"
        echo "5) Uso de disco y logs"
        echo "6) Buscar por rango de fechas"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ver_logs_recientes ;;
            2) logs_por_servicio ;;
            3) logs_errores ;;
            4) ver_auth_log ;;
            5) uso_disco ;;
            6) buscar_por_fecha ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
