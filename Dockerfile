# ---------- Stage 1: Build ----------
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /build

# Download Servlet API (Tomcat 9 = javax.servlet 4.0)
RUN curl -sSL -o /tmp/javax.servlet-api-4.0.1.jar \
    https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar

# Copy only the sources and dependencies needed for compilation
COPY lib/mysql-connector-j-8.4.0.jar /build/lib/
COPY src/ /build/src/

# Compile
RUN mkdir -p /build/classes && \
    javac -cp "/tmp/javax.servlet-api-4.0.1.jar:/build/lib/mysql-connector-j-8.4.0.jar" \
          -d /build/classes \
          $(find /build/src -name "*.java")

# ---------- Stage 2: Assemble WAR ----------
FROM eclipse-temurin:17-jdk AS assembler

WORKDIR /staging

# Copy web content (static files + WEB-INF/web.xml)
COPY web/ /staging/

# Remove any stale local artifacts that might have leaked in
RUN rm -rf /staging/WEB-INF/classes \
           /staging/WEB-INF/lib && \
    find /staging -name "*db.properties*" -delete

# Add freshly compiled classes and JDBC driver
COPY --from=builder /build/classes/ /staging/WEB-INF/classes/
COPY lib/mysql-connector-j-8.4.0.jar /staging/WEB-INF/lib/

# Package WAR
RUN jar -cvf /wms.war -C /staging .

# ---------- Stage 3: Runtime ----------
FROM tomcat:9-jdk17-temurin

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy the WAR — Tomcat auto-extracts it at /wms context
COPY --from=assembler /wms.war /usr/local/tomcat/webapps/wms.war

# Configure Tomcat to listen on the PORT env var (Render sets this)
# Replace the default 8080 connector port with ${PORT} using sed at startup
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/docker-entrypoint.sh"]
