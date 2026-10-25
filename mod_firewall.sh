#!/bin/bash
# Módulo: Gestión de firewall — v2.0

ver_reglas() {
    echo ""
    echo -e "${CYAN}=== Reglas iptables ===${NC}"
    iptables -L -n -v --line-numbers
}

ver_nat() {
    echo ""
    echo -e "${CYAN}=== Reglas NAT ===${NC}"
    iptables -t nat -L -n -v --line-numbers
}

agregar_regla() {
    echo "Tipo de regla:"
    echo "1) Permitir puerto entrante"
    echo "2) Bloquear IP específica"
    read -p "Opción: " tipo
    case $tipo in
        1)
            read -p "Puerto: " puerto
            if [ -z "$puerto" ]; then
                echo -e "${ROJO}Error: debe indicar un puerto.${NC}"
                return
            fi
            echo "Protocolo:"
            echo "1) TCP"
            echo "2) UDP"
            read -p "Opción: " proto
            case $proto in
                1) protocolo="tcp" ;;
                2) protocolo="udp" ;;
                *) echo -e "${ROJO}Opción inválida.${NC}"; return ;;
            esac
            iptables -A INPUT -p "$protocolo" --dport "$puerto" -j ACCEPT
            echo -e "${VERDE}Regla agregada: ACCEPT $protocolo $puerto${NC}"
            ;;
        2)
            read -p "IP a bloquear: " ip
            if [ -z "$ip" ]; then
                echo -e "${ROJO}Error: debe indicar una IP.${NC}"
                return
            fi
            read -p "$(echo -e "${AMARILLO}¿Confirmar bloqueo de $ip? (s/n): ${NC}")" confirmar
            if [ "$confirmar" != "s" ]; then
                echo "Operación cancelada."
                return
            fi
            iptables -A INPUT -s "$ip" -j DROP
            echo -e "${VERDE}Regla agregada: DROP desde $ip${NC}"
            ;;
        *) echo -e "${ROJO}Opción inválida.${NC}" ;;
    esac
}

eliminar_regla() {
    ver_reglas
    echo ""
    read -p "Cadena (INPUT/OUTPUT/FORWARD): " cadena
    read -p "Número de regla a eliminar: " num
    if [ -z "$cadena" ] || [ -z "$num" ]; then
        echo -e "${ROJO}Error: debe indicar cadena y número.${NC}"
        return
    fi
    read -p "$(echo -e "${AMARILLO}¿Confirmar eliminación de regla $num en $cadena? (s/n): ${NC}")" confirmar
    if [ "$confirmar" != "s" ]; then
        echo "Operación cancelada."
        return
    fi
    iptables -D "$cadena" "$num"
    [ $? -eq 0 ] && echo -e "${VERDE}Regla eliminada.${NC}" || echo -e "${ROJO}Error al eliminar.${NC}"
}

guardar_reglas() {
    netfilter-persistent save
    echo -e "${VERDE}Reglas guardadas de forma persistente.${NC}"
}

menu_firewall() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE FIREWALL ---${NC}"
        echo "1) Ver reglas iptables"
        echo "2) Ver reglas NAT"
        echo "3) Agregar regla"
        echo "4) Eliminar regla"
        echo "5) Guardar reglas (persistente)"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ver_reglas ;;
            2) ver_nat ;;
            3) agregar_regla ;;
            4) eliminar_regla ;;
            5) guardar_reglas ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
