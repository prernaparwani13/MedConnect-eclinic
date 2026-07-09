package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Doctor;
import com.Medconnect.Model.User;
import com.Medconnect.Utils.DBConnection;

public class DoctorDAO {
    
    private UserDAO userDAO = new UserDAO();

    // Add Doctor (creates a user and then creates doctor details)
    public boolean addDoctor(Doctor doctor, String password) throws SQLException, ClassNotFoundException {
        // Create User first
        User user = new User();
        user.setName(doctor.getName());
        user.setEmail(doctor.getEmail());
        user.setPassword(password);
        user.setRole("doctor");
        
        int userId = userDAO.registerUser(user);
        if (userId > 0) {
            doctor.setUserId(userId);
            String sql = "INSERT INTO doctors (user_id, name, email, specialization, phone, address, department_id, schedule) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = DBConnection.getInstance().getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, userId);
                stmt.setString(2, doctor.getName());
                stmt.setString(3, doctor.getEmail());
                stmt.setString(4, doctor.getSpecialization());
                stmt.setString(5, doctor.getPhone());
                stmt.setString(6, doctor.getAddress());
                if (doctor.getDepartmentId() != null) {
                    stmt.setInt(7, doctor.getDepartmentId());
                } else {
                    stmt.setNull(7, java.sql.Types.INTEGER);
                }
                stmt.setString(8, doctor.getSchedule());
                
                return stmt.executeUpdate() > 0;
            }
        }
        return false;
    }

    // Get Doctor by ID (refers to doctors.id, not users.id)
    public Doctor getDoctorById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT d.*, dept.name AS department_name FROM doctors d LEFT JOIN departments dept ON d.department_id = dept.id WHERE d.id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Doctor d = new Doctor(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("specialization"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getInt("department_id"),
                        rs.getString("schedule")
                    );
                    d.setDepartmentName(rs.getString("department_name"));
                    return d;
                }
            }
        }
        return null;
    }

    // Get Doctor by User ID
    public Doctor getDoctorByUserId(int userId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT d.*, dept.name AS department_name FROM doctors d LEFT JOIN departments dept ON d.department_id = dept.id WHERE d.user_id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Doctor d = new Doctor(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("specialization"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getInt("department_id"),
                        rs.getString("schedule")
                    );
                    d.setDepartmentName(rs.getString("department_name"));
                    return d;
                }
            }
        }
        return null;
    }

    // Get all Doctors
    public List<Doctor> getAllDoctors() throws SQLException, ClassNotFoundException {
        List<Doctor> doctors = new ArrayList<>();
        String sql = "SELECT d.*, dept.name AS department_name FROM doctors d LEFT JOIN departments dept ON d.department_id = dept.id ORDER BY d.name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Doctor d = new Doctor(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("specialization"),
                    rs.getString("phone"),
                    rs.getString("address"),
                    rs.getInt("department_id"),
                    rs.getString("schedule")
                );
                d.setDepartmentName(rs.getString("department_name"));
                doctors.add(d);
            }
        }
        return doctors;
    }

    // Update Doctor Details
    public boolean updateDoctor(Doctor doctor) throws SQLException, ClassNotFoundException {
        String updateDoctorSql = "UPDATE doctors SET name = ?, email = ?, specialization = ?, phone = ?, address = ?, department_id = ?, schedule = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(updateDoctorSql)) {
            stmt.setString(1, doctor.getName());
            stmt.setString(2, doctor.getEmail());
            stmt.setString(3, doctor.getSpecialization());
            stmt.setString(4, doctor.getPhone());
            stmt.setString(5, doctor.getAddress());
            if (doctor.getDepartmentId() != null && doctor.getDepartmentId() > 0) {
                stmt.setInt(6, doctor.getDepartmentId());
            } else {
                stmt.setNull(6, java.sql.Types.INTEGER);
            }
            stmt.setString(7, doctor.getSchedule());
            stmt.setInt(8, doctor.getId());
            
            boolean updated = stmt.executeUpdate() > 0;
            if (updated && doctor.getUserId() != null) {
                // Keep the corresponding users record updated too
                String updateUserSql = "UPDATE users SET name = ?, email = ? WHERE id = ?";
                try (PreparedStatement uStmt = conn.prepareStatement(updateUserSql)) {
                    uStmt.setString(1, doctor.getName());
                    uStmt.setString(2, doctor.getEmail());
                    uStmt.setInt(3, doctor.getUserId());
                    uStmt.executeUpdate();
                }
            }
            return updated;
        }
    }

    // Delete Doctor
    public boolean deleteDoctor(int id) throws SQLException, ClassNotFoundException {
        Doctor d = getDoctorById(id);
        if (d != null) {
            // Delete corresponding users record (will cascade delete or we can delete manually)
            if (d.getUserId() != null) {
                return userDAO.deleteUser(d.getUserId());
            } else {
                String sql = "DELETE FROM doctors WHERE id = ?";
                try (Connection conn = DBConnection.getInstance().getConnection();
                     PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, id);
                    return stmt.executeUpdate() > 0;
                }
            }
        }
        return false;
    }

    // Search Doctors
    public List<Doctor> searchDoctors(String keyword) throws SQLException, ClassNotFoundException {
        List<Doctor> doctors = new ArrayList<>();
        String sql = "SELECT d.*, dept.name AS department_name FROM doctors d LEFT JOIN departments dept ON d.department_id = dept.id " +
                     "WHERE d.name LIKE ? OR d.specialization LIKE ? OR dept.name LIKE ? ORDER BY d.name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String kw = "%" + keyword + "%";
            stmt.setString(1, kw);
            stmt.setString(2, kw);
            stmt.setString(3, kw);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Doctor d = new Doctor(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("specialization"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getInt("department_id"),
                        rs.getString("schedule")
                    );
                    d.setDepartmentName(rs.getString("department_name"));
                    doctors.add(d);
                }
            }
        }
        return doctors;
    }

    // Count Doctors
    public int getDoctorCount() throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM doctors";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
