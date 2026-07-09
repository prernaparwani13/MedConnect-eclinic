package com.Medconnect.Staff;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.StaffDAO;
import com.Medconnect.Model.Staff;

@WebServlet("/admin/staff-management")
public class StaffServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private StaffDAO staffDAO = new StaffDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                staffDAO.deleteStaff(id);
                response.sendRedirect("staff.jsp?msg=Staff member deleted successfully.");
            } else {
                response.sendRedirect("staff.jsp");
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("staff.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String role = request.getParameter("role");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");
                String password = request.getParameter("password");

                Staff staff = new Staff(0, null, name, email, role, phone, address);
                boolean success = staffDAO.addStaff(staff, password);
                
                if (success) {
                    response.sendRedirect("staff.jsp?msg=Staff member added successfully.");
                } else {
                    request.setAttribute("error", "Failed to add staff member. Check if email is unique.");
                    request.getRequestDispatcher("staff.jsp").forward(request, response);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String role = request.getParameter("role");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");

                Staff current = staffDAO.getStaffById(id);
                if (current != null) {
                    current.setName(name);
                    current.setEmail(email);
                    current.setRole(role);
                    current.setPhone(phone);
                    current.setAddress(address);
                    
                    boolean success = staffDAO.updateStaff(current);
                    if (success) {
                        response.sendRedirect("staff.jsp?msg=Staff details updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update staff details.");
                        request.getRequestDispatcher("staff.jsp").forward(request, response);
                    }
                } else {
                    response.sendRedirect("staff.jsp?error=Staff member not found.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("staff.jsp").forward(request, response);
        }
    }
}
