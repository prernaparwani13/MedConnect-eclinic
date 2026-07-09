package com.Medconnect.Report;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.AppointmentDAO;
import com.Medconnect.DAO.BillDAO;
import com.Medconnect.DAO.DoctorDAO;
import com.Medconnect.DAO.PatientDAO;
import com.Medconnect.Utils.DBConnection;

@WebServlet("/admin/reports")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private PatientDAO patientDAO = new PatientDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();
    private AppointmentDAO appointmentDAO = new AppointmentDAO();
    private BillDAO billDAO = new BillDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // General Stats
            request.setAttribute("totalPatients", patientDAO.getPatientCount());
            request.setAttribute("totalDoctors", doctorDAO.getDoctorCount());
            request.setAttribute("totalAppointments", appointmentDAO.getAppointmentCount(null));
            request.setAttribute("pendingAppointments", appointmentDAO.getAppointmentCount("Pending"));
            request.setAttribute("confirmedAppointments", appointmentDAO.getAppointmentCount("Confirmed"));
            
            // Revenue reports
            request.setAttribute("totalRevenue", billDAO.getTotalRevenue());
            request.setAttribute("dailyRevenue", billDAO.getDailyRevenue());
            request.setAttribute("monthlyRevenue", billDAO.getMonthlyRevenue());
            
            // Daily / Monthly activity counts
            request.setAttribute("dailyAppointments", getCountFromQuery("SELECT COUNT(*) FROM appointments WHERE DATE(appointment_date) = CURDATE()"));
            request.setAttribute("monthlyAppointments", getCountFromQuery("SELECT COUNT(*) FROM appointments WHERE MONTH(appointment_date) = MONTH(CURDATE()) AND YEAR(appointment_date) = YEAR(CURDATE())"));
            request.setAttribute("dailyPatients", getCountFromQuery("SELECT COUNT(*) FROM patients WHERE DATE(created_at) = CURDATE()"));
            request.setAttribute("monthlyPatients", getCountFromQuery("SELECT COUNT(*) FROM patients WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())"));
            
            // Patient breakdown counts
            request.setAttribute("malePatients", getCountFromQuery("SELECT COUNT(*) FROM patients WHERE gender = 'Male'"));
            request.setAttribute("femalePatients", getCountFromQuery("SELECT COUNT(*) FROM patients WHERE gender = 'Female'"));
            
            request.getRequestDispatcher("reports.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    private int getCountFromQuery(String sql) {
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
