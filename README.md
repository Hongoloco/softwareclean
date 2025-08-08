# Script de Limpieza de Archivos para Windows

Este repositorio contiene tres scripts especializados en limpieza de archivos para sistemas Windows.

## Scripts Disponibles

### 1. `windows-cleanup.bat` - Script Básico (Batch)
**Uso:** Para usuarios que prefieren un script simple y directo.

**Características:**
- ✅ Limpia archivos temporales del usuario y sistema
- ✅ Elimina cache de Internet Explorer
- ✅ Limpia archivos prefetch
- ✅ Vacía papelera de reciclaje
- ✅ Elimina logs antiguos (>30 días)
- ✅ Limpia cache de Windows Update
- ✅ Ejecuta limpieza automática del sistema
- ✅ Muestra resumen de espacio liberado

**Cómo usar:**
1. Descargar el archivo `windows-cleanup.bat`
2. Ejecutar como Administrador (clic derecho → "Ejecutar como administrador")
3. Seguir las instrucciones en pantalla

---

### 2. `windows-cleanup-advanced.ps1` - Script Avanzado (PowerShell)
**Uso:** Para usuarios avanzados que necesitan más control y detalle.

**Características:**
- ✅ Limpieza completa de archivos temporales
- ✅ Cache de múltiples navegadores (Chrome, Edge, Firefox, Opera)
- ✅ Archivos prefetch y dump
- ✅ Papelera de reciclaje avanzada
- ✅ Logs del sistema antiguos
- ✅ Cache de Windows Update
- ✅ Cache de miniaturas
- ✅ Modo preview (ver qué se eliminaría sin hacerlo)
- ✅ Reporte detallado con estadísticas
- ✅ Barra de progreso

**Parámetros:**
- `-Verbose`: Muestra información detallada durante la ejecución
- `-Preview`: Modo vista previa (no elimina archivos, solo muestra qué se eliminaría)

**Cómo usar:**
```powershell
# Ejecución normal
.\windows-cleanup-advanced.ps1

# Con información detallada
.\windows-cleanup-advanced.ps1 -Verbose

# Modo preview (sin eliminar archivos)
.\windows-cleanup-advanced.ps1 -Preview

# Ambos modos
.\windows-cleanup-advanced.ps1 -Verbose -Preview
```

---

### 3. `windows-cleanup-selective.ps1` - Script Selectivo (PowerShell)
**Uso:** Para usuarios que quieren elegir específicamente qué áreas limpiar.

**Características:**
- ✅ Menu interactivo para seleccionar áreas de limpieza
- ✅ Muestra el tamaño de cada área antes de limpiar
- ✅ Opción de limpiar todo o áreas específicas
- ✅ Confirmación antes de ejecutar
- ✅ Reporte de espacio liberado por área

**Áreas de limpieza disponibles:**
1. Archivos temporales del usuario
2. Archivos temporales del sistema
3. Cache de navegadores
4. Archivos prefetch
5. Papelera de reciclaje
6. Logs del sistema (>30 días)
7. Cache de Windows Update
8. Archivos de volcado (crash dumps)

**Cómo usar:**
```powershell
.\windows-cleanup-selective.ps1
# Luego seguir el menú interactivo
```

## Requisitos del Sistema

- **Windows 10/11** (compatible con versiones anteriores)
- **PowerShell 5.1+** (para scripts .ps1)
- **Permisos de Administrador** (recomendado para acceso completo)

## Instalación y Configuración

### Para PowerShell (primera vez):
```powershell
# Habilitar ejecución de scripts (ejecutar como Administrador)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Descarga:
1. Clonar repositorio: `git clone https://github.com/tuusuario/softwareclean.git`
2. O descargar archivos individualmente desde GitHub

## Precauciones y Recomendaciones

⚠️ **IMPORTANTE - Leer antes de usar:**

### Recomendaciones de Seguridad:
- **Crear punto de restauración** antes de ejecutar cualquier script
- **Cerrar aplicaciones** importantes antes de la limpieza
- **Ejecutar como Administrador** para mejores resultados
- **Hacer backup** de datos importantes

### Qué NO eliminan estos scripts:
- ❌ Archivos personales (documentos, fotos, música)
- ❌ Programas instalados
- ❌ Configuraciones de usuario importantes
- ❌ Archivos del sistema críticos

### Qué SÍ eliminan:
- ✅ Archivos temporales sin uso
- ✅ Cache de navegadores
- ✅ Archivos de log antiguos
- ✅ Archivos prefetch obsoletos
- ✅ Contenido de papelera
- ✅ Cache del sistema

## Resultados Esperados

Dependiendo del estado de tu sistema, puedes liberar entre **500 MB y 10+ GB** de espacio:

- **Sistema poco usado:** 500 MB - 2 GB
- **Sistema uso moderado:** 2 GB - 5 GB  
- **Sistema muy usado:** 5 GB - 10+ GB

## Solución de Problemas

### Error: "No se puede ejecutar scripts"
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Acceso denegado"
- Ejecutar PowerShell/CMD como Administrador
- Cerrar aplicaciones que puedan estar usando archivos temporales

### Script se queda "colgado"
- Algunas operaciones tardan tiempo (especialmente cleanmgr)
- Esperar a que complete o presionar Ctrl+C para cancelar

## Automatización

### Ejecutar automáticamente cada semana:
```cmd
# Crear tarea programada (ejecutar como Administrador)
schtasks /create /tn "Limpieza Semanal" /tr "C:
uta\al\windows-cleanup.bat" /sc weekly /d SUN /st 02:00
```

### Para PowerShell:
```powershell
# Crear tarea programada
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:
uta\al\windows-cleanup-advanced.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2AM
Register-ScheduledTask -TaskName "Limpieza Semanal PS" -Action $action -Trigger $trigger -RunLevel Highest
```

## Contribuciones

¿Tienes sugerencias o mejoras? ¡Las contribuciones son bienvenidas!

1. Fork del repositorio
2. Crear rama para tu feature (`git checkout -b feature/nueva-limpieza`)
3. Commit de cambios (`git commit -am 'Añadir nueva función de limpieza'`)
4. Push a la rama (`git push origin feature/nueva-limpieza`)
5. Crear Pull Request

## Licencia

Este proyecto está bajo licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.

## Changelog

### v1.0.0 (2025-08-08)
- ✅ Script básico de limpieza (BAT)
- ✅ Script avanzado con reporte (PowerShell)
- ✅ Script selectivo con menú interactivo (PowerShell)
- ✅ Documentación completa
- ✅ Modo preview para testing seguro

---

**⭐ Si estos scripts te fueron útiles, considera dar una estrella al repositorio!**