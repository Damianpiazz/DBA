# DBA

Repositorio de los trabajos prácticos de la materia, con un entorno de MySQL 8 levantado por Docker Compose y un visualizador web (CloudBeaver) para consultarlo desde el navegador.

## Estructura del repo

| Ruta | Contenido |
|---|---|
| `tp1/` | TP1 — SQL Básico 2: análisis de accidentes de tráfico en España |
| `tp2/` | TP2 — SQL Avanzado: vistas, stored procedures y triggers |
| `docs/comandos.md` | Comandos de MySQL: inspección, carga de datos y diagnóstico |
| `docker-compose.yml` | Servicios de MySQL 8.0 y CloudBeaver |
| `.env.example` | Ejemplo de variables de entorno para el compose |

Cada TP es **independiente**: usan bases distintas (`tp1_accidentes` y `music`) y se pueden cargar y resolver uno sin el otro.

---

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo.
- Docker Compose v2 (viene incluido con Docker Desktop).

Para verificar que todo esté listo:

```bash
docker --version
docker compose version
docker info --format '{{.ServerVersion}}'
```

Si `docker info` falla con *"failed to connect to the docker API"*, el daemon está apagado: abrí Docker Desktop y esperá a que aparezca el ícono en la bandeja del sistema.

---

## Levantar la base con Docker

### 1. Definir la contraseña de root (opcional)

```bash
cp .env.example .env
```

`.env` está en `.gitignore` y no se commitea. Si no se crea, se usa `root` como contraseña por defecto.

### 2. Levantar los servicios

```bash
docker compose up -d
```

Baja las imágenes `mysql:8.0` y `dbeaver/cloudbeaver` la primera vez (tarda unos minutos) y levanta los dos contenedores.

### 3. Verificar

```bash
docker compose ps
```

Estado esperado:

| Servicio | Estado | Puerto |
|---|---|---|
| `dba-mysql` | `Up (healthy)` | `localhost:3306` |
| `dba-cloudbeaver` | `Up` | `localhost:8978` |

> **Esperar a que `mysql` diga `healthy`** antes de conectarse. El healthcheck sondea el servidor cada 5s y tarda unos 20 segundos en el primer arranque. CloudBeaver arranca recién cuando MySQL está listo (`depends_on: condition: service_healthy`).

### Comandos del ciclo de vida

| Comando | Descripción |
|---|---|
| `docker compose up -d` | Levanta los servicios en segundo plano |
| `docker compose ps` | Muestra el estado de los contenedores |
| `docker compose logs -f mysql` | Sigue los logs de MySQL en tiempo real |
| `docker compose down` | Detiene los contenedores **conservando** los datos |
| `docker compose down -v` | Detiene y **borra los volúmenes** (pierde todas las bases) |

Los datos viven en el volumen `mysql-data`, así que sobreviven a un `down` y a los reinicios de la máquina. El volumen `cloudbeaver-data` guarda las conexiones guardadas del panel.

