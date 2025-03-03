@echo off

:: Descargar y extraer el archivo
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "%ProgramFiles(x86)%\Steam\AddS.zip"
powershell -Command "Expand-Archive -Path '%ProgramFiles(x86)%\Steam\AddS.zip' -DestinationPath '%ProgramFiles(x86)%\Steam\'"
powershell -Command "Copy-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main\*' -Destination '%ProgramFiles(x86)%\Steam\' -Recurse -Force"
powershell -Command "Remove-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main' -Recurse -Force"
del "%ProgramFiles(x86)%\Steam\AddS.zip"

:: Agregar entradas al registro
REG ADD "HKEY_CLASSES_ROOT\addsteam" /ve /d "URL:AddSteam Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\AddSteam.exe\" \"%1\"" /f

:: Agregar entradas al registro para AddDLC
REG ADD "HKEY_CLASSES_ROOT\adddlc" /ve /d "URL:AddDLC Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\adddlc\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\AddDLC.exe\" \"%1\"" /f

:: Agregar entradas al registro para Z1Downloader
REG ADD "HKEY_CLASSES_ROOT\z1downloader" /ve /d "URL:Z1Downloader Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\z1downloader\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\Z1Downloader.exe\" \"%1\"" /f

echo Completado.
pause
