package com.Medconnect.Utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static DBConnection instance;
    private String DB_URL;
    private String DB_USER;
    private String DB_PASSWORD;
    private String DB_DRIVER;

    private DBConnection() {
        java.util.Properties props = new java.util.Properties();
        try (java.io.InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (java.io.IOException e) {
            // ignore, will use defaults
        }

        DB_URL = props.getProperty("db.url", "jdbc:mysql://localhost:3306/medconnect_db");
        DB_USER = props.getProperty("db.user", "root");
        DB_PASSWORD = props.getProperty("db.password", "prerna25");
        DB_DRIVER = props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
    }

    public static DBConnection getInstance() {
        if (instance == null) {
            synchronized (DBConnection.class) {
                if (instance == null) {
                    instance = new DBConnection();
                }
            }
        }
        return instance;
    }

    public Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName(DB_DRIVER);
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    public void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
