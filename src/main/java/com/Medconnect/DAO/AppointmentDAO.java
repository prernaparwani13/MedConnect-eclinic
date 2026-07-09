package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Appointment;
import com.Medconnect.Utils.DBConnection;

public class AppointmentDAO {

    // Book a new appointment
    public boolean bookAppointment(Appointment appointment) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO appointments (patient_id, doctor_id, patient_name, doctor_name, specialization, appointment_date, time_slot, status, description, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, appointment.getPatientId());
            stmt.setInt(2, appointment.getDoctorId());
            stmt.setString(3, appointment.getPatientName());
            stmt.setString(4, appointment.getDoctorName());
            stmt.setString(5, appointment.getSpecialization());
            stmt.setTimestamp(6, appointment.getAppointmentDate());
            stmt.setString(7, appointment.getTimeSlot());
            stmt.setString(8, appointment.getStatus());
            stmt.setString(9, appointment.getDescription());

            return stmt.executeUpdate() > 0;
        }
    }

    // Get all appointments
    public List<Appointment> getAllAppointments() throws SQLException, ClassNotFoundException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM appointments ORDER BY appointment_date DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                appointments.add(new Appointment(
                    rs.getInt("id"),
                    rs.getInt("patient_id"),
                    rs.getInt("doctor_id"),
                    rs.getString("patient_name"),
                    rs.getString("doctor_name"),
                    rs.getString("specialization"),
                    rs.getTimestamp("appointment_date"),
                    rs.getString("time_slot"),
                    rs.getString("status"),
                    rs.getString("description"),
                    rs.getTimestamp("created_at")
                ));
            }
        }
        return appointments;
    }

    // Get appointments by patient ID
    public List<Appointment> getAppointmentsByPatientId(int patientId) throws SQLException, ClassNotFoundException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE patient_id = ? ORDER BY appointment_date DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(new Appointment(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("patient_name"),
                        rs.getString("doctor_name"),
                        rs.getString("specialization"),
                        rs.getTimestamp("appointment_date"),
                        rs.getString("time_slot"),
                        rs.getString("status"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return appointments;
    }

    // Get appointments by doctor ID
    public List<Appointment> getAppointmentsByDoctorId(int doctorId) throws SQLException, ClassNotFoundException {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE doctor_id = ? ORDER BY appointment_date DESC";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, doctorId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    appointments.add(new Appointment(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("patient_name"),
                        rs.getString("doctor_name"),
                        rs.getString("specialization"),
                        rs.getTimestamp("appointment_date"),
                        rs.getString("time_slot"),
                        rs.getString("status"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return appointments;
    }

    // Update appointment status
    public boolean updateAppointmentStatus(int appointmentId, String status) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE appointments SET status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, appointmentId);

            return stmt.executeUpdate() > 0;
        }
    }

    // Reschedule appointment
    public boolean rescheduleAppointment(int appointmentId, Timestamp newDate, String newTimeSlot, String status) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE appointments SET appointment_date = ?, time_slot = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, newDate);
            stmt.setString(2, newTimeSlot);
            stmt.setString(3, status);
            stmt.setInt(4, appointmentId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Get appointment by ID
    public Appointment getAppointmentById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM appointments WHERE id = ?";

        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Appointment(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("patient_name"),
                        rs.getString("doctor_name"),
                        rs.getString("specialization"),
                        rs.getTimestamp("appointment_date"),
                        rs.getString("time_slot"),
                        rs.getString("status"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }

    // Count Appointments by Status
    public int getAppointmentCount(String status) throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM appointments" + (status != null ? " WHERE status = ?" : "");
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (status != null) {
                stmt.setString(1, status);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}
