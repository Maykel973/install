# Descargar y extraer el archivo
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "$env:ProgramFiles(x86)\Steam\AddS.zip"

# Expander el archivo ZIP
Expand-Archive -Path "$env:ProgramFiles(x86)\Steam\AddS.zip" -DestinationPath "$env:ProgramFiles(x86)\Steam\" -Force

# Copiar los archivos dalam recursión
Copy-Item -Path "$env:ProgramFiles(x86)\Steam\AddS-main\*" -Destination "$env:ProgramFiles(x86)\Steam\" -Recurse -Force

# Eliminar el directorio temporal
Remove-Item -Path "$env:ProgramFiles(x86)\Steam\AddS-main" -Recurse -Force

# Eliminar el archivo ZIP descargado
Remove-Item -Path "$env:ProgramFiles(x86)\Steam\AddS.zip" -Force

# Agregar entradas al registro
$regKey = "HKEY_CLASSES_ROOT\addsteam"
New-RegistryKey -Path $regKey -Force

Set-RegistryValue -Path $regKey -Name "URL" -Value "" -Type String -Force
Set-RegistryValue -Path $regKey -Name "Protocol" -Value "http" -Type String -Force
Set-RegistryValue -Path "$regKey\shell" -Name "open" -Value "" -Type String -Force
Set-RegistryValue -Path "$regKey\shell\open" -Name "command" -Value '"C:\Program Files (x86)\Steam\config\stUI\AddSteam.exe" "%1"' -Type String -Force

echo Completado.
pause
