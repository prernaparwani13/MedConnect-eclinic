<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null || !"patient".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    PatientDAO patientDAO = new PatientDAO();
    AppointmentDAO appointmentDAO = new AppointmentDAO();
    PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

    Patient patient = patientDAO.getPatientByUserId(userId);
    List<Appointment> myAppointments = null;
    List<Prescription> myPrescriptions = null;
    
    if (patient != null) {
        myAppointments = appointmentDAO.getAppointmentsByPatientId(patient.getUserId());
        myPrescriptions = prescriptionDAO.getPrescriptionsByPatientId(patient.getUserId());
        
        if (myAppointments.size() > 3) {
            myAppointments = myAppointments.subList(0, 3);
        }
        if (myPrescriptions.size() > 3) {
            myPrescriptions = myPrescriptions.subList(0, 3);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Dashboard - MedConnect</title>
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
            background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
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

        .card-metric {
            background: white;
            border-radius: 16px;
            border: none;
            padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        .badge-status {
            padding: 0.35em 0.65em;
            border-radius: 50rem;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-status.pending { background-color: rgba(245, 158, 11, 0.1); color: #f59e0b; }
        .badge-status.confirmed { background-color: rgba(16, 185, 129, 0.1); color: #10b981; }
        .badge-status.cancelled { background-color: rgba(239, 68, 68, 0.1); color: #ef4444; }
        .badge-status.completed { background-color: rgba(14, 165, 233, 0.1); color: #0ea5e9; }
        .badge-status.rescheduled { background-color: rgba(139, 92, 246, 0.1); color: #8b5cf6; }
    </style>
</head>
<body>

    <div class="wrapper d-flex">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">
                <i class="bi bi-heart-pulse-fill"></i>
                <span>MedConnect</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link active">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="book-appointment.jsp" class="sidebar-menu-link">
                        <i class="bi bi-calendar-plus"></i>
                        <span>Book Appointment</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="appointments.jsp" class="sidebar-menu-link">
                        <i class="bi bi-calendar3"></i>
                        <span>My Bookings</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="prescriptions.jsp" class="sidebar-menu-link">
                        <i class="bi bi-file-earmark-medical"></i>
                        <span>Prescriptions</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="records.jsp" class="sidebar-menu-link">
                        <i class="bi bi-folder2-open"></i>
                        <span>My Reports</span>
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
                    <h2 class="fw-bold m-0 text-slate-800">Patient Portal</h2>
                    <p class="text-muted m-0">Welcome back, <%= session.getAttribute("username") %></p>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <div class="text-end">
                        <div class="fw-bold"><%= session.getAttribute("username") %></div>
                        <div class="text-muted small">Patient Account</div>
                    </div>
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width:40px; height:40px; font-weight:700;">
                        P
                    </div>
                </div>
            </div>

            <!-- Profile Info Widget -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 bg-white">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h4 class="fw-bold mb-2 text-primary"><i class="bi bi-person-fill me-2"></i>My Medical Profile</h4>
                        <div class="row text-slate-700">
                            <div class="col-6 mb-2"><strong>Blood Group:</strong> <span class="badge bg-danger"><%= patient != null && patient.getBloodGroup() != null ? patient.getBloodGroup() : "N/A" %></span></div>
                            <div class="col-6 mb-2"><strong>Gender:</strong> <%= patient != null && patient.getGender() != null ? patient.getGender() : "N/A" %></div>
                            <div class="col-6 mb-2"><strong>Date of Birth:</strong> <%= patient != null && patient.getDob() != null ? patient.getDob() : "N/A" %></div>
                            <div class="col-6 mb-2"><strong>Contact Phone:</strong> <%= patient != null && patient.getPhone() != null ? patient.getPhone() : "N/A" %></div>
                            <div class="col-12"><strong>Active History notes:</strong> <span class="text-muted"><%= patient != null && patient.getMedicalHistory() != null ? patient.getMedicalHistory() : "None logged" %></span></div>
                        </div>
                    </div>
                    <div class="col-md-4 text-center mt-3 mt-md-0">
                        <a href="book-appointment.jsp" class="btn btn-primary rounded-pill px-4 shadow-sm w-100 mb-2 py-2"><i class="bi bi-calendar-plus me-2"></i>Book Appointment</a>
                        <a href="records.jsp" class="btn btn-outline-secondary rounded-pill px-4 w-100 py-2"><i class="bi bi-folder2-open me-2"></i>View Reports</a>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Bookings -->
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm rounded-4 p-4 bg-white h-100">
                        <h5 class="fw-bold text-slate-800 mb-3"><i class="bi bi-calendar3 text-primary me-2"></i>Recent Bookings</h5>
                        <% if (myAppointments == null || myAppointments.isEmpty()) { %>
                            <div class="text-center py-4 text-muted small">You have no booked appointments.</div>
                        <% } else { %>
                            <ul class="list-group list-group-flush">
                                <% for (Appointment appt : myAppointments) { %>
                                    <li class="list-group-item px-0 py-3">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="fw-semibold mb-1"><%= appt.getDoctorName() %></h6>
                                                <small class="text-muted"><%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %> | Slot: <%= appt.getTimeSlot() %></small>
                                            </div>
                                            <span class="badge-status <%= appt.getStatus().toLowerCase() %>">
                                                <%= appt.getStatus() %>
                                            </span>
                                        </div>
                                    </li>
                                <% } %>
                            </ul>
                        <% } %>
                    </div>
                </div>

                <!-- Prescriptions -->
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm rounded-4 p-4 bg-white h-100">
                        <h5 class="fw-bold text-slate-800 mb-3"><i class="bi bi-file-earmark-medical text-primary me-2"></i>Active Prescriptions</h5>
                        <% if (myPrescriptions == null || myPrescriptions.isEmpty()) { %>
                            <div class="text-center py-4 text-muted small">No prescriptions written for you yet.</div>
                        <% } else { %>
                            <ul class="list-group list-group-flush">
                                <% for (Prescription p : myPrescriptions) { %>
                                    <li class="list-group-item px-0 py-3">
                                        <div class="d-flex justify-content-between">
                                            <div>
                                                <h6 class="fw-semibold mb-1"><%= p.getMedicineName() %></h6>
                                                <small class="text-slate-500">Dosage: <strong><%= p.getDosage() %></strong> | Days: <%= p.getDuration() %></small>
                                            </div>
                                            <div class="text-end">
                                                <small class="text-muted"><%= new SimpleDateFormat("yyyy-MM-dd").format(p.getCreatedAt()) %></small>
                                            </div>
                                        </div>
                                    </li>
                                <% } %>
                            </ul>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
