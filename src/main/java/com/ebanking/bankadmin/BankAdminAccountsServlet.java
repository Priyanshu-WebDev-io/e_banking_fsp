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

@WebServlet("/bank-admin/accounts")
public class BankAdminAccountsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        Integer assignedBankId = (Integer) session.getAttribute("bankAdminBankId");
        String bankIdParam = request.getParameter("bankId");
        String typeFilter = request.getParameter("type");
        String statusFilter = request.getParameter("status");

        int totalAccounts = 0;
        BigDecimal totalDeposits = BigDecimal.ZERO;
        int savingsCount = 0;
        int currentCount = 0;

        List<Map<String, Object>> accounts = new ArrayList<>();
        List<Map<String, Object>> banks = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Fetch Banks list for dropdown
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

            // 2. Metrics
            StringBuilder metricSql = new StringBuilder("""
                    SELECT COUNT(*),
                           COALESCE(SUM(balance), 0),
                           COALESCE(SUM(CASE WHEN account_type = 'SAVINGS' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN account_type = 'CURRENT' THEN 1 ELSE 0 END), 0)
                    FROM accounts
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
                        totalAccounts = rs.getInt(1);
                        totalDeposits = rs.getBigDecimal(2);
                        savingsCount = rs.getInt(3);
                        currentCount = rs.getInt(4);
                    }
                }
            }

            // 3. Accounts List
            StringBuilder sql = new StringBuilder("""
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           a.branch_name, a.ifsc_code, a.status, a.created_at,
                           u.first_name, u.last_name, u.email, u.phone,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM accounts a
                    JOIN users u ON a.user_id = u.user_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE 1=1
                    """);

            List<Object> params = new ArrayList<>();

            if (assignedBankId != null) {
                sql.append(" AND a.bank_id = ? ");
                params.add(assignedBankId);
            } else if (bankIdParam != null && !bankIdParam.trim().isEmpty() && !"ALL".equalsIgnoreCase(bankIdParam)) {
                sql.append(" AND a.bank_id = ? ");
                params.add(Integer.parseInt(bankIdParam.trim()));
            }

            if (typeFilter != null && !typeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(typeFilter)) {
                sql.append(" AND a.account_type = ? ");
                params.add(typeFilter.trim().toUpperCase());
            }

            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND a.status = ? ");
                params.add(statusFilter.trim().toUpperCase());
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
                        a.put("customerPhone", rs.getString("phone"));
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
        request.setAttribute("selectedBank", bankIdParam);
        request.setAttribute("selectedType", typeFilter);
        request.setAttribute("selectedStatus", statusFilter);

        request.getRequestDispatcher("/bank-admin/accounts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        String accountIdStr = request.getParameter("accountId");
        String action = request.getParameter("action");
        String newStatus = request.getParameter("status");

        if (accountIdStr != null && action != null) {
            try (Connection con = DBConnection.getConnection()) {
                int accountId = Integer.parseInt(accountIdStr.trim());

                if ("toggle_block".equalsIgnoreCase(action)) {
                    String sql = "UPDATE accounts SET status = CASE WHEN status = 'ACTIVE' THEN 'BLOCKED' ELSE 'ACTIVE' END WHERE account_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, accountId);
                        ps.executeUpdate();
                    }
                } else if ("set_status".equalsIgnoreCase(action) && newStatus != null) {
                    String sql = "UPDATE accounts SET status = ? WHERE account_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setString(1, newStatus.trim().toUpperCase());
                        ps.setInt(2, accountId);
                        ps.executeUpdate();
                    }
                }
                response.sendRedirect(request.getContextPath() + "/bank-admin/accounts?success=status_updated");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/bank-admin/accounts?error=" +
                        java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Update failed", "UTF-8"));
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/bank-admin/accounts");
    }
}
