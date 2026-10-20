@echo off
echo =================================================
echo   STARTING WMS SERVERS (MySQL 8.4 + Tomcat 9)
echo =================================================

set "MYSQL_BASE=C:\Program Files\MySQL\MySQL Server 8.4"
set "DATA_DIR=C:\Users\vidhi\mysql-data"
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
set "CATALINA_HOME=C:\apache-tomcat-9.0.97"

echo 1. Starting MySQL Server on port 3306...
start "MySQL Server" "%MYSQL_BASE%\bin\mysqld.exe" --datadir="%DATA_DIR%" --port=3306

timeout /t 3 >nul

echo 2. Starting Apache Tomcat on port 8080...
start "Apache Tomcat" "%CATALINA_HOME%\bin\catalina.bat" run

timeout /t 3 >nul

echo =================================================
echo   SERVERS STARTED!
echo   Open in browser: http://localhost:8080/wms/
echo =================================================
pause
