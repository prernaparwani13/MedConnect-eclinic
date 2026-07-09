package com.Medconnect.Department;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.DepartmentDAO;
import com.Medconnect.Model.Department;

@WebServlet("/admin/department-management")
public class DepartmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DepartmentDAO departmentDAO = new DepartmentDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                departmentDAO.deleteDepartment(id);
                response.sendRedirect("departments.jsp?msg=Department deleted successfully.");
            } else {
                response.sendRedirect("departments.jsp");
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("departments.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String description = request.getParameter("description");

                Department dept = new Department(0, name, description);
                boolean success = departmentDAO.addDepartment(dept);
                if (success) {
                    response.sendRedirect("departments.jsp?msg=Department added successfully.");
                } else {
                    request.setAttribute("error", "Failed to add department. Name must be unique.");
                    request.getRequestDispatcher("departments.jsp").forward(request, response);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String description = request.getParameter("description");

                Department current = departmentDAO.getDepartmentById(id);
                if (current != null) {
                    current.setName(name);
                    current.setDescription(description);
                    boolean success = departmentDAO.updateDepartment(current);
                    if (success) {
                        response.sendRedirect("departments.jsp?msg=Department updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update department details.");
                        request.getRequestDispatcher("departments.jsp").forward(request, response);
                    }
                } else {
                    response.sendRedirect("departments.jsp?error=Department not found.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("departments.jsp").forward(request, response);
        }
    }
}
