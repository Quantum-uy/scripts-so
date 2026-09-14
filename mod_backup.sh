#!/bin/bash
# Módulo: Gestión de backups

BACKUP_DIR="/backup"

ejecutar_backup() {
    echo "Ejecutando backup manual..."
    if [ -f "$HOME/backup.sh" ]; then
        bash "$HOME/backup.sh"
        echo "Backup ejecutado."
    else
        echo "No se encontró el script de backup en $HOME/backup.sh"
    fi
}

listar_backups() {
    echo ""
    echo "=== Backups de base de datos ==="
    ls -lh "$BACKUP_DIR/db/" 2>/dev/null || echo "No hay backups de BD."
    echo ""
    echo "=== Backups de configuraciones ==="
    ls -lh "$BACKUP_DIR/configs/" 2>/dev/null || echo "No hay backups de configs."
}

ver_ultimo_log() {
    echo ""
    ultimo=$(ls -t "$BACKUP_DIR/logs/"*.log 2>/dev/null | head -1)
    if [ -n "$ultimo" ]; then
        echo "Último log: $ultimo"
        echo "---"
        cat "$ultimo"
    else
        echo "No hay logs de backup."
    fi
}

restaurar_bd() {
    echo ""
    echo "Backups de BD disponibles:"
    ls -1 "$BACKUP_DIR/db/"*.sql.gz 2>/dev/null
    echo ""
    read -p "Archivo a restaurar (ruta completa): " archivo
    if [ -f "$archivo" ]; then
        read -p "¿Confirmar restauración? (s/n): " confirmar
        if [ "$confirmar" = "s" ]; then
            gunzip -c "$archivo" | mysql -u root
            [ $? -eq 0 ] && echo "Base de datos restaurada." || echo "Error en la restauración."
        fi
    else
        echo "Archivo no encontrado."
    fi
}

menu_backup() {
    while true; do
        echo ""
        echo "--- GESTIÓN DE BACKUPS ---"
        echo "1) Ejecutar backup manual"
        echo "2) Listar backups existentes"
        echo "3) Ver último log de backup"
        echo "4) Restaurar base de datos"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ejecutar_backup ;;
            2) listar_backups ;;
            3) ver_ultimo_log ;;
            4) restaurar_bd ;;
            0) return ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