> **No hay seeds automáticos**: el server arranca vacío y los `.sql` se cargan a mano (ver [Cargar los datos](#cargar-los-datos)).

---

## Entrar al visualizador de la base (CloudBeaver)

CloudBeaver es una consola de SQL en el navegador: permite navegar el esquema, correr queries, ver el historial y editar datos sin instalar nada.

### 1. Abrir la URL

```
http://localhost:8978
```

Si no responde, revisá que el servicio esté arriba con `docker compose ps`.

### 2. Iniciar sesión

| Campo | Valor |
|---|---|
| Usuario | `cbadmin` |
| Contraseña | `cloudbeaver` |

> En el primer ingreso CloudBeaver pide **cambiar la contraseña** del admin o crear un usuario propio. Anotala: es local a este panel, no es la contraseña de MySQL.

### 3. Crear la conexión a MySQL

Este es el paso con el que más se falla. Al crear la conexión nueva usá:

| Campo | Valor |
|---|---|
| Host | **`mysql`** |
| Puerto | `3306` |
| Base de datos | `tp1_accidentes` o `music` |
| Usuario | `root` |
| Contraseña | la del `.env` (`root` por defecto) |

> **¿Por qué `mysql` y no `localhost`?** CloudBeaver y MySQL son dos contenedores distintos en la misma red de Compose. Desde adentro del navegador, `localhost` apunta al **propio contenedor de CloudBeaver**, que no tiene ningún MySQL. El nombre del servicio en el compose (`mysql`) se resuelve por DNS interno hacia el contenedor correcto.
>
> `localhost:3306` solo funciona desde **fuera** de los contenedores, es decir desde tu terminal o desde Workbench.

### 4. Bases disponibles

| Base | TP | Contenido |
|---|---|---|
| `tp1_accidentes` | TP1 | 5 tablas normalizadas con los accidentes |
| `music` | TP2 | 11 tablas con artistas, álbumes, canciones y playlists |

Ambas aparecen en el árbol lateral una vez cargadas. Para listarlas desde la terminal:

```bash
docker compose exec mysql mysql -uroot -p -e "SHOW DATABASES;"
```

---

## Conectar por terminal

Alternativa al navegador, usando el cliente MySQL instalado en la máquina:

```bash
mysql -u root -p --default-character-set=utf8mb4
```

Desde dentro del contenedor:

```bash
docker compose exec mysql mysql -uroot -p
```

> El flag `--default-character-set=utf8mb4` es importante: sin él los acentos de los datos pueden mostrarse corruptos. Ver [docs/comandos.md](docs/comandos.md) para más comandos de inspección.

---

## Cargar los datos

Los `.sql` están en **UTF-8 sin BOM con finales CRLF**, y se cargan con `SOURCE` para preservar la codificación. **No** usar el pipeline de PowerShell (`Get-Content | mysql`), que degrada los caracteres acentuados a `?`.

### TP1 — base `tp1_accidentes`

```sql
SOURCE tp1/ejercicio01_ddl.sql;
SOURCE tp1/ejercicio02_aux_staging_ddl.sql;
SOURCE tp1/ejercicio02_aux_staging_dml.sql;
SOURCE tp1/ejercicio02_dml.sql;
SOURCE tp1/ejercicio03_consultas.sql;
```

> **El orden importa**: `ejercicio01_ddl.sql` va primero porque es el único que crea la base con `CREATE DATABASE`. Los dos archivos `aux_staging` **no tienen `USE`**, así que corren sobre la base que ya quedó seleccionada. `ejercicio03_consultas.sql` son las consultas de verificación, se corre al final.

Conteos esperados:

| Tabla | Filas |
|---|---|
| `provincia` | 52 |
| `comunidad_autonoma` | 19 |
| `accidentes` (staging) | 208 |
| `info_accidente` | 208 |
| `anio` | 2 |
| `tipo_via` | 2 |

Validación rápida:

```bash
docker compose exec mysql mysql -uroot -p --default-character-set=utf8mb4 tp1_accidentes \
  -e "SELECT (SELECT COUNT(*) FROM provincia) AS provincia, (SELECT COUNT(*) FROM info_accidente) AS info;"
```

### TP2 — base `music`

```sql
SOURCE tp2/00_ddl_music.sql;
SOURCE tp2/01_datos_de_prueba.sql;
SOURCE tp2/soluciones_music.sql;
```

Conteos esperados:

| Tabla | Filas |
|---|---|
| `artist` | 6 |
| `album` | 8 |
| `song` | 20 |
| `user` | 6 |
| `playlist` | 5 |
| `playlist_has_song` | 14 |

> La base **Chinook** que usan los ejercicios 02 al 10 del TP2 **no está en el repo**. Hay que crearla aparte (ver `tp2/schema chinook.png` y `tp2/SqlAvanzado.pdf`).

---

## Resetear el entorno

```bash
docker compose down -v && docker compose up -d
```

Borra los volúmenes y arranca un MySQL vacío. Después hay que volver a cargar los datos de cada TP. Usar `down` sin `-v` si lo único que querés es parar el entorno sin perder nada.

---

## Documentación

| Documento | Contenido |
|---|---|
| [tp1/README.md](tp1/README.md) | Esquema del TP1, las 10 queries y sus resultados |
| [tp2/README.md](tp2/README.md) | Esquema de `music`, los 16 ejercicios y lo que debe devolver cada uno |
| [docs/comandos.md](docs/comandos.md) | Comandos de MySQL: inspección de tablas, carga de datos, diagnóstico de encoding |
