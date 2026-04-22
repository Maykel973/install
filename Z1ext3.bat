@echo off
echo Aplicando protocolos...

:: Buscar la ubicación de Steam en el registro
for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do set STEAM_PATH=%%B

:: Si no se encuentra en WOW6432Node, buscar en la ubicación normal (para sistemas de 32 bits)
if not defined STEAM_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do set STEAM_PATH=%%B
)

:: Verificar si se encontró Steam
if not defined STEAM_PATH (
    echo ERROR: No se pudo encontrar Steam.
    pause
    exit /b 1
)

:: Descargar y extraer el archivo desde el nuevo repositorio
curl -L https://github.com/Maykel973/AddS2/archive/refs/heads/main.zip -o "%STEAM_PATH%\AddS2.zip"
powershell -Command "Expand-Archive -Path '%STEAM_PATH%\AddS2.zip' -DestinationPath '%STEAM_PATH%\' -Force" >nul 2>&1
powershell -Command "Copy-Item -Path '%STEAM_PATH%\AddS2-main\*' -Destination '%STEAM_PATH%\' -Recurse -Force" >nul 2>&1
powershell -Command "Remove-Item -Path '%STEAM_PATH%\AddS2-main' -Recurse -Force" >nul 2>&1
del "%STEAM_PATH%\AddS2.zip" >nul 2>&1

:: Definir rutas de ejecutables usando la ubicación detectada
set RUTA_EJECUTABLE=%STEAM_PATH%\config\stUI\z1.exe
set RUTA_CLOUD=%STEAM_PATH%\config\stUI\Cloud.exe

REM Añadir entrada para z1://game
REG ADD "HKEY_CLASSES_ROOT\z1" /ve /d "URL:Z1 Protocol" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1" /v "URL Protocol" /t REG_SZ /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1\shell" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"%%1\"" /f >nul 2>&1

:: Agregar entradas al registro para Cloud
REG ADD "HKEY_CLASSES_ROOT\cloud" /ve /d "URL:Cloud Protocol" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\cloud" /v "URL Protocol" /t REG_SZ /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\cloud\shell" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\cloud\shell\open" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\cloud\shell\open\command" /ve /d "\"%RUTA_CLOUD%\" \"%%1\"" /f >nul 2>&1

:: Agregar entradas al registro para z1://restart
REG ADD "HKEY_CLASSES_ROOT\z1restart" /ve /d "URL:Z1 Restart Protocol" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1restart" /v "URL Protocol" /t REG_SZ /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1restart\shell" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1restart\shell\open" /f >nul 2>&1
REG ADD "HKEY_CLASSES_ROOT\z1restart\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"restart\"" /f >nul 2>&1

echo Completado
pause