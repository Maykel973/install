@echo off
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "%ProgramFiles(x86)%\Steam\AddS.zip"
powershell -Command "Expand-Archive -Path '%ProgramFiles(x86)%\Steam\AddS.zip' -DestinationPath '%ProgramFiles(x86)%\Steam\'"
powershell -Command "Copy-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main\*' -Destination '%ProgramFiles(x86)%\Steam\' -Recurse -Force"
powershell -Command "Remove-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main' -Recurse -Force"
del "%ProgramFiles(x86)%\Steam\AddS.zip"

REG ADD "HKEY_CLASSES_ROOT\addsteam" /ve /d "URL:AddSteam Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\addsteam\shell\open\command" /ve /d "\"C:\\Program Files (x86)\\Steam\\config\\stUI\\AddSteam.exe\" \"%1\"" /f
echo Protocolo AddSteam registrado correctamente.