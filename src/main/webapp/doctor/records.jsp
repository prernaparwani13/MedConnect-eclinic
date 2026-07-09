<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"doctor".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    DoctorDAO doctorDAO = new DoctorDAO();
    MedicalRecordDAO recordDAO = new MedicalRecordDAO();

    Doctor doctor = doctorDAO.getDoctorByUserId(userId);
    List<MedicalRecord> records = null;
    if (doctor != null) {
        records = recordDAO.getMedicalRecordsByDoctorId(doctor.getUserId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uploaded Reports - MedConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8fafc;
            font-family: 'Outfit', 'Inter', sans-serif;
            min-height: 100vh;
        }

        .sidebar {
            width: 260px;
            background: #0f172a;
            color: #94a3b8;
            min-height: 100vh;
            padding: 1.5rem;
            position: fixed;
            z-index: 100;
        }

        .sidebar .brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #f8fafc;
            margin-bottom: 2.5rem;
            font-weight: 700;
            font-size: 1.25rem;
        }

        .sidebar .brand i {
            color: #0ea5e9;
            font-size: 1.75rem;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
        }

        .sidebar-menu-link {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.75rem 1rem;
            color: #94a3b8;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .sidebar-menu-link:hover, .sidebar-menu-link.active {
            color: #f8fafc;
            background: rgba(255, 255, 255, 0.05);
        }

        .sidebar-menu-link.active {
            background: linear-gradient(135deg, #38bdf8 0%, #0284c7 100%);
            color: white;
        }

        .content {
            margin-left: 260px;
            width: calc(100% - 260px);
            padding: 2rem;
        }

        .main-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .data-card {
            background: white;
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            padding: 1.5rem;
        }
    </style>
</head>
<body>

    <div class="wrapper d-flex">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">
                <i class="bi bi-heart-pulse-fill"></i>
                <span>MedConnect Doc</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="appointments.jsp" class="sidebar-menu-link">
                        <i class="bi bi-calendar-check"></i>
                        <span>My Appointments</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="prescriptions.jsp" class="sidebar-menu-link">
                        <i class="bi bi-file-earmark-medical"></i>
                        <span>Prescriptions</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="records.jsp" class="sidebar-menu-link active">
                        <i class="bi bi-folder2-open"></i>
                        <span>Patient Reports</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="../logout" class="sidebar-menu-link text-danger mt-4">
                        <i class="bi bi-box-arrow-right"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </div>

        <!-- Content -->
        <div class="content">
            <div class="main-header">
                <div>
                    <h2 class="fw-bold m-0 text-slate-800">Uploaded Diagnostic Reports</h2>
                    <p class="text-muted m-0">View or download report documents uploaded for patient records</p>
                </div>
            </div>

            <!-- Alerts -->
            <%
                String msg = request.getParameter("msg");
                String error = (String) request.getAttribute("error");
                if (msg != null) {
            %>
                <div class="alert alert-success alert-dismissible fade show border-0 rounded-3 mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i><%= msg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show border-0 rounded-3 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <!-- List -->
            <div class="data-card">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Patient Name</th>
                                <th>Report Description</th>
                                <th>File Name</th>
                                <th>Date Uploaded</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (records == null || records.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">No diagnostic reports uploaded yet.</td>
                                </tr>
                            <%
                                } else {
                                    for (MedicalRecord r : records) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= r.getPatientName() %></td>
                                    <td><%= r.getDescription() %></td>
                                    <td><i class="bi bi-file-earmark-pdf text-danger me-1"></i><%= r.getFileName() %></td>
                                    <td><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(r.getUploadDate()) %></td>
                                    <td>
                                        <a href="record-management?action=download&id=<%= r.getId() %>" class="btn btn-sm btn-outline-primary rounded-3">
                                            <i class="bi bi-download me-1"></i> Download
                                        </a>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
