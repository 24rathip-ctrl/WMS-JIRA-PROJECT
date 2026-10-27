# Warehouse Management System (WMS) - PowerShell Build & Deploy Script

$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$TomcatHome  = if ($env:CATALINA_HOME) { $env:CATALINA_HOME } else { "C:\apache-tomcat-9.0.97" }
$JavaHome    = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot" }

$Javac = if (Get-Command javac -ErrorAction SilentlyContinue) { "javac" } else { "$JavaHome\bin\javac.exe" }
$Jar   = if (Get-Command jar -ErrorAction SilentlyContinue) { "jar" } else { "$JavaHome\bin\jar.exe" }

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   BUILDING WAREHOUSE MANAGEMENT SYSTEM (WMS)   " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Clean previous build classes
$WebInfClasses = "$ProjectRoot\web\WEB-INF\classes"
$WebInfLib     = "$ProjectRoot\web\WEB-INF\lib"
$DistDir       = "$ProjectRoot\dist"

if (-not (Test-Path $WebInfClasses)) { New-Item -ItemType Directory -Path $WebInfClasses -Force | Out-Null }
if (-not (Test-Path $WebInfLib))     { New-Item -ItemType Directory -Path $WebInfLib -Force | Out-Null }
if (-not (Test-Path $DistDir))        { New-Item -ItemType Directory -Path $DistDir -Force | Out-Null }

# 2. Ensure JDBC Driver is in WEB-INF/lib and Tomcat lib
$DriverSrc = "$ProjectRoot\lib\mysql-connector-j-8.4.0.jar"
if (Test-Path $DriverSrc) {
    Copy-Item $DriverSrc "$WebInfLib\" -Force
    Copy-Item $DriverSrc "$TomcatHome\lib\" -Force
    Write-Host "[OK] MySQL JDBC driver verified in WEB-INF/lib and Tomcat/lib." -ForegroundColor Green
} else {
    Write-Host "[ERROR] MySQL JDBC driver missing from $DriverSrc" -ForegroundColor Red
    exit 1
}

# 3. Copy db.properties into classpath (WEB-INF/classes)
$DbProps = "$ProjectRoot\config\db.properties"
if (Test-Path $DbProps) {
    Copy-Item $DbProps "$WebInfClasses\" -Force
    Write-Host "[OK] db.properties copied to WEB-INF/classes." -ForegroundColor Green
} else {
    Write-Host "[ERROR] config/db.properties not found! Copy config/db.properties.example and configure credentials." -ForegroundColor Red
    exit 1
}

# 4. Compile Java sources
$Classpath = "$TomcatHome\lib\servlet-api.jar;$DriverSrc"
$JavaFiles = (Get-ChildItem -Path "$ProjectRoot\src" -Filter "*.java" -Recurse).FullName

Write-Host "Compiling $($JavaFiles.Count) Java source files..." -ForegroundColor Yellow
& $Javac -encoding UTF-8 -cp $Classpath -d $WebInfClasses $JavaFiles
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAILED] Java compilation error." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] All Java classes compiled successfully." -ForegroundColor Green

# 5. Deploy directly to Tomcat webapps/wms
$DeployDir = "$TomcatHome\webapps\wms"
if (Test-Path $DeployDir) {
    Remove-Item -Recurse -Force $DeployDir
}
New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null
Copy-Item -Recurse "$ProjectRoot\web\*" $DeployDir -Force
Write-Host "[OK] Deployed web application to $DeployDir." -ForegroundColor Green

# 6. Package WAR file into dist/wms.war
$WarFile = "$DistDir\wms.war"
if (Test-Path $WarFile) { Remove-Item -Force $WarFile }
Push-Location "$ProjectRoot\web"
& $Jar -cvf $WarFile * | Out-Null
Pop-Location
Write-Host "[OK] Packaged standalone WAR archive at $WarFile." -ForegroundColor Green

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "           BUILD COMPLETED SUCCESSFULLY!         " -ForegroundColor Green
Write-Host "   URL: http://localhost:8080/wms/               " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
