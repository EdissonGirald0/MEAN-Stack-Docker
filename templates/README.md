# Plantillas MEAN Stack

Este directorio contiene plantillas predefinidas para diferentes tipos de proyectos MEAN Stack.

## Plantillas Disponibles

### 1. Basic Template
**Descripción**: Plantilla básica con estructura mínima
**Comando**: `./scripts/create-project.sh -t basic mi-proyecto`

**Características**:
- Backend Express básico
- Frontend Angular básico
- MongoDB configurado
- Hot reload habilitado

### 2. Auth Template
**Descripción**: Plantilla con autenticación JWT
**Comando**: `./scripts/create-project.sh -t auth mi-proyecto-auth`

**Características**:
- Sistema de autenticación JWT
- Middleware de autorización
- Modelos de usuario
- Rutas protegidas
- Interceptores Angular para tokens

### 3. E-commerce Template
**Descripción**: Plantilla para aplicaciones de comercio electrónico
**Comando**: `./scripts/create-project.sh -t ecommerce mi-tienda`

**Características**:
- Gestión de productos
- Carrito de compras
- Sistema de pedidos
- Gestión de usuarios
- Panel de administración

### 4. API Template
**Descripción**: Plantilla para APIs RESTful
**Comando**: `./scripts/create-project.sh -t api mi-api`

**Características**:
- Estructura modular
- Validación de datos
- Documentación automática (Swagger)
- Rate limiting
- Logging avanzado

## Estructura de Plantillas

```
templates/
├── basic/
│   ├── backend/
│   │   ├── src/
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── frontend/
│   │   ├── src/
│   │   ├── package.json
│   │   └── Dockerfile
│   └── config/
├── auth/
│   ├── backend/
│   ├── frontend/
│   └── config/
├── ecommerce/
│   ├── backend/
│   ├── frontend/
│   └── config/
└── api/
    ├── backend/
    ├── frontend/
    └── config/
```

## Crear Plantilla Personalizada

Para crear una nueva plantilla:

1. Crear directorio en `templates/nombre-plantilla/`
2. Copiar estructura básica
3. Personalizar según necesidades
4. Actualizar script `create-project.sh`

### Ejemplo de Plantilla Personalizada

```bash
# Crear estructura
mkdir -p templates/mi-plantilla/{backend,frontend,config}

# Copiar archivos base
cp -r templates/basic/* templates/mi-plantilla/

# Personalizar
# ... modificar archivos según necesidades

# Actualizar script de creación
# Editar scripts/create-project.sh para incluir nueva plantilla
```

## Variables de Entorno por Plantilla

Cada plantilla puede tener sus propias variables de entorno:

### Basic Template
```env
PROJECT_NAME=mi-proyecto
NODE_ENV=development
BACKEND_PORT=3000
FRONTEND_PORT=4200
```

### Auth Template
```env
PROJECT_NAME=mi-proyecto-auth
NODE_ENV=development
BACKEND_PORT=3000
FRONTEND_PORT=4200
JWT_SECRET=mi-secreto-jwt
JWT_EXPIRES_IN=24h
```

### E-commerce Template
```env
PROJECT_NAME=mi-tienda
NODE_ENV=development
BACKEND_PORT=3000
FRONTEND_PORT=4200
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### API Template
```env
PROJECT_NAME=mi-api
NODE_ENV=development
BACKEND_PORT=3000
FRONTEND_PORT=4200
RATE_LIMIT_WINDOW=15m
RATE_LIMIT_MAX=100
```

## Comandos Útiles

### Listar proyectos
```bash
./scripts/manage-projects.sh list
```

### Crear proyecto con plantilla específica
```bash
./scripts/create-project.sh -t auth mi-proyecto-auth
```

### Iniciar proyecto
```bash
./scripts/manage-projects.sh start mi-proyecto
```

### Ver logs
```bash
./scripts/manage-projects.sh logs mi-proyecto backend
```

### Hacer backup
```bash
./scripts/manage-projects.sh backup mi-proyecto
```

## Mejores Prácticas

1. **Nomenclatura**: Usar nombres descriptivos para proyectos
2. **Puertos**: Evitar conflictos de puertos entre proyectos
3. **Variables de entorno**: Nunca subir archivos .env al repositorio
4. **Backups**: Hacer backups regulares de proyectos importantes
5. **Documentación**: Mantener README actualizado en cada proyecto

## Solución de Problemas

### Puerto en uso
```bash
# Cambiar puerto en .env del proyecto
BACKEND_PORT=3001
FRONTEND_PORT=4201
```

### Conflicto de nombres de contenedores
```bash
# Cambiar nombre del proyecto en .env
PROJECT_NAME=mi-proyecto-unico
```

### Problemas de permisos
```bash
# Dar permisos de ejecución a scripts
chmod +x scripts/*.sh
```

## Contribuir

Para contribuir con nuevas plantillas:

1. Crear nueva plantilla siguiendo la estructura existente
2. Documentar características y configuración
3. Probar con diferentes configuraciones
4. Actualizar documentación
5. Crear Pull Request 