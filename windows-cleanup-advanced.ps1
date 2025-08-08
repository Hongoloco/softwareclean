# Script de Limpieza Avanzada para Windows
# Ejecutar en PowerShell como Administrador

param(
    [switch]$Verbose,
    [switch]$Preview
)

# Función para mostrar el progreso
function Write-Progress-Custom {
    param([string]$Activity, [string]$Status, [int]$PercentComplete)
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    if ($Verbose) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Status" -ForegroundColor Cyan
    }
}

function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        return (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum
    }
    return 0
}

Write-Host "=== SCRIPT DE LIMPIEZA DE ARCHIVOS WINDOWS ===" -ForegroundColor Green
Write-Host "Inicio: $(Get-Date)" -ForegroundColor Yellow

$totalSteps = 10
$currentStep = 0
$spaceFreed = 0

# 1. Archivos temporales del usuario
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando archivos temporales del usuario" -PercentComplete (($currentStep / $totalSteps) * 100)

$tempPaths = @($env:TEMP, $env:TMP, "$env:USERPROFILE\AppData\Local\Temp")
foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        $sizeBefore = Get-FolderSize $path
        if ($Preview) {
            Write-Host "PREVIEW: Se eliminarían archivos en $path" -ForegroundColor Yellow
        } else {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
        $sizeAfter = Get-FolderSize $path
        $spaceFreed += ($sizeBefore - $sizeAfter)
    }
}

# 2. Archivos temporales del sistema
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando archivos temporales del sistema" -PercentComplete (($currentStep / $totalSteps) * 100)

