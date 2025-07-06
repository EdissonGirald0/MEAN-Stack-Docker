#!/bin/bash

# ===========================================
# SCRIPT INTERACTIVO PARA CREAR PROYECTOS MEAN STACK
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

# Función para validar entrada
validate_input() {
    if [[ -z "$1" ]]; then
        print_error "El nombre del proyecto no puede estar vacío"
        return 1
    fi
    
    if [[ ! "$1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "El nombre del proyecto solo puede contener letras, números, guiones y guiones bajos"
        return 1
    fi
    
    return 0
}

# Función para validar puerto
validate_port() {
    if [[ ! "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1024 ] || [ "$1" -gt 65535 ]; then
        print_error "El puerto debe ser un número entre 1024 y 65535"
        return 1
    fi
    
    # Verificar si el puerto está en uso
    if netstat -tuln 2>/dev/null | grep -q ":$1 "; then
        print_warning "El puerto $1 parece estar en uso"
        read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Función para solicitar información del proyecto
get_project_info() {
    print_header "CONFIGURACIÓN DEL PROYECTO"
    
    # Nombre del proyecto
    while true; do
        read -p "📝 Nombre del proyecto: " PROJECT_NAME
        if validate_input "$PROJECT_NAME"; then
            if [[ -d "$PROJECT_NAME" ]]; then
                print_error "El proyecto '$PROJECT_NAME' ya existe"
                continue
            fi
            break
        fi
    done
    
    # Descripción del proyecto
    read -p "📄 Descripción del proyecto (opcional): " PROJECT_DESCRIPTION
    PROJECT_DESCRIPTION=${PROJECT_DESCRIPTION:-"Proyecto MEAN Stack"}
    
    # Puerto base
    while true; do
        read -p "🔌 Puerto base para el proyecto (3000): " BASE_PORT
        BASE_PORT=${BASE_PORT:-3000}
        if validate_port "$BASE_PORT"; then
            break
        fi
    done
    
    # Entorno de desarrollo
    echo -e "\n🌍 Entorno de desarrollo:"
    echo "1) Development (recomendado para desarrollo)"
    echo "2) Production (para producción)"
    echo "3) Testing (para pruebas)"
    
    while true; do
        read -p "Selecciona el entorno (1-3) [1]: " ENV_CHOICE
        ENV_CHOICE=${ENV_CHOICE:-1}
        case $ENV_CHOICE in
            1) NODE_ENV="development"; break ;;
            2) NODE_ENV="production"; break ;;
            3) NODE_ENV="testing"; break ;;
            *) print_error "Opción inválida. Selecciona 1, 2 o 3." ;;
        esac
    done
    
    # Versión de Node.js
    echo -e "\n📦 Versión de Node.js:"
    echo "1) Node.js 18 (recomendado)"
    echo "2) Node.js 20 (última LTS)"
    echo "3) Node.js 16 (legacy)"
    
    while true; do
        read -p "Selecciona la versión (1-3) [1]: " NODE_CHOICE
        NODE_CHOICE=${NODE_CHOICE:-1}
        case $NODE_CHOICE in
            1) NODE_VERSION="18"; break ;;
            2) NODE_VERSION="20"; break ;;
            3) NODE_VERSION="16"; break ;;
            *) print_error "Opción inválida. Selecciona 1, 2 o 3." ;;
        esac
    done
    
    # Configuración de MongoDB
    echo -e "\n🗄️  Configuración de MongoDB:"
    read -p "Usuario de MongoDB (root): " MONGO_USER
    MONGO_USER=${MONGO_USER:-root}
    
    read -s -p "Contraseña de MongoDB (example): " MONGO_PASSWORD
    echo
    MONGO_PASSWORD=${MONGO_PASSWORD:-example}
    
    # Configuración de seguridad
    echo -e "\n🔒 Configuración de seguridad:"
    read -s -p "JWT Secret (se generará automáticamente si está vacío): " JWT_SECRET
    echo
    if [[ -z "$JWT_SECRET" ]]; then
        JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "your-super-secret-jwt-key-change-this-in-production")
    fi
    
    # Configuración de CORS
    echo -e "\n🌐 Configuración de CORS:"
    read -p "Origen permitido para CORS (http://localhost:$((BASE_PORT + 120))): " CORS_ORIGIN
    CORS_ORIGIN=${CORS_ORIGIN:-"http://localhost:$((BASE_PORT + 120))"}
    
    # Servicios adicionales
    echo -e "\n🔧 Servicios adicionales:"
    read -p "¿Incluir Redis para caché? (y/N): " -n 1 -r INCLUDE_REDIS
    echo
    INCLUDE_REDIS=${INCLUDE_REDIS:-n}
    
    read -p "¿Incluir Nginx como proxy reverso? (y/N): " -n 1 -r INCLUDE_NGINX
    echo
    INCLUDE_NGINX=${INCLUDE_NGINX:-n}
    
    # Configuración de logs
    echo -e "\n📊 Configuración de logs:"
    read -p "¿Habilitar logs detallados? (y/N): " -n 1 -r VERBOSE_LOGS
    echo
    VERBOSE_LOGS=${VERBOSE_LOGS:-n}
    
    # Confirmación final
    print_header "RESUMEN DE CONFIGURACIÓN"
    echo -e "📝 Nombre del proyecto: ${GREEN}$PROJECT_NAME${NC}"
    echo -e "📄 Descripción: ${GREEN}$PROJECT_DESCRIPTION${NC}"
    echo -e "🔌 Puerto base: ${GREEN}$BASE_PORT${NC}"
    echo -e "🌍 Entorno: ${GREEN}$NODE_ENV${NC}"
    echo -e "📦 Node.js: ${GREEN}v$NODE_VERSION${NC}"
    echo -e "🗄️  MongoDB: ${GREEN}$MONGO_USER@localhost:$((BASE_PORT + 17))${NC}"
    echo -e "🌐 CORS: ${GREEN}$CORS_ORIGIN${NC}"
    echo -e "🔧 Redis: ${GREEN}$([[ $INCLUDE_REDIS =~ ^[Yy]$ ]] && echo "Sí" || echo "No")${NC}"
    echo -e "🌐 Nginx: ${GREEN}$([[ $INCLUDE_NGINX =~ ^[Yy]$ ]] && echo "Sí" || echo "No")${NC}"
    echo -e "📊 Logs detallados: ${GREEN}$([[ $VERBOSE_LOGS =~ ^[Yy]$ ]] && echo "Sí" || echo "No")${NC}"
    
    echo -e "\n📊 Servicios que se crearán:"
    echo -e "   Backend: ${GREEN}http://localhost:$BASE_PORT${NC}"
    echo -e "   Frontend: ${GREEN}http://localhost:$((BASE_PORT + 120))${NC}"
    echo -e "   MongoDB: ${GREEN}mongodb://localhost:$((BASE_PORT + 17))${NC}"
    if [[ $INCLUDE_REDIS =~ ^[Yy]$ ]]; then
        echo -e "   Redis: ${GREEN}localhost:$((BASE_PORT + 379))${NC}"
    fi
    if [[ $INCLUDE_NGINX =~ ^[Yy]$ ]]; then
        echo -e "   Nginx: ${GREEN}http://localhost:80${NC}"
    fi
    
    echo
    read -p "¿Continuar con la creación del proyecto? (Y/n): " -n 1 -r CONFIRM
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_message "Creación del proyecto cancelada"
        exit 0
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -h, --help     Mostrar esta ayuda"
    echo "  -n, --name     Nombre del proyecto (modo no interactivo)"
    echo "  -p, --port     Puerto base (modo no interactivo)"
    echo "  -e, --env      Entorno (development/production/testing)"
    echo "  -v, --node     Versión de Node.js (16/18/20)"
    echo ""
    echo "Ejemplos:"
    echo "  $0                    # Modo interactivo"
    echo "  $0 -n mi-proyecto     # Crear con nombre específico"
    echo "  $0 -n api -p 4000     # Crear API en puerto 4000"
}

