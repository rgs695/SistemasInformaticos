# Guía básica para crear servicios y targets con systemd

## 1. ¿Qué es un archivo de unidad?

Un archivo de unidad de `systemd` es un fichero de texto con extensión `.service`, `.target`, `.mount`, etc., que define cómo debe arrancar, detenerse y comportarse un servicio o recurso del sistema.

`systemd` utiliza estos archivos para gestionar el arranque y funcionamiento de procesos y recursos en el sistema.

---

## 2. Ruta de instalación de archivos

Los archivos de unidad personalizados se deben crear en:

```
/etc/systemd/system/
```

Esta es la ruta recomendada para servicios creados por el administrador o por el usuario, ya que se mantiene separada de los servicios del sistema y de los paquetes.

---

## 3. Estructura general de un archivo `.service`

```ini
[Unit]
Description=Descripción del servicio
After=otra-unidad.target

[Service]
ExecStart=/ruta/al/script_o_binario
Type=simple
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## 4. Sección `[Unit]`

Esta sección define metadatos del servicio y dependencias con otras unidades.

| Directiva    | Descripción                                                                                   |
| ------------ | --------------------------------------------------------------------------------------------- |
| Description= | Descripción del servicio (aparece con `systemctl status`).                                    |
| After=       | Indica que esta unidad se debe iniciar **después** de otra.                                   |
| Requires=    | Indica que esta unidad **depende críticamente** de otra. Si la requerida falla, esta también. |
| Wants=       | Similar a `Requires=`, pero no es una dependencia crítica.                                    |
| BindsTo=     | Si la unidad vinculada se detiene, esta también se detiene automáticamente.                   |

---

## 5. Sección `[Service]`

Define el comportamiento del servicio en sí mismo.

| Directiva        | Descripción                                                         |
| ---------------- | ------------------------------------------------------------------- |
| Type=            | Tipo de servicio: `simple`, `forking`, `oneshot`, `notify`, `idle`. |
| ExecStart=       | Comando o script a ejecutar al iniciar el servicio.                 |
| ExecStop=        | (Opcional) Comando para detener el servicio.                        |
| Restart=         | Política de reinicio: `on-failure`, `always`, `no`.                 |
| RemainAfterExit= | Útil para `oneshot`: mantiene el servicio "activo" tras terminar.   |
| User=/Group=     | (Opcional) Usuario y grupo con los que se ejecutará el servicio.    |
| TimeoutSec=      | Tiempo de espera antes de forzar parada si no responde.             |

Tipos más comunes en `Type=`:

* `simple`: (por defecto) ejecuta el comando directamente.
* `forking`: el proceso se separa (usa fork), típico en demonios.
* `oneshot`: para comandos que se ejecutan una vez y terminan.
* `notify`: el servicio avisa a `systemd` cuando está listo.
* `idle`: espera a que el sistema esté inactivo.

---

## 6. Sección `[Install]`

Define cuándo debe activarse el servicio.

| Directiva   | Descripción                                                   |
| ----------- | ------------------------------------------------------------- |
| WantedBy=   | Indica qué target debe activar este servicio automáticamente. |
| RequiredBy= | Similar a `WantedBy`, pero como dependencia obligatoria.      |

Targets más usados:

* `multi-user.target`: sistema sin entorno gráfico.
* `graphical.target`: sistema con entorno gráfico.
* `default.target`: target que se ejecuta por defecto al iniciar el sistema.

---

## 7. Comandos esenciales para gestionar servicios

| Acción                    | Comando                                        |
| ------------------------- | ---------------------------------------------- |
| Crear archivo de servicio | `sudo nano /etc/systemd/system/nombre.service` |
| Recargar `systemd`        | `sudo systemctl daemon-reload`                 |
| Iniciar el servicio       | `sudo systemctl start nombre.service`          |
| Ver estado del servicio   | `systemctl status nombre.service`              |
| Habilitar al arranque     | `sudo systemctl enable nombre.service`         |
| Detener el servicio       | `sudo systemctl stop nombre.service`           |
| Deshabilitar al arranque  | `sudo systemctl disable nombre.service`        |
| Ver logs del servicio     | `journalctl -u nombre.service`                 |

---

## 8. Ejemplo de servicio funcional

Archivo: `/etc/systemd/system/check-disk.service`

```ini
[Unit]
Description=Ejecuta un script para comprobar disco
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-disk.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

---

## 9. Creación de targets personalizados

Un target agrupa varias unidades, permitiendo definir modos de operación.

Archivo: `/etc/systemd/system/mantenimiento.target`

```ini
[Unit]
Description=Modo de mantenimiento personalizado
Requires=multi-user.target
Wants=check-disk.service
After=multi-user.target
```

Activar el target:

```bash
sudo systemctl isolate mantenimiento.target
```

Hacerlo el modo por defecto:

```bash
sudo systemctl set-default mantenimiento.target
```

---

## 10. Consejos finales para el examen

1. Crea siempre los archivos en `/etc/systemd/system/`.
2. Usa `sudo systemctl daemon-reload` tras modificar cualquier unidad.
3. Verifica errores con `systemctl status` o `journalctl -u`.
4. Si usas `Type=oneshot`, añade `RemainAfterExit=yes` si necesitas que el servicio se mantenga activo.
5. Usa `WantedBy=multi-user.target` para que el servicio arranque automáticamente en modo normal.

---

