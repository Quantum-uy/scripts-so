#!/bin/bash
# Módulo: Gestión de logs del sistema

ver_logs_recientes() {
    read -p "Cantidad de líneas (default 50): " lineas
    lineas=${lineas:-50}
    sudo journalctl -n "$lineas" --no-pager
}

logs_por_servicio() {
    read -p "Servicio (ej: ssh, mysql, apache2): " servicio
    read -p "Cantidad de líneas (default 30): " lineas
    lineas=${lineas:-30}
    sudo journalctl -u "$servicio" -n "$lineas" --no-pager
}

logs_errores() {
    echo ""
    echo "Errores recientes del sistema:"
    sudo journalctl -p err -n 30 --no-pager
}

ver_auth_log() {
    echo ""
    echo "Últimos 30 eventos de autenticación:"
    sudo tail -30 /var/log/auth.log
}

uso_disco() {
    echo ""
    echo "Uso de disco:"
    df -h
    echo ""
    echo "Espacio usado por logs:"
    sudo journalctl --disk-usage
}

menu_logs() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE LOGS ---"
        echo "1) Ver logs recientes"
        echo "2) Logs por servicio"
        echo "3) Ver solo errores"
        echo "4) Ver log de autenticación"
        echo "5) Uso de disco y logs"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ver_logs_recientes ;;
            2) logs_por_servicio ;;
            3) logs_errores ;;
            4) ver_auth_log ;;
            5) uso_disco ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
