package com.ebanking.admin;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/loans")
public class AdminLoansServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String statusFilter = request.getParameter("status");

        int totalLoans = 0;
        int pendingLoans = 0;
        int disbursedLoans = 0;
        int rejectedLoans = 0;
        BigDecimal totalDisbursedAmount = BigDecimal.ZERO;

        List<Map<String, Object>> loans = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            String metricSql = """
                    SELECT COUNT(*),
                           COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0)
                    FROM loan_applications
                    """;
            try (PreparedStatement ps = con.prepareStatement(metricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalLoans = rs.getInt(1);
                    pendingLoans = rs.getInt(2);
                    disbursedLoans = rs.getInt(3);
                    rejectedLoans = rs.getInt(4);
                    totalDisbursedAmount = rs.getBigDecimal(5);
                }
            }

            // 2. Loans List
            StringBuilder sql = new StringBuilder("""
                    SELECT la.loan_id, la.application_number, la.principal_amount, la.tenure_months,
                           la.interest_rate, la.monthly_emi, la.total_repayable, la.purpose, la.status,
                           la.remarks, la.created_at, la.disbursed_at,
                           a.account_number,
                           u.first_name, u.last_name, u.email, u.phone,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(lp.product_name, CONCAT(la.loan_type, ' Loan')) AS product_name
                    FROM loan_applications la
                    JOIN accounts a ON la.account_id = a.account_id
                    JOIN users u ON la.user_id = u.user_id
                    LEFT JOIN banks b ON la.bank_id = b.bank_id
                    LEFT JOIN loan_products lp ON la.product_id = lp.product_id
                    WHERE 1=1
                    """);

            boolean hasStatusFilter = (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter));
            if (hasStatusFilter) {
                sql.append(" AND la.status = ? ");
            }
            sql.append(" ORDER BY la.created_at DESC");

            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                if (hasStatusFilter) {
                    ps.setString(1, statusFilter.trim().toUpperCase());
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> loan = new HashMap<>();
                        loan.put("loanId", rs.getInt("loan_id"));
                        loan.put("applicationNumber", rs.getString("application_number"));
                        loan.put("principalAmount", rs.getBigDecimal("principal_amount"));
                        loan.put("tenureMonths", rs.getInt("tenure_months"));
                        loan.put("interestRate", rs.getBigDecimal("interest_rate"));
                        loan.put("monthlyEmi", rs.getBigDecimal("monthly_emi"));
                        loan.put("totalRepayable", rs.getBigDecimal("total_repayable"));
                        loan.put("purpose", rs.getString("purpose"));
                        loan.put("status", rs.getString("status"));
                        loan.put("remarks", rs.getString("remarks"));
                        loan.put("createdAt", rs.getTimestamp("created_at"));
                        loan.put("disbursedAt", rs.getTimestamp("disbursed_at"));
                        loan.put("accountNumber", rs.getString("account_number"));
                        loan.put("customerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                        loan.put("customerEmail", rs.getString("email"));
                        loan.put("customerPhone", rs.getString("phone"));
                        loan.put("bankName", rs.getString("bank_name"));
                        loan.put("productName", rs.getString("product_name"));
                        loans.add(loan);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalLoans", totalLoans);
        request.setAttribute("pendingLoans", pendingLoans);
        request.setAttribute("disbursedLoans", disbursedLoans);
        request.setAttribute("rejectedLoans", rejectedLoans);
        request.setAttribute("totalDisbursedAmount", totalDisbursedAmount != null ? totalDisbursedAmount : BigDecimal.ZERO);
        request.setAttribute("loans", loans);
        request.setAttribute("selectedStatus", statusFilter);

        request.getRequestDispatcher("/admin/loans.jsp").forward(request, response);
    }
}
