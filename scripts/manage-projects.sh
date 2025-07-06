#!/bin/bash

# ===========================================
# SCRIPT PARA GESTIONAR MÚLTIPLES PROYECTOS MEAN STACK
# ===========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [COMANDO] [OPCIONES]"
    echo ""
    echo "Comandos:"
    echo "  list                    Listar todos los proyectos"
    echo "  start <proyecto>        Iniciar un proyecto específico"
    echo "  stop <proyecto>         Detener un proyecto específico"
    echo "  restart <proyecto>      Reiniciar un proyecto específico"
    echo "  logs <proyecto> [servicio] Ver logs de un proyecto"
    echo "  status <proyecto>       Ver estado de un proyecto"
    echo "  create <nombre>         Crear nuevo proyecto"
    echo "  delete <proyecto>       Eliminar un proyecto"
    echo "  backup <proyecto>       Hacer backup de un proyecto"
    echo "  restore <proyecto> <archivo> Restaurar proyecto desde backup"
    echo ""
    echo "Opciones globales:"
    echo "  -h, --help              Mostrar esta ayuda"
    echo "  -v, --verbose           Mostrar información detallada"
    echo ""
    echo "Ejemplos:"
    echo "  $0 list"
    echo "  $0 start mi-proyecto"
    echo "  $0 logs mi-proyecto backend"
    echo "  $0 create nuevo-proyecto"
}

# Función para listar proyectos
list_projects() {
    print_header "PROYECTOS MEAN STACK DISPONIBLES"
    
    local projects_found=false
    
    for dir in */; do
        if [[ -d "$dir" && -f "$dir/docker-compose.yml" ]]; then
            local project_name="${dir%/}"
            local env_file="$dir/.env"
            
            if [[ -f "$env_file" ]]; then
                # Extraer información del .env
                local backend_port=$(grep "^BACKEND_PORT=" "$env_file" | cut -d'=' -f2 2>/dev/null || echo "N/A")
                local frontend_port=$(grep "^FRONTEND_PORT=" "$env_file" | cut -d'=' -f2 2>/dev/null || echo "N/A")
                
                # Verificar si está ejecutándose
                local status="🛑 Detenido"
                if docker ps --format "table {{.Names}}" | grep -q "${project_name}-api"; then
                    status="🟢 Ejecutando"
                fi
                
                echo -e "${GREEN}📁 $project_name${NC}"
                echo -e "   Estado: $status"
                echo -e "   Backend: http://localhost:$backend_port"
                echo -e "   Frontend: http://localhost:$frontend_port"
                echo ""
                
                projects_found=true
            fi
        fi
    done
    
    if [[ "$projects_found" == false ]]; then
        print_warning "No se encontraron proyectos MEAN Stack"
        echo "Para crear un nuevo proyecto: $0 create <nombre>"
    fi
}

# Función para iniciar proyecto
start_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    print_message "Iniciando proyecto '$project_name'..."
    cd "$project_name"
    
    if [[ -f ".env" ]]; then
        export $(grep -v '^#' .env | xargs)
    fi
    
    docker-compose up -d --build
    
    print_message "Proyecto '$project_name' iniciado correctamente"
    print_message "Backend: http://localhost:${BACKEND_PORT:-3000}"
    print_message "Frontend: http://localhost:${FRONTEND_PORT:-4200}"
    print_message "MongoDB: mongodb://localhost:${MONGO_PORT:-27017}"
}

# Función para detener proyecto
stop_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    print_message "Deteniendo proyecto '$project_name'..."
    cd "$project_name"
    docker-compose down
    
    print_message "Proyecto '$project_name' detenido"
}

# Función para reiniciar proyecto
restart_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    print_message "Reiniciando proyecto '$project_name'..."
    stop_project "$project_name"
    start_project "$project_name"
}

# Función para ver logs
show_logs() {
    local project_name="$1"
    local service="$2"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    cd "$project_name"
    
    if [[ -n "$service" ]]; then
        print_message "Mostrando logs de '$service' en proyecto '$project_name'..."
        docker-compose logs -f "$service"
    else
        print_message "Mostrando logs de proyecto '$project_name'..."
        docker-compose logs -f
    fi
}

