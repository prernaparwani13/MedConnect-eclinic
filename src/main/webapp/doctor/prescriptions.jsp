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
    PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

    Doctor doctor = doctorDAO.getDoctorByUserId(userId);
    List<Prescription> prescriptions = null;
    if (doctor != null) {
        prescriptions = prescriptionDAO.getPrescriptionsByDoctorId(doctor.getUserId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Written Prescriptions - MedConnect</title>
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
                    <a href="prescriptions.jsp" class="sidebar-menu-link active">
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
                    <h2 class="fw-bold m-0 text-slate-800">Prescription History</h2>
                    <p class="text-muted m-0">View all patient medical prescriptions written by you</p>
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
                                <th>Medicine Name</th>
                                <th>Dosage Schedule</th>
                                <th>Duration</th>
                                <th>Instructions</th>
                                <th>Date Written</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (prescriptions == null || prescriptions.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">No prescriptions written yet.</td>
                                </tr>
                            <%
                                } else {
                                    for (Prescription p : prescriptions) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= p.getPatientName() %></td>
                                    <td><strong><%= p.getMedicineName() %></strong></td>
                                    <td><%= p.getDosage() %></td>
                                    <td><%= p.getDuration() %></td>
                                    <td><small class="text-muted"><%= p.getInstructions() != null ? p.getInstructions() : "None" %></small></td>
                                    <td><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt()) %></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary rounded-3" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#editPrescModal"
                                                onclick="populateEditModal(<%= p.getId() %>, '<%= p.getPatientName() %>', '<%= p.getMedicineName().replace("'", "\\'") %>', '<%= p.getDosage().replace("'", "\\'") %>', '<%= p.getDuration().replace("'", "\\'") %>', '<%= p.getInstructions() != null ? p.getInstructions().replace("'", "\\'") : "" %>')">
                                            Edit
                                        </button>
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

    <!-- Edit Prescription Modal -->
    <div class="modal fade" id="editPrescModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="prescription-management" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editPrescId">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Edit Prescription Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="mb-3">
                            <label class="form-label">Patient Name</label>
                            <input type="text" class="form-control rounded-3 bg-light" id="editPatientName" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Medicine Name</label>
                            <input type="text" name="medicineName" id="editMedName" class="form-control rounded-3" required>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Dosage Schedule</label>
                                <input type="text" name="dosage" id="editDosage" class="form-control rounded-3" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Duration</label>
                                <input type="text" name="duration" id="editDuration" class="form-control rounded-3" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Special Instructions</label>
                            <textarea name="instructions" id="editInstructions" class="form-control rounded-3" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function populateEditModal(id, patName, medName, dosage, duration, instructions) {
            document.getElementById('editPrescId').value = id;
            document.getElementById('editPatientName').value = patName;
            document.getElementById('editMedName').value = medName;
            document.getElementById('editDosage').value = dosage;
            document.getElementById('editDuration').value = duration;
            document.getElementById('editInstructions').value = instructions;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