# Variables por defecto
INTERACTIVE=true
PROJECT_NAME=""
BASE_PORT=3000
NODE_ENV="development"
NODE_VERSION="18"

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--name)
            PROJECT_NAME="$2"
            INTERACTIVE=false
            shift 2
            ;;
        -p|--port)
            BASE_PORT="$2"
            shift 2
            ;;
        -e|--env)
            NODE_ENV="$2"
            shift 2
            ;;
        -v|--node)
            NODE_VERSION="$2"
            shift 2
            ;;
        -*)
            print_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
                INTERACTIVE=false
            fi
            shift
            ;;
    esac
done

# Si no se proporcionó nombre en modo no interactivo, mostrar ayuda
if [[ -z "$PROJECT_NAME" && "$INTERACTIVE" == false ]]; then
    print_error "Debe proporcionar un nombre para el proyecto"
    show_help
    exit 1
fi

# Modo interactivo
if [[ "$INTERACTIVE" == true ]]; then
    get_project_info
else
    # Validar entrada en modo no interactivo
    if ! validate_input "$PROJECT_NAME"; then
        exit 1
    fi
    
    if [[ -d "$PROJECT_NAME" ]]; then
        print_error "El proyecto '$PROJECT_NAME' ya existe"
        exit 1
    fi
    
    # Valores por defecto para modo no interactivo
    PROJECT_DESCRIPTION="Proyecto MEAN Stack"
    MONGO_USER="root"
    MONGO_PASSWORD="example"
    JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
    CORS_ORIGIN="http://localhost:$((BASE_PORT + 120))"
    INCLUDE_REDIS="n"
    INCLUDE_NGINX="n"
    VERBOSE_LOGS="n"