# Función para ver estado
show_status() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    print_header "ESTADO DEL PROYECTO: $project_name"
    
    cd "$project_name"
    docker-compose ps
    
    echo ""
    print_message "Información del proyecto:"
    
    if [[ -f ".env" ]]; then
        export $(grep -v '^#' .env | xargs)
        echo -e "   Backend: http://localhost:${BACKEND_PORT:-3000}"
        echo -e "   Frontend: http://localhost:${FRONTEND_PORT:-4200}"
        echo -e "   MongoDB: mongodb://localhost:${MONGO_PORT:-27017}"
    fi
}

# Función para crear proyecto
create_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre para el proyecto"
        exit 1
    fi
    
    if [[ -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' ya existe"
        exit 1
    fi
    
    # Usar el script de creación
    ./scripts/create-project.sh "$project_name"
}

# Función para eliminar proyecto
delete_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    print_warning "¿Está seguro de que desea eliminar el proyecto '$project_name'?"
    print_warning "Esta acción no se puede deshacer."
    read -p "Escriba 'yes' para confirmar: " confirmation
    
    if [[ "$confirmation" == "yes" ]]; then
        print_message "Eliminando proyecto '$project_name'..."
        
        # Detener contenedores si están ejecutándose
        if [[ -f "$project_name/docker-compose.yml" ]]; then
            cd "$project_name"
            docker-compose down -v 2>/dev/null || true
            cd ..
        fi
        
        # Eliminar directorio
        rm -rf "$project_name"
        
        print_message "Proyecto '$project_name' eliminado"
    else
        print_message "Operación cancelada"
    fi
}

# Función para hacer backup
backup_project() {
    local project_name="$1"
    local backup_file="${project_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    if [[ -z "$project_name" ]]; then
        print_error "Debe especificar un nombre de proyecto"
        exit 1
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' no existe"
        exit 1
    fi
    
    print_message "Creando backup del proyecto '$project_name'..."
    
    # Crear directorio de backups si no existe
    mkdir -p backups
    
    # Hacer backup del código
    tar -czf "backups/$backup_file" --exclude="$project_name/node_modules" --exclude="$project_name/backend/node_modules" --exclude="$project_name/frontend/node_modules" "$project_name"
    
    print_message "Backup creado: backups/$backup_file"
}

# Función para restaurar proyecto
restore_project() {
    local project_name="$1"
    local backup_file="$2"
    
    if [[ -z "$project_name" || -z "$backup_file" ]]; then
        print_error "Debe especificar nombre del proyecto y archivo de backup"
        exit 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        print_error "El archivo de backup '$backup_file' no existe"
        exit 1
    fi
    
    if [[ -d "$project_name" ]]; then
        print_error "El proyecto '$project_name' ya existe"
        exit 1
    fi
    
    print_message "Restaurando proyecto '$project_name' desde '$backup_file'..."
    
    tar -xzf "$backup_file"
    
    print_message "Proyecto '$project_name' restaurado"
}

# Parsear argumentos
COMMAND=""
PROJECT_NAME=""
SERVICE_NAME=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        list|start|stop|restart|logs|status|create|delete|backup|restore)
            COMMAND="$1"
            shift
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            elif [[ -z "$SERVICE_NAME" ]]; then
                SERVICE_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Ejecutar comando
case $COMMAND in
    list)
        list_projects
        ;;
    start)
        start_project "$PROJECT_NAME"
        ;;
    stop)
        stop_project "$PROJECT_NAME"
        ;;
    restart)
        restart_project "$PROJECT_NAME"
        ;;
    logs)
        show_logs "$PROJECT_NAME" "$SERVICE_NAME"
        ;;
    status)
        show_status "$PROJECT_NAME"
        ;;
    create)
        create_project "$PROJECT_NAME"
        ;;
    delete)
        delete_project "$PROJECT_NAME"
        ;;
    backup)
        backup_project "$PROJECT_NAME"
        ;;
    restore)
        restore_project "$PROJECT_NAME" "$SERVICE_NAME"
        ;;
    "")
        show_help
        exit 1
        ;;
    *)
        print_error "Comando desconocido: $COMMAND"
        show_help
        exit 1
        ;;
esac 