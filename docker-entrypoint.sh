#!/bin/sh
set -e

# Render assigns PORT (default 10000); Tomcat must listen on it
PORT="${PORT:-10000}"

# Patch server.xml to use the assigned port for the HTTP connector
sed -i "s/Connector port=\"8080\"/Connector port=\"${PORT}\"/" /usr/local/tomcat/conf/server.xml

echo "Starting Tomcat on port ${PORT} ..."
exec /usr/local/tomcat/bin/catalina.sh run
