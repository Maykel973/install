@echo off
curl -L https://github.com/Maykel973/AddS/archive/refs/heads/main.zip -o "%ProgramFiles(x86)%\Steam\AddS.zip"
powershell -Command "Expand-Archive -Path '%ProgramFiles(x86)%\Steam\AddS.zip' -DestinationPath '%ProgramFiles(x86)%\Steam\'"
powershell -Command "Copy-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main\*' -Destination '%ProgramFiles(x86)%\Steam\' -Recurse -Force"
powershell -Command "Remove-Item -Path '%ProgramFiles(x86)%\Steam\AddS-main' -Recurse -Force"
del "%ProgramFiles(x86)%\Steam\AddS.zip"
