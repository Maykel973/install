@echo off
echo Configurando protocolos personalizados Z1 en el registro...
:: Descargar y extraer el archivo
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "%ProgramFiles(x86)%\Steam\AddS.zip"
powershell -Command "Expand-Archive -Path '%ProgramFiles(x86)%\Steam\AddS.zip' -DestinationPath '%ProgramFiles(x86)%\Steam\'"
powershell -Command "Copy-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main\*' -Destination '%ProgramFiles(x86)%\Steam\' -Recurse -Force"
powershell -Command "Remove-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main' -Recurse -Force"
del "%ProgramFiles(x86)%\Steam\AddS.zip"

set RUTA_EJECUTABLE=C:\Program Files (x86)\Steam\config\stUI\z1.exe

REM Añadir entrada para z1://game

REG ADD "HKEY_CLASSES_ROOT\z1" /ve /d "URL:Z1 Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\z1" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell" /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"%%1\"" /f

echo.
echo Configuración completada.
