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

@WebServlet("/admin/accounts")
public class AdminAccountsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String bankIdFilter = request.getParameter("bankId");
        String typeFilter = request.getParameter("type");

        int totalAccounts = 0;
        BigDecimal totalDeposits = BigDecimal.ZERO;
        int savingsCount = 0;
        int currentCount = 0;

        List<Map<String, Object>> accounts = new ArrayList<>();
        List<Map<String, Object>> banks = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            String metricSql = """
                    SELECT COUNT(*),
                           COALESCE(SUM(balance), 0),
                           COALESCE(SUM(CASE WHEN account_type = 'SAVINGS' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN account_type = 'CURRENT' THEN 1 ELSE 0 END), 0)
                    FROM accounts
                    """;
            try (PreparedStatement ps = con.prepareStatement(metricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalAccounts = rs.getInt(1);
                    totalDeposits = rs.getBigDecimal(2);
                    savingsCount = rs.getInt(3);
                    currentCount = rs.getInt(4);
                }
            }

            // 2. Banks for filter dropdown
            String bankSql = "SELECT bank_id, bank_name, bank_code FROM banks ORDER BY bank_name ASC";
            try (PreparedStatement ps = con.prepareStatement(bankSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> b = new HashMap<>();
                    b.put("bankId", rs.getInt("bank_id"));
                    b.put("bankName", rs.getString("bank_name"));
                    b.put("bankCode", rs.getString("bank_code"));
                    banks.add(b);
                }
            }

            // 3. Accounts List
            StringBuilder sql = new StringBuilder("""
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           a.branch_name, a.ifsc_code, a.status, a.created_at,
                           u.first_name, u.last_name, u.email,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM accounts a
                    JOIN users u ON a.user_id = u.user_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE 1=1
                    """);

            List<Object> params = new ArrayList<>();
            if (bankIdFilter != null && !bankIdFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(bankIdFilter)) {
                sql.append(" AND a.bank_id = ? ");
                params.add(Integer.parseInt(bankIdFilter.trim()));
            }
            if (typeFilter != null && !typeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(typeFilter)) {
                sql.append(" AND a.account_type = ? ");
                params.add(typeFilter.trim().toUpperCase());
            }

            sql.append(" ORDER BY a.account_id DESC");

            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
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
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);
        request.setAttribute("savingsCount", savingsCount);
        request.setAttribute("currentCount", currentCount);
        request.setAttribute("accounts", accounts);
        request.setAttribute("banks", banks);
        request.setAttribute("selectedBank", bankIdFilter);
        request.setAttribute("selectedType", typeFilter);

        request.getRequestDispatcher("/admin/accounts.jsp").forward(request, response);
    }
}
