#!/bin/bash
# Módulo: Gestión de grupos — v2.0

crear_grupo() {
    read -p "Nombre del grupo: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if getent group "$nombre" &>/dev/null; then
        echo -e "${ROJO}Error: el grupo '$nombre' ya existe.${NC}"
        return
    fi
    groupadd "$nombre"
    [ $? -eq 0 ] && echo -e "${VERDE}Grupo '$nombre' creado.${NC}" || echo -e "${ROJO}Error al crear el grupo.${NC}"
}

eliminar_grupo() {
    read -p "Nombre del grupo a eliminar: " nombre
    if [ -z "$nombre" ]; then
        echo -e "${ROJO}Error: el nombre no puede estar vacío.${NC}"
        return
    fi
    if ! getent group "$nombre" &>/dev/null; then
        echo -e "${ROJO}Error: el grupo '$nombre' no existe.${NC}"
        return
    fi
    read -p "$(echo -e "${AMARILLO}¿Confirmar eliminación del grupo '$nombre'? (s/n): ${NC}")" confirmar
    if [ "$confirmar" != "s" ]; then
        echo "Operación cancelada."
        return
    fi
    groupdel "$nombre"
    [ $? -eq 0 ] && echo -e "${VERDE}Grupo '$nombre' eliminado.${NC}" || echo -e "${ROJO}Error al eliminar.${NC}"
}

agregar_usuario_grupo() {
    read -p "Usuario: " usuario
    read -p "Grupo: " grupo
    if [ -z "$usuario" ] || [ -z "$grupo" ]; then
        echo -e "${ROJO}Error: usuario y grupo no pueden estar vacíos.${NC}"
        return
    fi
    usermod -aG "$grupo" "$usuario"
    [ $? -eq 0 ] && echo -e "${VERDE}'$usuario' agregado al grupo '$grupo'.${NC}" || echo -e "${ROJO}Error.${NC}"
}

quitar_usuario_grupo() {
    read -p "Usuario: " usuario
    read -p "Grupo: " grupo
    if [ -z "$usuario" ] || [ -z "$grupo" ]; then
        echo -e "${ROJO}Error: usuario y grupo no pueden estar vacíos.${NC}"
        return
    fi
    gpasswd -d "$usuario" "$grupo"
    [ $? -eq 0 ] && echo -e "${VERDE}'$usuario' removido del grupo '$grupo'.${NC}" || echo -e "${ROJO}Error.${NC}"
}

listar_grupos() {
    echo ""
    echo -e "${CYAN}Grupos del sistema (GID >= 1000):${NC}"
    echo "---------------------------------"
    awk -F: '$3 >= 1000 {printf "%-20s GID: %s  Miembros: %s\n", $1, $3, $4}' /etc/group
}

menu_grupos() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE GRUPOS ---${NC}"
        echo "1) Crear grupo"
        echo "2) Eliminar grupo"
        echo "3) Agregar usuario a grupo"
        echo "4) Quitar usuario de grupo"
        echo "5) Listar grupos"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) crear_grupo ;;
            2) eliminar_grupo ;;
            3) agregar_usuario_grupo ;;
            4) quitar_usuario_grupo ;;
            5) listar_grupos ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
