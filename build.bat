@echo off
setlocal

echo =================================================
echo    BUILDING WAREHOUSE MANAGEMENT SYSTEM (WMS)
echo =================================================

set "PROJECT_ROOT=%~dp0"
set "TOMCAT_HOME=C:\apache-tomcat-9.0.97"
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"

set "JAVAC=%JAVA_HOME%\bin\javac.exe"
set "JAR=%JAVA_HOME%\bin\jar.exe"

if not exist "%JAVAC%" (
    echo [ERROR] javac.exe not found at %JAVAC%
    exit /b 1
)

:: Create required directories
if not exist "%PROJECT_ROOT%web\WEB-INF\classes" mkdir "%PROJECT_ROOT%web\WEB-INF\classes"
if not exist "%PROJECT_ROOT%web\WEB-INF\lib" mkdir "%PROJECT_ROOT%web\WEB-INF\lib"
if not exist "%PROJECT_ROOT%dist" mkdir "%PROJECT_ROOT%dist"

:: Copy JDBC driver
copy /y "%PROJECT_ROOT%lib\mysql-connector-j-8.4.0.jar" "%PROJECT_ROOT%web\WEB-INF\lib\" >nul
copy /y "%PROJECT_ROOT%lib\mysql-connector-j-8.4.0.jar" "%TOMCAT_HOME%\lib\" >nul

:: Copy db.properties
copy /y "%PROJECT_ROOT%config\db.properties" "%PROJECT_ROOT%web\WEB-INF\classes\" >nul

:: Compile
echo Compiling Java source files...
dir /s /b "%PROJECT_ROOT%src\*.java" > "%TEMP%\sources.txt"
"%JAVAC%" -encoding UTF-8 -cp "%TOMCAT_HOME%\lib\servlet-api.jar;%PROJECT_ROOT%lib\mysql-connector-j-8.4.0.jar" -d "%PROJECT_ROOT%web\WEB-INF\classes" @"%TEMP%\sources.txt"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Java compilation failed!
    exit /b %ERRORLEVEL%
)
del "%TEMP%\sources.txt"

:: Deploy to Tomcat
echo Deploying to Tomcat...
if exist "%TOMCAT_HOME%\webapps\wms" rmdir /s /q "%TOMCAT_HOME%\webapps\wms"
mkdir "%TOMCAT_HOME%\webapps\wms"
xcopy /e /y "%PROJECT_ROOT%web\*" "%TOMCAT_HOME%\webapps\wms\" >nul

:: Create WAR
echo Packaging WAR file...
cd /d "%PROJECT_ROOT%web"
"%JAR%" -cvf "%PROJECT_ROOT%dist\wms.war" * >nul
cd /d "%PROJECT_ROOT%"

echo =================================================
echo         BUILD COMPLETED SUCCESSFULLY!
echo    URL: http://localhost:8080/wms/
echo =================================================
