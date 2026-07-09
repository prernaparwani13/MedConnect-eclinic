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
    AppointmentDAO appointmentDAO = new AppointmentDAO();

    Doctor doctor = doctorDAO.getDoctorByUserId(userId);
    List<Appointment> myAppointments = null;
    int pendingCount = 0;
    int confirmedCount = 0;
    
    if (doctor != null) {
        myAppointments = appointmentDAO.getAppointmentsByDoctorId(doctor.getUserId());
        for (Appointment appt : myAppointments) {
            if ("Pending".equals(appt.getStatus())) pendingCount++;
            if ("Confirmed".equals(appt.getStatus())) confirmedCount++;
        }
        if (myAppointments.size() > 5) {
            myAppointments = myAppointments.subList(0, 5);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Dashboard - MedConnect</title>
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

        .card-metric {
            background: white;
            border-radius: 16px;
            border: none;
            padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            transition: all 0.2s;
        }

        .card-metric-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
            background: rgba(56, 189, 248, 0.1);
            color: #38bdf8;
        }

        .card-metric-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: #0f172a;
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
                <span>MedConnect Doc</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link active">
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
                    <a href="records.jsp" class="sidebar-menu-link">
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
                    <h2 class="fw-bold m-0 text-slate-800">Doctor Dashboard</h2>
                    <p class="text-muted m-0">Welcome, <%= doctor != null ? doctor.getName() : "Dr. Guest" %> | Speciality: <%= doctor != null ? doctor.getSpecialization() : "General" %></p>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <div class="text-end">
                        <div class="fw-bold"><%= session.getAttribute("username") %></div>
                        <div class="text-muted small">Medical Staff</div>
                    </div>
                    <div class="bg-info text-white rounded-circle d-flex align-items-center justify-content-center" style="width:40px; height:40px; font-weight:700;">
                        MD
                    </div>
                </div>
            </div>

            <!-- Metrics -->
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="card-metric">
                        <div class="card-metric-icon" style="color: #38bdf8; background: rgba(56,189,248,0.1);">
                            <i class="bi bi-calendar-check-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= (myAppointments != null) ? myAppointments.size() : 0 %></div>
                        <div class="text-muted small fw-medium mt-1">Total Assigned Bookings</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card-metric">
                        <div class="card-metric-icon" style="color: #f59e0b; background: rgba(245,158,11,0.1);">
                            <i class="bi bi-clock-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= pendingCount %></div>
                        <div class="text-muted small fw-medium mt-1">Pending Appointments</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card-metric">
                        <div class="card-metric-icon" style="color: #10b981; background: rgba(16,185,129,0.1);">
                            <i class="bi bi-person-check-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= confirmedCount %></div>
                        <div class="text-muted small fw-medium mt-1">Confirmed Checkups Today</div>
                    </div>
                </div>
            </div>

            <!-- Schedule info -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mt-4 bg-white">
                <h5 class="fw-bold mb-3"><i class="bi bi-clock text-primary me-2"></i>My Clinic Schedule</h5>
                <p class="text-muted mb-0">Your current assigned duty schedule: <strong><%= doctor != null && doctor.getSchedule() != null ? doctor.getSchedule() : "Not Assigned Yet" %></strong></p>
            </div>

            <!-- Recent list -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mt-4 bg-white">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold text-slate-800 m-0">Upcoming Patient Checkups</h5>
                    <a href="appointments.jsp" class="btn btn-sm btn-outline-primary rounded-pill px-3">View Full Queue</a>
                </div>

                <% if (myAppointments == null || myAppointments.isEmpty()) { %>
                    <div class="text-center py-4 text-muted">No appointments booked with you.</div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Patient Name</th>
                                    <th>Checkup Date</th>
                                    <th>Time Slot</th>
                                    <th>Status</th>
                                    <th>Symptom Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Appointment appt : myAppointments) { %>
                                    <tr>
                                        <td class="fw-semibold"><%= appt.getPatientName() %></td>
                                        <td><%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %></td>
                                        <td><%= appt.getTimeSlot() %></td>
                                        <td>
                                            <span class="badge-status <%= appt.getStatus().toLowerCase() %>">
                                                <%= appt.getStatus() %>
                                            </span>
                                        </td>
                                        <td class="text-muted"><small><%= appt.getDescription() != null ? appt.getDescription() : "N/A" %></small></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
