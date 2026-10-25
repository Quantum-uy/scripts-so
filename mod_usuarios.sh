#!/bin/bash
# Módulo: Gestión de usuarios — v2.0

crear_usuario() {
    read -p "Nombre del usuario: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if id "$nombre" &>/dev/null; then
        echo -e "${ROJO}Error: el usuario '$nombre' ya existe.${NC}"
        return
    fi
    read -p "Shell (default /bin/bash): " shell
    shell=${shell:-/bin/bash}
    useradd -m -s "$shell" "$nombre"
    if [ $? -eq 0 ]; then
        echo -e "${VERDE}Usuario '$nombre' creado.${NC}"
        passwd "$nombre"
    else
        echo -e "${ROJO}Error al crear el usuario.${NC}"
    fi
}

eliminar_usuario() {
    read -p "Nombre del usuario a eliminar: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if ! id "$nombre" &>/dev/null; then
        echo -e "${ROJO}Error: el usuario '$nombre' no existe.${NC}"
        return
    fi
    read -p "¿Eliminar también su directorio home? (s/n): " home
    read -p "$(echo -e "${AMARILLO}¿Confirmar eliminación de '$nombre'? (s/n): ${NC}")" confirmar
    if [ "$confirmar" != "s" ]; then
        echo "Operación cancelada."
        return
    fi
    if [ "$home" = "s" ]; then
        userdel -r "$nombre"
    else
        userdel "$nombre"
    fi
    [ $? -eq 0 ] && echo -e "${VERDE}Usuario '$nombre' eliminado.${NC}" || echo -e "${ROJO}Error al eliminar.${NC}"
}

listar_usuarios() {
    echo ""
    echo -e "${CYAN}Usuarios del sistema (UID >= 1000):${NC}"
    echo "-----------------------------------"
    awk -F: '$3 >= 1000 && $3 < 65534 {printf "%-20s UID: %s\n", $1, $3}' /etc/passwd
}

info_usuario() {
    read -p "Nombre del usuario: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if id "$nombre" &>/dev/null; then
        echo ""
        id "$nombre"
        echo -e "${CYAN}Shell:${NC} $(grep "^$nombre:" /etc/passwd | cut -d: -f7)"
        echo -e "${CYAN}Grupos:${NC} $(groups "$nombre" 2>/dev/null | cut -d: -f2)"
        echo -e "${CYAN}Último login:${NC}"
        lastlog -u "$nombre" 2>/dev/null || echo "No disponible"
    else
        echo -e "${ROJO}El usuario '$nombre' no existe.${NC}"
    fi
}

cambiar_contrasena() {
    read -p "Nombre del usuario: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if ! id "$nombre" &>/dev/null; then
        echo -e "${ROJO}El usuario '$nombre' no existe.${NC}"
        return
    fi
    passwd "$nombre"
    [ $? -eq 0 ] && echo -e "${VERDE}Contraseña actualizada.${NC}" || echo -e "${ROJO}Error al cambiar contraseña.${NC}"
}

menu_usuarios() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE USUARIOS ---${NC}"
        echo "1) Crear usuario"
        echo "2) Eliminar usuario"
        echo "3) Listar usuarios"
        echo "4) Info de usuario"
        echo "5) Cambiar contraseña"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) crear_usuario ;;
            2) eliminar_usuario ;;
            3) listar_usuarios ;;
            4) info_usuario ;;
            5) cambiar_contrasena ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
