# Proyecto MEAN Stack con Docker

## Descripción
Implementación de una arquitectura MEAN Stack dockerizada para desarrollo.

## Prerrequisitos
- Docker y Docker Compose
- Node.js 18.x o superior (desarrollo local)
- Angular CLI (desarrollo local)

## Instalación Paso a Paso

### 1. Clonar el Repositorio
```bash
git clone <url-repositorio>
cd MEAN-Stack-Docker
```

### 2. Estructura de Directorios
```bash
mkdir -p backend/src/{config,models,routes,middleware}
mkdir -p frontend
mkdir -p mongo
```

### 3. Configuración Backend
1. Inicializar proyecto Node:
```bash
cd backend
npm init -y
```

2. Instalar dependencias:
```bash
npm install express mongoose cors dotenv nodemon
```

3. Crear archivo `.env`:
```bash
echo "NODE_ENV=development
PORT=3000
DB_URI=mongodb://root:example@db:27017/meanDB?authSource=admin" > .env
```

4. Crear `.dockerignore`:
```bash
echo "node_modules
.env" > .dockerignore
```

### 4. Configuración Frontend
1. Crear proyecto Angular:
```bash
ng new frontend --routing --style=scss
cd frontend
```

2. Crear `.dockerignore`:
```bash
echo "node_modules
dist" > .dockerignore
```

3. Crear proxy.conf.json:
```bash
echo '{
  "/api": {
    "target": "http://localhost:3000",
    "secure": false
  }
}' > proxy.conf.json
```

### 5. Configuración MongoDB
1. Crear script de inicialización:
```bash
echo 'db.createUser({
  user: "root",
  pwd: "example",
  roles: [{ role: "readWrite", db: "meanDB" }]
});
db = db.getSiblingDB("meanDB");
db.createCollection("users");' > mongo/init.js
```

### 6. Iniciar el Proyecto
1. Construir e iniciar contenedores:
```bash
docker-compose up -d --build
```

2. Verificar el estado:
```bash
docker-compose ps
```

### 7. Configuración de Git
1. Crear archivos .gitignore:
```bash
# En la raíz del proyecto
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Node.gitignore

# En el directorio backend
cd backend
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Node.gitignore

# En el directorio frontend
cd ../frontend
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Angular.gitignore
```

2. Inicializar repositorio:
```bash
git init
git add .
git commit -m "Configuración inicial del proyecto MEAN Stack"
```

## Variables de Entorno

### Configuración Inicial
1. Copia los archivos de ejemplo:
```bash
# Backend
cp backend/.env.example backend/.env

# Frontend
cp frontend/.env.example frontend/.env
```

2. Modifica los valores según tu entorno:
```bash
# Editar backend/.env
nano backend/.env

# Editar frontend/.env
nano frontend/.env
```

### Variables Backend (.env)
- `NODE_ENV`: Entorno de ejecución (development/production)
- `PORT`: Puerto del servidor backend
- `DB_URI`: URL de conexión a MongoDB
- `JWT_SECRET`: Clave secreta para tokens JWT
- `CORS_ORIGIN`: Origen permitido para CORS

### Variables Frontend (.env)
- `PORT`: Puerto del servidor frontend
- `HOST`: Host del servidor frontend
- `API_URL`: URL base de la API backend
- `ENVIRONMENT`: Entorno de ejecución

Nota: Nunca subas los archivos .env al repositorio. Usa los archivos .env.example como plantilla.

## Uso del Proyecto

### Desarrollo Local
1. Backend (http://localhost:3000):
- Los cambios en `/backend/src` se recargan automáticamente
- Logs: `docker-compose logs -f backend`

2. Frontend (http://localhost:4200):
- Los cambios en `/frontend/src` se recargan automáticamente
- Logs: `docker-compose logs -f frontend`

3. MongoDB (mongodb://localhost:27017):
- Acceder a la base de datos:
```bash
docker-compose exec db mongosh -u root -p example
```

### Comandos Principales
```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Reconstruir servicios
docker-compose up -d --build

# Ver logs de un servicio específico
docker-compose logs -f [servicio]

# Reiniciar un servicio
docker-compose restart [servicio]
```

## Solución de Problemas

### Error de Conexión MongoDB
```bash
# Reiniciar contenedor de base de datos
docker-compose restart db

# Si persiste, eliminar volumen y recrear
docker-compose down -v
docker-compose up -d
```

### Problemas con Node Modules
```bash
# Reconstruir contenedor sin caché
docker-compose build --no-cache [servicio]
docker-compose up -d
```

### Error en Angular
```bash
# Acceder al contenedor
docker-compose exec frontend bash
# Instalar dependencias manualmente
npm install
```

## Endpoints API
- `GET /api/health`: Estado del servidor
- Documentación completa de API en `/backend/docs`

## Consideraciones de Seguridad
1. Modificar credenciales por defecto
2. Configurar CORS según necesidad
3. Implementar autenticación JWT
4. Usar variables de entorno cifradas

## Desarrollo y Contribuciones
1. Crear rama: `git checkout -b feature/nombre`
2. Commit cambios: `git commit -am "descripción"`
3. Push rama: `git push origin feature/nombre`
4. Crear Pull Request