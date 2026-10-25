#!/bin/bash
# Módulo: Gestión de backups — v2.0

BACKUP_DIR="/backup"

ejecutar_backup() {
    echo "Ejecutando backup manual..."
    if [ -f "$HOME/backup.sh" ]; then
        bash "$HOME/backup.sh"
        echo -e "${VERDE}Backup ejecutado.${NC}"
    else
        echo -e "${ROJO}No se encontró el script de backup en $HOME/backup.sh${NC}"
    fi
}

listar_backups() {
    echo ""
    echo -e "${CYAN}=== Backups de base de datos ===${NC}"
    if ls "$BACKUP_DIR/db/"* &>/dev/null; then
        ls -lh "$BACKUP_DIR/db/"
        echo -e "${AMARILLO}Total: $(ls -1 "$BACKUP_DIR/db/" 2>/dev/null | wc -l) archivos${NC}"
    else
        echo "No hay backups de BD."
    fi
    echo ""
    echo -e "${CYAN}=== Backups de configuraciones ===${NC}"
    if ls "$BACKUP_DIR/configs/"* &>/dev/null; then
        ls -lh "$BACKUP_DIR/configs/"
        echo -e "${AMARILLO}Total: $(ls -1 "$BACKUP_DIR/configs/" 2>/dev/null | wc -l) archivos${NC}"
    else
        echo "No hay backups de configs."
    fi
}

ver_ultimo_log() {
    echo ""
    ultimo=$(ls -t "$BACKUP_DIR/logs/"*.log 2>/dev/null | head -1)
    if [ -n "$ultimo" ]; then
        echo -e "${CYAN}Último log: $ultimo${NC}"
        echo "---"
        cat "$ultimo"
    else
        echo "No hay logs de backup."
    fi
}

restaurar_bd() {
    echo ""
    echo -e "${CYAN}Backups de BD disponibles:${NC}"
    ls -1 "$BACKUP_DIR/db/"*.sql.gz 2>/dev/null
    echo ""
    read -p "Archivo a restaurar (ruta completa): " archivo
    if [ -z "$archivo" ]; then
        echo -e "${ROJO}Error: debe indicar un archivo.${NC}"
        return
    fi
    if [ -f "$archivo" ]; then
        read -p "$(echo -e "${AMARILLO}¿Confirmar restauración? (s/n): ${NC}")" confirmar
        if [ "$confirmar" = "s" ]; then
            gunzip -c "$archivo" | mysql -u root
            [ $? -eq 0 ] && echo -e "${VERDE}Base de datos restaurada.${NC}" || echo -e "${ROJO}Error en la restauración.${NC}"
        else
            echo "Operación cancelada."
        fi
    else
        echo -e "${ROJO}Archivo no encontrado.${NC}"
    fi
}

ver_cron_backup() {
    echo ""
    echo -e "${CYAN}Tareas cron de backup:${NC}"
    crontab -l 2>/dev/null | grep -i backup || echo "No hay tareas cron de backup configuradas."
}

menu_backup() {
    while true; do
        echo ""
        echo -e "${CYAN}--- GESTIÓN DE BACKUPS ---${NC}"
        echo "1) Ejecutar backup manual"
        echo "2) Listar backups existentes"
        echo "3) Ver último log de backup"
        echo "4) Restaurar base de datos"
        echo "5) Ver tareas cron de backup"
        echo "0) Volver"
        read -p "Opción: " op
        case $op in
            1) ejecutar_backup ;;
            2) listar_backups ;;
            3) ver_ultimo_log ;;
            4) restaurar_bd ;;
            5) ver_cron_backup ;;
            0) return ;;
            *) echo -e "${ROJO}Opción inválida.${NC}" ;;
        esac
    done
}
