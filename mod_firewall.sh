#!/bin/bash
# Módulo: Gestión de firewall

ver_reglas() {
    echo ""
    echo "=== Reglas iptables ==="
    sudo iptables -L -n -v --line-numbers
}

ver_nat() {
    echo ""
    echo "=== Reglas NAT ==="
    sudo iptables -t nat -L -n -v --line-numbers
}

agregar_regla() {
    echo "Tipo de regla:"
    echo "1) Permitir puerto TCP entrante"
    echo "2) Bloquear IP específica"
    read -p "Opción: " tipo
    case $tipo in
        1)
            read -p "Puerto: " puerto
            sudo iptables -A INPUT -p tcp --dport "$puerto" -j ACCEPT
            echo "Regla agregada: ACCEPT TCP $puerto"
            ;;
        2)
            read -p "IP a bloquear: " ip
            sudo iptables -A INPUT -s "$ip" -j DROP
            echo "Regla agregada: DROP desde $ip"
            ;;
        *) echo "Opción inválida." ;;
    esac
}

eliminar_regla() {
    ver_reglas
    echo ""
    read -p "Cadena (INPUT/OUTPUT/FORWARD): " cadena
    read -p "Número de regla a eliminar: " num
    sudo iptables -D "$cadena" "$num"
    [ $? -eq 0 ] && echo "Regla eliminada." || echo "Error al eliminar."
}

guardar_reglas() {
    sudo netfilter-persistent save
    echo "Reglas guardadas de forma persistente."
}

menu_firewall() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE FIREWALL ---"
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
            *) echo "Opción inválida." ;;
        esac
    done
}