fi

print_header "CREANDO PROYECTO MEAN STACK"
print_message "Nombre del proyecto: $PROJECT_NAME"
print_message "Puerto base: $BASE_PORT"
print_message "Entorno: $NODE_ENV"
print_message "Node.js: v$NODE_VERSION"

# Crear estructura de directorios
print_step "1" "Creando estructura de directorios..."
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Crear subdirectorios
mkdir -p {backend,frontend,mongo,nginx,scripts,docs}

# Crear archivos básicos para el backend
print_step "2" "Creando archivos básicos del backend..."
mkdir -p backend/src

# Package.json del backend
cat > backend/package.json << EOF
{
  "name": "backend",
  "version": "1.0.0",
  "description": "$PROJECT_DESCRIPTION - Backend API",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.2"
  },
  "keywords": ["express", "mongodb", "api", "mean-stack"],
  "author": "",
  "license": "MIT"
}
EOF

# Dockerfile del backend
cat > backend/Dockerfile << EOF
FROM node:$NODE_VERSION-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
EOF

# .dockerignore del backend
cat > backend/.dockerignore << 'EOF'
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
coverage
.nyc_output
EOF

# Aplicación Express básica
cat > backend/src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:4200',
  credentials: true
}));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas básicas
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Backend API funcionando correctamente',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    project: process.env.PROJECT_NAME || 'unknown'
  });
});

app.get('/api', (req, res) => {
  res.json({
    message: 'Bienvenido a la API MEAN Stack',
    version: '1.0.0',
    project: process.env.PROJECT_NAME || 'unknown',
    endpoints: {
      health: '/api/health',
      docs: '/api/docs'
    }
  });
});

// Ruta de prueba
app.get('/api/test', (req, res) => {
  res.json({
    message: 'Endpoint de prueba funcionando',
    data: {
      project: process.env.PROJECT_NAME || 'unknown',
      port: PORT,
      environment: process.env.NODE_ENV || 'development'
    }
  });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Algo salió mal!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Error interno del servidor'
  });
});

