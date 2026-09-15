# Tarea 1 - API con Stored Procedures 
### Nombre y carné de los integrantes:
Yader Siezar Chaves
Carné: 2024134032 

### Estado de la tarea:
Finalizada al 100%

### Enlace del video:
Falta

## 1. Introducción

Esta tarea tiene como objetivo implementar una arquitectura descentralizada donde una aplicación cliente se comunica con una base de datos SQL Server a través de una API REST. Se utilizó la base de datos AdventureWorks y todas las operaciones (CRUD y búsquedas) se realizan mediante Stored Procedures, siguiendo el principio de separar la lógica de datos de la lógica de la aplicación.

La solución corre completamente sobre Linux (Ubuntu 22.04) e incluye:

- SQL Server 2022 corriendo en Linux.
- Base de datos AdventureWorks restaurada.
- API REST desarrollada en Node.js + Express.
- Conexión a la base mediante la librería mssql.
- Pruebas en Postman ejecutándose desde Windows.

## 2. Requisitos previos

- Una Maquina Virtual Ubuntu 22.04.
- Conexión a internet.
- Postman instalado en windows (o curl en el PowerShell).

## 3. Instalación paso a paso

Debe clonar el repositorio con:
```bash
    git clone "https://github.com/ysiezar21/Tarea-1_Bases_de_Datos2.git"
```
### 3.1 Preparar Ubuntu 22.04

En la consola de la maquina virtual con Ubuntu ya instalado:
```bash
    sudo apt update && sudo apt upgrade -y
```
### 3.2 Instalar SQL Server 2022 en Linux

Importar clave GPG de Microsoft:
```bash
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
```
Registrar el repositorio de SQL Server 2022
```bash
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)"
```
Instalar SQL Server
```bash
    sudo apt-get update

    sudo apt-get install -y mssql-server
```
Elegir edición con la que desea trabajar, aceptar términos, definir contraseña de sa
```bash
    sudo /opt/mssql/bin/mssql-conf setup
```
Verificar que está corriendo
```bash
    systemctl status mssql-server --no-pager
```
### 3.3 Instalar herramientas en el PATH
```bash
    sudo apt-get install -y mssql-tools18 unixodbc-dev

    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

    source ~/.bashrc
```
### 3.4 Restaurar AdventureWorks

Descargar el backup (yo usé la versión 2022)
```bash
    mkdir -p ~/adventureworks && cd ~/adventureworks

    wget https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak
```
Moverlo a una carpeta accesible por SQL Server
```bash
    sudo mkdir -p /var/opt/mssql/backup

    sudo mv AdventureWorks2022.bak /var/opt/mssql/backup/

    sudo chown -R mssql:mssql /var/opt/mssql/backup
```
Restaurar (pegar todo el comando, se debe cambiar 'PASSWORD' por la contraseña de su maquina virtual)
```bash
    sqlcmd -S localhost -U sa -P 'PASSWORD' -C -Q "
    RESTORE DATABASE AdventureWorks
    FROM DISK='/var/opt/mssql/backup/AdventureWorks2022.bak'
    WITH 
        MOVE 'AdventureWorks2022' TO '/var/opt/mssql/data/AdventureWorks.mdf',
        MOVE 'AdventureWorks2022_log' TO '/var/opt/mssql/data/AdventureWorks_log.ldf',
        RECOVERY, REPLACE, STATS = 5"
```
### 3.5 Instalar Node.js
```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source ~/.bashrc

    nvm install 20

    node -v
```
### 3.6 Instalar dependencias de la API (en la carpeta del proyecto)
```bash
    cd proyectos

    npm install express mssql
```
## 4. Configuración de los servicios

### 4.1 Crear los Stored Procedures

Ejecutar el script ubicado en `codigo/stored_procedures.sql` (se debe cambiar 'PASSWORD' por la contraseña de su maquina virtual):
```bash
    sqlcmd -S localhost -U sa -P 'PASSWORD' -C -I -i codigo/stored_procedures.sql
```

Verificar que los 6 SPs existan (se debe cambiar 'PASSWORD' por la contraseña de su maquina virtual):
```bash
    sqlcmd -S localhost -U sa -P 'PASSWORD' -C -d AdventureWorks -Q "SELECT name FROM sys.procedures WHERE name LIKE 'sp_Person_%'"
```

Resultado esperado:
```bash
    sp_Person_Delete
    sp_Person_GetAll
    sp_Person_GetById
    sp_Person_GetWithEmail
    sp_Person_Insert
    sp_Person_Update
```

