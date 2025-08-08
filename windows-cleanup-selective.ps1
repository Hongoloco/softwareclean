# Script de Limpieza Selectiva para Windows
# Permite elegir qué áreas limpiar

Write-Host "=== LIMPIEZA SELECTIVA DE ARCHIVOS WINDOWS ===" -ForegroundColor Green
Write-Host ""

# Función para obtener tamaño de carpeta
function Get-FolderSizeMB {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

# Mostrar opciones de limpieza
Write-Host "Selecciona las áreas que deseas limpiar:" -ForegroundColor Yellow
Write-Host ""

$options = @{
    1 = @{
        Name = "Archivos temporales del usuario"
        Paths = @($env:TEMP, "$env:USERPROFILE\AppData\Local\Temp")
        Size = 0
    }
    2 = @{
        Name = "Archivos temporales del sistema"
        Paths = @("C:\Windows\Temp")
        Size = 0
    }
    3 = @{
        Name = "Cache de navegadores"
        Paths = @(
            "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache",
            "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
        )
        Size = 0
    }
    4 = @{
        Name = "Archivos prefetch"
        Paths = @("C:\Windows\Prefetch")
        Size = 0
    }
    5 = @{
        Name = "Papelera de reciclaje"
        Paths = @("C:\`$Recycle.Bin")
        Size = 0
    }
    6 = @{
        Name = "Logs del sistema (>30 días)"
        Paths = @("C:\Windows\Logs")
        Size = 0
    }
    7 = @{
        Name = "Cache de Windows Update"
        Paths = @("C:\Windows\SoftwareDistribution\Download")
        Size = 0
    }
    8 = @{
        Name = "Archivos de volcado (crash dumps)"
        Paths = @("C:\Windows\Minidump")
        Size = 0
    }
}

# Calcular tamaños
foreach ($key in $options.Keys) {
    $totalSize = 0
    foreach ($path in $options[$key].Paths) {
        $totalSize += Get-FolderSizeMB $path
    }
    $options[$key].Size = $totalSize
}

# Mostrar opciones con tamaños
foreach ($key in $options.Keys) {
    $option = $options[$key]
    Write-Host "[$key] $($option.Name) - $($option.Size) MB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[A] Limpiar todo" -ForegroundColor Green
Write-Host "[0] Salir" -ForegroundColor Red
Write-Host ""

do {
    $selection = Read-Host "Ingresa tu selección (1-8, A para todo, 0 para salir)"
} while ($selection -notmatch '^[0-8A]$')

if ($selection -eq "0") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit
}

$selectedOptions = @()

if ($selection -eq "A") {
    $selectedOptions = 1..8
} else {
    $selectedOptions = @([int]$selection)
}

# Confirmar limpieza
Write-Host ""
Write-Host "Se procederá a limpiar:" -ForegroundColor Yellow
foreach ($opt in $selectedOptions) {
    Write-Host "- $($options[$opt].Name)" -ForegroundColor White
}

$confirm = Read-Host "`n¿Continuar? (S/N)"
if ($confirm -notmatch '^[SsYy]$') {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit
}

# Ejecutar limpieza
Write-Host "`nIniciando limpieza..." -ForegroundColor Green
$totalSpaceFreed = 0

foreach ($optionNum in $selectedOptions) {
    $option = $options[$optionNum]
    Write-Host "Limpiando: $($option.Name)..." -ForegroundColor Cyan
    
    $spaceBefore = 0
    $spaceAfter = 0
    
    foreach ($path in $option.Paths) {
        $spaceBefore += Get-FolderSizeMB $path
    }
    
    switch ($optionNum) {
        1 {
            # Archivos temporales del usuario
            foreach ($path in $option.Paths) {
                if (Test-Path $path) {
                    Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                }
            }
        }
        2 {
            # Archivos temporales del sistema
            if (Test-Path "C:\Windows\Temp") {
                Get-ChildItem -Path "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        3 {
            # Cache de navegadores
            foreach ($path in $option.Paths) {
                if (Test-Path $path) {
                    Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                }
            }
        }
        4 {
            # Archivos prefetch
            if (Test-Path "C:\Windows\Prefetch") {
                Get-ChildItem -Path "C:\Windows\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
        5 {
            # Papelera de reciclaje
            try {
                $shell = New-Object -ComObject Shell.Application
                $recycleBin = $shell.Namespace(0xA)
                $recycleBin.Self.InvokeVerb("empty")
            } catch {
                Get-ChildItem -Path "C:\`$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        6 {
            # Logs antiguos
            if (Test-Path "C:\Windows\Logs") {
                $oldLogs = Get-ChildItem -Path "C:\Windows\Logs" -Recurse -File | 
                    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)}
                $oldLogs | Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
        7 {
            # Cache de Windows Update
            Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
            if (Test-Path "C:\Windows\SoftwareDistribution\Download") {
                Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
            Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        }
        8 {
            # Archivos de volcado
            if (Test-Path "C:\Windows\Minidump") {
                Get-ChildItem -Path "C:\Windows\Minidump" -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
            if (Test-Path "C:\Windows\MEMORY.DMP") {
                Remove-Item -Path "C:\Windows\MEMORY.DMP" -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    foreach ($path in $option.Paths) {
        $spaceAfter += Get-FolderSizeMB $path
    }
    
    $spaceFreed = $spaceBefore - $spaceAfter
    $totalSpaceFreed += $spaceFreed
    
    Write-Host "  Espacio liberado: $spaceFreed MB" -ForegroundColor Green
}

# Resumen final
Write-Host ""
Write-Host "=== LIMPIEZA COMPLETADA ===" -ForegroundColor Green
Write-Host "Espacio total liberado: $totalSpaceFreed MB ($([math]::Round($totalSpaceFreed / 1024, 2)) GB)" -ForegroundColor Yellow

# Mostrar espacio disponible en disco C:
$drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
Write-Host "Espacio libre en C:: $freeSpaceGB GB" -ForegroundColor Cyan

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
