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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/bank-admin/dashboard")
public class BankAdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        Integer bankIdFilter = (Integer) session.getAttribute("bankAdminBankId");

        int totalAccounts = 0;
        BigDecimal totalDeposits = BigDecimal.ZERO;
        int totalLoans = 0;
        int pendingLoans = 0;
        int disbursedLoans = 0;
        BigDecimal totalDisbursedAmount = BigDecimal.ZERO;
        int totalCards = 0;
        int activeCards = 0;
        int blockedCards = 0;
        int totalCustomers = 0;

        List<Map<String, Object>> recentLoans = new ArrayList<>();
        List<Map<String, Object>> recentAccounts = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metric: Total Accounts & Total Deposits
            StringBuilder accSql = new StringBuilder("SELECT COUNT(*), COALESCE(SUM(balance), 0) FROM accounts WHERE 1=1");
            if (bankIdFilter != null) {
                accSql.append(" AND bank_id = ?");
            }
            try (PreparedStatement ps = con.prepareStatement(accSql.toString())) {
                if (bankIdFilter != null) {
                    ps.setInt(1, bankIdFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalAccounts = rs.getInt(1);
                        totalDeposits = rs.getBigDecimal(2);
                    }
                }
            }

            // 2. Metric: Loans
            StringBuilder loanMetricSql = new StringBuilder("""
                    SELECT COUNT(*),
                           COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0)
                    FROM loan_applications
                    WHERE 1=1
                    """);
            if (bankIdFilter != null) {
                loanMetricSql.append(" AND bank_id = ?");
            }
            try (PreparedStatement ps = con.prepareStatement(loanMetricSql.toString())) {
                if (bankIdFilter != null) {
                    ps.setInt(1, bankIdFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        pendingLoans = rs.getInt(2);
                        disbursedLoans = rs.getInt(3);
                        totalDisbursedAmount = rs.getBigDecimal(4);
                    }
                }
            }

            // 3. Metric: Cards
            StringBuilder cardMetricSql = new StringBuilder("""
                    SELECT COUNT(c.card_id),
                           COALESCE(SUM(CASE WHEN c.status = 'ACTIVE' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN c.status = 'BLOCKED' THEN 1 ELSE 0 END), 0)
                    FROM cards c
                    JOIN accounts a ON c.account_id = a.account_id
                    WHERE 1=1
                    """);
            if (bankIdFilter != null) {
                cardMetricSql.append(" AND a.bank_id = ?");
            }
            try (PreparedStatement ps = con.prepareStatement(cardMetricSql.toString())) {
                if (bankIdFilter != null) {
                    ps.setInt(1, bankIdFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                        activeCards = rs.getInt(2);
                        blockedCards = rs.getInt(3);
                    }
                }
            }

            // 4. Metric: Customers
            String custSql = "SELECT COUNT(*) FROM users";
            try (PreparedStatement ps = con.prepareStatement(custSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCustomers = rs.getInt(1);
                }
            }

            // 5. Recent Pending Loans (Top 5)
            StringBuilder recentLoanSql = new StringBuilder("""
                    SELECT la.loan_id, la.application_number, la.principal_amount, la.loan_type,
                           la.status, la.created_at,
                           u.first_name, u.last_name,
                           COALESCE(b.bank_name, 'Bank') AS bank_name
                    FROM loan_applications la
                    JOIN users u ON la.user_id = u.user_id
                    LEFT JOIN banks b ON la.bank_id = b.bank_id
                    WHERE 1=1
                    """);
            if (bankIdFilter != null) {
                recentLoanSql.append(" AND la.bank_id = ?");
            }
            recentLoanSql.append(" ORDER BY la.created_at DESC LIMIT 5");

            try (PreparedStatement ps = con.prepareStatement(recentLoanSql.toString())) {
                if (bankIdFilter != null) {
                    ps.setInt(1, bankIdFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> l = new HashMap<>();
                        l.put("loanId", rs.getInt("loan_id"));
                        l.put("applicationNumber", rs.getString("application_number"));
                        l.put("principalAmount", rs.getBigDecimal("principal_amount"));
                        l.put("loanType", rs.getString("loan_type"));
                        l.put("status", rs.getString("status"));
                        l.put("createdAt", rs.getTimestamp("created_at"));
                        l.put("customerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                        l.put("bankName", rs.getString("bank_name"));
                        recentLoans.add(l);
                    }
                }
            }

            // 6. Recent Bank Accounts (Top 5)
            StringBuilder recentAccSql = new StringBuilder("""
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           a.status, a.created_at,
                           u.first_name, u.last_name,
                           COALESCE(b.bank_name, 'Bank') AS bank_name
                    FROM accounts a
                    JOIN users u ON a.user_id = u.user_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE 1=1
                    """);
            if (bankIdFilter != null) {
                recentAccSql.append(" AND a.bank_id = ?");
            }
            recentAccSql.append(" ORDER BY a.created_at DESC LIMIT 5");

            try (PreparedStatement ps = con.prepareStatement(recentAccSql.toString())) {
                if (bankIdFilter != null) {
                    ps.setInt(1, bankIdFilter);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> a = new HashMap<>();
                        a.put("accountId", rs.getInt("account_id"));
                        a.put("accountNumber", rs.getString("account_number"));
                        a.put("accountType", rs.getString("account_type"));
                        a.put("balance", rs.getBigDecimal("balance"));
                        a.put("status", rs.getString("status"));
                        a.put("createdAt", rs.getTimestamp("created_at"));
                        a.put("customerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                        a.put("bankName", rs.getString("bank_name"));
                        recentAccounts.add(a);
                    }
                }
            }

        } catch (SQLException e) {
            log("Error loading Bank Admin dashboard data", e);
            request.setAttribute("dbError", "Unable to load dashboard data: " + e.getMessage());
        }

        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);
        request.setAttribute("totalLoans", totalLoans);
        request.setAttribute("pendingLoans", pendingLoans);
        request.setAttribute("disbursedLoans", disbursedLoans);
        request.setAttribute("totalDisbursedAmount", totalDisbursedAmount != null ? totalDisbursedAmount : BigDecimal.ZERO);
        request.setAttribute("totalCards", totalCards);
        request.setAttribute("activeCards", activeCards);
        request.setAttribute("blockedCards", blockedCards);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("recentLoans", recentLoans);
        request.setAttribute("recentAccounts", recentAccounts);

        request.getRequestDispatcher("/bank-admin/dashboard.jsp").forward(request, response);
    }
}
