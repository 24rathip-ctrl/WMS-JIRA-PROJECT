package com.wms.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Manages JDBC database connections.
 * Credentials are loaded from config/db.properties or classpath, never hard-coded.
 */
public class DBConnection {

    private static String url;
    private static String user;
    private static String password;
    private static boolean initialized = false;

    /**
     * Loads database configuration.
     */
    private static synchronized void init() {
        if (initialized) return;

        Properties props = new Properties();
        boolean loaded = false;

        // 1. Try Classpath (standard in Tomcat WEB-INF/classes)
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
                loaded = true;
            }
        } catch (IOException ignored) {}

        // 2. Try file system candidate locations if not loaded from classpath
        if (!loaded) {
            String[] candidatePaths = {
                System.getProperty("wms.config", ""),
                "config/db.properties",
                "../config/db.properties",
                "c:/Users/vidhi/OneDrive/Desktop/Jira project/config/db.properties"
            };

            for (String path : candidatePaths) {
                if (path != null && !path.trim().isEmpty()) {
                    File file = new File(path);
                    if (file.exists() && file.isFile()) {
                        try (InputStream in = new FileInputStream(file)) {
                            props.load(in);
                            loaded = true;
                            break;
                        } catch (IOException ignored) {}
                    }
                }
            }
        }

        // 3. Fallback to environment variables if provided
        if (System.getenv("WMS_DB_URL") != null) {
            url = System.getenv("WMS_DB_URL");
            user = System.getenv("WMS_DB_USER");
            password = System.getenv("WMS_DB_PASS");
            loaded = true;
        } else if (loaded) {
            url = props.getProperty("db.url");
            user = props.getProperty("db.user");
            password = props.getProperty("db.password");
        }

        if (!loaded || url == null || user == null || password == null) {
            throw new RuntimeException(
                "Unable to load database configuration. Ensure db.properties exists with db.url, db.user, and db.password.");
        }

        // Register JDBC driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found on classpath.", e);
        }

        initialized = true;
    }

    /**
     * Returns a new active database connection.
     * The caller is responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        init();
        return DriverManager.getConnection(url, user, password);
    }
}
