package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Staff;
import com.Medconnect.Model.User;
import com.Medconnect.Utils.DBConnection;

public class StaffDAO {

    private UserDAO userDAO = new UserDAO();

    // Add Staff (creates a user account first and then staff details)
    public boolean addStaff(Staff staff, String password) throws SQLException, ClassNotFoundException {
        User user = new User();
        user.setName(staff.getName());
        user.setEmail(staff.getEmail());
        user.setPassword(password != null ? password : "staff123");
        user.setRole(staff.getRole()); // e.g. 'receptionist'
        
        int userId = userDAO.registerUser(user);
        if (userId > 0) {
            staff.setUserId(userId);
            String sql = "INSERT INTO staff (user_id, name, email, role, phone, address) VALUES (?, ?, ?, ?, ?, ?)";
            try (Connection conn = DBConnection.getInstance().getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, userId);
                stmt.setString(2, staff.getName());
                stmt.setString(3, staff.getEmail());
                stmt.setString(4, staff.getRole());
                stmt.setString(5, staff.getPhone());
                stmt.setString(6, staff.getAddress());
                
                return stmt.executeUpdate() > 0;
            }
        }
        return false;
    }

    // Get Staff by ID
    public Staff getStaffById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM staff WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Staff s = new Staff(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getString("phone"),
                        rs.getString("address")
                    );
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    return s;
                }
            }
        }
        return null;
    }

    // Get all Staff
    public List<Staff> getAllStaff() throws SQLException, ClassNotFoundException {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT * FROM staff ORDER BY name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Staff s = new Staff(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("role"),
                    rs.getString("phone"),
                    rs.getString("address")
                );
                s.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(s);
            }
        }
        return list;
    }

    // Update Staff details
    public boolean updateStaff(Staff staff) throws SQLException, ClassNotFoundException {
        String updateStaffSql = "UPDATE staff SET name = ?, email = ?, role = ?, phone = ?, address = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(updateStaffSql)) {
            stmt.setString(1, staff.getName());
            stmt.setString(2, staff.getEmail());
            stmt.setString(3, staff.getRole());
            stmt.setString(4, staff.getPhone());
            stmt.setString(5, staff.getAddress());
            stmt.setInt(6, staff.getId());
            
            boolean updated = stmt.executeUpdate() > 0;
            if (updated && staff.getUserId() != null) {
                // Also update the users table
                String updateUserSql = "UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?";
                try (PreparedStatement uStmt = conn.prepareStatement(updateUserSql)) {
                    uStmt.setString(1, staff.getName());
                    uStmt.setString(2, staff.getEmail());
                    uStmt.setString(3, staff.getRole());
                    uStmt.setInt(4, staff.getUserId());
                    uStmt.executeUpdate();
                }
            }
            return updated;
        }
    }

    // Delete Staff
    public boolean deleteStaff(int id) throws SQLException, ClassNotFoundException {
        Staff s = getStaffById(id);
        if (s != null) {
            if (s.getUserId() != null) {
                return userDAO.deleteUser(s.getUserId());
            } else {
                String sql = "DELETE FROM staff WHERE id = ?";
                try (Connection conn = DBConnection.getInstance().getConnection();
                     PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, id);
                    return stmt.executeUpdate() > 0;
                }
            }
        }
        return false;
    }
}
