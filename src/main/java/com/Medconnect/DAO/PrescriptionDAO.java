package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Prescription;
import com.Medconnect.Utils.DBConnection;

public class PrescriptionDAO {

    // Create Prescription
    public boolean createPrescription(Prescription p) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO prescriptions (appointment_id, patient_id, doctor_id, medicine_name, dosage, duration, instructions, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (p.getAppointmentId() != null) {
                stmt.setInt(1, p.getAppointmentId());
            } else {
                stmt.setNull(1, java.sql.Types.INTEGER);
            }
            stmt.setInt(2, p.getPatientId());
            stmt.setInt(3, p.getDoctorId());
            stmt.setString(4, p.getMedicineName());
            stmt.setString(5, p.getDosage());
            stmt.setString(6, p.getDuration());
            stmt.setString(7, p.getInstructions());
            return stmt.executeUpdate() > 0;
        }
    }

    // Get Prescription by ID
    public Prescription getPrescriptionById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT p.*, pat.name AS patient_name, doc.name AS doctor_name FROM prescriptions p " +
                     "JOIN users pat ON p.patient_id = pat.id " +
                     "JOIN users doc ON p.doctor_id = doc.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Prescription p = new Prescription(
                        rs.getInt("id"),
                        rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("medicine_name"),
                        rs.getString("dosage"),
                        rs.getString("duration"),
                        rs.getString("instructions"),
                        rs.getTimestamp("created_at")
                    );
                    p.setPatientName(rs.getString("patient_name"));
                    p.setDoctorName(rs.getString("doctor_name"));
                    return p;
                }
            }
        }
        return null;
    }

    // Get Prescriptions by Patient ID
    public List<Prescription> getPrescriptionsByPatientId(int patientId) throws SQLException, ClassNotFoundException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, pat.name AS patient_name, doc.name AS doctor_name FROM prescriptions p " +
                     "JOIN users pat ON p.patient_id = pat.id " +
                     "JOIN users doc ON p.doctor_id = doc.id " +
                     "WHERE p.patient_id = ? ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Prescription p = new Prescription(
                        rs.getInt("id"),
                        rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("medicine_name"),
                        rs.getString("dosage"),
                        rs.getString("duration"),
                        rs.getString("instructions"),
                        rs.getTimestamp("created_at")
                    );
                    p.setPatientName(rs.getString("patient_name"));
                    p.setDoctorName(rs.getString("doctor_name"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    // Get Prescriptions by Doctor ID
    public List<Prescription> getPrescriptionsByDoctorId(int doctorId) throws SQLException, ClassNotFoundException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, pat.name AS patient_name, doc.name AS doctor_name FROM prescriptions p " +
                     "JOIN users pat ON p.patient_id = pat.id " +
                     "JOIN users doc ON p.doctor_id = doc.id " +
                     "WHERE p.doctor_id = ? ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Prescription p = new Prescription(
                        rs.getInt("id"),
                        rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("medicine_name"),
                        rs.getString("dosage"),
                        rs.getString("duration"),
                        rs.getString("instructions"),
                        rs.getTimestamp("created_at")
                    );
                    p.setPatientName(rs.getString("patient_name"));
                    p.setDoctorName(rs.getString("doctor_name"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    // Get all Prescriptions
    public List<Prescription> getAllPrescriptions() throws SQLException, ClassNotFoundException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, pat.name AS patient_name, doc.name AS doctor_name FROM prescriptions p " +
                     "JOIN users pat ON p.patient_id = pat.id " +
                     "JOIN users doc ON p.doctor_id = doc.id " +
                     "ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Prescription p = new Prescription(
                    rs.getInt("id"),
                    rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                    rs.getInt("patient_id"),
                    rs.getInt("doctor_id"),
                    rs.getString("medicine_name"),
                    rs.getString("dosage"),
                    rs.getString("duration"),
                    rs.getString("instructions"),
                    rs.getTimestamp("created_at")
                );
                p.setPatientName(rs.getString("patient_name"));
                p.setDoctorName(rs.getString("doctor_name"));
                list.add(p);
            }
        }
        return list;
    }

    // Update Prescription
    public boolean updatePrescription(Prescription p) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE prescriptions SET medicine_name = ?, dosage = ?, duration = ?, instructions = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getMedicineName());
            stmt.setString(2, p.getDosage());
            stmt.setString(3, p.getDuration());
            stmt.setString(4, p.getInstructions());
            stmt.setInt(5, p.getId());
            return stmt.executeUpdate() > 0;
        }
    }
}
