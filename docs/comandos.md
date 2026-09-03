# Comandos útiles

Listado y explicación de los comandos usados para gestionar MySQL y consultar la base del trabajo práctico.

## Índice

- [Servicio de MySQL](#servicio-de-mysql)
- [Cliente MySQL](#cliente-mysql)
- [Inspección de tablas](#inspección-de-tablas)
- [Carga de datos](#carga-de-datos)

---

## Servicio de MySQL

| Comando | Descripción |
|---|---|
| `net start MySQL80` | Inicia el servicio de MySQL (más rápido desde PowerShell que `Start-Service` cuando falla) |
| `Get-Service -Name "MySQL80"` | Muestra el estado del servicio (Running / Stopped) |
| `Start-Service -Name "MySQL80"` | Inicia el servicio vía PowerShell |

> Nota: en PowerShell `Start-Service` puede lanzar un error "no se puede abrir el servicio" aunque realmente lo deje corriendo; verificá siempre el estado con `Get-Service`.

---

## Cliente MySQL

La ruta del cliente en este equipo es:

```
C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
```

| Comando | Descripción |
|---|---|
| `mysql -u root -p` | Conecta al servidor pidiendo contraseña interactivamente |
| `mysql -u root -p"<pass>"` | Conecta pasando la contraseña inline (no usar en producción) |
| `mysql -u root -p"<pass>" --default-character-set=utf8mb4` | Conecta forzando el juego de caracteres UTF-8 (necesario para tildes) |
| `mysql -u root -p"<pass>" -t <base>` | Ejecuta consultas con salida en formato de tabla (bordes `\|`) |

> El warning `Using a password on the command line interface can be insecure` es normal y se puede ignorar en un entorno local.

---

## Inspección de tablas

> Se usa `-e "<consulta>"` para ejecutar SQL directo sin entrar al cliente interactivo, y `\G` (en vez de `;`) para salida vertical en una sola columna por campo.

| Comando | Descripción |
|---|---|
| `mysql ... -e "SHOW DATABASES;"` | Lista todas las bases de datos |
| `mysql ... <base> -e "SHOW TABLES;"` | Lista las tablas de la base indicada |
| `mysql ... <base> -e "SHOW CREATE TABLE <tabla>\G"` | Muestra el DDL completo de una tabla (columnas, tipos, PKs, FKs, charset) |
| `mysql ... <base> -e "DESCRIBE <tabla>;"` | Muestra columnas, tipos, nulabilidad y claves de una tabla |
| `mysql ... <base> -e "SELECT COUNT(*) AS n FROM <tabla>;"` | Cuenta los registros de una tabla (para validar la carga) |
| `mysql ... <base> -e "SELECT DISTINCT <col> FROM <tabla>;"` | Lista valores únicos de una columna (para validar contenido) |
| `mysql ... <base> -e "SELECT HEX(<col>) FROM <tabla> LIMIT n;"` | Muestra los bytes hexadecimales de un campo para diagnosticar problemas de encoding |

### Ejemplos usados

```bash
# Ver todas las tablas de la base del trabajo práctico
mysql -u root -p"<pass>" tp1_accidentes -e "SHOW TABLES;"

# Ver la estructura completa de la tabla de hechos
mysql -u root -p"<pass>" tp1_accidentes -e "SHOW CREATE TABLE info_accidente\G"

# Contar registros de la staging table y de las normalizadas
mysql -u root -p"<pass>" tp1_accidentes -e "SELECT COUNT(*) AS n FROM accidentes;"
mysql -u root -p"<pass>" tp1_accidentes -e "SELECT (SELECT COUNT(*) FROM info_accidente) AS info, (SELECT COUNT(*) FROM provincia) AS prov;"

# Detectar caracteres corruptos (el `3F` = '?' revela un encoding roto)
mysql -u root -p"<pass>" --default-character-set=utf8mb4 tp1_accidentes -e "SELECT DISTINCT HEX(ccaa) FROM accidentes LIMIT 3;"
```

---

## Carga de datos

| Comando | Descripción |
|---|---|
| `Get-Content <archivo>.sql -Raw \| mysql ...` | Carga un script por el pipeline de PowerShell (**NO recomendado**: puede degradar la codificación de caracteres) |
| `mysql ... -e "source <ruta>\<archivo>.sql"` | Ejecuta un script dentro del cliente con `source` (**recomendado**: preserva la codificación UTF-8) |

> **Gotcha de encoding**: los scripts `.sql` de este repo están guardados en **Windows-1252**, no en UTF-8. Si se cargan por el pipeline de PowerShell (`Get-Content | mysql`), los caracteres acentuados (Á, í, ó) se convierten en `?`. La forma robusta es cargarlos con `source` dentro del cliente MySQL con `--default-character-set=utf8mb4`, o convertirlos previamente a UTF-8.

### Orden de carga recomendado

```bash
mysql -u root -p"<pass>" tp1_accidentes -e "source E:\Repo\DBA\tp1\ejercicio2_ddl.sql"
mysql -u root -p"<pass>" tp1_accidentes -e "source E:\Repo\DBA\tp1\ejercicio2_dml.sql"
mysql -u root -p"<pass>" tp1_accidentes -e "source E:\Repo\DBA\tp1\ejercicio1.sql"
mysql -u root -p"<pass>" tp1_accidentes -e "source E:\Repo\DBA\tp1\ejercicio2.sql"
```
