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
import com.Medconnect.DAO.UserDAO;
import com.Medconnect.Model.Appointment;
import com.Medconnect.Model.User;

@WebServlet("/patient/book-appointment")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public BookingServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to booking form page
        response.sendRedirect("book-appointment.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userId == null || !"patient".equals(role)) {
            response.sendRedirect("../Login.jsp");
            return;
        }

        // Get form parameters
        String doctorIdStr = request.getParameter("doctorId");
        String appointmentDateStr = request.getParameter("appointmentDate");
        String timeSlot = request.getParameter("timeSlot");
        String description = request.getParameter("description");

        // Input validation
        if (doctorIdStr == null || doctorIdStr.trim().isEmpty() ||
            appointmentDateStr == null || appointmentDateStr.trim().isEmpty() ||
            timeSlot == null || timeSlot.trim().isEmpty()) {
            request.setAttribute("error", "Please provide all required fields.");
            request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
            return;
        }

        try {
            int doctorId = Integer.parseInt(doctorIdStr.trim());

            // Parse date
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            java.util.Date parsedDate = sdf.parse(appointmentDateStr + " " + timeSlot);
            Timestamp appointmentDate = new Timestamp(parsedDate.getTime());

            // Get patient details
            UserDAO userDAO = new UserDAO();
            User patient = userDAO.getUserById(userId);
            User doctor = userDAO.getUserById(doctorId);

            if (patient == null || doctor == null) {
                request.setAttribute("error", "Invalid patient or doctor ID.");
                request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
                return;
            }

            // Create appointment object
            Appointment appointment = new Appointment();
            appointment.setPatientId(patient.getId());
            appointment.setDoctorId(doctor.getId());
            appointment.setPatientName(patient.getName());
            appointment.setDoctorName(doctor.getName());
            appointment.setSpecialization("General"); // You might want to get this from doctor profile
            appointment.setAppointmentDate(appointmentDate);
            appointment.setTimeSlot(timeSlot);
            appointment.setStatus("Pending");
            appointment.setDescription(description != null ? description.trim() : "");

            // Save appointment
            AppointmentDAO appointmentDAO = new AppointmentDAO();
            boolean success = appointmentDAO.bookAppointment(appointment);

            if (success) {
                request.setAttribute("success", "Appointment booked successfully!");
                request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to book appointment. Please try again.");
                request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid doctor ID format.");
            request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date or time format.");
            request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
        } catch (SQLException | ClassNotFoundException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
        }
    }
}
