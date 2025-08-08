@echo off
REM Script de Limpieza de Archivos para Windows
REM Ejecutar como Administrador para mejores resultados

echo ============================================
echo    SCRIPT DE LIMPIEZA DE ARCHIVOS WINDOWS
echo ============================================
echo.

echo [1/8] Limpiando archivos temporales del usuario...
del /q /f /s "%TEMP%\*" 2>nul
del /q /f /s "%tmp%\*" 2>nul
echo Archivos temporales del usuario eliminados.

echo.
echo [2/8] Limpiando archivos temporales del sistema...
del /q /f /s "C:\Windows\Temp\*" 2>nul
echo Archivos temporales del sistema eliminados.

echo.
echo [3/8] Limpiando cache de Internet Explorer...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
echo Cache de Internet Explorer limpiado.

echo.
echo [4/8] Limpiando archivos prefetch...
del /q /f /s "C:\Windows\Prefetch\*" 2>nul
echo Archivos prefetch eliminados.

echo.
echo [5/8] Limpiando papelera de reciclaje...
rd /s /q "C:\$Recycle.Bin" 2>nul
echo Papelera de reciclaje vaciada.

echo.
echo [6/8] Limpiando archivos de registro antiguos...
forfiles /p "C:\Windows\Logs" /s /m *.* /d -30 /c "cmd /c del @path" 2>nul
echo Archivos de registro antiguos eliminados.

echo.
echo [7/8] Limpiando cache de Windows Update...
net stop wuauserv >nul 2>&1
del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" 2>nul
net start wuauserv >nul 2>&1
echo Cache de Windows Update limpiado.

echo.
echo [8/8] Ejecutando limpieza automatica del sistema...
cleanmgr /sagerun:1
echo Limpieza automatica completada.

echo.
echo ============================================
echo    LIMPIEZA COMPLETADA EXITOSAMENTE
echo ============================================
echo.
echo Presiona cualquier tecla para mostrar el resumen...
pause >nul

REM Mostrar espacio liberado
echo.
echo === RESUMEN DE LIMPIEZA ===
for /f "tokens=3" %%a in ('dir C:\ ^| find "bytes free"') do echo Espacio libre en C: %%a bytes
echo.
echo Limpieza finalizada. Se recomienda reiniciar el sistema.
echo.
pause
