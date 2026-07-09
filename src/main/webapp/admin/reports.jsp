<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    // Check if attributes are loaded, if not redirect to servlet
    if (request.getAttribute("totalPatients") == null) {
        response.sendRedirect("reports");
        return;
    }

    int totalPatients = (Integer) request.getAttribute("totalPatients");
    int totalDoctors = (Integer) request.getAttribute("totalDoctors");
    int totalAppointments = (Integer) request.getAttribute("totalAppointments");
    int pendingAppointments = (Integer) request.getAttribute("pendingAppointments");
    int confirmedAppointments = (Integer) request.getAttribute("confirmedAppointments");
    
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    BigDecimal dailyRevenue = (BigDecimal) request.getAttribute("dailyRevenue");
    BigDecimal monthlyRevenue = (BigDecimal) request.getAttribute("monthlyRevenue");

    int dailyAppointments = (Integer) request.getAttribute("dailyAppointments");
    int monthlyAppointments = (Integer) request.getAttribute("monthlyAppointments");
    int dailyPatients = (Integer) request.getAttribute("dailyPatients");
    int monthlyPatients = (Integer) request.getAttribute("monthlyPatients");

    int malePatients = (Integer) request.getAttribute("malePatients");
    int femalePatients = (Integer) request.getAttribute("femalePatients");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics - MedConnect</title>
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

        .chart-card {
            background: white;
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            padding: 1.5rem;
            height: 100%;
        }

        .progress-bar-custom {
            height: 8px;
            border-radius: 4px;
        }
    </style>
</head>
<body>

    <div class="wrapper d-flex">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="brand">
                <i class="bi bi-heart-pulse-fill"></i>
                <span>MedConnect Admin</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link">
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
                    <a href="reports.jsp" class="sidebar-menu-link active">
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

        <!-- Content -->
        <div class="content">
            <div class="main-header">
                <div>
                    <h2 class="fw-bold m-0 text-slate-800">Reports & Analytics</h2>
                    <p class="text-muted m-0">Aggregate metrics on hospital revenue, billing activity, and patient traffic</p>
                </div>
                <div>
                    <a href="reports" class="btn btn-outline-primary rounded-pill px-3">
                        <i class="bi bi-arrow-clockwise me-2"></i>Refresh Data
                    </a>
                </div>
            </div>

            <!-- Revenue metrics -->
            <h4 class="fw-bold mb-3 text-slate-800">Financial Reports</h4>
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card p-3 border-0 shadow-sm rounded-4 bg-primary text-white">
                        <h6 class="text-white-50">Total Billing Revenue</h6>
                        <h2 class="fw-bold">$<%= totalRevenue != null ? totalRevenue.setScale(2, BigDecimal.ROUND_HALF_UP).toString() : "0.00" %></h2>
                        <span class="small"><i class="bi bi-info-circle me-1"></i>Accumulated paid balances</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card p-3 border-0 shadow-sm rounded-4 bg-success text-white">
                        <h6 class="text-white-50">Monthly Revenue</h6>
                        <h2 class="fw-bold">$<%= monthlyRevenue != null ? monthlyRevenue.setScale(2, BigDecimal.ROUND_HALF_UP).toString() : "0.00" %></h2>
                        <span class="small"><i class="bi bi-calendar-event me-1"></i>Current month aggregates</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card p-3 border-0 shadow-sm rounded-4 bg-warning text-dark">
                        <h6 class="text-black-50">Daily Revenue</h6>
                        <h2 class="fw-bold">$<%= dailyRevenue != null ? dailyRevenue.setScale(2, BigDecimal.ROUND_HALF_UP).toString() : "0.00" %></h2>
                        <span class="small"><i class="bi bi-clock me-1"></i>Transactions paid today</span>
                    </div>
                </div>
            </div>

            <!-- Demographics and traffic -->
            <div class="row g-4">
                <!-- Traffic -->
                <div class="col-md-6">
                    <div class="chart-card">
                        <h5 class="fw-bold mb-4">Hospital Traffic & Bookings</h5>
                        
                        <div class="mb-4">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="fw-medium text-slate-700">Daily Booked Appointments</span>
                                <span class="fw-bold text-primary"><%= dailyAppointments %></span>
                            </div>
                            <div class="progress progress-bar-custom" style="height: 10px;">
                                <div class="progress-bar bg-primary" role="progressbar" style="width: <%= Math.min(100, dailyAppointments * 5) %>%"></div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="fw-medium text-slate-700">Monthly Booked Appointments</span>
                                <span class="fw-bold text-success"><%= monthlyAppointments %></span>
                            </div>
                            <div class="progress progress-bar-custom" style="height: 10px;">
                                <div class="progress-bar bg-success" role="progressbar" style="width: <%= Math.min(100, monthlyAppointments) %>%"></div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="fw-medium text-slate-700">Daily Newly Registered Patients</span>
                                <span class="fw-bold text-warning"><%= dailyPatients %></span>
                            </div>
                            <div class="progress progress-bar-custom" style="height: 10px;">
                                <div class="progress-bar bg-warning" role="progressbar" style="width: <%= Math.min(100, dailyPatients * 10) %>%"></div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="fw-medium text-slate-700">Monthly Newly Registered Patients</span>
                                <span class="fw-bold text-info"><%= monthlyPatients %></span>
                            </div>
                            <div class="progress progress-bar-custom" style="height: 10px;">
                                <div class="progress-bar bg-info" role="progressbar" style="width: <%= Math.min(100, monthlyPatients * 3) %>%"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Demographics -->
                <div class="col-md-6">
                    <div class="chart-card">
                        <h5 class="fw-bold mb-4">Patient Gender Demographics</h5>
                        
                        <%
                            int totalGenders = malePatients + femalePatients;
                            double malePct = totalGenders > 0 ? (malePatients * 100.0 / totalGenders) : 50.0;
                            double femalePct = totalGenders > 0 ? (femalePatients * 100.0 / totalGenders) : 50.0;
                        %>
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h6 class="text-muted mb-1">Male Patients</h6>
                                <h3 class="fw-bold text-primary"><%= malePatients %></h3>
                            </div>
                            <div>
                                <h6 class="text-muted mb-1">Female Patients</h6>
                                <h3 class="fw-bold text-danger"><%= femalePatients %></h3>
                            </div>
                        </div>

                        <div class="progress progress-bar-custom mb-3" style="height: 25px;">
                            <div class="progress-bar bg-primary" role="progressbar" style="width: <%= malePct %>%" aria-valuenow="<%= malePct %>" aria-valuemin="0" aria-valuemax="100"><%= (int)malePct %>% Male</div>
                            <div class="progress-bar bg-danger" role="progressbar" style="width: <%= femalePct %>%" aria-valuenow="<%= femalePct %>" aria-valuemin="0" aria-valuemax="100"><%= (int)femalePct %>% Female</div>
                        </div>

                        <hr>
                        <h6 class="fw-bold mb-3">Appointment Queue Breakdown</h6>
                        <div class="row text-center">
                            <div class="col-4 border-end">
                                <h6 class="text-muted small">Total Booked</h6>
                                <h4 class="fw-semibold text-slate-800"><%= totalAppointments %></h4>
                            </div>
                            <div class="col-4 border-end">
                                <h6 class="text-muted small">Pending</h6>
                                <h4 class="fw-semibold text-warning"><%= pendingAppointments %></h4>
                            </div>
                            <div class="col-4">
                                <h6 class="text-muted small">Confirmed</h6>
                                <h4 class="fw-semibold text-success"><%= confirmedAppointments %></h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
