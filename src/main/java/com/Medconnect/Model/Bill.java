package com.Medconnect.Model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Bill {
    private int id;
    private int patientId;
    private String patientName; // Helper
    private Integer appointmentId;
    private BigDecimal consultationFee = BigDecimal.ZERO;
    private BigDecimal treatmentFee = BigDecimal.ZERO;
    private BigDecimal medicineFee = BigDecimal.ZERO;
    private BigDecimal otherCharges = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private String paymentStatus = "Unpaid"; // 'Paid', 'Unpaid'
    private String paymentMethod; // 'Cash', 'Card', 'Online'
    private Timestamp createdAt;
    
    public Bill() {}
    
    public Bill(int id, int patientId, Integer appointmentId, BigDecimal consultationFee, BigDecimal treatmentFee, BigDecimal medicineFee, BigDecimal otherCharges, BigDecimal totalAmount, String paymentStatus, String paymentMethod, Timestamp createdAt) {
        this.id = id;
        this.patientId = patientId;
        this.appointmentId = appointmentId;
        this.consultationFee = consultationFee;
        this.treatmentFee = treatmentFee;
        this.medicineFee = medicineFee;
        this.otherCharges = otherCharges;
        this.totalAmount = totalAmount;
        this.paymentStatus = paymentStatus;
        this.paymentMethod = paymentMethod;
        this.createdAt = createdAt;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    
    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }
    
    public BigDecimal getConsultationFee() { return consultationFee; }
    public void setConsultationFee(BigDecimal consultationFee) { this.consultationFee = consultationFee; }
    
    public BigDecimal getTreatmentFee() { return treatmentFee; }
    public void setTreatmentFee(BigDecimal treatmentFee) { this.treatmentFee = treatmentFee; }
    
    public BigDecimal getMedicineFee() { return medicineFee; }
    public void setMedicineFee(BigDecimal medicineFee) { this.medicineFee = medicineFee; }
    
    public BigDecimal getOtherCharges() { return otherCharges; }
    public void setOtherCharges(BigDecimal otherCharges) { this.otherCharges = otherCharges; }
    
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
