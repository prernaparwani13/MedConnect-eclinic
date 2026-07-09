package com.Medconnect.MedicalRecord;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Paths;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.Medconnect.DAO.MedicalRecordDAO;
import com.Medconnect.Model.MedicalRecord;

@WebServlet({"/doctor/record-management", "/patient/record-management"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class MedicalRecordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MedicalRecordDAO recordDAO = new MedicalRecordDAO();
    private static final String UPLOAD_DIR = "uploads";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("download".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                MedicalRecord record = recordDAO.getMedicalRecordById(id);
                if (record != null) {
                    File file = new File(record.getFilePath());
                    if (file.exists()) {
                        response.setContentType("application/octet-stream");
                        response.setContentLength((int) file.length());
                        
                        // force download
                        String headerValue = String.format("attachment; filename=\"%s\"", record.getFileName());
                        response.setHeader("Content-Disposition", headerValue);
                        
                        try (FileInputStream inStream = new FileInputStream(file);
                             OutputStream outStream = response.getOutputStream()) {
                            byte[] buffer = new byte[4096];
                            int bytesRead;
                            while ((bytesRead = inStream.read(buffer)) != -1) {
                                outStream.write(buffer, 0, bytesRead);
                            }
                        }
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Medical report file not found.");
        } else {
            response.sendRedirect("records.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("upload".equals(action)) {
            try {
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                int doctorId = Integer.parseInt(request.getParameter("doctorId"));
                String description = request.getParameter("description");
                
                Part filePart = request.getPart("file");
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                
                // Set upload directory inside web app context
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
                
                File uploadDir = new File(uploadFilePath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                // Add millisecond stamp to file to prevent duplicate names
                String savedFileName = System.currentTimeMillis() + "_" + fileName;
                String filePath = uploadFilePath + File.separator + savedFileName;
                
                filePart.write(filePath);
                
                MedicalRecord mr = new MedicalRecord(0, patientId, doctorId, description, fileName, filePath, null);
                boolean success = recordDAO.addMedicalRecord(mr);
                
                if (success) {
                    response.sendRedirect("records.jsp?msg=Medical report uploaded successfully.");
                } else {
                    request.setAttribute("error", "Failed to save file details in database.");
                    request.getRequestDispatcher("records.jsp").forward(request, response);
                }
                
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("records.jsp").forward(request, response);
            }
        }
    }
}
