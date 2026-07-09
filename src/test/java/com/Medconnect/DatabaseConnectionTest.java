package com.Medconnect;

import java.sql.Connection;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;
import org.junit.jupiter.api.Test;

import com.Medconnect.Utils.DBConnection;

public class DatabaseConnectionTest {

    @Test
    public void testDatabaseConnection() {
        Connection conn = null;
        try {
            conn = DBConnection.getInstance().getConnection();
            assertNotNull(conn, "Database connection should not be null");
            assertFalse(conn.isClosed(), "Database connection should be open");
            System.out.println("Database connection test passed!");
        } catch (SQLException | ClassNotFoundException e) {
            fail("Database connection failed: " + e.getMessage());
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }
}
