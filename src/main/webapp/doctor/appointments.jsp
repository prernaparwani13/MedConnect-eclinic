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
    if (doctor != null) {
        myAppointments = appointmentDAO.getAppointmentsByDoctorId(doctor.getUserId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Appointments - MedConnect</title>
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
                    <a href="dashboard.jsp" class="sidebar-menu-link">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="appointments.jsp" class="sidebar-menu-link active">
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
                    <h2 class="fw-bold m-0 text-slate-800">My Appointments Queue</h2>
                    <p class="text-muted m-0">View scheduled checkups, modify status, and write diagnostic prescriptions</p>
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
                                <th>Appointment Date</th>
                                <th>Time Slot</th>
                                <th>Symptom Notes</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (myAppointments == null || myAppointments.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="6" class="text-center py-4 text-muted">No appointments booked with you.</td>
                                </tr>
                            <%
                                } else {
                                    for (Appointment appt : myAppointments) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= appt.getPatientName() %></td>
                                    <td><%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %></td>
                                    <td><%= appt.getTimeSlot() %></td>
                                    <td><small class="text-muted"><%= appt.getDescription() != null ? appt.getDescription() : "N/A" %></small></td>
                                    <td>
                                        <span class="badge-status <%= appt.getStatus().toLowerCase() %>">
                                            <%= appt.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if ("Pending".equals(appt.getStatus())) { %>
                                            <a href="appointment-management?action=confirm&id=<%= appt.getId() %>" class="btn btn-sm btn-outline-success me-1 rounded-3">Confirm</a>
                                        <% } %>
                                        <% if ("Confirmed".equals(appt.getStatus()) || "Rescheduled".equals(appt.getStatus())) { %>
                                            <button class="btn btn-sm btn-primary me-1 rounded-3" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#prescriptionModal" 
                                                    onclick="populatePrescModal(<%= appt.getId() %>, <%= appt.getPatientId() %>, '<%= appt.getPatientName() %>')">
                                                Prescribe
                                            </button>
                                            <button class="btn btn-sm btn-outline-info me-1 rounded-3" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#uploadReportModal" 
                                                    onclick="populateReportModal(<%= appt.getPatientId() %>, '<%= appt.getPatientName() %>')">
                                                Upload Report
                                            </button>
                                            <a href="appointment-management?action=complete&id=<%= appt.getId() %>" class="btn btn-sm btn-outline-success me-1 rounded-3">Complete</a>
                                        <% } %>
                                        <% if (!"Cancelled".equals(appt.getStatus()) && !"Completed".equals(appt.getStatus())) { %>
                                            <a href="appointment-management?action=cancel&id=<%= appt.getId() %>" class="btn btn-sm btn-outline-danger rounded-3" onclick="return confirm('Cancel this appointment?');">Cancel</a>
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

    <!-- Prescription Modal -->
    <div class="modal fade" id="prescriptionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="prescription-management" method="POST">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="appointmentId" id="prescApptId">
                    <input type="hidden" name="patientId" id="prescPatientId">
                    <input type="hidden" name="doctorId" value="<%= doctor != null ? doctor.getUserId() : 0 %>">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Write Prescription</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="mb-3">
                            <label class="form-label">Patient Name</label>
                            <input type="text" class="form-control rounded-3 bg-light" id="prescPatientName" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Medicine Name</label>
                            <input type="text" name="medicineName" class="form-control rounded-3" required placeholder="e.g. Paracetamol 500mg">
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Dosage Schedule</label>
                                <input type="text" name="dosage" class="form-control rounded-3" required placeholder="e.g. 1-0-1 (twice daily)">
                            </div>
                            <div class="col-6">
                                <label class="form-label">Duration</label>
                                <input type="text" name="duration" class="form-control rounded-3" required placeholder="e.g. 5 days">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Special Instructions</label>
                            <textarea name="instructions" class="form-control rounded-3" rows="3" placeholder="Take after meals, avoid cold beverages, etc."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Save Prescription</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Upload Report Modal -->
    <div class="modal fade" id="uploadReportModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="record-management" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="upload">
                    <input type="hidden" name="patientId" id="reportPatientId">
                    <input type="hidden" name="doctorId" value="<%= doctor != null ? doctor.getUserId() : 0 %>">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Upload Diagnostic Report</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="mb-3">
                            <label class="form-label">Patient Name</label>
                            <input type="text" class="form-control rounded-3 bg-light" id="reportPatientName" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Report Description</label>
                            <input type="text" name="description" class="form-control rounded-3" required placeholder="e.g. Complete Blood Count Report">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Select PDF/Image File</label>
                            <input type="file" name="file" class="form-control rounded-3" required>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-info text-white rounded-pill px-4">Upload File</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function populatePrescModal(apptId, patientId, name) {
            document.getElementById('prescApptId').value = apptId;
            document.getElementById('prescPatientId').value = patientId;
            document.getElementById('prescPatientName').value = name;
        }

        function populateReportModal(patientId, name) {
            document.getElementById('reportPatientId').value = patientId;
            document.getElementById('reportPatientName').value = name;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
