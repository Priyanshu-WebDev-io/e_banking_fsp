package com.ebanking.bankadmin;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@WebServlet("/bank-admin/loans")
public class BankAdminLoansServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        Integer assignedBankId = (Integer) session.getAttribute("bankAdminBankId");
        String statusFilter = request.getParameter("status");

        int totalLoans = 0;
        int pendingLoans = 0;
        int disbursedLoans = 0;
        int rejectedLoans = 0;
        BigDecimal totalDisbursedAmount = BigDecimal.ZERO;

        List<Map<String, Object>> loans = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            StringBuilder metricSql = new StringBuilder("""
                    SELECT COUNT(*),
                           COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0)
                    FROM loan_applications
                    WHERE 1=1
                    """);
            if (assignedBankId != null) {
                metricSql.append(" AND bank_id = ?");
            }

            try (PreparedStatement ps = con.prepareStatement(metricSql.toString())) {
                if (assignedBankId != null) {
                    ps.setInt(1, assignedBankId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        pendingLoans = rs.getInt(2);
                        disbursedLoans = rs.getInt(3);
                        rejectedLoans = rs.getInt(4);
                        totalDisbursedAmount = rs.getBigDecimal(5);
                    }
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

            List<Object> params = new ArrayList<>();

            if (assignedBankId != null) {
                sql.append(" AND la.bank_id = ? ");
                params.add(assignedBankId);
            }

            boolean hasStatusFilter = (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter));
            if (hasStatusFilter) {
                sql.append(" AND la.status = ? ");
                params.add(statusFilter.trim().toUpperCase());
            }

            sql.append(" ORDER BY CASE WHEN la.status = 'PENDING' THEN 0 ELSE 1 END, la.created_at DESC");

            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
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

        request.getRequestDispatcher("/bank-admin/loans.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        String adminName = (String) session.getAttribute("bankAdminName");
        String loanIdStr = request.getParameter("loanId");
        String decision = request.getParameter("decision");
        String remarks = request.getParameter("remarks");

        if (loanIdStr == null || decision == null) {
            response.sendRedirect(request.getContextPath() + "/bank-admin/loans");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            int loanId = Integer.parseInt(loanIdStr.trim());

            if ("APPROVE".equalsIgnoreCase(decision)) {
                int accountId = 0;
                int bankId = 0;
                BigDecimal principal = BigDecimal.ZERO;
                String appNumber = "";

                String lockSql = "SELECT account_id, bank_id, principal_amount, application_number FROM loan_applications WHERE loan_id = ? AND status = 'PENDING' FOR UPDATE";
                try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                    ps.setInt(1, loanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            accountId = rs.getInt("account_id");
                            bankId = rs.getInt("bank_id");
                            principal = rs.getBigDecimal("principal_amount");
                            appNumber = rs.getString("application_number");
                        } else {
                            con.rollback();
                            response.sendRedirect(request.getContextPath() + "/bank-admin/loans?error=loan_not_pending");
                            return;
                        }
                    }
                }

                // 1. Credit customer account
                String creditSql = "UPDATE accounts SET balance = balance + ? WHERE account_id = ?";
                try (PreparedStatement ps = con.prepareStatement(creditSql)) {
                    ps.setBigDecimal(1, principal);
                    ps.setInt(2, accountId);
                    ps.executeUpdate();
                }

                // 2. Ledger transaction for disbursal
                String refNo = "TXNDSB" + System.currentTimeMillis() % 10000000L + (10000 + new Random().nextInt(90000));
                String transSql = """
                        INSERT INTO transactions
                        (reference_number, from_account_id, to_account_id, amount, transaction_type, status, description)
                        VALUES (?, NULL, ?, ?, 'DEPOSIT', 'SUCCESS', ?)
                        """;
                int transId = 0;
                try (PreparedStatement ps = con.prepareStatement(transSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, refNo);
                    ps.setInt(2, accountId);
                    ps.setBigDecimal(3, principal);
                    ps.setString(4, "Loan Disbursal Credit (Ref: " + appNumber + ")");
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            transId = rs.getInt(1);
                        }
                    }
                }

                // 3. Record Platform Commission for Loan Sanctioned
                BigDecimal commRate = new BigDecimal("0.50");
                if (bankId > 0) {
                    String rateSql = "SELECT commission_rate FROM banks WHERE bank_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(rateSql)) {
                        ps.setInt(1, bankId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                commRate = rs.getBigDecimal("commission_rate");
                            }
                        }
                    }
                }

                BigDecimal loanCommission = principal.multiply(commRate)
                        .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);

                if (transId > 0 && bankId > 0 && loanCommission.compareTo(BigDecimal.ZERO) > 0) {
                    String commSql = """
                            INSERT INTO commissions (bank_id, transaction_id, commission_rate, commission_amount)
                            VALUES (?, ?, ?, ?)
                            """;
                    try (PreparedStatement ps = con.prepareStatement(commSql)) {
                        ps.setInt(1, bankId);
                        ps.setInt(2, transId);
                        ps.setBigDecimal(3, commRate);
                        ps.setBigDecimal(4, loanCommission);
                        ps.executeUpdate();
                    }
                }

                // 4. Update loan application status to DISBURSED
                String updateLoanSql = """
                        UPDATE loan_applications
                        SET status = 'DISBURSED', remarks = ?, disbursed_at = CURRENT_TIMESTAMP
                        WHERE loan_id = ?
                        """;
                try (PreparedStatement ps = con.prepareStatement(updateLoanSql)) {
                    String reviewerRemark = (remarks != null && !remarks.trim().isEmpty())
                            ? remarks.trim()
                            : "Approved & Disbursed by Bank Administrator (" + (adminName != null ? adminName : "Bank Admin") + ")";
                    ps.setString(1, reviewerRemark);
                    ps.setInt(2, loanId);
                    ps.executeUpdate();
                }

                con.commit();
                response.sendRedirect(request.getContextPath() + "/bank-admin/loans?success=loan_approved");
                return;

            } else if ("REJECT".equalsIgnoreCase(decision)) {
                String rejectSql = "UPDATE loan_applications SET status = 'REJECTED', remarks = ? WHERE loan_id = ?";
                try (PreparedStatement ps = con.prepareStatement(rejectSql)) {
                    String rejectRemark = (remarks != null && !remarks.trim().isEmpty())
                            ? remarks.trim()
                            : "Application criteria not met (Rejected by Bank Admin)";
                    ps.setString(1, rejectRemark);
                    ps.setInt(2, loanId);
                    ps.executeUpdate();
                }
                con.commit();
                response.sendRedirect(request.getContextPath() + "/bank-admin/loans?success=loan_rejected");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/bank-admin/loans?error=" +
                    java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Review failed", "UTF-8"));
        }
    }
}
