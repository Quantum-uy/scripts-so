#!/bin/bash
# Módulo: Gestión de red

ver_interfaces() {
    echo ""
    ip -br addr show
}

ver_rutas() {
    echo ""
    echo "Tabla de rutas:"
    ip route
}

probar_conectividad() {
    read -p "IP o dominio a probar: " destino
    echo "Probando conectividad con $destino..."
    ping -c 4 "$destino"
}

ver_puertos() {
    echo ""
    echo "Puertos en escucha:"
    sudo ss -tlnp
}

ver_dns() {
    echo ""
    echo "Configuración DNS:"
    resolvectl status 2>/dev/null || cat /etc/resolv.conf
}

menu_red() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE RED ---"
        echo "1) Ver interfaces de red"
        echo "2) Ver tabla de rutas"
        echo "3) Probar conectividad (ping)"
        echo "4) Ver puertos en escucha"
        echo "5) Ver configuración DNS"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ver_interfaces ;;
            2) ver_rutas ;;
            3) probar_conectividad ;;
            4) ver_puertos ;;
            5) ver_dns ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
