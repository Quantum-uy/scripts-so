#!/bin/bash
# Módulo: Gestión de red — v2.0

ver_interfaces() {
    echo ""
    echo -e "${CYAN}Interfaces de red:${NC}"
    ip -br addr show
}

ver_rutas() {
    echo ""
    echo -e "${CYAN}Tabla de rutas:${NC}"
    ip route
}

probar_conectividad() {
    read -p "IP o dominio a probar: " destino
    if [ -z "$destino" ]; then
        echo -e "${ROJO}Error: debe indicar un destino.${NC}"
        return
    fi
    echo "Probando conectividad con $destino..."
    ping -c 4 "$destino"
    if [ $? -eq 0 ]; then
        echo -e "${VERDE}Conectividad exitosa.${NC}"
    else
        echo -e "${ROJO}Sin conectividad con $destino.${NC}"
    fi
}

ver_puertos() {
    echo ""
    echo -e "${CYAN}Puertos en escucha:${NC}"
    ss -tlnp
}

ver_dns() {
    echo ""
    echo -e "${CYAN}Configuración DNS:${NC}"
    resolvectl status 2>/dev/null || cat /etc/resolv.conf
}

ver_conexiones_activas() {
    echo ""
    echo -e "${CYAN}Conexiones establecidas:${NC}"
    ss -tn state established
}

menu_red() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE RED ---${NC}"
        echo "1) Ver interfaces de red"
        echo "2) Ver tabla de rutas"
        echo "3) Probar conectividad (ping)"
        echo "4) Ver puertos en escucha"
        echo "5) Ver configuración DNS"
        echo "6) Ver conexiones activas"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ver_interfaces ;;
            2) ver_rutas ;;
            3) probar_conectividad ;;
            4) ver_puertos ;;
            5) ver_dns ;;
            6) ver_conexiones_activas ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
