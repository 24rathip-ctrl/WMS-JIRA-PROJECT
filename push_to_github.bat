@echo off
setlocal
title Push WMS Project to GitHub

echo =========================================================
echo             PUSHING WMS PROJECT TO GITHUB
echo =========================================================
echo Target Repository: https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT
echo.

set "PATH=C:\Users\vidhi\PortableGit\cmd;C:\Users\vidhi\PortableGit\bin;C:\Users\vidhi\PortableGit\mingw64\bin;%PATH%"
set "GCM_INTERACTIVE=always"

cd /d "%~dp0"

echo [1/2] Connecting to GitHub...
echo A browser window (Chrome) will open for you to authorize GitHub.
echo If prompted, click "Sign in with your browser" and click "Authorize".
echo.

git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo =========================================================
    echo   SUCCESSFULLY PUSHED TO GITHUB!
    echo   Repository: https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT
    echo =========================================================
) else (
    echo.
    echo [NOTICE] If the browser did not pop up automatically, you can also sign in
    echo using a Personal Access Token from GitHub Settings.
)

echo.
pause
