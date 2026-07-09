package com.Medconnect.Booking;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.Medconnect.DAO.AppointmentDAO;
import com.Medconnect.DAO.DoctorDAO;
import com.Medconnect.DAO.PatientDAO;
import com.Medconnect.Model.Appointment;
import com.Medconnect.Model.Doctor;
import com.Medconnect.Model.Patient;

@WebServlet({
    "/patient/appointment-management", 
    "/doctor/appointment-management", 
    "/receptionist/appointment-management", 
    "/admin/appointment-management"
})
public class AppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AppointmentDAO appointmentDAO = new AppointmentDAO();
    private PatientDAO patientDAO = new PatientDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String uri = request.getRequestURI();
        
        String redirectPage = "appointments.jsp";
        if (uri.contains("/admin/")) {
            redirectPage = "../admin/appointments.jsp";
        } else if (uri.contains("/doctor/")) {
            redirectPage = "../doctor/appointments.jsp";
        } else if (uri.contains("/patient/")) {
            redirectPage = "../patient/appointments.jsp";
        }
        
        try {
            if ("cancel".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                appointmentDAO.updateAppointmentStatus(id, "Cancelled");
                response.sendRedirect(redirectPage + "?msg=Appointment cancelled successfully.");
            } else if ("confirm".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                appointmentDAO.updateAppointmentStatus(id, "Confirmed");
                response.sendRedirect(redirectPage + "?msg=Appointment confirmed successfully.");
            } else if ("complete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                appointmentDAO.updateAppointmentStatus(id, "Completed");
                response.sendRedirect(redirectPage + "?msg=Appointment marked as completed.");
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
        String uri = request.getRequestURI();
        
        String redirectPage = "appointments.jsp";
        if (uri.contains("/admin/")) {
            redirectPage = "../admin/appointments.jsp";
        } else if (uri.contains("/doctor/")) {
            redirectPage = "../doctor/appointments.jsp";
        } else if (uri.contains("/patient/")) {
            redirectPage = "../patient/appointments.jsp";
        } else if (uri.contains("/receptionist/")) {
            redirectPage = "appointments.jsp";
        }

        try {
            if ("book".equals(action)) {
                int doctorId = Integer.parseInt(request.getParameter("doctorId"));
                int patientId = Integer.parseInt(request.getParameter("patientId")); // User ID of patient
                String dateStr = request.getParameter("appointmentDate");
                String timeSlot = request.getParameter("timeSlot");
                String description = request.getParameter("description");

                // Parse date & time
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                java.util.Date parsedDate = sdf.parse(dateStr + " " + timeSlot);
                Timestamp apptDate = new Timestamp(parsedDate.getTime());

                // Find patient and doctor details
                Patient patient = patientDAO.getPatientByUserId(patientId);
                Doctor doctor = doctorDAO.getDoctorByUserId(doctorId);

                String patientName = (patient != null) ? patient.getName() : "Unknown Patient";
                String doctorName = (doctor != null) ? doctor.getName() : "Unknown Doctor";
                String spec = (doctor != null) ? doctor.getSpecialization() : "General";

                Appointment appt = new Appointment(0, patientId, doctorId, patientName, doctorName, spec, apptDate, timeSlot, "Pending", description, null);
                boolean success = appointmentDAO.bookAppointment(appt);
                
                if (success) {
                    response.sendRedirect(redirectPage + "?msg=Appointment booked successfully.");
                } else {
                    request.setAttribute("error", "Failed to book appointment.");
                    request.getRequestDispatcher(redirectPage).forward(request, response);
                }
            } else if ("reschedule".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String dateStr = request.getParameter("appointmentDate");
                String timeSlot = request.getParameter("timeSlot");

                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                java.util.Date parsedDate = sdf.parse(dateStr + " " + timeSlot);
                Timestamp apptDate = new Timestamp(parsedDate.getTime());

                boolean success = appointmentDAO.rescheduleAppointment(id, apptDate, timeSlot, "Rescheduled");
                if (success) {
                    response.sendRedirect(redirectPage + "?msg=Appointment rescheduled successfully.");
                } else {
                    request.setAttribute("error", "Failed to reschedule appointment.");
                    request.getRequestDispatcher(redirectPage).forward(request, response);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(redirectPage).forward(request, response);
        }
    }
}
