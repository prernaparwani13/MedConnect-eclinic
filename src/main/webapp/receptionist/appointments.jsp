<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"receptionist".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    AppointmentDAO appointmentDAO = new AppointmentDAO();
    PatientDAO patientDAO = new PatientDAO();
    DoctorDAO doctorDAO = new DoctorDAO();

    List<Appointment> appointments = appointmentDAO.getAllAppointments();
    List<Patient> patients = patientDAO.getAllPatients();
    List<Doctor> doctors = doctorDAO.getAllDoctors();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Appointments - MedConnect</title>
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
            color: #10b981;
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
                <i class="bi bi-hospital"></i>
                <span>MedConnect Front</span>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-menu-item">
                    <a href="dashboard.jsp" class="sidebar-menu-link">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="patients.jsp" class="sidebar-menu-link">
                        <i class="bi bi-emoji-smile"></i>
                        <span>Patients</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="appointments.jsp" class="sidebar-menu-link active">
                        <i class="bi bi-calendar-check"></i>
                        <span>Appointments</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="bills.jsp" class="sidebar-menu-link">
                        <i class="bi bi-receipt-cutoff"></i>
                        <span>Billing & Bills</span>
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
                    <h2 class="fw-bold m-0 text-slate-800">Appointment Registry</h2>
                    <p class="text-muted m-0">Book, reschedule, cancel, or confirm patient appointments</p>
                </div>
                <div>
                    <button class="btn btn-emerald btn-success rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#bookApptModal">
                        <i class="bi bi-calendar-plus me-2"></i>Book Appointment
                    </button>
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
                                <th>Doctor Name</th>
                                <th>Department</th>
                                <th>Date</th>
                                <th>Time Slot</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (appointments == null || appointments.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">No appointments booked.</td>
                                </tr>
                            <%
                                } else {
                                    for (Appointment appt : appointments) {
                            %>
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
                                    <td>
                                        <% if ("Pending".equals(appt.getStatus())) { %>
                                            <a href="appointment-management?action=confirm&id=<%= appt.getId() %>" class="btn btn-sm btn-outline-success me-1 rounded-3">Confirm</a>
                                        <% } %>
                                        <% if (!"Cancelled".equals(appt.getStatus()) && !"Completed".equals(appt.getStatus())) { %>
                                            <button class="btn btn-sm btn-outline-primary me-1 rounded-3" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#rescheduleModal" 
                                                    onclick="populateRescheduleModal(<%= appt.getId() %>, '<%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %>', '<%= appt.getTimeSlot() %>')">
                                                Reschedule
                                            </button>
                                            <a href="appointment-management?action=cancel&id=<%= appt.getId() %>" class="btn btn-sm btn-outline-danger rounded-3" onclick="return confirm('Are you sure you want to cancel this booking?');">Cancel</a>
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

    <!-- Book Appointment Modal -->
    <div class="modal fade" id="bookApptModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="appointment-management" method="POST">
                    <input type="hidden" name="action" value="book">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Book Clinic Appointment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="mb-3">
                            <label class="form-label">Select Patient</label>
                            <select name="patientId" class="form-select rounded-3" required>
                                <option value="">Select Registered Patient...</option>
                                <% for (Patient p : patients) { %>
                                    <% if (p.getUserId() != null) { %>
                                        <option value="<%= p.getUserId() %>"><%= p.getName() %> (ID: <%= p.getId() %>)</option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Select Doctor</label>
                            <select name="doctorId" class="form-select rounded-3" required>
                                <option value="">Select Doctor...</option>
                                <% for (Doctor d : doctors) { %>
                                    <% if (d.getUserId() != null) { %>
                                        <option value="<%= d.getUserId() %>"><%= d.getName() %> (<%= d.getSpecialization() %>)</option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Appointment Date</label>
                                <input type="date" name="appointmentDate" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Slot</label>
                                <select name="timeSlot" class="form-select rounded-3" required>
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
                        <div class="mb-3">
                            <label class="form-label">Description / Symptoms</label>
                            <textarea name="description" class="form-control rounded-3" rows="3" placeholder="Symptoms, checkup notes, etc."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success rounded-pill px-4">Book Now</button>
                    </div>
                </form>
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
                                <label class="form-label">New Date</label>
                                <input type="date" name="appointmentDate" id="rescheduleDate" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">New Time Slot</label>
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
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Confirm Reschedule</button>
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
