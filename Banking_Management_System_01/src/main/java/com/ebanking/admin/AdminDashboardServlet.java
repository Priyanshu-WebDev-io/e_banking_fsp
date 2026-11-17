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

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
            return;
        }

        int totalCustomers = 0;
        int totalAccounts = 0;
        int totalBanks = 0;
        int totalTransactions = 0;
        BigDecimal totalDeposits = BigDecimal.ZERO;
        BigDecimal totalCommissions = BigDecimal.ZERO;

        List<Map<String, Object>> customers = new ArrayList<>();
        List<Map<String, Object>> accounts = new ArrayList<>();
        List<Map<String, Object>> transactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metric: Total Customers
            String countCustomersSql = "SELECT COUNT(*) FROM users";
            try (PreparedStatement ps = con.prepareStatement(countCustomersSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCustomers = rs.getInt(1);
                }
            }

            // 2. Metric: Total Accounts & Total Deposits
            String countAccountsSql = "SELECT COUNT(*), COALESCE(SUM(balance), 0) FROM accounts";
            try (PreparedStatement ps = con.prepareStatement(countAccountsSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalAccounts = rs.getInt(1);
                    totalDeposits = rs.getBigDecimal(2);
                }
            }

            // 2b. Metric: Total Partner Banks
            String countBanksSql = "SELECT COUNT(*) FROM banks";
            try (PreparedStatement ps = con.prepareStatement(countBanksSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalBanks = rs.getInt(1);
                }
            }

            // 2c. Metric: Total Transactions & Total Commission Revenue
            String transMetricSql = "SELECT COUNT(*) FROM transactions";
            try (PreparedStatement ps = con.prepareStatement(transMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTransactions = rs.getInt(1);
                }
            }

            String commMetricSql = "SELECT COALESCE(SUM(commission_amount), 0) FROM commissions";
            try (PreparedStatement ps = con.prepareStatement(commMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCommissions = rs.getBigDecimal(1);
                }
            }

            // 3. Customers List
            String customersSql = """
                    SELECT user_id, first_name, last_name, email, phone, city, state, status, created_at
                    FROM users
                    ORDER BY user_id DESC
                    """;
            try (PreparedStatement ps = con.prepareStatement(customersSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> c = new HashMap<>();
                    c.put("userId", rs.getInt("user_id"));
                    c.put("firstName", rs.getString("first_name"));
                    c.put("lastName", rs.getString("last_name"));
                    c.put("email", rs.getString("email"));
                    c.put("phone", rs.getString("phone"));
                    c.put("city", rs.getString("city"));
                    c.put("state", rs.getString("state"));
                    c.put("status", rs.getString("status"));
                    c.put("createdAt", rs.getTimestamp("created_at"));
                    customers.add(c);
                }
            }

            // 4. Accounts List with Customer & Bank Info
            String accountsSql = """
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           a.branch_name, a.ifsc_code, a.status, a.created_at,
                           u.first_name, u.last_name, u.email,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM accounts a
                    JOIN users u ON a.user_id = u.user_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    ORDER BY a.account_id DESC
                    """;
            try (PreparedStatement ps = con.prepareStatement(accountsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("accountId", rs.getInt("account_id"));
                    a.put("accountNumber", rs.getString("account_number"));
                    a.put("accountType", rs.getString("account_type"));
                    a.put("balance", rs.getBigDecimal("balance"));
                    a.put("branchName", rs.getString("branch_name"));
                    a.put("ifscCode", rs.getString("ifsc_code"));
                    a.put("status", rs.getString("status"));
                    a.put("createdAt", rs.getTimestamp("created_at"));
                    a.put("customerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                    a.put("customerEmail", rs.getString("email"));
                    a.put("bankName", rs.getString("bank_name"));
                    a.put("bankCode", rs.getString("bank_code"));
                    accounts.add(a);
                }
            }

            // 5. Recent Platform Transactions with Bank Commission Info
            String transactionsSql = """
                    SELECT t.transaction_id, t.reference_number, t.amount, t.transaction_type,
                           t.status, t.description, t.created_at,
                           fa.account_number AS from_account_number,
                           ta.account_number AS to_account_number,
                           COALESCE(fb.bank_name, 'Partner Bank') AS from_bank_name,
                           COALESCE(tb.bank_name, 'Partner Bank') AS to_bank_name,
                           COALESCE(c.commission_amount, 0) AS commission_amount,
                           COALESCE(c.commission_rate, 0) AS commission_rate
                    FROM transactions t
                    LEFT JOIN accounts fa ON t.from_account_id = fa.account_id
                    LEFT JOIN banks fb ON fa.bank_id = fb.bank_id
                    LEFT JOIN accounts ta ON t.to_account_id = ta.account_id
                    LEFT JOIN banks tb ON ta.bank_id = tb.bank_id
                    LEFT JOIN commissions c ON t.transaction_id = c.transaction_id
                    ORDER BY t.created_at DESC
                    LIMIT 50
                    """;
            try (PreparedStatement ps = con.prepareStatement(transactionsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> t = new HashMap<>();
                    t.put("transactionId", rs.getInt("transaction_id"));
                    t.put("referenceNumber", rs.getString("reference_number"));
                    t.put("amount", rs.getBigDecimal("amount"));
                    t.put("transactionType", rs.getString("transaction_type"));
                    t.put("status", rs.getString("status"));
                    t.put("description", rs.getString("description"));
                    t.put("createdAt", rs.getTimestamp("created_at"));
                    t.put("fromAccountNumber", rs.getString("from_account_number"));
                    t.put("toAccountNumber", rs.getString("to_account_number"));
                    t.put("fromBankName", rs.getString("from_bank_name"));
                    t.put("toBankName", rs.getString("to_bank_name"));
                    t.put("commissionAmount", rs.getBigDecimal("commission_amount"));
                    t.put("commissionRate", rs.getBigDecimal("commission_rate"));
                    transactions.add(t);
                }
            }

        } catch (SQLException e) {
            log("Error fetching admin dashboard data", e);
            request.setAttribute("dbError", "Unable to load dashboard data from database.");
        }

        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalBanks", totalBanks);
        request.setAttribute("totalTransactions", totalTransactions);
        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);
        request.setAttribute("customers", customers);
        request.setAttribute("accounts", accounts);
        request.setAttribute("transactions", transactions);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
