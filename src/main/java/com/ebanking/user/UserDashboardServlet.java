package com.ebanking.user;

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

@WebServlet(urlPatterns = {"/user/dashboard", "/user/home"})
public class UserDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        BigDecimal totalBalance = BigDecimal.ZERO;
        int totalAccounts = 0;
        int pendingAccounts = 0;
        int totalCards = 0;
        int pendingCards = 0;
        int totalLoans = 0;
        int pendingLoans = 0;
        BigDecimal disbursedLoansAmount = BigDecimal.ZERO;

        List<Map<String, Object>> accountsList = new ArrayList<>();
        List<Map<String, Object>> recentTransactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Total liquid balance, active accounts, and pending accounts
            String accSql = """
                    SELECT 
                        COUNT(*),
                        COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END), 0),
                        COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                        COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN balance ELSE 0 END), 0)
                    FROM accounts
                    WHERE user_id = ?
                    """;
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalAccounts = rs.getInt(2);
                        pendingAccounts = rs.getInt(3);
                        totalBalance = rs.getBigDecimal(4);
                    }
                }
            }

            // 2. Active cards and pending cards
            String cardSql = """
                    SELECT 
                        COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END), 0),
                        COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0)
                    FROM cards
                    WHERE user_id = ?
                    """;
            try (PreparedStatement ps = con.prepareStatement(cardSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                        pendingCards = rs.getInt(2);
                    }
                }
            }

            // 3. Active loans, pending loans and disbursed amount
            String loanSql = """
                    SELECT 
                        COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0),
                        COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0),
                        COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0)
                    FROM loan_applications
                    WHERE user_id = ?
                    """;
            try (PreparedStatement ps = con.prepareStatement(loanSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        pendingLoans = rs.getInt(2);
                        disbursedLoansAmount = rs.getBigDecimal(3);
                    }
                }
            }

            // 4. Accounts List for this user
            String accListSql = """
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           a.branch_name, a.ifsc_code, a.status, a.created_at,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM accounts a
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE a.user_id = ?
                    ORDER BY a.account_id DESC
                    """;
            try (PreparedStatement ps = con.prepareStatement(accListSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> acc = new HashMap<>();
                        acc.put("accountId", rs.getInt("account_id"));
                        acc.put("accountNumber", rs.getString("account_number"));
                        acc.put("accountType", rs.getString("account_type"));
                        acc.put("balance", rs.getBigDecimal("balance"));
                        acc.put("branchName", rs.getString("branch_name"));
                        acc.put("ifscCode", rs.getString("ifsc_code"));
                        acc.put("status", rs.getString("status"));
                        acc.put("createdAt", rs.getTimestamp("created_at"));
                        acc.put("bankName", rs.getString("bank_name"));
                        acc.put("bankCode", rs.getString("bank_code"));
                        accountsList.add(acc);
                    }
                }
            }

            // 5. Recent Transactions for this user (Top 5)
            String transSql = """
                    SELECT t.transaction_id, t.reference_number, t.amount, t.transaction_type,
                           t.status, t.description, t.created_at,
                           t.from_account_id, t.to_account_id,
                           fa.account_number AS from_acc_num,
                           ta.account_number AS to_acc_num,
                           CASE WHEN fa.user_id = ? THEN 1 ELSE 0 END AS is_sender
                    FROM transactions t
                    LEFT JOIN accounts fa ON t.from_account_id = fa.account_id
                    LEFT JOIN accounts ta ON t.to_account_id = ta.account_id
                    WHERE fa.user_id = ? OR ta.user_id = ?
                    ORDER BY t.created_at DESC
                    LIMIT 5
                    """;
            try (PreparedStatement ps = con.prepareStatement(transSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                ps.setInt(3, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> tr = new HashMap<>();
                        tr.put("transactionId", rs.getInt("transaction_id"));
                        tr.put("referenceNumber", rs.getString("reference_number"));
                        tr.put("amount", rs.getBigDecimal("amount"));
                        tr.put("transactionType", rs.getString("transaction_type"));
                        tr.put("status", rs.getString("status"));
                        tr.put("description", rs.getString("description"));
                        tr.put("createdAt", rs.getTimestamp("created_at"));
                        tr.put("fromAccNum", rs.getString("from_acc_num"));
                        tr.put("toAccNum", rs.getString("to_acc_num"));
                        tr.put("isSender", rs.getInt("is_sender") == 1);
                        recentTransactions.add(tr);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("totalBalance", totalBalance != null ? totalBalance : BigDecimal.ZERO);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("pendingAccounts", pendingAccounts);
        request.setAttribute("totalCards", totalCards);
        request.setAttribute("pendingCards", pendingCards);
        request.setAttribute("totalLoans", totalLoans);
        request.setAttribute("pendingLoans", pendingLoans);
        request.setAttribute("disbursedLoansAmount", disbursedLoansAmount != null ? disbursedLoansAmount : BigDecimal.ZERO);
        request.setAttribute("accountsList", accountsList);
        request.setAttribute("recentTransactions", recentTransactions);

        request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
    }
}
