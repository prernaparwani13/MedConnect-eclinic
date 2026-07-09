package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.User;
import com.Medconnect.Utils.DBConnection;
import com.Medconnect.Utils.PasswordHasher;

public class UserDAO {
    
    // User authentication with password hashing
    public User authenticateUser(String email, String password) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM users WHERE email = ? AND is_active = 1";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
                    String hashedInput = PasswordHasher.hashPassword(password);
                    if (storedPassword.equals(hashedInput)) {
                        return new User(
                            rs.getInt("id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            rs.getString("role"),
                            rs.getBoolean("is_active"),
                            rs.getString("created_at")
                        );
                    }
                }
            }
        }
        return null;
    }
    
    // Register new user with password hashing
    public int registerUser(User user) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO users (name, email, password, role, is_active, created_at) VALUES (?, ?, ?, ?, 1, NOW())";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, PasswordHasher.hashPassword(user.getPassword()));
            stmt.setString(4, user.getRole());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1); // Return generated user ID
                    }
                }
            }
        }
        return -1;
    }
    
    // Check if email exists
    public boolean emailExists(String email) throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
    
    // Get user by ID
    public User getUserById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getBoolean("is_active"),
                        rs.getString("created_at")
                    );
                }
            }
        }
        return null;
    }
    
    // Get all users
    public List<User> getAllUsers() throws SQLException, ClassNotFoundException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                users.add(new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("role"),
                    rs.getBoolean("is_active"),
                    rs.getString("created_at")
                ));
            }
        }
        return users;
    }
    
    // Update user (without password modification)
    public boolean updateUser(User user) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getRole());
            stmt.setInt(4, user.getId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Update user password
    public boolean changePassword(int userId, String newPassword) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, PasswordHasher.hashPassword(newPassword));
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Delete user
    public boolean deleteUser(int id) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
}
