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

    DoctorDAO doctorDAO = new DoctorDAO();
    List<Doctor> doctors = doctorDAO.getAllDoctors();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schedule Consultation - MedConnect</title>
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

        .form-card {
            background: white;
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            max-width: 600px;
            padding: 2rem;
        }
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
                    <a href="dashboard.jsp" class="sidebar-menu-link">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="book-appointment.jsp" class="sidebar-menu-link active">
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
                    <h2 class="fw-bold m-0 text-slate-800">Schedule Consultation</h2>
                    <p class="text-muted m-0">Select your specialty doctor and request an appointment</p>
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

            <!-- Form -->
            <div class="form-card">
                <form action="appointment-management" method="POST" id="bookingForm">
                    <input type="hidden" name="action" value="book">
                    <input type="hidden" name="patientId" value="<%= userId %>">

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-slate-700">Choose Specialist Doctor</label>
                        <select name="doctorId" class="form-select rounded-3 py-2" required>
                            <option value="">Select Doctor...</option>
                            <% for (Doctor d : doctors) { %>
                                <% if (d.getUserId() != null) { %>
                                    <option value="<%= d.getUserId() %>">
                                        <%= d.getName() %> | <%= d.getSpecialization() %> (<%= d.getSchedule() != null ? d.getSchedule() : "Mon-Fri" %>)
                                    </option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-slate-700">Preferred Date</label>
                            <input type="date" name="appointmentDate" class="form-control rounded-3 py-2" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-slate-700">Time Slot</label>
                            <select name="timeSlot" class="form-select rounded-3 py-2" required>
                                <option value="09:00">09:00 AM</option>
                                <option value="10:00">10:00 AM</option>
                                <option value="11:00">11:00 AM</option>
                                <option value="12:00">12:00 PM</option>
                                <option value="14:00">02:00 PM</option>
                                <option value="15:00">03:00 PM</option>
                                <option value="16:00">04:00 PM</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold text-slate-700">Brief Symptoms Description</label>
                        <textarea name="description" class="form-control rounded-3" rows="4" placeholder="Briefly describe what checkup concerns you have..."></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary rounded-pill px-4 py-2 w-100 shadow-sm fw-semibold">
                        <i class="bi bi-calendar-check me-2"></i>Submit Booking Request
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
