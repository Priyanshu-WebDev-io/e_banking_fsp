package com.ebanking.loan;

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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@WebServlet(urlPatterns = {"/loan", "/user/loans"})
public class LoanServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check Bank Admin - send to dedicated bank admin loans desk
        if (session != null && session.getAttribute("bankAdminId") != null) {
            response.sendRedirect(request.getContextPath() + "/bank-admin/loans");
            return;
        }

        // Platform admin cannot manage loans - redirect to platform commission dashboard
        if (session != null && session.getAttribute("adminId") != null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=loans_managed_by_bank_admin");
            return;
        }

        // Check Customer
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        List<Map<String, Object>> userAccounts = new ArrayList<>();
        List<Map<String, Object>> loanProducts = new ArrayList<>();
        List<Map<String, Object>> userLoans = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Fetch user's active bank accounts
            String accSql = """
                    SELECT a.account_id, a.account_number, a.account_type, a.balance, a.bank_id,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM accounts a
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE a.user_id = ? AND a.status = 'ACTIVE'
                    ORDER BY a.account_id ASC
                    """;
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> acc = new HashMap<>();
                        acc.put("accountId", rs.getInt("account_id"));
                        acc.put("accountNumber", rs.getString("account_number"));
                        acc.put("accountType", rs.getString("account_type"));
                        acc.put("balance", rs.getBigDecimal("balance"));
                        acc.put("bankId", rs.getInt("bank_id"));
                        acc.put("bankName", rs.getString("bank_name"));
                        acc.put("bankCode", rs.getString("bank_code"));
                        userAccounts.add(acc);
                    }
                }
            }

            // 2. Fetch loan products
            String prodSql = "SELECT * FROM loan_products WHERE status = 'ACTIVE' ORDER BY product_id ASC";
            try (PreparedStatement ps = con.prepareStatement(prodSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> prod = new HashMap<>();
                    prod.put("productId", rs.getInt("product_id"));
                    prod.put("productName", rs.getString("product_name"));
                    prod.put("loanType", rs.getString("loan_type"));
                    prod.put("interestRate", rs.getBigDecimal("interest_rate"));
                    prod.put("minAmount", rs.getBigDecimal("min_amount"));
                    prod.put("maxAmount", rs.getBigDecimal("max_amount"));
                    prod.put("minTenureMonths", rs.getInt("min_tenure_months"));
                    prod.put("maxTenureMonths", rs.getInt("max_tenure_months"));
                    loanProducts.add(prod);
                }
            }

            // 3. Fetch user's loan applications
            String loanSql = """
                    SELECT la.loan_id, la.application_number, la.loan_type, la.principal_amount,
                           la.interest_rate, la.tenure_months, la.monthly_emi, la.total_repayable,
                           la.remaining_balance, la.purpose, la.status, la.remarks, la.disbursed_at,
                           la.created_at, a.account_number,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(lp.product_name, 'Bank Loan') AS product_name
                    FROM loan_applications la
                    JOIN accounts a ON la.account_id = a.account_id
                    JOIN banks b ON la.bank_id = b.bank_id
                    LEFT JOIN loan_products lp ON la.product_id = lp.product_id
                    WHERE la.user_id = ?
                    ORDER BY la.created_at DESC
                    """;
            try (PreparedStatement ps = con.prepareStatement(loanSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> loan = new HashMap<>();
                        loan.put("loanId", rs.getInt("loan_id"));
                        loan.put("applicationNumber", rs.getString("application_number"));
                        loan.put("loanType", rs.getString("loan_type"));
                        loan.put("productName", rs.getString("product_name"));
                        loan.put("principalAmount", rs.getBigDecimal("principal_amount"));
                        loan.put("interestRate", rs.getBigDecimal("interest_rate"));
                        loan.put("tenureMonths", rs.getInt("tenure_months"));
                        loan.put("monthlyEmi", rs.getBigDecimal("monthly_emi"));
                        loan.put("totalRepayable", rs.getBigDecimal("total_repayable"));
                        loan.put("remainingBalance", rs.getBigDecimal("remaining_balance"));
                        loan.put("purpose", rs.getString("purpose"));
                        loan.put("status", rs.getString("status"));
                        loan.put("remarks", rs.getString("remarks"));
                        loan.put("disbursedAt", rs.getTimestamp("disbursed_at"));
                        loan.put("createdAt", rs.getTimestamp("created_at"));
                        loan.put("accountNumber", rs.getString("account_number"));
                        loan.put("bankName", rs.getString("bank_name"));
                        userLoans.add(loan);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error loading loans: " + e.getMessage());
        }

        request.setAttribute("userAccounts", userAccounts);
        request.setAttribute("loanProducts", loanProducts);
        request.setAttribute("loans", userLoans);

        request.getRequestDispatcher("/user/loans.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        String action = request.getParameter("action");

        // Action 1: Bank Admin Loan Review (Approve / Reject)
        if ("review".equalsIgnoreCase(action)) {
            if (session == null || session.getAttribute("bankAdminId") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
                return;
            }
            handleAdminReview(request, response);
            return;
        }

        // Action 2: Customer Loan Application
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        if ("apply".equalsIgnoreCase(action)) {
            handleCustomerApply(request, response, userId);
        } else {
            response.sendRedirect(request.getContextPath() + "/user/loans");
        }
    }

    private void handleCustomerApply(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {

        String accountIdStr = request.getParameter("accountId");
        String productIdStr = request.getParameter("productId");
        String amountStr = request.getParameter("amount");
        String tenureStr = request.getParameter("tenureMonths");
        String purpose = request.getParameter("purpose");

        if (accountIdStr == null || productIdStr == null || amountStr == null || tenureStr == null) {
            response.sendRedirect(request.getContextPath() + "/user/loans?error=missing_fields");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            int accountId = Integer.parseInt(accountIdStr.trim());
            int productId = Integer.parseInt(productIdStr.trim());
            BigDecimal principal = new BigDecimal(amountStr.trim());
            int tenureMonths = Integer.parseInt(tenureStr.trim());

            // 1. Verify account ownership and get bank_id
            int bankId = 1;
            String accSql = "SELECT bank_id FROM accounts WHERE account_id = ? AND user_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, accountId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bankId = rs.getInt("bank_id");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/user/loans?error=invalid_account");
                        return;
                    }
                }
            }

            // 2. Fetch loan product terms
            BigDecimal interestRate = new BigDecimal("10.50");
            String loanType = "PERSONAL";
            String prodSql = "SELECT interest_rate, loan_type, min_amount, max_amount, min_tenure_months, max_tenure_months FROM loan_products WHERE product_id = ?";
            try (PreparedStatement ps = con.prepareStatement(prodSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        interestRate = rs.getBigDecimal("interest_rate");
                        loanType = rs.getString("loan_type");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/user/loans?error=invalid_product");
                        return;
                    }
                }
            }

            // 3. Compute Monthly EMI
            // Standard formula: EMI = P * r * (1 + r)^n / ((1 + r)^n - 1)
            double p = principal.doubleValue();
            double annualR = interestRate.doubleValue() / 100.0;
            double monthlyR = annualR / 12.0;
            double emiCalc = (p * monthlyR * Math.pow(1 + monthlyR, tenureMonths)) / (Math.pow(1 + monthlyR, tenureMonths) - 1);
            if (Double.isNaN(emiCalc) || Double.isInfinite(emiCalc)) {
                emiCalc = (p + (p * annualR * (tenureMonths / 12.0))) / tenureMonths;
            }

            BigDecimal monthlyEmi = BigDecimal.valueOf(emiCalc).setScale(2, RoundingMode.HALF_UP);
            BigDecimal totalRepayable = monthlyEmi.multiply(BigDecimal.valueOf(tenureMonths)).setScale(2, RoundingMode.HALF_UP);

            // 4. Generate Application Number
            Random rand = new Random();
            long suffix = 10000L + rand.nextInt(90000);
            String appNumber = "LNAPP" + System.currentTimeMillis() % 1000000L + suffix;

            // 5. Insert Application
            String insertSql = """
                    INSERT INTO loan_applications
                    (application_number, user_id, account_id, bank_id, product_id, loan_type,
                     principal_amount, interest_rate, tenure_months, monthly_emi, total_repayable,
                     remaining_balance, purpose, status)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')
                    """;
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setString(1, appNumber);
                ps.setInt(2, userId);
                ps.setInt(3, accountId);
                ps.setInt(4, bankId);
                ps.setInt(5, productId);
                ps.setString(6, loanType);
                ps.setBigDecimal(7, principal);
                ps.setBigDecimal(8, interestRate);
                ps.setInt(9, tenureMonths);
                ps.setBigDecimal(10, monthlyEmi);
                ps.setBigDecimal(11, totalRepayable);
                ps.setBigDecimal(12, totalRepayable);
                ps.setString(13, purpose != null ? purpose.trim() : "Personal Purpose");
                ps.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/user/loans?success=applied&ref=" + appNumber);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user/loans?error=" +
                    java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Application failed", "UTF-8"));
        }
    }

    private void handleAdminReview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

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
                // Fetch loan details and lock
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

                // Disburse loan into customer account
                String creditSql = "UPDATE accounts SET balance = balance + ? WHERE account_id = ?";
                try (PreparedStatement ps = con.prepareStatement(creditSql)) {
                    ps.setBigDecimal(1, principal);
                    ps.setInt(2, accountId);
                    ps.executeUpdate();
                }

                // Generate ledger transaction for disbursement
                String refNo = "TXNDSB" + System.currentTimeMillis() % 10000000L + (10000 + new Random().nextInt(90000));
                String transSql = """
                        INSERT INTO transactions
                        (reference_number, from_account_id, to_account_id, amount, transaction_type, status, description)
                        VALUES (?, NULL, ?, ?, 'DEPOSIT', 'SUCCESS', ?)
                        """;
                int transId = 0;
                try (PreparedStatement ps = con.prepareStatement(transSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
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

                // Record Platform Commission for Loan Sanctioned
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
                        .divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);

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

                // Update loan application status to DISBURSED
                String updateLoanSql = """
                        UPDATE loan_applications
                        SET status = 'DISBURSED', remarks = ?, disbursed_at = CURRENT_TIMESTAMP
                        WHERE loan_id = ?
                        """;
                try (PreparedStatement ps = con.prepareStatement(updateLoanSql)) {
                    ps.setString(1, remarks != null && !remarks.trim().isEmpty() ? remarks.trim() : "Approved & Disbursed by Bank Administrator");
                    ps.setInt(2, loanId);
                    ps.executeUpdate();
                }

                con.commit();
                response.sendRedirect(request.getContextPath() + "/bank-admin/loans?success=loan_approved");
                return;

            } else if ("REJECT".equalsIgnoreCase(decision)) {
                String rejectSql = "UPDATE loan_applications SET status = 'REJECTED', remarks = ? WHERE loan_id = ?";
                try (PreparedStatement ps = con.prepareStatement(rejectSql)) {
                    ps.setString(1, remarks != null && !remarks.trim().isEmpty() ? remarks.trim() : "Application criteria not met");
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
