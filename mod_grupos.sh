#!/bin/bash
# Módulo: Gestión de grupos

crear_grupo() {
    read -p "Nombre del grupo: " nombre
    sudo groupadd "$nombre"
    [ $? -eq 0 ] && echo "Grupo '$nombre' creado." || echo "Error al crear el grupo."
}

eliminar_grupo() {
    read -p "Nombre del grupo a eliminar: " nombre
    sudo groupdel "$nombre"
    [ $? -eq 0 ] && echo "Grupo '$nombre' eliminado." || echo "Error al eliminar."
}

agregar_usuario_grupo() {
    read -p "Usuario: " usuario
    read -p "Grupo: " grupo
    sudo usermod -aG "$grupo" "$usuario"
    [ $? -eq 0 ] && echo "'$usuario' agregado al grupo '$grupo'." || echo "Error."
}

listar_grupos() {
    echo ""
    echo "Grupos del sistema (GID >= 1000):"
    echo "---------------------------------"
    awk -F: '$3 >= 1000 {printf "%-20s GID: %s  Miembros: %s\n", $1, $3, $4}' /etc/group
}

menu_grupos() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE GRUPOS ---"
        echo "1) Crear grupo"
        echo "2) Eliminar grupo"
        echo "3) Agregar usuario a grupo"
        echo "4) Listar grupos"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) crear_grupo ;;
            2) eliminar_grupo ;;
            3) agregar_usuario_grupo ;;
            4) listar_grupos ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
