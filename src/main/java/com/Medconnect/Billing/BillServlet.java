package com.Medconnect.Billing;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.Medconnect.DAO.BillDAO;
import com.Medconnect.Model.Bill;

@WebServlet({"/receptionist/bill-management", "/admin/bill-management"})
public class BillServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BillDAO billDAO = new BillDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("bills.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String redirectPage = request.getRequestURI().contains("/admin/") ? "../admin/bills.jsp" : "bills.jsp";
        try {
            if ("generate".equals(action)) {
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                String apptIdStr = request.getParameter("appointmentId");
                
                Integer appointmentId = null;
                if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                    appointmentId = Integer.parseInt(apptIdStr);
                }

                BigDecimal consultationFee = new BigDecimal(request.getParameter("consultationFee"));
                BigDecimal treatmentFee = new BigDecimal(request.getParameter("treatmentFee"));
                BigDecimal medicineFee = new BigDecimal(request.getParameter("medicineFee"));
                BigDecimal otherCharges = new BigDecimal(request.getParameter("otherCharges"));
                
                BigDecimal totalAmount = consultationFee.add(treatmentFee).add(medicineFee).add(otherCharges);
                String paymentStatus = request.getParameter("paymentStatus");
                String paymentMethod = request.getParameter("paymentMethod");

                Bill bill = new Bill(0, patientId, appointmentId, consultationFee, treatmentFee, medicineFee, otherCharges, totalAmount, paymentStatus, paymentMethod, null);
                boolean success = billDAO.generateBill(bill);
                
                if (success) {
                    response.sendRedirect(redirectPage + "?msg=Bill generated successfully.");
                } else {
                    request.setAttribute("error", "Failed to generate bill.");
                    request.getRequestDispatcher(redirectPage).forward(request, response);
                }
            } else if ("pay".equals(action)) {
                int billId = Integer.parseInt(request.getParameter("id"));
                String paymentStatus = request.getParameter("paymentStatus");
                String paymentMethod = request.getParameter("paymentMethod");

                boolean success = billDAO.updatePaymentStatus(billId, paymentStatus, paymentMethod);
                if (success) {
                    response.sendRedirect(redirectPage + "?msg=Payment status updated successfully.");
                } else {
                    request.setAttribute("error", "Failed to update payment status.");
                    request.getRequestDispatcher(redirectPage).forward(request, response);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(redirectPage).forward(request, response);
        }
    }
}
