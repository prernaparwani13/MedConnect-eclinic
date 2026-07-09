<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    PatientDAO patientDAO = new PatientDAO();
    DoctorDAO doctorDAO = new DoctorDAO();
    DepartmentDAO departmentDAO = new DepartmentDAO();
    StaffDAO staffDAO = new StaffDAO();
    BillDAO billDAO = new BillDAO();
    AppointmentDAO appointmentDAO = new AppointmentDAO();

    int patientCount = patientDAO.getPatientCount();
    int doctorCount = doctorDAO.getDoctorCount();
    int deptCount = departmentDAO.getDepartmentCount();
    int staffCount = staffDAO.getAllStaff().size();
    BigDecimal revenue = billDAO.getTotalRevenue();
    List<Appointment> recentAppointments = appointmentDAO.getAllAppointments();
    if (recentAppointments.size() > 5) {
        recentAppointments = recentAppointments.subList(0, 5);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MedConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            --accent-blue: #0ea5e9;
            --accent-green: #10b981;
            --accent-red: #ef4444;
            --accent-yellow: #f59e0b;
        }

        body {
            background-color: #f8fafc;
            font-family: 'Outfit', 'Inter', sans-serif;
            min-height: 100vh;
        }

        /* Layout structure */
        .wrapper {
            display: flex;
            width: 100%;
        }

        /* Sidebar Styling */
        .sidebar {
            width: 260px;
            background: #0f172a;
            color: #94a3b8;
            min-height: 100vh;
            padding: 1.5rem;
            position: fixed;
            transition: all 0.3s;
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
            padding-left: 0.5rem;
        }

        .sidebar .brand i {
            color: var(--accent-blue);
            font-size: 1.75rem;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar-menu-item {
            margin-bottom: 0.5rem;
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

        /* Main Content Panel */
        .content {
            margin-left: 260px;
            width: calc(100% - 260px);
            padding: 2rem;
            transition: all 0.3s;
        }

        /* Header block */
        .main-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #38bdf8, #0369a1);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        /* Metric cards */
        .card-metric {
            background: white;
            border-radius: 16px;
            border: none;
            padding: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -2px rgba(0,0,0,0.05);
            transition: all 0.2s;
        }

        .card-metric:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08);
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
        }

        .icon-blue { background: rgba(14, 165, 233, 0.1); color: var(--accent-blue); }
        .icon-green { background: rgba(16, 185, 129, 0.1); color: var(--accent-green); }
        .icon-yellow { background: rgba(245, 158, 11, 0.1); color: var(--accent-yellow); }
        .icon-red { background: rgba(239, 68, 68, 0.1); color: var(--accent-red); }

        .card-metric-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 0.25rem;
        }

        .card-metric-label {
            color: #64748b;
            font-size: 0.875rem;
            font-weight: 500;
        }

        /* Recent table card */
        .recent-card {
            background: white;
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            margin-top: 2rem;
            padding: 1.5rem;
        }

        .table {
            vertical-align: middle;
        }
        
        .badge-status {
            padding: 0.35em 0.65em;
            border-radius: 50rem;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .badge-status.pending { background-color: rgba(245, 158, 11, 0.1); color: var(--accent-yellow); }
        .badge-status.confirmed { background-color: rgba(16, 185, 129, 0.1); color: var(--accent-green); }
        .badge-status.cancelled { background-color: rgba(239, 68, 68, 0.1); color: var(--accent-red); }
        .badge-status.completed { background-color: rgba(14, 165, 233, 0.1); color: var(--accent-blue); }
    </style>
</head>
<body>

    <div class="wrapper">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">
                <i class="bi bi-heart-pulse-fill"></i>
                <span>MedConnect Admin</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link active">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="doctors.jsp" class="sidebar-menu-link">
                        <i class="bi bi-person-badge"></i>
                        <span>Doctors</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="departments.jsp" class="sidebar-menu-link">
                        <i class="bi bi-diagram-3"></i>
                        <span>Departments</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="staff.jsp" class="sidebar-menu-link">
                        <i class="bi bi-people"></i>
                        <span>Staff Directory</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="patients.jsp" class="sidebar-menu-link">
                        <i class="bi bi-emoji-smile"></i>
                        <span>Patients</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="reports.jsp" class="sidebar-menu-link">
                        <i class="bi bi-bar-chart"></i>
                        <span>Reports & Revenue</span>
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

        <!-- Main Panel -->
        <div class="content">
            <!-- Header -->
            <div class="main-header">
                <div>
                    <h2 class="fw-bold text-slate-800 m-0">Dashboard Overview</h2>
                    <p class="text-muted m-0">Welcome back, system manager</p>
                </div>
                <div class="user-profile">
                    <div class="text-end">
                        <div class="fw-bold text-slate-800"><%= session.getAttribute("username") %></div>
                        <div class="text-muted small">Administrator</div>
                    </div>
                    <div class="user-avatar">
                        <%= session.getAttribute("username").toString().substring(0, 1).toUpperCase() %>
                    </div>
                </div>
            </div>

            <!-- Metrics -->
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="card-metric">
                        <div class="card-metric-icon icon-blue">
                            <i class="bi bi-person-badge-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= doctorCount %></div>
                        <div class="card-metric-label">Active Doctors</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-metric">
                        <div class="card-metric-icon icon-green">
                            <i class="bi bi-emoji-smile-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= patientCount %></div>
                        <div class="card-metric-label">Registered Patients</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-metric">
                        <div class="card-metric-icon icon-yellow">
                            <i class="bi bi-people-fill"></i>
                        </div>
                        <div class="card-metric-value"><%= staffCount %></div>
                        <div class="card-metric-label">Staff Members</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-metric">
                        <div class="card-metric-icon icon-red">
                            <i class="bi bi-cash-stack"></i>
                        </div>
                        <div class="card-metric-value">$<%= revenue != null ? revenue.setScale(2, BigDecimal.ROUND_HALF_UP).toString() : "0.00" %></div>
                        <div class="card-metric-label">Total Revenue</div>
                    </div>
                </div>
            </div>

            <!-- Recent activity -->
            <div class="recent-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold text-slate-800 m-0">Recent Appointments</h5>
                    <a href="reports.jsp" class="btn btn-outline-primary btn-sm rounded-pill px-3">View Analytics</a>
                </div>
                
                <% if (recentAppointments == null || recentAppointments.isEmpty()) { %>
                    <div class="text-center py-4 text-muted">No appointments booked yet.</div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Patient</th>
                                    <th>Doctor</th>
                                    <th>Department</th>
                                    <th>Schedule Date</th>
                                    <th>Time Slot</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Appointment appt : recentAppointments) { %>
                                    <tr>
                                        <td class="fw-semibold"><%= appt.getPatientName() %></td>
                                        <td><%= appt.getDoctorName() %></td>
                                        <td><span class="badge bg-secondary"><%= appt.getSpecialization() %></span></td>
                                        <td><%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %></td>
                                        <td><%= appt.getTimeSlot() %></td>
                                        <td>
                                            <span class="badge-status <%= appt.getStatus().toLowerCase() %>">
                                                <%= appt.getStatus() %>
                                            </span>
                                        </td>
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
