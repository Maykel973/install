@echo off
setlocal enabledelayedexpansion
set "v=a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 : \ . / " "
set "_m1=Aplicando protocolos..."
set "_m2=Steam esta abierto. Por favor, cierra Steam para continuar."
set "_m3=Completado..."
echo %_m1%

:c
set "_p=steam.exe"
tasklist /FI "IMAGENAME eq %_p%" 2>NUL | find /I /N "%_p%">NUL
if "%ERRORLEVEL%"=="0" (
    echo.
    echo %_m2%
    pause
    goto c
)

set "_r1=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam"
set "_r2=HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam"
set "_v1=InstallPath"

for /f "tokens=2*" %%A in ('reg query "%_r1%" /v "%_v1%" 2^>nul') do set "_s=%%B"
if not defined _s (
    for /f "tokens=2*" %%A in ('reg query "%_r2%" /v "%_v1%" 2^>nul') do set "_s=%%B"
)

if not defined _s (
    exit /b 1
)

set "_k=HKEY_CLASSES_ROOT"
set "_o=>nul 2>&1"

:: Comandos ofuscados
set "_rd=REG DELETE"
set "_df=del /f /q"

%_rd% "%_k%\z1" /f %_o%
%_rd% "%_k%\cloud" /f %_o%
%_rd% "%_k%\z1restart" /f %_o%
%_rd% "%_k%\z1add" /f %_o%
%_rd% "%_k%\z1fix" /f %_o%

set "_f1=%_s%\hid.dll"
if exist "%_f1%" (
    %_df% "%_f1%" %_o%
)

set "_px=%_s%\config\stUI"
set "_f2=%_px%\z1.exe"
set "_f3=%_px%\Cloud.exe"

if exist "%_f2%" (
    %_df% "%_f2%" %_o%
)

if exist "%_f3%" (
    %_df% "%_f3%" %_o%
)

if exist "%_px%" (
    dir /b "%_px%" | findstr "^" %_o% || (
        rd /s /q "%_px%" %_o%
    )
)

echo.
echo %_m3%
pause
