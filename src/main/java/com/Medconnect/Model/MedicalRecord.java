package com.Medconnect.Model;

import java.sql.Timestamp;

public class MedicalRecord {
    private int id;
    private int patientId;
    private String patientName; // Helper
    private int doctorId;
    private String doctorName; // Helper
    private String description;
    private String fileName;
    private String filePath;
    private Timestamp uploadDate;
    
    public MedicalRecord() {}
    
    public MedicalRecord(int id, int patientId, int doctorId, String description, String fileName, String filePath, Timestamp uploadDate) {
        this.id = id;
        this.patientId = patientId;
        this.doctorId = doctorId;
        this.description = description;
        this.fileName = fileName;
        this.filePath = filePath;
        this.uploadDate = uploadDate;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    
    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }
    
    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    
    public Timestamp getUploadDate() { return uploadDate; }
    public void setUploadDate(Timestamp uploadDate) { this.uploadDate = uploadDate; }
}
