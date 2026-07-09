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

    DoctorDAO doctorDAO = new DoctorDAO();
    DepartmentDAO departmentDAO = new DepartmentDAO();

    String searchKeyword = request.getParameter("search");
    List<Doctor> doctors;
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        doctors = doctorDAO.searchDoctors(searchKeyword.trim());
    } else {
        doctors = doctorDAO.getAllDoctors();
    }
    List<Department> departments = departmentDAO.getAllDepartments();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Management - MedConnect</title>
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
                    <a href="doctors.jsp" class="sidebar-menu-link active">
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

        <!-- Content -->
        <div class="content">
            <div class="main-header">
                <div>
                    <h2 class="fw-bold m-0 text-slate-800">Doctor Management</h2>
                    <p class="text-muted m-0">Add, edit, or delete doctors and allocate clinic schedules</p>
                </div>
                <div>
                    <button class="btn btn-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#addDoctorModal">
                        <i class="bi bi-plus-lg me-2"></i>Add Doctor
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
                        <form action="doctors.jsp" method="GET" class="d-flex">
                            <input type="text" name="search" class="form-control rounded-pill px-3 me-2" placeholder="Search by name, specialization, or department..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
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
                                <th>Specialization</th>
                                <th>Department</th>
                                <th>Phone</th>
                                <th>Schedule</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (doctors == null || doctors.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">No doctors found.</td>
                                </tr>
                            <%
                                } else {
                                    for (Doctor d : doctors) {
                            %>
                                <tr>
                                    <td class="fw-semibold"><%= d.getName() %></td>
                                    <td><%= d.getEmail() %></td>
                                    <td><%= d.getSpecialization() %></td>
                                    <td>
                                        <span class="badge bg-info text-dark">
                                            <%= d.getDepartmentName() != null ? d.getDepartmentName() : "N/A" %>
                                        </span>
                                    </td>
                                    <td><%= d.getPhone() %></td>
                                    <td><%= d.getSchedule() %></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary me-2 rounded-3" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#editDoctorModal"
                                                onclick="populateEditModal(<%= d.getId() %>, '<%= d.getName() %>', '<%= d.getEmail() %>', '<%= d.getSpecialization() %>', '<%= d.getPhone() %>', '<%= d.getAddress().replace("'", "\\'") %>', <%= d.getDepartmentId() %>, '<%= d.getSchedule() %>')">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <a href="doctor-management?action=delete&id=<%= d.getId() %>" 
                                           class="btn btn-sm btn-outline-danger rounded-3"
                                           onclick="return confirm('Are you sure you want to delete this doctor?');">
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

    <!-- Add Doctor Modal -->
    <div class="modal fade" id="addDoctorModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4">
                <form action="doctor-management" method="POST" id="addDoctorForm">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Register New Doctor</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="name" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Specialization</label>
                                <input type="text" name="specialization" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Department</label>
                                <select name="departmentId" class="form-select rounded-3">
                                    <option value="">Select Department...</option>
                                    <% for (Department dept : departments) { %>
                                        <option value="<%= dept.getId() %>"><%= dept.getName() %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number</label>
                                <input type="text" name="phone" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duty Schedule</label>
                                <input type="text" name="schedule" class="form-control rounded-3" placeholder="Mon-Fri 09:00-17:00">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Login Password</label>
                                <input type="password" name="password" class="form-control rounded-3" required minlength="6">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">Clinic Address</label>
                                <textarea name="address" class="form-control rounded-3" rows="2"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4">Register Doctor</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Doctor Modal -->
    <div class="modal fade" id="editDoctorModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4">
                <form action="doctor-management" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editId">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Edit Doctor Details</h5>
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
                                <input type="email" name="email" id="editEmail" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Specialization</label>
                                <input type="text" name="specialization" id="editSpecialization" class="form-control rounded-3" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Department</label>
                                <select name="departmentId" id="editDeptId" class="form-select rounded-3">
                                    <option value="">Select Department...</option>
                                    <% for (Department dept : departments) { %>
                                        <option value="<%= dept.getId() %>"><%= dept.getName() %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number</label>
                                <input type="text" name="phone" id="editPhone" class="form-control rounded-3">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duty Schedule</label>
                                <input type="text" name="schedule" id="editSchedule" class="form-control rounded-3">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">Clinic Address</label>
                                <textarea name="address" id="editAddress" class="form-control rounded-3" rows="2"></textarea>
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

    <!-- Script to populate edit details -->
    <script>
        function populateEditModal(id, name, email, spec, phone, address, deptId, schedule) {
            document.getElementById('editId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editSpecialization').value = spec;
            document.getElementById('editPhone').value = phone;
            document.getElementById('editAddress').value = address;
            document.getElementById('editDeptId').value = deptId ? deptId : "";
            document.getElementById('editSchedule').value = schedule;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
