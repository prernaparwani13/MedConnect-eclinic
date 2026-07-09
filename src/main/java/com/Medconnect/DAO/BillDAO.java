package com.Medconnect.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.Medconnect.Model.Bill;
import com.Medconnect.Utils.DBConnection;

public class BillDAO {

    // Generate/Insert Bill
    public boolean generateBill(Bill bill) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO bills (patient_id, appointment_id, consultation_fee, treatment_fee, medicine_fee, other_charges, total_amount, payment_status, payment_method, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, bill.getPatientId());
            if (bill.getAppointmentId() != null) {
                stmt.setInt(2, bill.getAppointmentId());
            } else {
                stmt.setNull(2, java.sql.Types.INTEGER);
            }
            stmt.setBigDecimal(3, bill.getConsultationFee());
            stmt.setBigDecimal(4, bill.getTreatmentFee());
            stmt.setBigDecimal(5, bill.getMedicineFee());
            stmt.setBigDecimal(6, bill.getOtherCharges());
            stmt.setBigDecimal(7, bill.getTotalAmount());
            stmt.setString(8, bill.getPaymentStatus());
            stmt.setString(9, bill.getPaymentMethod());
            
            return stmt.executeUpdate() > 0;
        }
    }

    // Get Bill by ID
    public Bill getBillById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT b.*, u.name AS patient_name FROM bills b JOIN users u ON b.patient_id = u.id WHERE b.id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Bill b = new Bill(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                        rs.getBigDecimal("consultation_fee"),
                        rs.getBigDecimal("treatment_fee"),
                        rs.getBigDecimal("medicine_fee"),
                        rs.getBigDecimal("other_charges"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status"),
                        rs.getString("payment_method"),
                        rs.getTimestamp("created_at")
                    );
                    b.setPatientName(rs.getString("patient_name"));
                    return b;
                }
            }
        }
        return null;
    }

    // Get Bills by Patient ID
    public List<Bill> getBillsByPatientId(int patientId) throws SQLException, ClassNotFoundException {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, u.name AS patient_name FROM bills b JOIN users u ON b.patient_id = u.id WHERE b.patient_id = ? ORDER BY b.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Bill b = new Bill(
                        rs.getInt("id"),
                        rs.getInt("patient_id"),
                        rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                        rs.getBigDecimal("consultation_fee"),
                        rs.getBigDecimal("treatment_fee"),
                        rs.getBigDecimal("medicine_fee"),
                        rs.getBigDecimal("other_charges"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("payment_status"),
                        rs.getString("payment_method"),
                        rs.getTimestamp("created_at")
                    );
                    b.setPatientName(rs.getString("patient_name"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    // Get all Bills
    public List<Bill> getAllBills() throws SQLException, ClassNotFoundException {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, u.name AS patient_name FROM bills b JOIN users u ON b.patient_id = u.id ORDER BY b.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Bill b = new Bill(
                    rs.getInt("id"),
                    rs.getInt("patient_id"),
                    rs.getObject("appointment_id") != null ? rs.getInt("appointment_id") : null,
                    rs.getBigDecimal("consultation_fee"),
                    rs.getBigDecimal("treatment_fee"),
                    rs.getBigDecimal("medicine_fee"),
                    rs.getBigDecimal("other_charges"),
                    rs.getBigDecimal("total_amount"),
                    rs.getString("payment_status"),
                    rs.getString("payment_method"),
                    rs.getTimestamp("created_at")
                );
                b.setPatientName(rs.getString("patient_name"));
                list.add(b);
            }
        }
        return list;
    }

    // Update Payment Status
    public boolean updatePaymentStatus(int billId, String status, String method) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE bills SET payment_status = ?, payment_method = ? WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, method);
            stmt.setInt(3, billId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Calculate Total Revenue
    public BigDecimal getTotalRevenue() throws SQLException, ClassNotFoundException {
        String sql = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'Paid'";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getBigDecimal(1) != null) {
                return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }

    // Calculate Daily Revenue
    public BigDecimal getDailyRevenue() throws SQLException, ClassNotFoundException {
        String sql = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'Paid' AND DATE(created_at) = CURDATE()";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getBigDecimal(1) != null) {
                return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }

    // Calculate Monthly Revenue
    public BigDecimal getMonthlyRevenue() throws SQLException, ClassNotFoundException {
        String sql = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'Paid' AND MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())";
        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getBigDecimal(1) != null) {
                return rs.getBigDecimal(1);
            }
        }
        return BigDecimal.ZERO;
    }
}
