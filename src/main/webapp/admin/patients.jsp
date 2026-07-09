<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    PatientDAO patientDAO = new PatientDAO();
    String searchKeyword = request.getParameter("search");
    List<Patient> patients;
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        patients = patientDAO.searchPatients(searchKeyword.trim());
    } else {
        patients = patientDAO.getAllPatients();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Directory - MedConnect</title>
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
                    <a href="patients.jsp" class="sidebar-menu-link active">
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

        <!-- Content -->
        <div class="content">
            <div class="main-header">
                <div>
                    <h2 class="fw-bold m-0 text-slate-800">Patient Directory</h2>
                    <p class="text-muted m-0">View registered patients and patient profile history</p>
                </div>
                <div>
                    <button class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addPatientModal">
                        <i class="bi bi-plus-lg me-2"></i>Add Patient
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

            <!-- Search and List -->
            <div class="data-card">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <form action="patients.jsp" method="GET" class="d-flex">
                            <input type="text" name="search" class="form-control rounded-pill px-3 me-2" placeholder="Search by name, email, phone..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                            <button type="submit" class="btn btn-outline-secondary rounded-pill px-3">Search</button>
                        </form>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Gender</th>
                                <th>DOB</th>
                                <th>Blood Group</th>
                                <th>Medical History</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (patients == null || patients.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-muted">No patients found.</td>
                                </tr>
                            <%
                                } else {
                                    for (Patient p : patients) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= p.getName() %></td>
                                    <td><%= p.getEmail() != null ? p.getEmail() : "N/A" %></td>
                                    <td><%= p.getPhone() != null ? p.getPhone() : "N/A" %></td>
                                    <td><%= p.getGender() != null ? p.getGender() : "N/A" %></td>
                                    <td><%= p.getDob() != null ? p.getDob() : "N/A" %></td>
                                    <td><span class="badge bg-danger"><%= p.getBloodGroup() != null ? p.getBloodGroup() : "N/A" %></span></td>
                                    <td>
                                        <small class="text-muted"><%= p.getMedicalHistory() != null ? p.getMedicalHistory() : "None" %></small>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary me-2 rounded-3" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#editPatientModal"
                                                onclick="populateEditModal(<%= p.getId() %>, '<%= p.getName() %>', '<%= p.getEmail() != null ? p.getEmail() : "" %>', '<%= p.getPhone() != null ? p.getPhone() : "" %>', '<%= p.getGender() %>', '<%= p.getDob() != null ? p.getDob() : "" %>', '<%= p.getBloodGroup() != null ? p.getBloodGroup() : "" %>', '<%= p.getAddress() != null ? p.getAddress().replace("'", "\\'") : "" %>', '<%= p.getMedicalHistory() != null ? p.getMedicalHistory().replace("'", "\\'") : "" %>')">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <a href="patient-management?action=delete&id=<%= p.getId() %>" 
                                           class="btn btn-sm btn-outline-danger rounded-3"
                                           onclick="return confirm('Are you sure you want to delete this patient?');">
                                            <i class="bi bi-trash"></i>
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

    <!-- Add Patient Modal -->
    <div class="modal fade" id="addPatientModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4">
                <form action="patient-management" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Register New Patient</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="name" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email Address (Optional)</label>
                                <input type="email" name="email" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number</label>
                                <input type="text" name="phone" class="form-control rounded-3">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Gender</label>
                                <select name="gender" class="form-select rounded-3">
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Blood Group</label>
                                <input type="text" name="bloodGroup" class="form-control rounded-3" placeholder="O+">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date of Birth</label>
                                <input type="date" name="dob" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Login Password (Optional)</label>
                                <input type="password" name="password" class="form-control rounded-3" placeholder="Default: patient123">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <textarea name="address" class="form-control rounded-3" rows="2"></textarea>
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">Initial Medical History</label>
                                <textarea name="medicalHistory" class="form-control rounded-3" rows="2" placeholder="Chronic diseases, past surgeries, active medications..."></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Register Patient</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Patient Modal -->
    <div class="modal fade" id="editPatientModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4">
                <form action="patient-management" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editId">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Edit Patient Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="name" id="editName" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" id="editEmail" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number</label>
                                <input type="text" name="phone" id="editPhone" class="form-control rounded-3">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Gender</label>
                                <select name="gender" id="editGender" class="form-select rounded-3">
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Blood Group</label>
                                <input type="text" name="bloodGroup" id="editBloodGroup" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date of Birth</label>
                                <input type="date" name="dob" id="editDob" class="form-control rounded-3">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <textarea name="address" id="editAddress" class="form-control rounded-3" rows="2"></textarea>
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">Active Medical History</label>
                                <textarea name="medicalHistory" id="editHistory" class="form-control rounded-3" rows="2"></textarea>
                            </div>
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
        function populateEditModal(id, name, email, phone, gender, dob, bloodGroup, address, history) {
            document.getElementById('editId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editPhone').value = phone;
            document.getElementById('editGender').value = gender;
            document.getElementById('editDob').value = dob;
            document.getElementById('editBloodGroup').value = bloodGroup;
            document.getElementById('editAddress').value = address;
            document.getElementById('editHistory').value = history;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
