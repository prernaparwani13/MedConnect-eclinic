<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Medconnect.DAO.*" %>
<%@ page import="com.Medconnect.Model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Session validation
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("userId") == null || !"receptionist".equals(role)) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }

    BillDAO billDAO = new BillDAO();
    PatientDAO patientDAO = new PatientDAO();
    AppointmentDAO appointmentDAO = new AppointmentDAO();

    List<Bill> bills = billDAO.getAllBills();
    List<Patient> patients = patientDAO.getAllPatients();
    List<Appointment> appointments = appointmentDAO.getAllAppointments();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoices & Billing - MedConnect</title>
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
        .badge-status.paid { background-color: rgba(16, 185, 129, 0.1); color: #10b981; }
        .badge-status.unpaid { background-color: rgba(239, 68, 68, 0.1); color: #ef4444; }
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
                    <a href="appointments.jsp" class="sidebar-menu-link">
                        <i class="bi bi-calendar-check"></i>
                        <span>Appointments</span>
                    </a>
                </li>
                <li class="sidebar-menu-item">
                    <a href="bills.jsp" class="sidebar-menu-link active">
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
                    <h2 class="fw-bold m-0 text-slate-800">Billing Registry</h2>
                    <p class="text-muted m-0">Generate hospital checkup invoices and update payment clearings</p>
                </div>
                <div>
                    <button class="btn btn-emerald btn-success rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#generateBillModal">
                        <i class="bi bi-file-earmark-plus me-2"></i>Generate Bill
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

            <!-- Bills list -->
            <div class="data-card">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Invoice ID</th>
                                <th>Patient Name</th>
                                <th>Consultation Fee</th>
                                <th>Treatment Fee</th>
                                <th>Medicine Fee</th>
                                <th>Other Charges</th>
                                <th>Total Bill</th>
                                <th>Status</th>
                                <th>Date Generated</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (bills == null || bills.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="10" class="text-center py-4 text-muted">No bills generated yet.</td>
                                </tr>
                            <%
                                } else {
                                    for (Bill b : bills) {
                            %>
                                <tr>
                                    <td><strong>INV-<%= b.getId() %></strong></td>
                                    <td class="fw-semibold"><%= b.getPatientName() %></td>
                                    <td>$<%= b.getConsultationFee() %></td>
                                    <td>$<%= b.getTreatmentFee() %></td>
                                    <td>$<%= b.getMedicineFee() %></td>
                                    <td>$<%= b.getOtherCharges() %></td>
                                    <td class="text-primary fw-bold">$<%= b.getTotalAmount() %></td>
                                    <td>
                                        <span class="badge-status <%= b.getPaymentStatus().toLowerCase() %>">
                                            <%= b.getPaymentStatus() %>
                                        </span>
                                    </td>
                                    <td><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(b.getCreatedAt()) %></td>
                                    <td>
                                        <% if ("Unpaid".equals(b.getPaymentStatus())) { %>
                                            <button class="btn btn-sm btn-outline-success me-1 rounded-3" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#payBillModal"
                                                    onclick="populatePayModal(<%= b.getId() %>, '<%= b.getPatientName() %>', '<%= b.getTotalAmount() %>')">
                                                Collect Payment
                                            </button>
                                        <% } %>
                                        <button class="btn btn-sm btn-outline-secondary rounded-3" onclick="printReceipt(<%= b.getId() %>, '<%= b.getPatientName() %>', <%= b.getConsultationFee() %>, <%= b.getTreatmentFee() %>, <%= b.getMedicineFee() %>, <%= b.getOtherCharges() %>, <%= b.getTotalAmount() %>, '<%= b.getPaymentStatus() %>', '<%= b.getPaymentMethod() != null ? b.getPaymentMethod() : "N/A" %>', '<%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(b.getCreatedAt()) %>')">
                                            <i class="bi bi-printer"></i> Print
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

    <!-- Generate Bill Modal -->
    <div class="modal fade" id="generateBillModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="bill-management" method="POST" id="generateForm">
                    <input type="hidden" name="action" value="generate">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Generate Invoice</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <div class="mb-3">
                            <label class="form-label">Select Patient</label>
                            <select name="patientId" class="form-select rounded-3" required>
                                <option value="">Select Patient...</option>
                                <% for (Patient p : patients) { %>
                                    <% if (p.getUserId() != null) { %>
                                        <option value="<%= p.getUserId() %>"><%= p.getName() %></option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Link Appointment (Optional)</label>
                            <select name="appointmentId" class="form-select rounded-3">
                                <option value="">Select Appointment...</option>
                                <% for (Appointment appt : appointments) { %>
                                    <option value="<%= appt.getId() %>"><%= appt.getPatientName() %> with <%= appt.getDoctorName() %> (<%= new SimpleDateFormat("yyyy-MM-dd").format(appt.getAppointmentDate()) %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Consultation Fee ($)</label>
                                <input type="number" step="0.01" name="consultationFee" class="form-control rounded-3" required value="0.00">
                            </div>
                            <div class="col-6">
                                <label class="form-label">Treatment Fee ($)</label>
                                <input type="number" step="0.01" name="treatmentFee" class="form-control rounded-3" required value="0.00">
                            </div>
                            <div class="col-6">
                                <label class="form-label">Medicine Fee ($)</label>
                                <input type="number" step="0.01" name="medicineFee" class="form-control rounded-3" required value="0.00">
                            </div>
                            <div class="col-6">
                                <label class="form-label">Other Charges ($)</label>
                                <input type="number" step="0.01" name="otherCharges" class="form-control rounded-3" required value="0.00">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Payment Status</label>
                            <select name="paymentStatus" class="form-select rounded-3" required>
                                <option value="Unpaid">Unpaid</option>
                                <option value="Paid">Paid</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Payment Method</label>
                            <select name="paymentMethod" class="form-select rounded-3">
                                <option value="Cash">Cash</option>
                                <option value="Card">Card</option>
                                <option value="Online">Online</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success rounded-pill px-4">Generate</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Pay Bill Modal -->
    <div class="modal fade" id="payBillModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4">
                <form action="bill-management" method="POST">
                    <input type="hidden" name="action" value="pay">
                    <input type="hidden" name="id" id="payBillId">
                    <input type="hidden" name="paymentStatus" value="Paid">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold">Collect Payment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body py-0 px-4">
                        <p class="mb-3">Updating invoice status to <strong>Paid</strong>.</p>
                        <div class="mb-3">
                            <label class="form-label">Patient Name</label>
                            <input type="text" class="form-control rounded-3 bg-light" id="payPatientName" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Total Amount Due ($)</label>
                            <input type="text" class="form-control rounded-3 bg-light fw-bold text-success" id="payTotalAmount" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Select Payment Method</label>
                            <select name="paymentMethod" class="form-select rounded-3" required>
                                <option value="Cash">Cash</option>
                                <option value="Card">Card</option>
                                <option value="Online">Online</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pb-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success rounded-pill px-4">Submit Payment</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function populatePayModal(id, name, amount) {
            document.getElementById('payBillId').value = id;
            document.getElementById('payPatientName').value = name;
            document.getElementById('payTotalAmount').value = "$" + amount;
        }

        function printReceipt(id, name, consult, treatment, medicine, other, total, status, method, date) {
            const printWindow = window.open('', '_blank', 'width=800,height=600');
            printWindow.document.write(`
                <html>
                <head>
                    <title>Invoice Receipt - INV-\${id}</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                    <style>
                        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 40px; }
                        .invoice-header { border-bottom: 2px solid #0d6efd; padding-bottom: 20px; margin-bottom: 30px; }
                        .item-table th { background: #f8f9fa; }
                    </style>
                </head>
                <body>
                    <div class="invoice-header d-flex justify-content-between align-items-center">
                        <div>
                            <h2 class="text-primary fw-bold mb-1">MedConnect Hospital</h2>
                            <p class="text-muted mb-0">Indore, MP, India | +91 9876543210</p>
                        </div>
                        <div class="text-end">
                            <h4 class="fw-bold mb-1">INVOICE RECEIPT</h4>
                            <p class="text-muted mb-0">Invoice No: <strong>INV-\${id}</strong></p>
                            <p class="text-muted mb-0">Date: \${date}</p>
                        </div>
                    </div>

                    <div class="row mb-4">
                        <div class="col-6">
                            <h6 class="text-muted mb-1">Billed To:</h6>
                            <h5 class="fw-semibold">\${name}</h5>
                        </div>
                        <div class="col-6 text-end">
                            <h6 class="text-muted mb-1">Payment Status:</h6>
                            <span class="badge bg-\${status === 'Paid' ? 'success' : 'danger'} fs-6">\${status}</span>
                            <p class="text-muted small mt-1">Method: \${method}</p>
                        </div>
                    </div>

                    <table class="table table-bordered item-table mb-4">
                        <thead>
                            <tr>
                                <th>Item Description</th>
                                <th class="text-end" style="width: 150px;">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Doctor Consultation Fee</td>
                                <td class="text-end">$\${consult.toFixed(2)}</td>
                            </tr>
                            <tr>
                                <td>Clinical Treatment Fee</td>
                                <td class="text-end">$\${treatment.toFixed(2)}</td>
                            </tr>
                            <tr>
                                <td>Prescribed Medicines Fee</td>
                                <td class="text-end">$\${medicine.toFixed(2)}</td>
                            </tr>
                            <tr>
                                <td>Miscellaneous Hospital Charges</td>
                                <td class="text-end">$\${other.toFixed(2)}</td>
                            </tr>
                            <tr class="table-light">
                                <td class="fw-bold text-end">Grand Total</td>
                                <td class="fw-bold text-end text-primary">$\${total.toFixed(2)}</td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="text-center mt-5 text-muted small">
                        <p>Thank you for choosing MedConnect. Wishing you good health!</p>
                        <button class="btn btn-primary btn-sm mt-3 d-print-none" onclick="window.print()">Print Invoice</button>
                    </div>
                </body>
                </html>
            `);
            printWindow.document.close();
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
