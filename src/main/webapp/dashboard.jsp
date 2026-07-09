<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Hospital System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .navbar-custom {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        .navbar-brand {
            font-weight: 600;
            color: white !important;
        }
        .dashboard-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 3rem 0;
            margin-bottom: 2rem;
        }
        .welcome-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        .role-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
        }
        .role-admin {
            background: linear-gradient(135deg, #ff6b6b, #ee5a52);
            color: white;
        }
        .role-doctor {
            background: linear-gradient(135deg, #4ecdc4, #44a08d);
            color: white;
        }
        .role-patient {
            background: linear-gradient(135deg, #45b7d1, #96c93d);
            color: white;
        }
        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .card-custom {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: none;
        }
        .card-custom:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }
        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }
        .icon-admin { background: linear-gradient(135deg, #ff6b6b, #ee5a52); color: white; }
        .icon-doctor { background: linear-gradient(135deg, #4ecdc4, #44a08d); color: white; }
        .icon-patient { background: linear-gradient(135deg, #45b7d1, #96c93d); color: white; }
        .icon-general { background: linear-gradient(135deg, #667eea, #764ba2); color: white; }
        .btn-custom {
            border-radius: 25px;
            padding: 0.5rem 1.5rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-custom:hover {
            transform: translateY(-2px);
        }
        .logout-btn {
            background: linear-gradient(135deg, #dc3545, #c82333);
            border: none;
            color: white;
        }
        .logout-btn:hover {
            background: linear-gradient(135deg, #c82333, #a02622);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.4);
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-custom">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="bi bi-hospital me-2"></i>
                Hospital System
            </a>
            <div class="ms-auto">
                <form action="logout" method="post" class="d-inline">
                    <button type="submit" class="btn logout-btn btn-custom">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </button>
                </form>
            </div>
        </div>
    </nav>

    <header class="dashboard-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <h1 class="display-4 fw-bold mb-2">Welcome to Your Dashboard</h1>
                    <p class="lead mb-0">Manage your healthcare needs efficiently and securely</p>
                </div>
                <div class="col-lg-4 text-center">
                    <i class="bi bi-person-circle fs-1 text-white"></i>
                </div>
            </div>
        </div>
    </header>

    <div class="container">
        <div class="welcome-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h2 class="mb-2">Hello, <c:out value="${sessionScope.username}" />!</h2>
                    <p class="mb-3">You are logged in as:
                        <c:choose>
                            <c:when test="${sessionScope.role == 'admin'}">
                                <span class="role-badge role-admin">Administrator</span>
                            </c:when>
                            <c:when test="${sessionScope.role == 'doctor'}">
                                <span class="role-badge role-doctor">Doctor</span>
                            </c:when>
                            <c:otherwise>
                                <span class="role-badge role-patient">Patient</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <p class="text-muted mb-0">Email: <c:out value="${sessionScope.email}" /></p>
                </div>
                <div class="col-md-4 text-center">
                    <c:choose>
                        <c:when test="${sessionScope.role == 'admin'}">
                            <div class="card-icon icon-admin mx-auto">
                                <i class="bi bi-shield-check"></i>
                            </div>
                        </c:when>
                        <c:when test="${sessionScope.role == 'doctor'}">
                            <div class="card-icon icon-doctor mx-auto">
                                <i class="bi bi-heart-pulse"></i>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card-icon icon-patient mx-auto">
                                <i class="bi bi-person"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="dashboard-cards">
            <c:if test="${sessionScope.role == 'admin'}">
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-admin mx-auto">
                            <i class="bi bi-people"></i>
                        </div>
                        <h5 class="card-title">User Management</h5>
                        <p class="card-text">Manage users, roles, and permissions</p>
                        <a href="/admin/users" class="btn btn-primary btn-custom">Manage Users</a>
                    </div>
                </div>
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-admin mx-auto">
                            <i class="bi bi-bar-chart"></i>
                        </div>
                        <h5 class="card-title">Reports</h5>
                        <p class="card-text">View system reports and analytics</p>
                        <a href="/admin/reports" class="btn btn-primary btn-custom">View Reports</a>
                    </div>
                </div>
            </c:if>

            <c:if test="${sessionScope.role == 'doctor'}">
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-doctor mx-auto">
                            <i class="bi bi-calendar-check"></i>
                        </div>
                        <h5 class="card-title">Appointments</h5>
                        <p class="card-text">Manage your patient appointments</p>
                        <a href="/doctor/appointments" class="btn btn-primary btn-custom">View Appointments</a>
                    </div>
                </div>
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-doctor mx-auto">
                            <i class="bi bi-clipboard-data"></i>
                        </div>
                        <h5 class="card-title">Patient Records</h5>
                        <p class="card-text">Access and update patient records</p>
                        <a href="/doctor/patients" class="btn btn-primary btn-custom">View Records</a>
                    </div>
                </div>
            </c:if>

            <c:if test="${sessionScope.role == 'patient' || sessionScope.role == null}">
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-patient mx-auto">
                            <i class="bi bi-calendar-plus"></i>
                        </div>
                        <h5 class="card-title">Book Appointment</h5>
                        <p class="card-text">Schedule an appointment with a doctor</p>
                        <a href="/patient/book-appointment" class="btn btn-primary btn-custom">Book Now</a>
                    </div>
                </div>
                <div class="card card-custom">
                    <div class="card-body text-center">
                        <div class="card-icon icon-patient mx-auto">
                            <i class="bi bi-file-medical"></i>
                        </div>
                        <h5 class="card-title">My Records</h5>
                        <p class="card-text">View your medical records and history</p>
                        <a href="/patient/records" class="btn btn-primary btn-custom">View Records</a>
                    </div>
                </div>
            </c:if>

            <div class="card card-custom">
                <div class="card-body text-center">
                    <div class="card-icon icon-general mx-auto">
                        <i class="bi bi-gear"></i>
                    </div>
                    <h5 class="card-title">Settings</h5>
                    <p class="card-text">Update your profile and preferences</p>
                    <a href="/settings" class="btn btn-secondary btn-custom">Go to Settings</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