$systemTemp = "C:\Windows\Temp"
if (Test-Path $systemTemp) {
    $sizeBefore = Get-FolderSize $systemTemp
    if ($Preview) {
        Write-Host "PREVIEW: Se eliminarían archivos en $systemTemp" -ForegroundColor Yellow
    } else {
        Get-ChildItem -Path $systemTemp -Recurse -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
    $sizeAfter = Get-FolderSize $systemTemp
    $spaceFreed += ($sizeBefore - $sizeAfter)
}

# 3. Cache de navegadores
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando cache de navegadores" -PercentComplete (($currentStep / $totalSteps) * 100)

$browserCaches = @(
    "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache",
    "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Cache",
    "$env:USERPROFILE\AppData\Local\Mozilla\Firefox\Profiles\*\cache2",
    "$env:USERPROFILE\AppData\Roaming\Opera Software\Opera Stable\Cache"
)

foreach ($cache in $browserCaches) {
    $paths = Get-ChildItem -Path (Split-Path $cache) -Filter (Split-Path $cache -Leaf) -ErrorAction SilentlyContinue
    foreach ($path in $paths) {
        if ($path.Exists) {
            $sizeBefore = Get-FolderSize $path.FullName
            if ($Preview) {
                Write-Host "PREVIEW: Se eliminaría cache en $($path.FullName)" -ForegroundColor Yellow
            } else {
                Get-ChildItem -Path $path.FullName -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
            $sizeAfter = Get-FolderSize $path.FullName
            $spaceFreed += ($sizeBefore - $sizeAfter)
        }
    }
}

# 4. Archivos prefetch
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando archivos prefetch" -PercentComplete (($currentStep / $totalSteps) * 100)

$prefetchPath = "C:\Windows\Prefetch"
if (Test-Path $prefetchPath) {
    $sizeBefore = Get-FolderSize $prefetchPath
    if ($Preview) {
        Write-Host "PREVIEW: Se eliminarían archivos prefetch" -ForegroundColor Yellow
    } else {
        Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    $sizeAfter = Get-FolderSize $prefetchPath
    $spaceFreed += ($sizeBefore - $sizeAfter)
}

# 5. Papelera de reciclaje
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Vaciando papelera de reciclaje" -PercentComplete (($currentStep / $totalSteps) * 100)

if ($Preview) {
    Write-Host "PREVIEW: Se vaciaría la papelera de reciclaje" -ForegroundColor Yellow
} else {
    try {
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(0xA)
        $recycleBin.Self.InvokeVerb("empty")
    } catch {
        # Método alternativo
        Get-ChildItem -Path "C:\`$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# 6. Logs antiguos
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Eliminando logs antiguos" -PercentComplete (($currentStep / $totalSteps) * 100)

$logPaths = @("C:\Windows\Logs", "C:\Windows\System32\LogFiles")
foreach ($logPath in $logPaths) {
    if (Test-Path $logPath) {
        $oldLogs = Get-ChildItem -Path $logPath -Recurse -File | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)}
        $sizeBefore = ($oldLogs | Measure-Object -Property Length -Sum).Sum
        if ($Preview) {
            Write-Host "PREVIEW: Se eliminarían $($oldLogs.Count) archivos de log antiguos" -ForegroundColor Yellow
        } else {
            $oldLogs | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        $spaceFreed += $sizeBefore
    }
}

# 7. Cache de Windows Update
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando cache de Windows Update" -PercentComplete (($currentStep / $totalSteps) * 100)

$updateCache = "C:\Windows\SoftwareDistribution\Download"
if (Test-Path $updateCache) {
    $sizeBefore = Get-FolderSize $updateCache
    if ($Preview) {
        Write-Host "PREVIEW: Se limpiaría cache de Windows Update" -ForegroundColor Yellow
    } else {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path $updateCache -Recurse -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    }
    $sizeAfter = Get-FolderSize $updateCache
    $spaceFreed += ($sizeBefore - $sizeAfter)
}

# 8. Archivos dump y crash
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Eliminando archivos de volcado" -PercentComplete (($currentStep / $totalSteps) * 100)

$dumpPaths = @("C:\Windows\Minidump", "C:\Windows\MEMORY.DMP")
foreach ($dumpPath in $dumpPaths) {
    if (Test-Path $dumpPath) {
        $sizeBefore = Get-FolderSize $dumpPath
        if ($Preview) {
            Write-Host "PREVIEW: Se eliminarían archivos de volcado en $dumpPath" -ForegroundColor Yellow
        } else {
            if ((Get-Item $dumpPath).PSIsContainer) {
                Get-ChildItem -Path $dumpPath -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            } else {
                Remove-Item -Path $dumpPath -Force -ErrorAction SilentlyContinue
            }
        }
        $sizeAfter = Get-FolderSize $dumpPath
        $spaceFreed += ($sizeBefore - $sizeAfter)
    }
}

# 9. Thumbnails cache
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Limpiando cache de miniaturas" -PercentComplete (($currentStep / $totalSteps) * 100)

$thumbCache = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer"
if (Test-Path $thumbCache) {
    $sizeBefore = Get-FolderSize $thumbCache
    if ($Preview) {
        Write-Host "PREVIEW: Se limpiaría cache de miniaturas" -ForegroundColor Yellow
    } else {
        Get-ChildItem -Path $thumbCache -Filter "thumbcache_*.db" -ErrorAction SilentlyContinue | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    $sizeAfter = Get-FolderSize $thumbCache
    $spaceFreed += ($sizeBefore - $sizeAfter)
}

# 10. Ejecutar Disk Cleanup
$currentStep++
Write-Progress-Custom -Activity "Limpieza de Windows" -Status "Ejecutando limpieza de disco del sistema" -PercentComplete (($currentStep / $totalSteps) * 100)

if (-not $Preview) {
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -NoNewWindow -ErrorAction SilentlyContinue
}

Write-Progress -Activity "Limpieza de Windows" -Completed

# Generar reporte
$spaceFreedMB = [math]::Round($spaceFreed / 1MB, 2)
$spaceFreedGB = [math]::Round($spaceFreed / 1GB, 2)

$report = @"
=== REPORTE DE LIMPIEZA DE ARCHIVOS ===
Fecha y hora: $(Get-Date)
Modo: $(if ($Preview) { "PREVIEW" } else { "EJECUCIÓN" })

Espacio liberado: $spaceFreedMB MB ($spaceFreedGB GB)

Áreas limpiadas:
✓ Archivos temporales de usuario
✓ Archivos temporales del sistema  
✓ Cache de navegadores
✓ Archivos prefetch
✓ Papelera de reciclaje
✓ Logs antiguos (>30 días)
✓ Cache de Windows Update
✓ Archivos de volcado y crash
✓ Cache de miniaturas
✓ Limpieza de disco del sistema

Finalizado: $(Get-Date)
"@

Write-Host $report -ForegroundColor Green

# Guardar reporte
$reportPath = "$env:USERPROFILE\Desktop\CleanupReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Reporte guardado en: $reportPath" -ForegroundColor Cyan
