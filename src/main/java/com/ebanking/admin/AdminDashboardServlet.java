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

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        int totalCustomers = 0;
        int totalAccounts = 0;
        int totalBanks = 0;
        int totalTransactions = 0;
        int totalCards = 0;
        int blockedCards = 0;
        int totalLoans = 0;
        int pendingLoans = 0;
        int disbursedLoans = 0;
        BigDecimal totalDeposits = BigDecimal.ZERO;
        BigDecimal totalCommissions = BigDecimal.ZERO;
        BigDecimal totalDisbursedAmount = BigDecimal.ZERO;

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

            // 3. Metric: Total Partner Banks
            String countBanksSql = "SELECT COUNT(*) FROM banks";
            try (PreparedStatement ps = con.prepareStatement(countBanksSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalBanks = rs.getInt(1);
                }
            }

            // 4. Metric: Total Transactions & Total Commission Revenue
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

            // 5. Metric: Total Cards & Blocked Cards
            String cardsMetricSql = "SELECT COUNT(*), COALESCE(SUM(CASE WHEN status = 'BLOCKED' THEN 1 ELSE 0 END), 0) FROM cards";
            try (PreparedStatement ps = con.prepareStatement(cardsMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCards = rs.getInt(1);
                    blockedCards = rs.getInt(2);
                }
            }

            // 6. Metric: Loan Applications & Disbursed Totals
            String loanMetricSql = """
                    SELECT COUNT(*),
                           COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0)
                    FROM loan_applications
                    """;
            try (PreparedStatement ps = con.prepareStatement(loanMetricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalLoans = rs.getInt(1);
                    pendingLoans = rs.getInt(2);
                    disbursedLoans = rs.getInt(3);
                    totalDisbursedAmount = rs.getBigDecimal(4);
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
        request.setAttribute("totalCards", totalCards);
        request.setAttribute("blockedCards", blockedCards);
        request.setAttribute("totalLoans", totalLoans);
        request.setAttribute("pendingLoans", pendingLoans);
        request.setAttribute("disbursedLoans", disbursedLoans);
        request.setAttribute("totalDisbursedAmount", totalDisbursedAmount != null ? totalDisbursedAmount : BigDecimal.ZERO);
        request.setAttribute("totalCommissions", totalCommissions != null ? totalCommissions : BigDecimal.ZERO);
        request.setAttribute("totalDeposits", totalDeposits != null ? totalDeposits : BigDecimal.ZERO);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
