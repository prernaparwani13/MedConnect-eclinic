package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Patient;
import com.Medconnect.Model.User;
import com.Medconnect.Utils.DBConnection;

public class PatientDAO {

    private UserDAO userDAO = new UserDAO();

    // Add Patient (creates user login if email provided, then adds patient details)
    public boolean addPatient(Patient patient, String password) throws SQLException, ClassNotFoundException {
        Integer userId = null;
        if (patient.getEmail() != null && !patient.getEmail().trim().isEmpty()) {
            User user = new User();
            user.setName(patient.getName());
            user.setEmail(patient.getEmail());
            user.setPassword(password != null ? password : "patient123");
            user.setRole("patient");
            
            userId = userDAO.registerUser(user);
        }
        
        String sql = "INSERT INTO patients (user_id, name, email, phone, gender, dob, blood_group, address, medical_history) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (userId != null && userId > 0) {
                stmt.setInt(1, userId);
            } else {
                stmt.setNull(1, java.sql.Types.INTEGER);
            }
            stmt.setString(2, patient.getName());
            stmt.setString(3, patient.getEmail());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getGender());
            stmt.setDate(6, patient.getDob());
            stmt.setString(7, patient.getBloodGroup());
            stmt.setString(8, patient.getAddress());
            stmt.setString(9, patient.getMedicalHistory());
            
            return stmt.executeUpdate() > 0;
        }
    }

    // Get Patient by ID (refers to patients.id)
    public Patient getPatientById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM patients WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Patient p = new Patient(
                        rs.getInt("id"),
                        rs.getObject("user_id") != null ? rs.getInt("user_id") : null,
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("gender"),
                        rs.getDate("dob"),
                        rs.getString("blood_group"),
                        rs.getString("address"),
                        rs.getString("medical_history")
                    );
                    p.setCreatedAt(rs.getString("created_at"));
                    return p;
                }
            }
        }
        return null;
    }

    // Get Patient by User ID
    public Patient getPatientByUserId(int userId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM patients WHERE user_id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Patient p = new Patient(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("gender"),
                        rs.getDate("dob"),
                        rs.getString("blood_group"),
                        rs.getString("address"),
                        rs.getString("medical_history")
                    );
                    p.setCreatedAt(rs.getString("created_at"));
                    return p;
                }
            }
        }
        return null;
    }

    // Get all Patients
    public List<Patient> getAllPatients() throws SQLException, ClassNotFoundException {
        List<Patient> patients = new ArrayList<>();
        String sql = "SELECT * FROM patients ORDER BY name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Patient p = new Patient(
                    rs.getInt("id"),
                    rs.getObject("user_id") != null ? rs.getInt("user_id") : null,
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("phone"),
                    rs.getString("gender"),
                    rs.getDate("dob"),
                    rs.getString("blood_group"),
                    rs.getString("address"),
                    rs.getString("medical_history")
                );
                p.setCreatedAt(rs.getString("created_at"));
                patients.add(p);
            }
        }
        return patients;
    }

    // Update Patient Details
    public boolean updatePatient(Patient patient) throws SQLException, ClassNotFoundException {
        String updatePatientSql = "UPDATE patients SET name = ?, email = ?, phone = ?, gender = ?, dob = ?, blood_group = ?, address = ?, medical_history = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(updatePatientSql)) {
            stmt.setString(1, patient.getName());
            stmt.setString(2, patient.getEmail());
            stmt.setString(3, patient.getPhone());
            stmt.setString(4, patient.getGender());
            stmt.setDate(5, patient.getDob());
            stmt.setString(6, patient.getBloodGroup());
            stmt.setString(7, patient.getAddress());
            stmt.setString(8, patient.getMedicalHistory());
            stmt.setInt(9, patient.getId());
            
            boolean updated = stmt.executeUpdate() > 0;
            if (updated && patient.getUserId() != null) {
                // Keep the corresponding users record updated too
                String updateUserSql = "UPDATE users SET name = ?, email = ? WHERE id = ?";
                try (PreparedStatement uStmt = conn.prepareStatement(updateUserSql)) {
                    uStmt.setString(1, patient.getName());
                    uStmt.setString(2, patient.getEmail());
                    uStmt.setInt(3, patient.getUserId());
                    uStmt.executeUpdate();
                }
            }
            return updated;
        }
    }

    // Delete Patient
    public boolean deletePatient(int id) throws SQLException, ClassNotFoundException {
        Patient p = getPatientById(id);
        if (p != null) {
            // Delete corresponding users record (will cascade delete or we can delete manually)
            if (p.getUserId() != null) {
                return userDAO.deleteUser(p.getUserId());
            } else {
                String sql = "DELETE FROM patients WHERE id = ?";
                try (Connection conn = DBConnection.getInstance().getConnection();
                     PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, id);
                    return stmt.executeUpdate() > 0;
                }
            }
        }
        return false;
    }

    // Search Patients
    public List<Patient> searchPatients(String keyword) throws SQLException, ClassNotFoundException {
        List<Patient> patients = new ArrayList<>();
        String sql = "SELECT * FROM patients WHERE name LIKE ? OR email LIKE ? OR phone LIKE ? ORDER BY name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String kw = "%" + keyword + "%";
            stmt.setString(1, kw);
            stmt.setString(2, kw);
            stmt.setString(3, kw);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Patient p = new Patient(
                        rs.getInt("id"),
                        rs.getObject("user_id") != null ? rs.getInt("user_id") : null,
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("gender"),
                        rs.getDate("dob"),
                        rs.getString("blood_group"),
                        rs.getString("address"),
                        rs.getString("medical_history")
                    );
                    p.setCreatedAt(rs.getString("created_at"));
                    patients.add(p);
                }
            }
        }
        return patients;
    }

    // Count Patients
    public int getPatientCount() throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM patients";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
