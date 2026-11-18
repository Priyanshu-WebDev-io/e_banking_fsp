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

@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        BigDecimal totalDeposits = BigDecimal.ZERO;
        BigDecimal totalCommissions = BigDecimal.ZERO;
        BigDecimal totalLoansDisbursed = BigDecimal.ZERO;
        int totalAccounts = 0;
        int totalCustomers = 0;
        int totalBanks = 0;
        int totalTransactions = 0;

        List<Map<String, Object>> bankBreakdown = new ArrayList<>();
        List<Map<String, Object>> loanProductBreakdown = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. High-level financial totals
            String accMetricSql = "SELECT COUNT(*), COALESCE(SUM(balance), 0) FROM accounts";
            try (PreparedStatement ps = con.prepareStatement(accMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalAccounts = rs.getInt(1);
                    totalDeposits = rs.getBigDecimal(2);
                }
            }

            String commMetricSql = "SELECT COALESCE(SUM(commission_amount), 0) FROM commissions";
            try (PreparedStatement ps = con.prepareStatement(commMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCommissions = rs.getBigDecimal(1);
                }
            }

            String loanMetricSql = "SELECT COALESCE(SUM(principal_amount), 0) FROM loan_applications WHERE status = 'DISBURSED'";
            try (PreparedStatement ps = con.prepareStatement(loanMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalLoansDisbursed = rs.getBigDecimal(1);
                }
            }

            String custMetricSql = "SELECT COUNT(*) FROM users";
            try (PreparedStatement ps = con.prepareStatement(custMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCustomers = rs.getInt(1);
                }
            }

            String transMetricSql = "SELECT COUNT(*) FROM transactions";
            try (PreparedStatement ps = con.prepareStatement(transMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalTransactions = rs.getInt(1);
                }
            }

            // 2. Institutional Breakdown per Partner Bank
            String bankBreakdownSql = """
                    SELECT b.bank_id, b.bank_name, b.bank_code, b.commission_rate, b.status,
                           COUNT(DISTINCT a.account_id) AS account_count,
                           COALESCE(SUM(a.balance), 0) AS total_bank_deposits,
                           (SELECT COALESCE(SUM(c.commission_amount), 0)
                            FROM commissions c
                            JOIN transactions t ON c.transaction_id = t.transaction_id
                            JOIN accounts fa ON t.from_account_id = fa.account_id
                            WHERE fa.bank_id = b.bank_id) AS total_commissions_generated
                    FROM banks b
                    LEFT JOIN accounts a ON b.bank_id = a.bank_id
                    GROUP BY b.bank_id, b.bank_name, b.bank_code, b.commission_rate, b.status
                    ORDER BY total_bank_deposits DESC
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
                    bankBreakdown.add(row);
                }
            }
            totalBanks = bankBreakdown.size();

            // 3. Loan Product Breakdown
            String prodBreakdownSql = """
                    SELECT lp.product_name, lp.loan_type, lp.interest_rate,
                           COUNT(la.loan_id) AS total_applications,
                           COALESCE(SUM(CASE WHEN la.status = 'DISBURSED' THEN 1 ELSE 0 END), 0) AS disbursed_count,
                           COALESCE(SUM(CASE WHEN la.status = 'DISBURSED' THEN la.principal_amount ELSE 0 END), 0) AS total_disbursed_amt
                    FROM loan_products lp
                    LEFT JOIN loan_applications la ON lp.product_id = la.product_id
                    GROUP BY lp.product_id, lp.product_name, lp.loan_type, lp.interest_rate
                    ORDER BY lp.product_id ASC
                    """;
            try (PreparedStatement ps = con.prepareStatement(prodBreakdownSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("productName", rs.getString("product_name"));
                    p.put("loanType", rs.getString("loan_type"));
                    p.put("interestRate", rs.getBigDecimal("interest_rate"));
                    p.put("totalApplications", rs.getInt("total_applications"));
                    p.put("disbursedCount", rs.getInt("disbursed_count"));
                    p.put("disbursedAmount", rs.getBigDecimal("total_disbursed_amt"));
                    loanProductBreakdown.add(p);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);
        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("totalLoansDisbursed", totalLoansDisbursed != null ? totalLoansDisbursed : BigDecimal.ZERO);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalBanks", totalBanks);
        request.setAttribute("totalTransactions", totalTransactions);
        request.setAttribute("bankBreakdown", bankBreakdown);
        request.setAttribute("loanProductBreakdown", loanProductBreakdown);

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
