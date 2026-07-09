package com.Medconnect.Patient;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.PatientDAO;
import com.Medconnect.Model.Patient;

@WebServlet({"/receptionist/patient-management", "/admin/patient-management"})
public class PatientServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PatientDAO patientDAO = new PatientDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String redirectPage = request.getRequestURI().contains("/admin/") ? "../admin/patients.jsp" : "patients.jsp";
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                patientDAO.deletePatient(id);
                response.sendRedirect(redirectPage + "?msg=Patient deleted successfully.");
            } else {
                response.sendRedirect(redirectPage);
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(redirectPage).forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String redirectPage = request.getRequestURI().contains("/admin/") ? "../admin/patients.jsp" : "patients.jsp";
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String gender = request.getParameter("gender");
                String dobStr = request.getParameter("dob");
                String bloodGroup = request.getParameter("bloodGroup");
                String address = request.getParameter("address");
                String medicalHistory = request.getParameter("medicalHistory");
                String password = request.getParameter("password");
                
                Date dob = null;
                if (dobStr != null && !dobStr.trim().isEmpty()) {
                    dob = Date.valueOf(dobStr);
                }

                Patient patient = new Patient(0, null, name, email, phone, gender, dob, bloodGroup, address, medicalHistory);
                
                boolean success = patientDAO.addPatient(patient, password);
                if (success) {
                    response.sendRedirect(redirectPage + "?msg=Patient registered successfully.");
                } else {
                    request.setAttribute("error", "Failed to register patient.");
                    request.getRequestDispatcher(redirectPage).forward(request, response);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String gender = request.getParameter("gender");
                String dobStr = request.getParameter("dob");
                String bloodGroup = request.getParameter("bloodGroup");
                String address = request.getParameter("address");
                String medicalHistory = request.getParameter("medicalHistory");
                
                Date dob = null;
                if (dobStr != null && !dobStr.trim().isEmpty()) {
                    dob = Date.valueOf(dobStr);
                }

                Patient current = patientDAO.getPatientById(id);
                if (current != null) {
                    current.setName(name);
                    current.setEmail(email);
                    current.setPhone(phone);
                    current.setGender(gender);
                    current.setDob(dob);
                    current.setBloodGroup(bloodGroup);
                    current.setAddress(address);
                    current.setMedicalHistory(medicalHistory);
                    
                    boolean success = patientDAO.updatePatient(current);
                    if (success) {
                        response.sendRedirect(redirectPage + "?msg=Patient details updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update patient details.");
                        request.getRequestDispatcher(redirectPage).forward(request, response);
                    }
                } else {
                    response.sendRedirect(redirectPage + "?error=Patient not found.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(redirectPage).forward(request, response);
        }
    }
}
