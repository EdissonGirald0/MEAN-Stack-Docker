# 🚀 Entorno de Desarrollo MEAN Stack con Docker

Un entorno completo y flexible para crear y gestionar múltiples proyectos MEAN Stack (MongoDB, Express.js, Angular, Node.js) de forma aislada usando Docker y scripts automatizados.

## ✨ Características Principales

- **🔧 Múltiples Proyectos**: Desarrolla varios proyectos MEAN Stack simultáneamente
- **🎯 Aislamiento Total**: Cada proyecto tiene sus propios contenedores, puertos y recursos
- **⚡ Configuración Flexible**: Variables de entorno personalizables por proyecto
- **🛠️ Scripts Automatizados**: Gestión completa con comandos simples
- **📦 Plantillas Reutilizables**: Estructuras base para diferentes tipos de aplicaciones
- **🔄 Hot Reload**: Desarrollo con recarga automática
- **🔒 Seguridad**: Configuración de seguridad por defecto

## 📋 Prerrequisitos

- **Docker** y **Docker Compose**
- **Git**
- **Node.js 18+** (opcional, para desarrollo local)

## 🚀 Inicio Rápido

### 1. Clonar y Configurar
```bash
git clone <url-repositorio>
cd MEAN-Stack-Docker
chmod +x scripts/*.sh
```

### 2. Crear tu Primer Proyecto
```bash
# Proyecto básico
./scripts/create-project.sh mi-primer-proyecto

# Proyecto con puerto específico
./scripts/create-project.sh -p 4000 mi-proyecto-produccion
```

### 3. Iniciar y Desarrollar
```bash
cd mi-primer-proyecto
./start.sh

# Acceder a los servicios:
# Backend: http://localhost:3000
# Frontend: http://localhost:4200
# MongoDB: mongodb://localhost:2717
```

## 🛠️ Gestión de Proyectos

### Comandos Principales
```bash
# Listar todos los proyectos
./scripts/manage-projects.sh list

# Crear nuevo proyecto
./scripts/manage-projects.sh create mi-nuevo-proyecto

# Gestionar proyecto específico
./scripts/manage-projects.sh start mi-proyecto
./scripts/manage-projects.sh stop mi-proyecto
./scripts/manage-projects.sh restart mi-proyecto
./scripts/manage-projects.sh logs mi-proyecto
./scripts/manage-projects.sh status mi-proyecto

# Eliminar proyecto
./scripts/manage-projects.sh delete mi-proyecto

# Backup y restauración
./scripts/manage-projects.sh backup mi-proyecto
./scripts/manage-projects.sh restore mi-proyecto archivo-backup.tar.gz
```

### Scripts Individuales por Proyecto
```bash
cd mi-proyecto
./start.sh    # Iniciar servicios
./stop.sh     # Detener servicios
./logs.sh     # Ver logs
```

## 📁 Estructura del Proyecto

```
MEAN-Stack-Docker/
├── scripts/                 # Scripts de gestión
│   ├── create-project.sh   # Crear nuevos proyectos
│   ├── manage-projects.sh  # Gestionar proyectos
│   └── quick-start.sh      # Demostración rápida
├── templates/              # Plantillas predefinidas
│   └── README.md          # Documentación de plantillas
├── docker-compose.yml      # Configuración base Docker
├── env.example            # Variables de entorno de ejemplo
├── .gitignore             # Archivos ignorados por Git
└── README.md              # Esta documentación

# Proyectos creados (no se suben al repo)
mi-proyecto-1/
├── backend/               # API Node.js/Express
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── frontend/              # Aplicación Angular
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── mongo/                # Scripts MongoDB
├── .env                  # Variables del proyecto
├── docker-compose.yml    # Configuración específica
├── start.sh             # Script de inicio
├── stop.sh              # Script de parada
└── logs.sh              # Script de logs
```

## ⚙️ Configuración

### Variables de Entorno por Proyecto
Cada proyecto tiene su propio archivo `.env`:

