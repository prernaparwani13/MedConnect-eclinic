package com.Medconnect.Utils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.stream.Collectors;

public class DatabaseInitializer {

    public static void initializeDatabase() {
        try (Connection conn = DBConnection.getInstance().getConnection()) {
            System.out.println("Initializing database tables...");
            
            // Read schema.sql
            InputStream in = DatabaseInitializer.class.getClassLoader().getResourceAsStream("schema.sql");
            if (in == null) {
                System.err.println("schema.sql not found in resources!");
                return;
            }
            
            String sqlContent;
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in))) {
                sqlContent = reader.lines().collect(Collectors.joining("\n"));
            }
            
            // Execute statements
            try (Statement stmt = conn.createStatement()) {
                // Split by semicolon, but ignore semicolons inside comments or quotes
                // Our schema.sql is simple, so splitting by ";" and filtering empty lines is fine.
                String[] queries = sqlContent.split(";");
                for (String query : queries) {
                    String trimmedQuery = query.trim();
                    if (!trimmedQuery.isEmpty()) {
                        stmt.execute(trimmedQuery);
                    }
                }
            }
            
            System.out.println("Database tables checked/created successfully.");
            
            // Insert default data if users table is empty
            String checkUsersSql = "SELECT COUNT(*) FROM users";
            boolean insertDefaults = false;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(checkUsersSql)) {
                if (rs.next() && rs.getInt(1) == 0) {
                    insertDefaults = true;
                }
            }
            
            if (insertDefaults) {
                System.out.println("Inserting sample/default users, departments, doctors, and patients...");
                
                // 1. Default Users
                String insertUserSql = "INSERT INTO users (name, email, password, role, is_active) VALUES (?, ?, ?, ?, 1)";
                
                // Admin (admin123)
                int adminId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "System Admin");
                    ps.setString(2, "admin@medconnect.com");
                    ps.setString(3, PasswordHasher.hashPassword("admin123"));
                    ps.setString(4, "admin");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) adminId = rsKeys.getInt(1);
                    }
                }
                
                // Doctor User (doctor123)
                int doctorId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Dr. Priya Sharma");
                    ps.setString(2, "doctor@medconnect.com");
                    ps.setString(3, PasswordHasher.hashPassword("doctor123"));
                    ps.setString(4, "doctor");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) doctorId = rsKeys.getInt(1);
                    }
                }
                
                // Receptionist User (recep123)
                int recepId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Sarah Connor");
                    ps.setString(2, "receptionist@medconnect.com");
                    ps.setString(3, PasswordHasher.hashPassword("recep123"));
                    ps.setString(4, "receptionist");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) recepId = rsKeys.getInt(1);
                    }
                }
                
                // Patient User (patient123)
                int patientId = 0;
                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "John Doe");
                    ps.setString(2, "patient@medconnect.com");
                    ps.setString(3, PasswordHasher.hashPassword("patient123"));
                    ps.setString(4, "patient");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) patientId = rsKeys.getInt(1);
                    }
                }
                
                // 2. Default Departments
                String insertDeptSql = "INSERT INTO departments (name, description) VALUES (?, ?)";
                int cardioId = 0;
                int dermaId = 0;
                
                try (PreparedStatement ps = conn.prepareStatement(insertDeptSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Cardiology");
                    ps.setString(2, "Cardiovascular health, heart issues and surgery");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) cardioId = rsKeys.getInt(1);
                    }
                }
                
                try (PreparedStatement ps = conn.prepareStatement(insertDeptSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, "Dermatology");
                    ps.setString(2, "Skin, hair and nail diseases");
                    ps.executeUpdate();
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) dermaId = rsKeys.getInt(1);
                    }
                }
                
                // 3. Default Doctors details
                if (doctorId > 0) {
                    String insertDoctorSql = "INSERT INTO doctors (user_id, name, email, specialization, phone, address, department_id, schedule) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertDoctorSql)) {
                        ps.setInt(1, doctorId);
                        ps.setString(2, "Dr. Priya Sharma");
                        ps.setString(3, "doctor@medconnect.com");
                        ps.setString(4, "Cardiology");
                        ps.setString(5, "+91 9876543211");
                        ps.setString(6, "Sector 5, Indore");
                        ps.setInt(7, cardioId);
                        ps.setString(8, "Mon-Fri 10:00-16:00");
                        ps.executeUpdate();
                    }
                }
                
                // 4. Default Patient details
                if (patientId > 0) {
                    String insertPatientSql = "INSERT INTO patients (user_id, name, email, phone, gender, dob, blood_group, address, medical_history) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertPatientSql)) {
                        ps.setInt(1, patientId);
                        ps.setString(2, "John Doe");
                        ps.setString(3, "patient@medconnect.com");
                        ps.setString(4, "+91 9876543212");
                        ps.setString(5, "Male");
                        ps.setString(6, "1990-05-15");
                        ps.setString(7, "O+");
                        ps.setString(8, "Vijay Nagar, Indore");
                        ps.setString(9, "No chronic conditions. Occasional seasonal allergies.");
                        ps.executeUpdate();
                    }
                }
                
                // 5. Default Staff details
                if (recepId > 0) {
                    String insertStaffSql = "INSERT INTO staff (user_id, name, email, role, phone, address) VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertStaffSql)) {
                        ps.setInt(1, recepId);
                        ps.setString(2, "Sarah Connor");
                        ps.setString(3, "receptionist@medconnect.com");
                        ps.setString(4, "receptionist");
                        ps.setString(5, "+91 9876543213");
                        ps.setString(6, "Palasia, Indore");
                        ps.executeUpdate();
                    }
                }
                
                System.out.println("Default data inserted successfully.");
            }
            
        } catch (Exception e) {
            System.err.println("Error initializing database: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
