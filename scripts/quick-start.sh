#!/bin/bash

# ===========================================
# SCRIPT DE INICIO RÁPIDO - DEMOSTRACIÓN
# ===========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_step() {
    echo -e "${CYAN}[PASO $1]${NC} $2"
}

# Función para verificar prerrequisitos
check_prerequisites() {
    print_header "VERIFICANDO PRERREQUISITOS"
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor, instala Docker primero."
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado. Por favor, instala Docker Compose primero."
        exit 1
    fi
    
    # Verificar que Docker esté ejecutándose
    if ! docker info &> /dev/null; then
        print_error "Docker no está ejecutándose. Por favor, inicia Docker."
        exit 1
    fi
    
    print_message "✅ Todos los prerrequisitos están satisfechos"
}

# Función para crear proyecto de demostración
create_demo_project() {
    print_header "CREANDO PROYECTO DE DEMOSTRACIÓN"
    
    local demo_name="demo-mean-stack"
    
    if [[ -d "$demo_name" ]]; then
        print_warning "El proyecto de demostración ya existe. Eliminando..."
        rm -rf "$demo_name"
    fi
    
    print_step "1" "Creando proyecto básico..."
    ./scripts/create-project.sh "$demo_name"
    
    print_step "2" "Configurando variables de entorno..."
    cd "$demo_name"
    
    # Personalizar configuración para demostración
    sed -i 's/BACKEND_PORT=3000/BACKEND_PORT=3001/' .env
    sed -i 's/FRONTEND_PORT=4200/FRONTEND_PORT=4201/' .env
    sed -i 's/MONGO_PORT=2717/MONGO_PORT=2718/' .env
    
    print_message "✅ Proyecto de demostración creado: $demo_name"
}

# Función para iniciar servicios
start_services() {
    print_header "INICIANDO SERVICIOS"
    
    print_step "3" "Iniciando contenedores..."
    ./start.sh
    
    # Esperar un momento para que los servicios se inicien
    print_step "4" "Esperando que los servicios estén listos..."
    sleep 10
    
    print_message "✅ Servicios iniciados correctamente"
}

# Función para verificar servicios
verify_services() {
    print_header "VERIFICANDO SERVICIOS"
    
    print_step "5" "Verificando estado de contenedores..."
    docker-compose ps
    
    print_step "6" "Verificando conectividad..."
    
    # Verificar backend
    if curl -s http://localhost:3001/api/health &> /dev/null; then
        print_message "✅ Backend API funcionando en http://localhost:3001"
    else
        print_warning "⚠️  Backend API no responde aún (puede estar iniciando)"
    fi
    
    # Verificar frontend
    if curl -s http://localhost:4201 &> /dev/null; then
        print_message "✅ Frontend Angular funcionando en http://localhost:4201"
    else
        print_warning "⚠️  Frontend Angular no responde aún (puede estar iniciando)"
    fi
    
    # Verificar MongoDB
    if docker-compose exec -T db mongosh --eval "db.runCommand('ping')" &> /dev/null; then
        print_message "✅ MongoDB funcionando en puerto 2718"
    else
        print_warning "⚠️  MongoDB no responde aún (puede estar iniciando)"
    fi
}

# Función para mostrar información final
show_final_info() {
    print_header "🎉 DEMOSTRACIÓN COMPLETADA"
    
    echo -e "${GREEN}¡Tu entorno MEAN Stack está listo!${NC}"
    echo ""
    echo -e "${CYAN}📊 Servicios disponibles:${NC}"
    echo -e "   Backend API: ${GREEN}http://localhost:3001${NC}"
    echo -e "   Frontend Angular: ${GREEN}http://localhost:4201${NC}"
    echo -e "   MongoDB: ${GREEN}mongodb://localhost:2718${NC}"
    echo ""
    echo -e "${CYAN}🛠️  Comandos útiles:${NC}"
    echo -e "   Ver logs: ${YELLOW}./logs.sh${NC}"
    echo -e "   Detener servicios: ${YELLOW}./stop.sh${NC}"
    echo -e "   Acceder al backend: ${YELLOW}docker-compose exec backend bash${NC}"
    echo -e "   Acceder al frontend: ${YELLOW}docker-compose exec frontend bash${NC}"
    echo -e "   Acceder a MongoDB: ${YELLOW}docker-compose exec db mongosh -u root -p example${NC}"
    echo ""
    echo -e "${CYAN}📚 Próximos pasos:${NC}"
    echo -e "   1. Abre http://localhost:4201 en tu navegador"
    echo -e "   2. Explora la API en http://localhost:3001"
    echo -e "   3. Comienza a desarrollar en las carpetas backend/ y frontend/"
    echo -e "   4. Crea más proyectos con: ${YELLOW}../scripts/create-project.sh mi-nuevo-proyecto${NC}"
    echo ""
    echo -e "${BLUE}¡Disfruta desarrollando con tu entorno MEAN Stack! 🚀${NC}"
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -h, --help     Mostrar esta ayuda"
    echo "  -s, --skip-demo Solo verificar prerrequisitos"
    echo "  -c, --clean    Limpiar proyecto de demostración al final"
    echo ""
    echo "Este script crea un proyecto de demostración para mostrar"
    echo "las capacidades del entorno MEAN Stack."
}

# Variables
SKIP_DEMO=false
CLEAN_UP=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--skip-demo)
            SKIP_DEMO=true
            shift
            ;;
        -c|--clean)
            CLEAN_UP=true
            shift
            ;;
        *)
            print_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Función principal
main() {
    print_header "🚀 INICIO RÁPIDO - ENTORNO MEAN STACK"
    
    # Verificar prerrequisitos
    check_prerequisites
    
    if [[ "$SKIP_DEMO" == true ]]; then
        print_message "Modo solo verificación activado. Saltando creación de proyecto."
        exit 0
    fi
    
    # Crear proyecto de demostración
    create_demo_project
    
    # Iniciar servicios
    start_services
    
    # Verificar servicios
    verify_services
    
    # Mostrar información final
    show_final_info
    
    # Limpiar si se solicita
    if [[ "$CLEAN_UP" == true ]]; then
        echo ""
        print_warning "¿Deseas eliminar el proyecto de demostración? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            cd ..
            rm -rf demo-mean-stack
            print_message "Proyecto de demostración eliminado"
        fi
    fi
}

# Ejecutar función principal
main "$@" 