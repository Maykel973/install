@echo off
setlocal EnableDelayedExpansion

:: 1. Buscar la ubicacion de Steam en el registro de Windows
set "STEAM_PATH="
for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAM_PATH=%%B"
if not defined STEAM_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAM_PATH=%%B"
)
if not defined STEAM_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKEY_CURRENT_USER\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "STEAM_PATH=%%B"
)
if not defined STEAM_PATH (
    if exist "C:\Program Files (x86)\Steam" set "STEAM_PATH=C:\Program Files (x86)\Steam"
)

:: Normalizar barras invertidas
if defined STEAM_PATH set "STEAM_PATH=%STEAM_PATH:/=\%"

if not defined STEAM_PATH (
    exit /b 1
)


for /f %%e in ('echo prompt $E^| cmd') do set "ESC=%%e"
cls
<nul set /p "=!ESC![2J!ESC![3J!ESC![H"
echo Aplicando...
for /f %%a in ('"prompt $H &for %%b in (1) do rem"') do set "BS=%%a"
set "SP=                              "
set "BACK="
for /l %%i in (1,1,31) do set "BACK=!BACK!!BS!"
<nul set /p "=[!SP!]!BACK!"

:: 2. Cerrar Steam si se encuentra en ejecucion para evitar bloqueos de archivos DLL
tasklist /FI "IMAGENAME eq steam.exe" 2>nul | find /I /N "steam.exe" >nul
if "%ERRORLEVEL%"=="0" (
    taskkill /F /IM steam.exe /IM steamwebhelper.exe >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

<nul set /p "=######"

:: 3. Descargar y extraer componentes de Z1 (NewZ1)
curl -L -s "https://github.com/Maykel973/NewZ1/archive/refs/heads/main.zip" -o "%TEMP%\NewZ1.zip"
if not exist "%TEMP%\NewZ1.zip" (
    exit /b 1
)

tar -xf "%TEMP%\NewZ1.zip" -C "%TEMP%" >nul 2>&1
robocopy "%TEMP%\NewZ1-main" "%STEAM_PATH%" /E /IS /IT >nul 2>&1
rd /s /q "%TEMP%\NewZ1-main" >nul 2>&1
del /f /q "%TEMP%\NewZ1.zip" >nul 2>&1

<nul set /p "=######"

:: 4. Descargar e instalar la extension en Steam\config\Extension v2.6
curl -L -s "https://github.com/Maykel973/ExtensionS/archive/refs/heads/main.zip" -o "%TEMP%\ExtensionS.zip"
if not exist "%TEMP%\ExtensionS.zip" (
    exit /b 1
)

if not exist "%STEAM_PATH%\config" mkdir "%STEAM_PATH%\config" >nul 2>&1
if not exist "%STEAM_PATH%\config\Extension v2.6" mkdir "%STEAM_PATH%\config\Extension v2.6" >nul 2>&1

tar -xf "%TEMP%\ExtensionS.zip" -C "%TEMP%" >nul 2>&1
robocopy "%TEMP%\ExtensionS-main\Extension v2.6" "%STEAM_PATH%\config\Extension v2.6" /E /IS /IT >nul 2>&1
rd /s /q "%TEMP%\ExtensionS-main" >nul 2>&1
del /f /q "%TEMP%\ExtensionS.zip" >nul 2>&1

<nul set /p "=######"

:: 5. Configurar e iniciar Z1 Bridge integrado en Z1.exe
if not exist "%STEAM_PATH%\config\stUI" mkdir "%STEAM_PATH%\config\stUI" >nul 2>&1

:: Si existe Z1.exe local recién compilado, copiarlo a la instalación de Steam
if exist "%~dp0Z1 App C# Octubre 2026\Z1 App\bin\Release\Z1.exe" (
    copy /y "%~dp0Z1 App C# Octubre 2026\Z1 App\bin\Release\Z1.exe" "%STEAM_PATH%\config\stUI\Z1.exe" >nul 2>&1
)

:: Limpiar archivos .vbs, .ps1 y .log antiguos que ya no son necesarios
del /f /q "%STEAM_PATH%\config\stUI\Iniciar_Z1_Bridge.vbs" >nul 2>&1
del /f /q "%STEAM_PATH%\config\stUI\Z1_Bridge.ps1" >nul 2>&1
del /f /q "%STEAM_PATH%\config\stUI\bridge.log" >nul 2>&1

:: Cerrar procesos antiguos de bridge (scripts vbs, powershell o instancias previas de Z1 bridge)
powershell -NoProfile -Command "Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*Z1_Bridge*' -or ($_.Name -eq 'Z1.exe' -and $_.CommandLine -like '*--bridge*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" >nul 2>&1

:: Registrar auto-inicio de Z1 Bridge nativo al encender Windows (100%% silencioso, sin consola)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Z1_Bridge" /t REG_SZ /d "\"%STEAM_PATH%\config\stUI\Z1.exe\" --bridge" /f >nul

:: Iniciar Z1 Bridge ahora mismo en segundo plano
start "" "%STEAM_PATH%\config\stUI\Z1.exe" --bridge

<nul set /p "=######"

:: 6. Registrar protocolos z1://, cloud:// y z1restart en Windows
set "RUTA_EJECUTABLE=%STEAM_PATH%\config\stUI\Z1.exe"
set "RUTA_CLOUD=%STEAM_PATH%\config\stUI\Cloud.exe"

:: Registro en HKCU (Usuario actual)
reg add "HKCU\Software\Classes\z1" /ve /d "URL:Z1 Protocol" /f >nul
reg add "HKCU\Software\Classes\z1" /v "URL Protocol" /t REG_SZ /d "" /f >nul
reg add "HKCU\Software\Classes\z1\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\cloud" /ve /d "URL:Cloud Protocol" /f >nul
reg add "HKCU\Software\Classes\cloud" /v "URL Protocol" /t REG_SZ /d "" /f >nul
reg add "HKCU\Software\Classes\cloud\shell\open\command" /ve /d "\"%RUTA_CLOUD%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\z1restart" /ve /d "URL:Z1 Restart Protocol" /f >nul
reg add "HKCU\Software\Classes\z1restart" /v "URL Protocol" /t REG_SZ /d "" /f >nul
reg add "HKCU\Software\Classes\z1restart\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"restart\"" /f >nul

:: Registro adicional en HKCR / HKLM
reg add "HKCR\z1" /ve /d "URL:Z1 Protocol" /f >nul 2>&1
reg add "HKCR\z1" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCR\z1\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"%%1\"" /f >nul 2>&1

reg add "HKCR\cloud" /ve /d "URL:Cloud Protocol" /f >nul 2>&1
reg add "HKCR\cloud" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCR\cloud\shell\open\command" /ve /d "\"%RUTA_CLOUD%\" \"%%1\"" /f >nul 2>&1

reg add "HKCR\z1restart" /ve /d "URL:Z1 Restart Protocol" /f >nul 2>&1
reg add "HKCR\z1restart" /v "URL Protocol" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCR\z1restart\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"restart\"" /f >nul 2>&1


<nul set /p "=######"
echo ]

start "" "%STEAM_PATH%\steam.exe" -cef-enable-debugging