### 4.2 Configurar la conexión a la base de datos

Editar `proyectos/db.js` y ajustar las credenciales (se debe cambiar 'PASSWORD' por la contraseña de su maquina virtual):

```javascript
const sql = require('mssql');

const config = {
  user: 'sa',
  password: 'PASSWORD',
  server: 'localhost',
  database: 'AdventureWorks',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

module.exports = { sql, config };
```

### 4.3 Arrancar la API
```bash
    cd proyectos

    node server.js
```

Debe mostrar:
```bash
    API en http://localhost:3000
```

Para acceder desde Windows (host), el adaptador de red debe estar en modo NAT con port forwarding, o en modo Bridged.


## 5. Datos de prueba

### 5.1 Healthcheck

Petición (debe cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/
```

Respuesta esperada:
```json
    {"message":"API AdventureWorks funcionando 🚀"}
```

### 5.2 Lista de todas las personas

Petición (debe cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/api/persons/all
```

Respuesta (solo muestro una parte):
```json
    [
        {
            "BusinessEntityID": 1,
            "PersonType": "EM",
            "FirstName": "Ken",
            "LastName": "Sánchez",
            "EmailPromotion": 0,
            "ModifiedDate": "2009-01-07T00:00:00.000Z"
        },
        {
            "BusinessEntityID": 2,
            "PersonType": "EM",
            "FirstName": "Terri",
            "LastName": "Duffy",
            "EmailPromotion": 1,
            "ModifiedDate": "2008-01-24T00:00:00.000Z"
        }
    ]
```

### 5.3 Lista de personas con email (consulta con JOIN)

Petición (debe cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/api/persons/join
```

Respuesta (solo muestro una parte):
```json
    [
        {
            "BusinessEntityID": 285,
            "FirstName": "Syed",
            "LastName": "Abbas",
            "EmailAddress": "syed0@adventure-works.com"
        }
    ]
```

### 5.4 Consultar por ID

Petición (debe cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/api/persons/285
```

Respuesta esperada:
```json
    [
        {
            "BusinessEntityID": 285,
            "PersonType": "EM",
            "FirstName": "Syed",
            "MiddleName": null,
            "LastName": "Abbas",
            "EmailPromotion": 0,
            "ModifiedDate": "2009-01-07T00:00:00.000Z"
        }
    ]
```

### 5.5 Insertar persona

Petición (debe cambiar IP_MV por la ip de su maquina virtual):
```bash
    POST http://IP_VM:3000/api/persons
    Content-Type: application/json

    {
        "firstName": "Yader",
        "lastName": "Siezar"
    }
```

Respuesta esperada (en 'ID' se retornará un ID nuevo para cada persona insertada):
```json
    {"ok":true,"result":[{"NewID": 'ID' }]}
```

### 5.6 Actualizar persona

Petición (cambiar 'ID' por el NewID retornado y cambiar IP_MV por la ip de su maquina virtual):
```bash
    PUT http://IP_VM:3000/api/persons/'ID'
    Content-Type: application/json

    {
        "firstName": "Yader Stiven",
        "lastName": "Siezar Modificado"
    }
```

Respuesta esperada:
```json
    {"ok":true}
```

Verificar cambios con (cambiar 'ID' por el NewID retornado y cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/api/persons/'ID'
```

### 5.7 Eliminar persona

Petición (cambiar 'ID' por el NewID retornado y cambiar IP_MV por la ip de su maquina virtual):
```bash
    DELETE http://IP_VM:3000/api/persons/'ID'
```

**Respuesta esperada:**
```json
    {"ok":true}
```

### 7.8 Verificar eliminación

Petición (cambiar 'ID' por el NewID retornado y cambiar IP_MV por la ip de su maquina virtual):
```bash
    GET http://IP_VM:3000/api/persons/'ID'
```

Respuesta esperada:
```json
    []
```

## 8. Estructura del repositorio

```bash
Tarea-1_Bases_de_Datos2/
├── README.md                          ← este archivo
├── codigo/
│   └── stored_procedures.sql          ← definición de los 6 SPs
├── proyectos/                         ← código de la API Node.js
│   ├── db.js                          ← configuración de conexión
│   ├── server.js                       ← servidor Express
│   ├── package.json
│   ├── package-lock.json
│   └── routes/
│       └── persons.js                 ← endpoints CRUD
└── Script sql/
    └── stored_procedures.sql          ← copia del script SQL
```