#!/bin/bash
# Módulo: Gestión de usuarios

crear_usuario() {
    read -p "Nombre del usuario: " nombre
    read -p "Shell (default /bin/bash): " shell
    shell=${shell:-/bin/bash}
    sudo useradd -m -s "$shell" "$nombre"
    if [ $? -eq 0 ]; then
        echo "Usuario '$nombre' creado."
        sudo passwd "$nombre"
    else
        echo "Error al crear el usuario."
    fi
}

eliminar_usuario() {
    read -p "Nombre del usuario a eliminar: " nombre
    read -p "¿Eliminar también su directorio home? (s/n): " confirmar
    if [ "$confirmar" = "s" ]; then
        sudo userdel -r "$nombre"
    else
        sudo userdel "$nombre"
    fi
    [ $? -eq 0 ] && echo "Usuario '$nombre' eliminado." || echo "Error al eliminar."
}

listar_usuarios() {
    echo ""
    echo "Usuarios del sistema (UID >= 1000):"
    echo "-----------------------------------"
    awk -F: '$3 >= 1000 && $3 < 65534 {printf "%-20s UID: %s\n", $1, $3}' /etc/passwd
}

info_usuario() {
    read -p "Nombre del usuario: " nombre
    if id "$nombre" &>/dev/null; then
        echo ""
        id "$nombre"
        echo "Último login:"
        lastlog -u "$nombre" 2>/dev/null || echo "No disponible"
    else
        echo "El usuario '$nombre' no existe."
    fi
}

menu_usuarios() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE USUARIOS ---"
        echo "1) Crear usuario"
        echo "2) Eliminar usuario"
        echo "3) Listar usuarios"
        echo "4) Info de usuario"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) crear_usuario ;;
            2) eliminar_usuario ;;
            3) listar_usuarios ;;
            4) info_usuario ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