```env
# Configuración del proyecto
PROJECT_NAME=mi-proyecto
NODE_ENV=development

# Puertos (únicos por proyecto)
BACKEND_PORT=3000
FRONTEND_PORT=4200
MONGO_PORT=2717

# MongoDB
MONGO_ROOT_USER=root
MONGO_ROOT_PASSWORD=example
MONGO_DATABASE=miProyectoDB

# Seguridad
JWT_SECRET=mi-secreto-jwt
CORS_ORIGIN=http://localhost:4200

# Servicios opcionales
REDIS_PORT=6379
NGINX_PORT=80
NGINX_SSL_PORT=443
```

### Personalización de Puertos
Los proyectos usan puertos únicos automáticamente:
- **Proyecto 1**: Backend:3000, Frontend:4200, MongoDB:2717
- **Proyecto 2**: Backend:3001, Frontend:4201, MongoDB:2718
- **Proyecto 3**: Backend:3002, Frontend:4202, MongoDB:2719

## 🔧 Desarrollo

### Acceso a Contenedores
```bash
# Backend
docker-compose exec backend bash
npm install nueva-dependencia

# Frontend
docker-compose exec frontend bash
ng generate component mi-componente

# MongoDB
docker-compose exec db mongosh -u root -p example
```

### Hot Reload
- **Backend**: Los cambios en `backend/src` se recargan automáticamente
- **Frontend**: Los cambios en `frontend/src` se recargan automáticamente
- **MongoDB**: Persistencia de datos en volúmenes Docker

### Logs en Tiempo Real
```bash
# Todos los servicios
./logs.sh

# Servicio específico
./logs.sh backend
./logs.sh frontend
./logs.sh db
```

## 🚀 Producción

### Configuración para Producción
```bash
# Crear proyecto para producción
./scripts/create-project.sh -p 4000 mi-api-produccion

# Configurar variables de producción
cd mi-api-produccion
# Editar .env con configuración de producción
```

### Servicios Opcionales
```bash
# Incluir Redis para caché
docker-compose --profile cache up -d

# Incluir Nginx como proxy reverso
docker-compose --profile production up -d
```

## 🧹 Mantenimiento

### Limpiar Proyectos de Prueba
```bash
# Eliminar proyectos de prueba
./scripts/manage-projects.sh delete demo-mean-stack
./scripts/manage-projects.sh delete proyecto-test

# Limpiar recursos Docker
docker system prune -a
docker volume prune
```

### Backup y Restauración
```bash
# Crear backup
./scripts/manage-projects.sh backup mi-proyecto-importante

# Restaurar desde backup
./scripts/manage-projects.sh restore mi-proyecto-nuevo backup.tar.gz
```

## 🔒 Seguridad

### Configuración por Defecto
- Credenciales de MongoDB personalizables
- JWT secrets únicos por proyecto
- CORS configurado
- Variables de entorno separadas

### Mejores Prácticas
1. **Cambiar credenciales por defecto** en producción
2. **Usar secrets de Docker** para credenciales sensibles
3. **Configurar firewall** y acceso restringido
4. **Mantener dependencias actualizadas**
5. **Hacer backups regulares** de proyectos importantes

## 🛠️ Solución de Problemas

### Puerto en Uso
```bash
# Cambiar puerto en .env del proyecto
BACKEND_PORT=3001
FRONTEND_PORT=4201
```

### Conflicto de Contenedores
```bash
# Cambiar nombre del proyecto
PROJECT_NAME=mi-proyecto-unico
```

### Problemas de Permisos
```bash
# Dar permisos de ejecución
chmod +x scripts/*.sh
chmod +x */start.sh */stop.sh */logs.sh
```

### Limpiar Recursos
```bash
# Detener y eliminar contenedores
docker-compose down -v

# Eliminar imágenes no utilizadas
docker system prune -a
```

## 📚 Recursos Adicionales

- **Plantillas**: Consulta `templates/README.md` para plantillas avanzadas
- **Scripts**: Revisa `scripts/` para comandos adicionales
- **Docker**: Documentación oficial de Docker Compose

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

**¡Disfruta desarrollando con tu entorno MEAN Stack! 🚀**