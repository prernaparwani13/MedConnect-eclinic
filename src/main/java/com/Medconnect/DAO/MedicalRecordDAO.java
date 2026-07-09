package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.MedicalRecord;
import com.Medconnect.Utils.DBConnection;

public class MedicalRecordDAO {

    // Add Medical Record
    public boolean addMedicalRecord(MedicalRecord mr) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO medical_records (patient_id, doctor_id, description, file_name, file_path, upload_date) VALUES (?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, mr.getPatientId());
            stmt.setInt(2, mr.getDoctorId());
            stmt.setString(3, mr.getDescription());
            stmt.setString(4, mr.getFileName());
            stmt.setString(5, mr.getFilePath());
            return stmt.executeUpdate() > 0;
        }
    }

    // Get Medical Record by ID
    public MedicalRecord getMedicalRecordById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT mr.*, pat.name AS patient_name, doc.name AS doctor_name FROM medical_records mr " +
                     "JOIN users pat ON mr.patient_id = pat.id " +
                     "JOIN users doc ON mr.doctor_id = doc.id " +
                     "WHERE mr.id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    MedicalRecord mr = new MedicalRecord(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("description"),
                        rs.getString("file_name"),
                        rs.getString("file_path"),
                        rs.getTimestamp("upload_date")
                    );
                    mr.setPatientName(rs.getString("patient_name"));
                    mr.setDoctorName(rs.getString("doctor_name"));
                    return mr;
                }
            }
        }
        return null;
    }

    // Get Medical Records by Patient ID
    public List<MedicalRecord> getMedicalRecordsByPatientId(int patientId) throws SQLException, ClassNotFoundException {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT mr.*, pat.name AS patient_name, doc.name AS doctor_name FROM medical_records mr " +
                     "JOIN users pat ON mr.patient_id = pat.id " +
                     "JOIN users doc ON mr.doctor_id = doc.id " +
                     "WHERE mr.patient_id = ? ORDER BY mr.upload_date DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    MedicalRecord mr = new MedicalRecord(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("description"),
                        rs.getString("file_name"),
                        rs.getString("file_path"),
                        rs.getTimestamp("upload_date")
                    );
                    mr.setPatientName(rs.getString("patient_name"));
                    mr.setDoctorName(rs.getString("doctor_name"));
                    list.add(mr);
                }
            }
        }
        return list;
    }

    // Get Medical Records by Doctor ID
    public List<MedicalRecord> getMedicalRecordsByDoctorId(int doctorId) throws SQLException, ClassNotFoundException {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT mr.*, pat.name AS patient_name, doc.name AS doctor_name FROM medical_records mr " +
                     "JOIN users pat ON mr.patient_id = pat.id " +
                     "JOIN users doc ON mr.doctor_id = doc.id " +
                     "WHERE mr.doctor_id = ? ORDER BY mr.upload_date DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    MedicalRecord mr = new MedicalRecord(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getInt("doctor_id"),
                        rs.getString("description"),
                        rs.getString("file_name"),
                        rs.getString("file_path"),
                        rs.getTimestamp("upload_date")
                    );
                    mr.setPatientName(rs.getString("patient_name"));
                    mr.setDoctorName(rs.getString("doctor_name"));
                    list.add(mr);
                }
            }
        }
        return list;
    }

    // Get all Medical Records
    public List<MedicalRecord> getAllMedicalRecords() throws SQLException, ClassNotFoundException {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT mr.*, pat.name AS patient_name, doc.name AS doctor_name FROM medical_records mr " +
                     "JOIN users pat ON mr.patient_id = pat.id " +
                     "JOIN users doc ON mr.doctor_id = doc.id " +
                     "ORDER BY mr.upload_date DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                MedicalRecord mr = new MedicalRecord(
                    rs.getInt("id"),
                    rs.getInt("patient_id"),
                    rs.getInt("doctor_id"),
                    rs.getString("description"),
                    rs.getString("file_name"),
                    rs.getString("file_path"),
                    rs.getTimestamp("upload_date")
                );
                mr.setPatientName(rs.getString("patient_name"));
                mr.setDoctorName(rs.getString("doctor_name"));
                list.add(mr);
            }
        }
        return list;
    }
}
