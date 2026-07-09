package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Department;
import com.Medconnect.Utils.DBConnection;

public class DepartmentDAO {

    // Add Department
    public boolean addDepartment(Department dept) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO departments (name, description) VALUES (?, ?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dept.getName());
            stmt.setString(2, dept.getDescription());
            return stmt.executeUpdate() > 0;
        }
    }

    // Get Department by ID
    public Department getDepartmentById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM departments WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Department d = new Department(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("description")
                    );
                    d.setCreatedAt(rs.getString("created_at"));
                    return d;
                }
            }
        }
        return null;
    }

    // Get all Departments
    public List<Department> getAllDepartments() throws SQLException, ClassNotFoundException {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT * FROM departments ORDER BY name ASC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Department d = new Department(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("description")
                );
                d.setCreatedAt(rs.getString("created_at"));
                list.add(d);
            }
        }
        return list;
    }

    // Update Department
    public boolean updateDepartment(Department dept) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE departments SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dept.getName());
            stmt.setString(2, dept.getDescription());
            stmt.setInt(3, dept.getId());
            return stmt.executeUpdate() > 0;
        }
    }

    // Delete Department
    public boolean deleteDepartment(int id) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM departments WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Count Departments
    public int getDepartmentCount() throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM departments";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
