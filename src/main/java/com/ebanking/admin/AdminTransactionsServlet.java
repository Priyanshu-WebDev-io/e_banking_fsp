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

@WebServlet("/admin/transactions")
public class AdminTransactionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String typeFilter = request.getParameter("type");

        int totalTransactions = 0;
        BigDecimal totalCommissions = BigDecimal.ZERO;
        BigDecimal totalVolume = BigDecimal.ZERO;

        List<Map<String, Object>> transactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            String metricSql = "SELECT COUNT(*), COALESCE(SUM(amount), 0) FROM transactions";
            try (PreparedStatement ps = con.prepareStatement(metricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTransactions = rs.getInt(1);
                    totalVolume = rs.getBigDecimal(2);
                }
            }

            String commMetricSql = "SELECT COALESCE(SUM(commission_amount), 0) FROM commissions";
            try (PreparedStatement ps = con.prepareStatement(commMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCommissions = rs.getBigDecimal(1);
                }
            }

            // 2. Transactions List
            StringBuilder sql = new StringBuilder("""
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
                    WHERE 1=1
                    """);

            boolean hasTypeFilter = (typeFilter != null && !typeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(typeFilter));
            if (hasTypeFilter) {
                sql.append(" AND t.transaction_type = ? ");
            }
            sql.append(" ORDER BY t.created_at DESC LIMIT 100");

            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                if (hasTypeFilter) {
                    ps.setString(1, typeFilter.trim().toUpperCase());
                }

                try (ResultSet rs = ps.executeQuery()) {
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
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalTransactions", totalTransactions);
        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("totalVolume", totalVolume != null ? totalVolume : BigDecimal.ZERO);
        request.setAttribute("transactions", transactions);
        request.setAttribute("selectedType", typeFilter);

        request.getRequestDispatcher("/admin/transactions.jsp").forward(request, response);
    }
}
