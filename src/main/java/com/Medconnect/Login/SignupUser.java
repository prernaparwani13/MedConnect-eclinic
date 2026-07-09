package com.Medconnect.Login;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.Utils.DBConnection;
import com.Medconnect.Utils.PasswordHasher;

@WebServlet("/SignupNewUser")
public class SignupUser extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database configuration - using DatabaseConnection utility
    
    public SignupUser() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("signup.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Input validation
        if (name == null || name.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        // Email validation
        if (!isValidEmail(email)) {
            request.setAttribute("error", "Please enter a valid email address.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        // Password validation
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Get connection from utility class
            conn = DBConnection.getInstance().getConnection();
            
            // Check if email already exists
            String checkEmailSql = "SELECT id FROM users WHERE email=?";
            stmt = conn.prepareStatement(checkEmailSql);
            stmt.setString(1, email.trim());
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                request.setAttribute("error", "Email address already registered.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }
            
            // Insert new user
            String insertSql = "INSERT INTO users (name, email, password, role, is_active, created_at) VALUES (?, ?, ?, ?, 1, NOW())";
            stmt = conn.prepareStatement(insertSql);
            stmt.setString(1, name.trim());
            stmt.setString(2, email.trim());
            stmt.setString(3, PasswordHasher.hashPassword(password)); 
            stmt.setString(4, "patient"); // Default role
            
            int rows = stmt.executeUpdate();
            
            if (rows > 0) {
                // Use session to pass success message across redirect
                request.getSession().setAttribute("success", "Registration successful! Please login.");
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }
            
        } catch (ClassNotFoundException e) {
            request.setAttribute("error", "Database driver not found.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        } finally {
            // Close resources
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
}
