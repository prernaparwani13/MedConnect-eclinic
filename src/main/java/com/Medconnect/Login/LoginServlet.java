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
import javax.servlet.http.HttpSession;

import com.Medconnect.Utils.DBConnection;
import com.Medconnect.Utils.PasswordHasher;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LoginServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Input validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please provide both email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        email = email.trim();
        if (!isValidEmail(email)) {
            request.setAttribute("error", "Please provide a valid email address.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Get connection from utility class
            conn = DBConnection.getInstance().getConnection();

            // Query to check user credentials with password verification
            String sql = "SELECT id, name, email, password, role FROM users WHERE email=? AND is_active=1";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email.trim());

            rs = stmt.executeQuery();

            if (rs.next()) {
                // Verify password
                String storedPassword = rs.getString("password");
                String hashedInput = PasswordHasher.hashPassword(password);
                if (storedPassword.equals(hashedInput)) {
                    // Create session
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("username", rs.getString("name"));
                    session.setAttribute("email", email);
                    session.setAttribute("role", rs.getString("role"));

                    // Redirect based on role
                    String userRole = rs.getString("role");
                    if ("admin".equals(userRole)) {
                        response.sendRedirect("admin/dashboard.jsp");
                    } else if ("doctor".equals(userRole)) {
                        response.sendRedirect("doctor/dashboard.jsp");
                    } else if ("receptionist".equals(userRole)) {
                        response.sendRedirect("receptionist/dashboard.jsp");
                    } else {
                        response.sendRedirect("patient/dashboard.jsp");
                    }
                } else {
                    request.setAttribute("error", "Invalid email or password.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
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
