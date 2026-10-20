@echo off
setlocal
echo =================================================
echo        PUSHING WMS PROJECT TO GITHUB
echo =================================================
echo Target Repository: https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT
echo.

set "PATH=C:\Users\vidhi\PortableGit\bin;C:\Users\vidhi\PortableGit\mingw64\bin;%PATH%"

cd /d "%~dp0"

echo Running: git push -u origin main
echo (If a browser window or login prompt appears, please authorize or sign in)
echo.

git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo =================================================
    echo   SUCCESSFULLY PUSHED TO GITHUB!
    echo   View online: https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT
    echo =================================================
) else (
    echo.
    echo [ERROR] Git push failed. Please check your credentials or network connection.
)

pause
