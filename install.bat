@echo off
echo Configurando protocolos personalizados Z1 en el registro...

set RUTA_EJECUTABLE=C:\Program Files (x86)\Steam\config\stUI\z1.exe

REM Añadir entrada para z1://game

REG ADD "HKEY_CLASSES_ROOT\z1" /ve /d "URL:Z1 Protocol" /f
REG ADD "HKEY_CLASSES_ROOT\z1" /v "URL Protocol" /t REG_SZ /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell" /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open" /f
REG ADD "HKEY_CLASSES_ROOT\z1\shell\open\command" /ve /d "\"%RUTA_EJECUTABLE%\" \"%%1\"" /f

echo.
echo Configuración completada.
