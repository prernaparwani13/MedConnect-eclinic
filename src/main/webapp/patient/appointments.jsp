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

    AppointmentDAO appointmentDAO = new AppointmentDAO();
    List<Appointment> myAppointments = appointmentDAO.getAppointmentsByPatientId(userId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - MedConnect</title>
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

        .data-card {
            background: white;
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            padding: 1.5rem;
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
                    <a href="dashboard.jsp" class="sidebar-menu-link">
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
                    <a href="appointments.jsp" class="sidebar-menu-link active">
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
                    <h2 class="fw-bold m-0 text-slate-800">My Consultation Bookings</h2>
                    <p class="text-muted m-0">View checkup queue, reschedule schedules, or cancel requests</p>
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
                                <th>Doctor Name</th>
                                <th>Department / Specialization</th>
                                <th>Appointment Date</th>
                                <th>Time Slot</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (myAppointments == null || myAppointments.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">You have no booked consultations.</td>
                                </tr>
                            <%
                                } else {
                                    for (Appointment appt : myAppointments) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= appt.getDoctorName() %></td>
                                    <td><span class="badge bg-secondary"><%= appt.getSpecialization() %></span></td>
                                    <td><%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %></td>
                                    <td><%= appt.getTimeSlot() %></td>
                                    <td><small class="text-muted"><%= appt.getDescription() != null ? appt.getDescription() : "N/A" %></small></td>
                                    <td>
                                        <span class="badge-status <%= appt.getStatus().toLowerCase() %>">
                                            <%= appt.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (!"Cancelled".equals(appt.getStatus()) && !"Completed".equals(appt.getStatus())) { %>
                                            <button class="btn btn-sm btn-outline-primary me-2 rounded-3" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#rescheduleModal"
                                                    onclick="populateRescheduleModal(<%= appt.getId() %>, '<%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %>', '<%= appt.getTimeSlot() %>')">
                                                Reschedule
                                            </button>
                                            <a href="appointment-management?action=cancel&id=<%= appt.getId() %>" 
                                               class="btn btn-sm btn-outline-danger rounded-3"
                                               onclick="return confirm('Are you sure you want to cancel this appointment?');">
                                                Cancel
                                            </a>
                                        <% } else { %>
                                            <span class="text-muted small">No actions</span>
                                        <% } %>
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

    <!-- Reschedule Modal -->
    <div class="modal fade" id="rescheduleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="appointment-management" method="POST">
                    <input type="hidden" name="action" value="reschedule">
                    <input type="hidden" name="id" id="rescheduleId">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Reschedule Appointment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Select New Date</label>
                                <input type="date" name="appointmentDate" id="rescheduleDate" class="form-control rounded-3" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Select New Time Slot</label>
                                <select name="timeSlot" id="rescheduleSlot" class="form-select rounded-3" required>
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
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Save Schedule</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function populateRescheduleModal(id, date, slot) {
            document.getElementById('rescheduleId').value = id;
            document.getElementById('rescheduleDate').value = date;
            document.getElementById('rescheduleSlot').value = slot;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
