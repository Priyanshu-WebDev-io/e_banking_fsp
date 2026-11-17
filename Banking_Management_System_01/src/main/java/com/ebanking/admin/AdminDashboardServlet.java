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
        BigDecimal totalDeposits = BigDecimal.ZERO;

        List<Map<String, Object>> customers = new ArrayList<>();
        List<Map<String, Object>> accounts = new ArrayList<>();

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

        } catch (SQLException e) {
            log("Error fetching admin dashboard data", e);
            request.setAttribute("dbError", "Unable to load dashboard data from database.");
        }

        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalBanks", totalBanks);
        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);
        request.setAttribute("customers", customers);
        request.setAttribute("accounts", accounts);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