// Ruta 404
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.originalUrl
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor backend ejecutándose en puerto ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🌍 Entorno: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📝 Proyecto: ${process.env.PROJECT_NAME || 'unknown'}`);
});

module.exports = app;
EOF

# Crear archivos básicos para el frontend
print_step "3" "Creando archivos básicos del frontend..."
mkdir -p frontend/src

# Package.json del frontend
cat > frontend/package.json << EOF
{
  "name": "frontend",
  "version": "1.0.0",
  "description": "$PROJECT_DESCRIPTION - Frontend Angular",
  "scripts": {
    "ng": "ng",
    "start": "ng serve --host 0.0.0.0 --port 4200",
    "build": "ng build",
    "watch": "ng build --watch --configuration development",
    "test": "ng test"
  },
  "private": true,
  "dependencies": {
    "@angular/animations": "^16.1.0",
    "@angular/common": "^16.1.0",
    "@angular/compiler": "^16.1.0",
    "@angular/core": "^16.1.0",
    "@angular/forms": "^16.1.0",
    "@angular/platform-browser": "^16.1.0",
    "@angular/platform-browser-dynamic": "^16.1.0",
    "@angular/router": "^16.1.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.13.0"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^16.1.0",
    "@angular/cli": "^16.1.0",
    "@angular/compiler-cli": "^16.1.0",
    "@types/jasmine": "~4.3.0",
    "jasmine-core": "~4.6.0",
    "karma": "~6.4.0",
    "karma-chrome-launcher": "~3.2.0",
    "karma-coverage": "~2.2.0",
    "karma-jasmine": "~5.1.0",
    "karma-jasmine-html-reporter": "~2.1.0",
    "typescript": "~5.1.3"
  }
}
EOF

# Dockerfile del frontend
cat > frontend/Dockerfile << EOF
FROM node:$NODE_VERSION-alpine

WORKDIR /app

# Instalar Angular CLI globalmente
RUN npm install -g @angular/cli

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 4200

CMD ["npm", "start"]
EOF

# .dockerignore del frontend
cat > frontend/.dockerignore << 'EOF'
node_modules
npm-debug.log
dist
.git
.gitignore
README.md
coverage
.nyc_output
EOF

# Crear script de inicialización de MongoDB
print_step "4" "Creando script de inicialización de MongoDB..."
cat > mongo/init.js << EOF
// Script de inicialización para MongoDB
// Este script se ejecuta automáticamente cuando se inicia el contenedor de MongoDB

print('Inicializando base de datos...');

// Crear usuario para la base de datos del proyecto
db.createUser({
  user: "$MONGO_USER",
  pwd: "$MONGO_PASSWORD",
  roles: [
    { role: "readWrite", db: "${PROJECT_NAME}DB" },
    { role: "dbAdmin", db: "${PROJECT_NAME}DB" }
  ]
});

// Cambiar a la base de datos del proyecto
db = db.getSiblingDB("${PROJECT_NAME}DB");

// Crear colecciones básicas
db.createCollection("users");
db.createCollection("sessions");

// Crear índices básicos
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "username": 1 }, { unique: true });

print('Base de datos inicializada correctamente');
print('Colecciones creadas: users, sessions');
print('Índices creados: email (único), username (único)');
EOF

# Crear archivo .env para el proyecto
print_step "5" "Configurando variables de entorno..."
cat > .env << EOF
# ===========================================
# CONFIGURACIÓN DEL PROYECTO: $PROJECT_NAME
# ===========================================

# Información del proyecto
PROJECT_NAME=$PROJECT_NAME
PROJECT_DESCRIPTION=$PROJECT_DESCRIPTION

# ===========================================
# CONFIGURACIÓN DE MONGODB
# ===========================================
MONGO_ROOT_USER=$MONGO_USER
MONGO_ROOT_PASSWORD=$MONGO_PASSWORD
MONGO_DATABASE=${PROJECT_NAME}DB
MONGO_PORT=$((BASE_PORT + 17))

# ===========================================
# CONFIGURACIÓN DEL BACKEND
# ===========================================
BACKEND_PORT=$BASE_PORT
NODE_ENV=$NODE_ENV
NODE_VERSION=$NODE_VERSION
JWT_SECRET=$JWT_SECRET
CORS_ORIGIN=$CORS_ORIGIN

# ===========================================
# CONFIGURACIÓN DEL FRONTEND
# ===========================================
FRONTEND_PORT=$((BASE_PORT + 120))

# ===========================================
# SERVICIOS OPCIONALES
# ===========================================
REDIS_PORT=$((BASE_PORT + 379))
NGINX_PORT=80
NGINX_SSL_PORT=443

# ===========================================
# CONFIGURACIÓN DE DESARROLLO
# ===========================================
HOT_RELOAD=true
VERBOSE_LOGS=$([[ $VERBOSE_LOGS =~ ^[Yy]$ ]] && echo "true" || echo "false")

# ===========================================
# CONFIGURACIÓN DE SEGURIDAD
# ===========================================
ENABLE_SSL=false
SSL_CERT_PATH=./nginx/ssl/cert.pem
SSL_KEY_PATH=./nginx/ssl/key.pem

# ===========================================
# SERVICIOS ADICIONALES
# ===========================================
INCLUDE_REDIS=$([[ $INCLUDE_REDIS =~ ^[Yy]$ ]] && echo "true" || echo "false")
INCLUDE_NGINX=$([[ $INCLUDE_NGINX =~ ^[Yy]$ ]] && echo "true" || echo "false")
EOF

# Copiar docker-compose.yml
print_step "6" "Configurando Docker Compose..."
cp ../docker-compose.yml .

# Crear script de inicio
cat > start.sh << 'EOF'
#!/bin/bash
# Cargar variables de entorno
if [[ -f ".env" ]]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "🚀 Iniciando proyecto $PROJECT_NAME..."
echo "📝 Descripción: $PROJECT_DESCRIPTION"
echo "🌍 Entorno: $NODE_ENV"

# Construir e iniciar servicios
docker-compose up -d --build

echo "✅ Proyecto iniciado correctamente"
echo "📊 Backend: http://localhost:${BACKEND_PORT:-3000}"
echo "🌐 Frontend: http://localhost:${FRONTEND_PORT:-4200}"
echo "🗄️  MongoDB: mongodb://localhost:${MONGO_PORT:-27017}"

if [[ "$INCLUDE_REDIS" == "true" ]]; then
    echo "🔴 Redis: localhost:${REDIS_PORT:-6379}"
fi

if [[ "$INCLUDE_NGINX" == "true" ]]; then
    echo "🌐 Nginx: http://localhost:${NGINX_PORT:-80}"
fi

echo ""
echo "🛠️  Comandos útiles:"
echo "   Ver logs: ./logs.sh"
echo "   Detener: ./stop.sh"
echo "   Acceder al backend: docker-compose exec backend bash"
echo "   Acceder al frontend: docker-compose exec frontend bash"
echo "   Acceder a MongoDB: docker-compose exec db mongosh -u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD"
EOF

chmod +x start.sh

# Crear script de parada
cat > stop.sh << 'EOF'
#!/bin/bash
echo "🛑 Deteniendo proyecto $PROJECT_NAME..."
docker-compose down
echo "✅ Proyecto detenido"
EOF

chmod +x stop.sh

# Crear script de logs
cat > logs.sh << 'EOF'
#!/bin/bash
if [[ -z "$1" ]]; then
    docker-compose logs -f
else
    docker-compose logs -f "$1"
fi
EOF

chmod +x logs.sh

# Crear README específico del proyecto
cat > README.md << EOF
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## 📊 Información del Proyecto

- **Nombre**: $PROJECT_NAME
- **Descripción**: $PROJECT_DESCRIPTION
- **Entorno**: $NODE_ENV
- **Node.js**: v$NODE_VERSION
- **Creado**: $(date '+%Y-%m-%d %H:%M:%S')

## 🚀 Inicio Rápido

\`\`\`bash
# Iniciar el proyecto
./start.sh

# Ver logs
./logs.sh

# Detener el proyecto
./stop.sh
\`\`\`

## 📊 Servicios

- **Backend**: http://localhost:$BASE_PORT
- **Frontend**: http://localhost:$((BASE_PORT + 120))
- **MongoDB**: mongodb://localhost:$((BASE_PORT + 17))
EOF

if [[ $INCLUDE_REDIS =~ ^[Yy]$ ]]; then
    cat >> README.md << EOF
- **Redis**: localhost:$((BASE_PORT + 379))
EOF
fi

if [[ $INCLUDE_NGINX =~ ^[Yy]$ ]]; then
    cat >> README.md << EOF
- **Nginx**: http://localhost:80
EOF
fi

cat >> README.md << EOF

## 🔧 Desarrollo

\`\`\`bash
# Acceder al backend
docker-compose exec backend bash

# Acceder al frontend
docker-compose exec frontend bash

# Acceder a MongoDB
docker-compose exec db mongosh -u $MONGO_USER -p $MONGO_PASSWORD
EOF

if [[ $INCLUDE_REDIS =~ ^[Yy]$ ]]; then
    cat >> README.md << EOF

# Acceder a Redis
docker-compose exec redis redis-cli
EOF
fi

cat >> README.md << EOF
\`\`\`

## 📁 Estructura

\`\`\`
$PROJECT_NAME/
├── backend/          # API Node.js/Express
├── frontend/         # Aplicación Angular
├── mongo/           # Scripts de inicialización de MongoDB
EOF

if [[ $INCLUDE_NGINX =~ ^[Yy]$ ]]; then
    cat >> README.md << EOF
├── nginx/           # Configuración de Nginx
EOF
fi

cat >> README.md << EOF
├── scripts/         # Scripts de utilidad
├── docs/            # Documentación del proyecto
├── .env             # Variables de entorno
├── docker-compose.yml
├── start.sh         # Script de inicio
├── stop.sh          # Script de parada
└── logs.sh          # Script de logs
\`\`\`

## 🔒 Configuración de Seguridad

- **JWT Secret**: Configurado automáticamente
- **MongoDB**: Usuario: $MONGO_USER
- **CORS**: Origen permitido: $CORS_ORIGIN

## 📝 Notas

- Los cambios en \`backend/src\` se recargan automáticamente
- Los cambios en \`frontend/src\` se recargan automáticamente
- La base de datos MongoDB persiste en volúmenes Docker
EOF

# Crear .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build outputs
dist/
build/
.next/
out/

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env.test

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

print_message "Proyecto '$PROJECT_NAME' creado exitosamente!"
print_message "Para comenzar:"
print_message "  cd $PROJECT_NAME"
print_message "  ./start.sh"

print_header "PRÓXIMOS PASOS"
echo "1. cd $PROJECT_NAME"
echo "2. ./start.sh"
echo "3. Personalizar la configuración en .env si es necesario"
echo "4. Comenzar a desarrollar en backend/ y frontend/"

print_warning "Recuerda cambiar las credenciales por defecto en producción"
print_message "¡Proyecto listo para desarrollar! 🚀" 