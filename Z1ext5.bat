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

:: 5. Instalar Z1 Bridge y su lanzador silencioso en Steam\config\stUI
if not exist "%STEAM_PATH%\config\stUI" mkdir "%STEAM_PATH%\config\stUI" >nul 2>&1

:: Escribir Z1_Bridge.ps1 decodificando el script base
powershell -NoProfile -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('IyBaMSBCcmlkZ2UgLSBTZXJ2aWRvciBsb2NhbCBwYXJhIGNvbXVuaWNhciBsYSBleHRlbnNpb24gZGUgU3RlYW0gY29uIFoxCiRzY3JpcHREaXIgPSAkUFNTY3JpcHRSb290CmlmICgtbm90ICRzY3JpcHREaXIpIHsgJHNjcmlwdERpciA9IFNwbGl0LVBhdGggLVBhcmVudCAkTXlJbnZvY2F0aW9uLk15Q29tbWFuZC5QYXRoIH0KaWYgKC1ub3QgJHNjcmlwdERpcikgeyAkc2NyaXB0RGlyID0gKEdldC1Mb2NhdGlvbikuUGF0aCB9CgokbG9nUGF0aCA9IEpvaW4tUGF0aCAkc2NyaXB0RGlyICJicmlkZ2UubG9nIgoiU3RhcnRpbmcgWjEgQnJpZGdlIGF0ICQoR2V0LURhdGUpIiB8IE91dC1GaWxlIC1GaWxlUGF0aCAkbG9nUGF0aCAtRW5jb2RpbmcgdXRmOAoKJHoxRXhlID0gSm9pbi1QYXRoICRzY3JpcHREaXIgIloxLmV4ZSIKJGNsb3VkRXhlID0gSm9pbi1QYXRoICRzY3JpcHREaXIgIkNsb3VkLmV4ZSIKaWYgKC1ub3QgKFRlc3QtUGF0aCAkejFFeGUpKSB7CiAgICB0cnkgewogICAgICAgICRyZWdQID0gKEdldC1JdGVtUHJvcGVydHkgLVBhdGggIkhLTE06XFNPRlRXQVJFXFdPVzY0MzJOb2RlXFZhbHZlXFN0ZWFtIiAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSkuSW5zdGFsbFBhdGgKICAgICAgICBpZiAoLW5vdCAkcmVnUCkgeyAkcmVnUCA9IChHZXQtSXRlbVByb3BlcnR5IC1QYXRoICJIS0xNOlxTT0ZUV0FSRVxWYWx2ZVxTdGVhbSIgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUpLkluc3RhbGxQYXRoIH0KICAgICAgICBpZiAoJHJlZ1ApIHsgJHoxRXhlID0gSm9pbi1QYXRoICRyZWdQICJjb25maWdcc3RVSVxaMS5leGUiOyAkY2xvdWRFeGUgPSBKb2luLVBhdGggJHJlZ1AgImNvbmZpZ1xzdFVJXENsb3VkLmV4ZSIgfQogICAgfSBjYXRjaCB7fQp9CgokcG9ydCA9IDQ1NzMxCiRsaXN0ZW5lciA9IE5ldy1PYmplY3QgU3lzdGVtLk5ldC5IdHRwTGlzdGVuZXIKJGxpc3RlbmVyLlByZWZpeGVzLkFkZCgiaHR0cDovLzEyNy4wLjAuMTokcG9ydC8iKQoKdHJ5IHsKICAgICRsaXN0ZW5lci5TdGFydCgpCiAgICAiTGlzdGVuZXIgYWN0aXZvIGVuIGh0dHA6Ly8xMjcuMC4wLjE6JHBvcnQvIiB8IE91dC1GaWxlIC1GaWxlUGF0aCAkbG9nUGF0aCAtQXBwZW5kIC1FbmNvZGluZyB1dGY4Cn0gY2F0Y2ggewogICAgIkVycm9yIGluaWNpYW5kbyBsaXN0ZW5lcjogJCgkXy5FeGNlcHRpb24uTWVzc2FnZSkiIHwgT3V0LUZpbGUgLUZpbGVQYXRoICRsb2dQYXRoIC1BcHBlbmQgLUVuY29kaW5nIHV0ZjgKICAgIGV4aXQgMQp9Cgp3aGlsZSAoJGxpc3RlbmVyLklzTGlzdGVuaW5nKSB7CiAgICB0cnkgewogICAgICAgICRjb250ZXh0ID0gJGxpc3RlbmVyLkdldENvbnRleHQoKQogICAgICAgICRyZXEgPSAkY29udGV4dC5SZXF1ZXN0CiAgICAgICAgJHJlcyA9ICRjb250ZXh0LlJlc3BvbnNlCgogICAgICAgIHRyeSB7CiAgICAgICAgICAgICRyZXMuSGVhZGVycy5BZGQoIkFjY2Vzcy1Db250cm9sLUFsbG93LU9yaWdpbiIsICIqIikKICAgICAgICAgICAgJHJlcy5IZWFkZXJzLkFkZCgiQWNjZXNzLUNvbnRyb2wtQWxsb3ctTWV0aG9kcyIsICJHRVQsIFBPU1QsIE9QVElPTlMiKQogICAgICAgICAgICAkcmVzLkhlYWRlcnMuQWRkKCJBY2Nlc3MtQ29udHJvbC1BbGxvdy1IZWFkZXJzIiwgIioiKQoKICAgICAgICAgICAgaWYgKCRyZXEuSHR0cE1ldGhvZCAtZXEgIk9QVElPTlMiKSB7CiAgICAgICAgICAgICAgICAkcmVzLlN0YXR1c0NvZGUgPSAyMDAKICAgICAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgICAgIH0KCiAgICAgICAgICAgICR1cmwgPSAkcmVxLlF1ZXJ5U3RyaW5nWyJ1cmwiXQogICAgICAgICAgICAiU29saWNpdHVkIHJlY2liaWRhOiAkdXJsIGEgbGFzICQoR2V0LURhdGUpIiB8IE91dC1GaWxlIC1GaWxlUGF0aCAkbG9nUGF0aCAtQXBwZW5kIC1FbmNvZGluZyB1dGY4CgogICAgICAgICAgICAkZXhlY3V0ZWQgPSAkZmFsc2UKICAgICAgICAgICAgaWYgKC1ub3QgW3N0cmluZ106OklzTnVsbE9yRW1wdHkoJHVybCkgLWFuZCAoJHVybCAtbWF0Y2ggIl56MTovLyIgLW9yICR1cmwgLW1hdGNoICJeQ2xvdWQ6Ly8iKSkgewogICAgICAgICAgICAgICAgdHJ5IHsKICAgICAgICAgICAgICAgICAgICBTdGFydC1Qcm9jZXNzICR1cmwgLUVycm9yQWN0aW9uIFN0b3AKICAgICAgICAgICAgICAgICAgICAkZXhlY3V0ZWQgPSAkdHJ1ZQogICAgICAgICAgICAgICAgfSBjYXRjaCB7CiAgICAgICAgICAgICAgICAgICAgIkZhbGxvIFNoZWxsRXhlY3V0ZTogJCgkXy5FeGNlcHRpb24uTWVzc2FnZSkiIHwgT3V0LUZpbGUgLUZpbGVQYXRoICRsb2dQYXRoIC1BcHBlbmQgLUVuY29kaW5nIHV0ZjgKICAgICAgICAgICAgICAgIH0KCiAgICAgICAgICAgICAgICBpZiAoLW5vdCAkZXhlY3V0ZWQpIHsKICAgICAgICAgICAgICAgICAgICB0cnkgewogICAgICAgICAgICAgICAgICAgICAgICBpZiAoJHVybCAtbWF0Y2ggIl56MTovLyIgLWFuZCAoVGVzdC1QYXRoICR6MUV4ZSkpIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIFN0YXJ0LVByb2Nlc3MgLUZpbGVQYXRoICR6MUV4ZSAtQXJndW1lbnRMaXN0ICJgIiR1cmxgIiIKICAgICAgICAgICAgICAgICAgICAgICAgICAgICRleGVjdXRlZCA9ICR0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgIH0gZWxzZWlmICgkdXJsIC1tYXRjaCAiXkNsb3VkOi8vIiAtYW5kIChUZXN0LVBhdGggJGNsb3VkRXhlKSkgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgU3RhcnQtUHJvY2VzcyAtRmlsZVBhdGggJGNsb3VkRXhlIC1Bcmd1bWVudExpc3QgImAiJHVybGAiIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgJGV4ZWN1dGVkID0gJHRydWUKICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggewogICAgICAgICAgICAgICAgICAgICAgICAiRXJyb3IgZWplY3VjaW9uIGRpcmVjdGE6ICQoJF8uRXhjZXB0aW9uLk1lc3NhZ2UpIiB8IE91dC1GaWxlIC1GaWxlUGF0aCAkbG9nUGF0aCAtQXBwZW5kIC1FbmNvZGluZyB1dGY4CiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgfQoKICAgICAgICAgICAgICAgIGlmICgkZXhlY3V0ZWQpIHsKICAgICAgICAgICAgICAgICAgICAkYnVmZmVyID0gW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRCeXRlcygiT0siKQogICAgICAgICAgICAgICAgfSBlbHNlIHsKICAgICAgICAgICAgICAgICAgICAkYnVmZmVyID0gW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRCeXRlcygiRVJST1JfRVhFQyIpCiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0gZWxzZSB7CiAgICAgICAgICAgICAgICAkYnVmZmVyID0gW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRCeXRlcygiRVJST1JfSU5WQUxJRF9VUkwiKQogICAgICAgICAgICB9CgogICAgICAgICAgICAkcmVzLkNvbnRlbnRMZW5ndGg2NCA9ICRidWZmZXIuTGVuZ3RoCiAgICAgICAgICAgICRyZXMuT3V0cHV0U3RyZWFtLldyaXRlKCRidWZmZXIsIDAsICRidWZmZXIuTGVuZ3RoKQogICAgICAgIH0gZmluYWxseSB7CiAgICAgICAgICAgIHRyeSB7ICRyZXMuQ2xvc2UoKSB9IGNhdGNoIHt9CiAgICAgICAgfQogICAgfSBjYXRjaCB7CiAgICAgICAgIkVycm9yIGVuIGJ1Y2xlOiAkKCRfLkV4Y2VwdGlvbi5NZXNzYWdlKSIgfCBPdXQtRmlsZSAtRmlsZVBhdGggJGxvZ1BhdGggLUFwcGVuZCAtRW5jb2RpbmcgdXRmOAogICAgICAgIFN0YXJ0LVNsZWVwIC1NaWxsaXNlY29uZHMgMTAwCiAgICB9Cn0=')) | Set-Content -Path '%STEAM_PATH%\config\stUI\Z1_Bridge.ps1' -Encoding UTF8"

:: Escribir Iniciar_Z1_Bridge.vbs (lanzador 100% invisible)
> "%STEAM_PATH%\config\stUI\Iniciar_Z1_Bridge.vbs" (
    echo Set WshShell = CreateObject("WScript.Shell"^)
    echo Set fso = CreateObject("Scripting.FileSystemObject"^)
    echo scriptDir = fso.GetParentFolderName(WScript.ScriptFullName^)
    echo psScript = scriptDir ^& "\Z1_Bridge.ps1"
    echo WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ ^& psScript ^& """", 0, False
)

:: Registrar auto-inicio silencioso al encender Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Z1_Bridge" /t REG_SZ /d "wscript.exe \"%STEAM_PATH%\config\stUI\Iniciar_Z1_Bridge.vbs\"" /f >nul

:: Iniciar el Bridge ahora mismo en segundo plano
powershell -NoProfile -Command "Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'wscript.exe \"%STEAM_PATH%\config\stUI\Iniciar_Z1_Bridge.vbs\"' }" >nul 2>&1

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
