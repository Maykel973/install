
Hola, entiendo que necesitas otro archivo ejecutable llamado Cloud.exe en la misma ubicación que los demás. Voy a crear un script batch similar al que compartiste, pero modificado para instalar Cloud.exe.


CloudExe_Installer.bat
Código 
He creado un archivo batch similar al que compartiste, pero he añadido el protocolo URL para Cloud.exe. Este script:

Descarga y extrae los archivos desde el repositorio GitHub
Añade una nueva entrada de registro para el protocolo "cloud:" que apunta a Cloud.exe
Mantiene las entradas existentes para addsteam, adddlc y z1downloader
El nuevo ejecutable Cloud.exe estará en la misma ubicación que los demás: C:\Program Files (x86)\Steam\config\stUI\Cloud.exe

¿Necesitas alguna modificación adicional en este script?







@echo off

:: Descargar y extraer el archivo
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "%ProgramFiles(x86)%\Steam\AddS.zip"
powershell -Command "Expand-Archive -Path '%ProgramFiles(x86)%\Steam\AddS.zip' -DestinationPath '%ProgramFiles(x86)%\Steam\'"
powershell -Command "Copy-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main\*' -Destination '%ProgramFiles(x86)%\Steam\' -Recurse -Force"
powershell -Command "Remove-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main' -Recurse -Force"
del "%ProgramFiles(x86)%\Steam\AddS.zip"

:: Agregar entradas al registro para Cloud
REG ADD "HKEY_CLASSES_ROOT\cloud" /ve /d "URL:Cloud Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\cloud" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\cloud\shell" /f
REG ADD "HKEY_CLASSES_ROOT\cloud\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\cloud\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\Cloud.exe\" \"%1\"" /f

:: Mantener las entradas de registro existentes
REG ADD "HKEY_CLASSES_ROOT\addsteam" /ve /d "URL:AddSteam Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\AddSteam.exe\" \"%1\"" /f

REG ADD "HKEY_CLASSES_ROOT\adddlc" /ve /d "URL:AddDLC Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\AddDLC.exe\" \"%1\"" /f

REG ADD "HKEY_CLASSES_ROOT\z1downloader" /ve /d "URL:Z1Downloader Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\Z1Downloader.exe\" \"%1\"" /f

echo Completado.
pause
