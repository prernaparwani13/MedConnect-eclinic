package com.Medconnect.Prescription;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.PrescriptionDAO;
import com.Medconnect.Model.Prescription;

@WebServlet("/doctor/prescription-management")
public class PrescriptionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("prescriptions.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String apptIdStr = request.getParameter("appointmentId");
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                int doctorId = Integer.parseInt(request.getParameter("doctorId"));
                String medicineName = request.getParameter("medicineName");
                String dosage = request.getParameter("dosage");
                String duration = request.getParameter("duration");
                String instructions = request.getParameter("instructions");

                Integer appointmentId = null;
                if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                    appointmentId = Integer.parseInt(apptIdStr);
                }

                Prescription p = new Prescription(0, appointmentId, patientId, doctorId, medicineName, dosage, duration, instructions, null);
                boolean success = prescriptionDAO.createPrescription(p);
                
                if (success) {
                    response.sendRedirect("appointments.jsp?msg=Prescription added successfully.");
                } else {
                    request.setAttribute("error", "Failed to add prescription.");
                    request.getRequestDispatcher("appointments.jsp").forward(request, response);
                }
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String medicineName = request.getParameter("medicineName");
                String dosage = request.getParameter("dosage");
                String duration = request.getParameter("duration");
                String instructions = request.getParameter("instructions");

                Prescription p = prescriptionDAO.getPrescriptionById(id);
                if (p != null) {
                    p.setMedicineName(medicineName);
                    p.setDosage(dosage);
                    p.setDuration(duration);
                    p.setInstructions(instructions);
                    
                    boolean success = prescriptionDAO.updatePrescription(p);
                    if (success) {
                        response.sendRedirect("prescriptions.jsp?msg=Prescription updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update prescription.");
                        request.getRequestDispatcher("prescriptions.jsp").forward(request, response);
                    }
                } else {
                    response.sendRedirect("prescriptions.jsp?error=Prescription not found.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("prescriptions.jsp").forward(request, response);
        }
    }
}
