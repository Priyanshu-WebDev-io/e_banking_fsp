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
 * Platform Admin Commission Reports Servlet:
 * Strictly focuses on:
 * 1. Commissions on Loans Sanctioned
 * 2. Commissions on Transactions Being Done
 * 3. Bank-Related Commissions & Institutional Yields
 */
@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=platform_admin");
            return;
        }

        BigDecimal totalCommissions = BigDecimal.ZERO;
        BigDecimal loanCommissions = BigDecimal.ZERO;
        int loanCommissionCount = 0;
        BigDecimal transCommissions = BigDecimal.ZERO;
        int transCommissionCount = 0;

        BigDecimal totalVolume = BigDecimal.ZERO;
        int totalTransactions = 0;
        int totalBanks = 0;
        BigDecimal avgCommissionYield = BigDecimal.ZERO;

        List<Map<String, Object>> bankBreakdown = new ArrayList<>();
        List<Map<String, Object>> topCommissionTransactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Total Platform Commissions
            String commMetricSql = "SELECT COALESCE(SUM(commission_amount), 0) FROM commissions";
            try (PreparedStatement ps = con.prepareStatement(commMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCommissions = rs.getBigDecimal(1);
                }
            }

            // 1a. Commissions on Loans Sanctioned
            String loanCommSql = """
                    SELECT COALESCE(SUM(c.commission_amount), 0), COUNT(c.commission_id)
                    FROM commissions c
                    JOIN transactions t ON c.transaction_id = t.transaction_id
                    WHERE t.description LIKE '%Loan Disbursal%'
                    """;
            try (PreparedStatement ps = con.prepareStatement(loanCommSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    loanCommissions = rs.getBigDecimal(1);
                    loanCommissionCount = rs.getInt(2);
                }
            }

            // 1b. Commissions on Transactions Being Done
            String transCommSql = """
                    SELECT COALESCE(SUM(c.commission_amount), 0), COUNT(c.commission_id)
                    FROM commissions c
                    JOIN transactions t ON c.transaction_id = t.transaction_id
                    WHERE t.description NOT LIKE '%Loan Disbursal%'
                    """;
            try (PreparedStatement ps = con.prepareStatement(transCommSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    transCommissions = rs.getBigDecimal(1);
                    transCommissionCount = rs.getInt(2);
                }
            }

            // 2. Gross Transaction Volume & Count
            String transMetricSql = "SELECT COUNT(*), COALESCE(SUM(amount), 0) FROM transactions";
            try (PreparedStatement ps = con.prepareStatement(transMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTransactions = rs.getInt(1);
                    totalVolume = rs.getBigDecimal(2);
                }
            }

            if (totalVolume.compareTo(BigDecimal.ZERO) > 0) {
                avgCommissionYield = totalCommissions.divide(totalVolume, 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100")).setScale(2, RoundingMode.HALF_UP);
            }

            // 3. Institutional Bank-Related Commission Breakdown
            String bankBreakdownSql = """
                    SELECT b.bank_id, b.bank_name, b.bank_code, b.commission_rate, b.status,
                           (SELECT COUNT(*) FROM accounts a WHERE a.bank_id = b.bank_id) AS account_count,
                           (SELECT COALESCE(SUM(a.balance), 0) FROM accounts a WHERE a.bank_id = b.bank_id) AS total_bank_deposits,
                           (SELECT COALESCE(SUM(c.commission_amount), 0)
                            FROM commissions c
                            JOIN transactions t ON c.transaction_id = t.transaction_id
                            JOIN accounts fa ON t.from_account_id = fa.account_id
                            WHERE fa.bank_id = b.bank_id) AS total_commissions_generated,
                           (SELECT COALESCE(SUM(c.commission_amount), 0)
                            FROM commissions c
                            JOIN transactions t ON c.transaction_id = t.transaction_id
                            WHERE c.bank_id = b.bank_id AND t.description LIKE '%Loan Disbursal%') AS loan_commissions_generated,
                           (SELECT COUNT(c.commission_id)
                            FROM commissions c
                            WHERE c.bank_id = b.bank_id) AS trans_count
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
                    row.put("totalDeposits", rs.getBigDecimal("total_bank_deposits"));
                    row.put("commissionsGenerated", rs.getBigDecimal("total_commissions_generated"));
                    row.put("loanCommissionsGenerated", rs.getBigDecimal("loan_commissions_generated"));
                    row.put("transCount", rs.getInt("trans_count"));
                    bankBreakdown.add(row);
                }
            }
            totalBanks = bankBreakdown.size();

            // 4. Top Commission Generating Transactions (both Loans & Regular)
            String topCommSql = """
                    SELECT c.commission_id, c.commission_rate, c.commission_amount, c.created_at,
                           t.reference_number, t.amount, t.transaction_type, t.description,
                           COALESCE(fb.bank_name, b.bank_name, 'Partner Bank') AS from_bank_name,
                           COALESCE(tb.bank_name, 'Partner Bank') AS to_bank_name
                    FROM commissions c
                    JOIN transactions t ON c.transaction_id = t.transaction_id
                    LEFT JOIN accounts fa ON t.from_account_id = fa.account_id
                    LEFT JOIN banks fb ON fa.bank_id = fb.bank_id
                    LEFT JOIN accounts ta ON t.to_account_id = ta.account_id
                    LEFT JOIN banks tb ON ta.bank_id = tb.bank_id
                    LEFT JOIN banks b ON c.bank_id = b.bank_id
                    ORDER BY c.commission_amount DESC LIMIT 20
                    """;
            try (PreparedStatement ps = con.prepareStatement(topCommSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> r = new HashMap<>();
                    r.put("commissionId", rs.getInt("commission_id"));
                    r.put("referenceNumber", rs.getString("reference_number"));
                    r.put("amount", rs.getBigDecimal("amount"));
                    r.put("transactionType", rs.getString("transaction_type"));
                    r.put("commissionRate", rs.getBigDecimal("commission_rate"));
                    r.put("commissionAmount", rs.getBigDecimal("commission_amount"));
                    r.put("fromBankName", rs.getString("from_bank_name"));
                    r.put("toBankName", rs.getString("to_bank_name"));
                    r.put("createdAt", rs.getTimestamp("created_at"));

                    String desc = rs.getString("description");
                    boolean isLoan = desc != null && desc.contains("Loan Disbursal");
                    r.put("sourceType", isLoan ? "LOAN_SANCTION" : "TRANSACTION");
                    r.put("description", desc);
                    topCommissionTransactions.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("loanCommissions", loanCommissions != null ? loanCommissions : BigDecimal.ZERO);
        request.setAttribute("loanCommissionCount", loanCommissionCount);
        request.setAttribute("transCommissions", transCommissions != null ? transCommissions : BigDecimal.ZERO);
        request.setAttribute("transCommissionCount", transCommissionCount);
        request.setAttribute("totalVolume", totalVolume != null ? totalVolume : BigDecimal.ZERO);
        request.setAttribute("totalTransactions", totalTransactions);
        request.setAttribute("totalBanks", totalBanks);
        request.setAttribute("avgCommissionYield", avgCommissionYield);
        request.setAttribute("bankBreakdown", bankBreakdown);
        request.setAttribute("topCommissionTransactions", topCommissionTransactions);

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
