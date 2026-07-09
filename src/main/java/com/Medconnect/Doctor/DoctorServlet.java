package com.Medconnect.Doctor;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.DoctorDAO;
import com.Medconnect.Model.Doctor;

@WebServlet("/admin/doctor-management")
public class DoctorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DoctorDAO doctorDAO = new DoctorDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                doctorDAO.deleteDoctor(id);
                response.sendRedirect("doctors.jsp?msg=Doctor deleted successfully.");
            } else {
                response.sendRedirect("doctors.jsp");
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("doctors.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String specialization = request.getParameter("specialization");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");
                String schedule = request.getParameter("schedule");
                String password = request.getParameter("password");
                String deptIdStr = request.getParameter("departmentId");
                
                Integer departmentId = null;
                if (deptIdStr != null && !deptIdStr.trim().isEmpty()) {
                    departmentId = Integer.parseInt(deptIdStr);
                }

                Doctor doctor = new Doctor(0, null, name, email, specialization, phone, address, departmentId, schedule);
                
                boolean success = doctorDAO.addDoctor(doctor, password);
                if (success) {
                    response.sendRedirect("doctors.jsp?msg=Doctor added successfully.");
                } else {
                    request.setAttribute("error", "Failed to add doctor. Check if email is unique.");
                    request.getRequestDispatcher("doctors.jsp").forward(request, response);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String specialization = request.getParameter("specialization");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");
                String schedule = request.getParameter("schedule");
                String deptIdStr = request.getParameter("departmentId");
                
                Integer departmentId = null;
                if (deptIdStr != null && !deptIdStr.trim().isEmpty()) {
                    departmentId = Integer.parseInt(deptIdStr);
                }

                Doctor current = doctorDAO.getDoctorById(id);
                if (current != null) {
                    current.setName(name);
                    current.setEmail(email);
                    current.setSpecialization(specialization);
                    current.setPhone(phone);
                    current.setAddress(address);
                    current.setDepartmentId(departmentId);
                    current.setSchedule(schedule);
                    
                    boolean success = doctorDAO.updateDoctor(current);
                    if (success) {
                        response.sendRedirect("doctors.jsp?msg=Doctor details updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update doctor details.");
                        request.getRequestDispatcher("doctors.jsp").forward(request, response);
                    }
                } else {
                    response.sendRedirect("doctors.jsp?error=Doctor not found.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("doctors.jsp").forward(request, response);
        }
    }
}
