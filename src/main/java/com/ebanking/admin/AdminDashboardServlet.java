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
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Platform Admin Dashboard Servlet:
 * Exclusively focused on Platform Commissions, Commission Revenue, Partner Bank Commission Yields,
 * and transaction fee tracking.
 * All accounts, loans, and cards management is delegated to Bank Administrators.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=platform_admin");
            return;
        }

        BigDecimal totalCommissions = BigDecimal.ZERO;
        BigDecimal totalVolume = BigDecimal.ZERO;
        int totalTransactions = 0;
        int totalBanks = 0;
        BigDecimal avgCommissionRate = BigDecimal.ZERO;

        List<Map<String, Object>> bankBreakdown = new ArrayList<>();
        List<Map<String, Object>> recentCommissions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metric: Total Platform Commissions Generated
            String commMetricSql = "SELECT COALESCE(SUM(commission_amount), 0) FROM commissions";
            try (PreparedStatement ps = con.prepareStatement(commMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCommissions = rs.getBigDecimal(1);
                }
            }

            // 2. Metric: Total Transactions & Total Transaction Volume
            String transMetricSql = "SELECT COUNT(*), COALESCE(SUM(amount), 0) FROM transactions";
            try (PreparedStatement ps = con.prepareStatement(transMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTransactions = rs.getInt(1);
                    totalVolume = rs.getBigDecimal(2);
                }
            }

            // 3. Metric: Active Partner Banks & Average Commission Rate
            String bankMetricSql = "SELECT COUNT(*), COALESCE(AVG(commission_rate), 0) FROM banks WHERE status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(bankMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalBanks = rs.getInt(1);
                    avgCommissionRate = rs.getBigDecimal(2).setScale(2, RoundingMode.HALF_UP);
                }
            }

            // 4. Partner Banks Commission Breakdown
            String bankBreakdownSql = """
                    SELECT b.bank_id, b.bank_name, b.bank_code, b.commission_rate, b.status,
                           (SELECT COUNT(*) FROM accounts a WHERE a.bank_id = b.bank_id) AS account_count,
                           (SELECT COALESCE(SUM(a.balance), 0) FROM accounts a WHERE a.bank_id = b.bank_id) AS total_deposits,
                           (SELECT COALESCE(SUM(c.commission_amount), 0)
                            FROM commissions c
                            JOIN transactions t ON c.transaction_id = t.transaction_id
                            JOIN accounts fa ON t.from_account_id = fa.account_id
                            WHERE fa.bank_id = b.bank_id) AS total_commissions_generated,
                           (SELECT COUNT(c.commission_id)
                            FROM commissions c
                            JOIN transactions t ON c.transaction_id = t.transaction_id
                            JOIN accounts fa ON t.from_account_id = fa.account_id
                            WHERE fa.bank_id = b.bank_id) AS commission_trans_count
                    FROM banks b
                    ORDER BY total_commissions_generated DESC, b.bank_id ASC
                    """;
            try (PreparedStatement ps = con.prepareStatement(bankBreakdownSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("bankId", rs.getInt("bank_id"));
                    row.put("bankName", rs.getString("bank_name"));
                    row.put("bankCode", rs.getString("bank_code"));
                    row.put("commissionRate", rs.getBigDecimal("commission_rate"));
                    row.put("status", rs.getString("status"));
                    row.put("accountCount", rs.getInt("account_count"));
                    row.put("totalDeposits", rs.getBigDecimal("total_deposits"));
                    row.put("commissionsGenerated", rs.getBigDecimal("total_commissions_generated"));
                    row.put("commissionTransCount", rs.getInt("commission_trans_count"));
                    bankBreakdown.add(row);
                }
            }

            // 5. Recent Platform Commission Events (Top 10)
            String recentCommSql = """
                    SELECT c.commission_id, c.commission_rate, c.commission_amount, c.created_at,
                           t.reference_number, t.amount AS transaction_amount, t.transaction_type,
                           COALESCE(fb.bank_name, 'Partner Bank') AS from_bank_name,
                           COALESCE(tb.bank_name, 'Partner Bank') AS to_bank_name
                    FROM commissions c
                    JOIN transactions t ON c.transaction_id = t.transaction_id
                    LEFT JOIN accounts fa ON t.from_account_id = fa.account_id
                    LEFT JOIN banks fb ON fa.bank_id = fb.bank_id
                    LEFT JOIN accounts ta ON t.to_account_id = ta.account_id
                    LEFT JOIN banks tb ON ta.bank_id = tb.bank_id
                    ORDER BY c.created_at DESC LIMIT 10
                    """;
            try (PreparedStatement ps = con.prepareStatement(recentCommSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> r = new HashMap<>();
                    r.put("commissionId", rs.getInt("commission_id"));
                    r.put("referenceNumber", rs.getString("reference_number"));
                    r.put("transactionAmount", rs.getBigDecimal("transaction_amount"));
                    r.put("transactionType", rs.getString("transaction_type"));
                    r.put("commissionRate", rs.getBigDecimal("commission_rate"));
                    r.put("commissionAmount", rs.getBigDecimal("commission_amount"));
                    r.put("fromBankName", rs.getString("from_bank_name"));
                    r.put("toBankName", rs.getString("to_bank_name"));
                    r.put("createdAt", rs.getTimestamp("created_at"));
                    recentCommissions.add(r);
                }
            }

        } catch (SQLException e) {
            log("Error fetching Platform Admin commission dashboard data", e);
            request.setAttribute("dbError", "Unable to load commission dashboard: " + e.getMessage());
        }

        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("totalVolume", totalVolume != null ? totalVolume : BigDecimal.ZERO);
        request.setAttribute("totalTransactions", totalTransactions);
        request.setAttribute("totalBanks", totalBanks);
        request.setAttribute("avgCommissionRate", avgCommissionRate);
        request.setAttribute("bankBreakdown", bankBreakdown);
        request.setAttribute("recentCommissions", recentCommissions);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
