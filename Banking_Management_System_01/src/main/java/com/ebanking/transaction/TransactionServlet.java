package com.ebanking.transaction;

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
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@WebServlet(urlPatterns = {"/transaction", "/user/transactions"})
public class TransactionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String filterAcc = request.getParameter("accountNumber");

        List<Map<String, Object>> userAccounts = new ArrayList<>();
        List<Map<String, Object>> transactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Fetch all accounts of this user
            String accSql = """
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code,
                           COALESCE(b.commission_rate, 0.50) AS commission_rate
                    FROM accounts a
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE a.user_id = ? AND a.status = 'ACTIVE'
                    ORDER BY a.account_id ASC
                    """;

            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> acc = new HashMap<>();
                        acc.put("accountId", rs.getInt("account_id"));
                        acc.put("accountNumber", rs.getString("account_number"));
                        acc.put("accountType", rs.getString("account_type"));
                        acc.put("balance", rs.getBigDecimal("balance"));
                        acc.put("bankName", rs.getString("bank_name"));
                        acc.put("bankCode", rs.getString("bank_code"));
                        acc.put("commissionRate", rs.getBigDecimal("commission_rate"));
                        userAccounts.add(acc);
                    }
                }
            }

            // 2. Fetch transactions related to the user's accounts
            StringBuilder transSql = new StringBuilder("""
                    SELECT t.transaction_id,
                           t.reference_number,
                           t.from_account_id,
                           t.to_account_id,
                           t.amount,
                           t.transaction_type,
                           t.status,
                           t.description,
                           t.created_at,
                           fa.account_number AS from_account_number,
                           fa.user_id AS from_user_id,
                           COALESCE(fb.bank_name, 'Bank') AS from_bank_name,
                           ta.account_number AS to_account_number,
                           ta.user_id AS to_user_id,
                           COALESCE(tb.bank_name, 'Bank') AS to_bank_name
                    FROM transactions t
                    LEFT JOIN accounts fa ON t.from_account_id = fa.account_id
                    LEFT JOIN banks fb ON fa.bank_id = fb.bank_id
                    LEFT JOIN accounts ta ON t.to_account_id = ta.account_id
                    LEFT JOIN banks tb ON ta.bank_id = tb.bank_id
                    WHERE (fa.user_id = ? OR ta.user_id = ?)
                    """);

            if (filterAcc != null && !filterAcc.trim().isEmpty()) {
                transSql.append(" AND (fa.account_number = ? OR ta.account_number = ?) ");
            }

            transSql.append(" ORDER BY t.created_at DESC LIMIT 100");

            try (PreparedStatement ps = con.prepareStatement(transSql.toString())) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                if (filterAcc != null && !filterAcc.trim().isEmpty()) {
                    ps.setString(3, filterAcc.trim());
                    ps.setString(4, filterAcc.trim());
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
                        t.put("fromBankName", rs.getString("from_bank_name"));
                        t.put("toAccountNumber", rs.getString("to_account_number"));
                        t.put("toBankName", rs.getString("to_bank_name"));

                        int fromUid = rs.getInt("from_user_id");
                        int toUid = rs.getInt("to_user_id");

                        // Determine if this is a Credit or Debit for the current viewer
                        boolean isDebit = (fromUid == userId && !"DEPOSIT".equals(rs.getString("transaction_type")));
                        t.put("isDebit", isDebit);

                        transactions.add(t);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading transaction records: " + e.getMessage());
        }

        request.setAttribute("userAccounts", userAccounts);
        request.setAttribute("transactions", transactions);
        request.setAttribute("filterAccount", filterAcc);

        request.getRequestDispatcher("/user/transactions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/transactions");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false); // Enable atomic database transaction

            try {
                if ("deposit".equalsIgnoreCase(action)) {
                    handleDeposit(request, response, con, userId);
                } else if ("withdraw".equalsIgnoreCase(action)) {
                    handleWithdraw(request, response, con, userId);
                } else if ("transfer".equalsIgnoreCase(action)) {
                    handleTransfer(request, response, con, userId);
                } else {
                    con.rollback();
                    response.sendRedirect(request.getContextPath() + "/user/transactions?error=invalid_action");
                }
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/user/transactions?error=" +
                        java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Transaction processing failed", "UTF-8"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user/transactions?error=database_connection_failure");
        }
    }

    private void handleDeposit(HttpServletRequest request, HttpServletResponse response, Connection con, int userId)
            throws Exception {

        String accountIdStr = request.getParameter("accountId");
        String amountStr = request.getParameter("amount");
        String description = request.getParameter("description");

        if (accountIdStr == null || amountStr == null) {
            throw new IllegalArgumentException("Account and deposit amount are required.");
        }

        int accountId = Integer.parseInt(accountIdStr.trim());
        BigDecimal amount = new BigDecimal(amountStr.trim());

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Deposit amount must be greater than zero.");
        }

        // Verify account ownership
        String verifySql = "SELECT account_id FROM accounts WHERE account_id = ? AND user_id = ? AND status = 'ACTIVE' FOR UPDATE";
        try (PreparedStatement ps = con.prepareStatement(verifySql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalStateException("Account not found or inactive.");
                }
            }
        }

        // Credit the account
        String creditSql = "UPDATE accounts SET balance = balance + ? WHERE account_id = ?";
        try (PreparedStatement ps = con.prepareStatement(creditSql)) {
            ps.setBigDecimal(1, amount);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }

        // Generate Reference Number
        String refNo = generateReferenceNumber("DEP");

        // Record transaction
        String transSql = """
                INSERT INTO transactions
                (reference_number, from_account_id, to_account_id, amount, transaction_type, status, description)
                VALUES (?, NULL, ?, ?, 'DEPOSIT', 'SUCCESS', ?)
                """;
        try (PreparedStatement ps = con.prepareStatement(transSql)) {
            ps.setString(1, refNo);
            ps.setInt(2, accountId);
            ps.setBigDecimal(3, amount);
            ps.setString(4, description != null && !description.trim().isEmpty() ? description.trim() : "Cash Deposit at Bank");
            ps.executeUpdate();
        }

        con.commit();
        response.sendRedirect(request.getContextPath() + "/user/transactions?success=deposit&ref=" + refNo + "&amt=" + amount);
    }

    private void handleWithdraw(HttpServletRequest request, HttpServletResponse response, Connection con, int userId)
            throws Exception {

        String accountIdStr = request.getParameter("accountId");
        String amountStr = request.getParameter("amount");
        String description = request.getParameter("description");

        if (accountIdStr == null || amountStr == null) {
            throw new IllegalArgumentException("Account and withdrawal amount are required.");
        }

        int accountId = Integer.parseInt(accountIdStr.trim());
        BigDecimal amount = new BigDecimal(amountStr.trim());

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be greater than zero.");
        }

        // Check account balance and lock row
        BigDecimal currentBalance = BigDecimal.ZERO;
        String verifySql = "SELECT balance FROM accounts WHERE account_id = ? AND user_id = ? AND status = 'ACTIVE' FOR UPDATE";
        try (PreparedStatement ps = con.prepareStatement(verifySql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentBalance = rs.getBigDecimal("balance");
                } else {
                    throw new IllegalStateException("Account not found or inactive.");
                }
            }
        }

        if (currentBalance.compareTo(amount) < 0) {
            throw new IllegalArgumentException("Insufficient funds. Available balance: ₹" + currentBalance);
        }

        // Debit the account
        String debitSql = "UPDATE accounts SET balance = balance - ? WHERE account_id = ?";
        try (PreparedStatement ps = con.prepareStatement(debitSql)) {
            ps.setBigDecimal(1, amount);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }

        String refNo = generateReferenceNumber("WTH");

        // Record transaction
        String transSql = """
                INSERT INTO transactions
                (reference_number, from_account_id, to_account_id, amount, transaction_type, status, description)
                VALUES (?, ?, NULL, ?, 'WITHDRAWAL', 'SUCCESS', ?)
                """;
        try (PreparedStatement ps = con.prepareStatement(transSql)) {
            ps.setString(1, refNo);
            ps.setInt(2, accountId);
            ps.setBigDecimal(3, amount);
            ps.setString(4, description != null && !description.trim().isEmpty() ? description.trim() : "ATM Cash Withdrawal");
            ps.executeUpdate();
        }

        con.commit();
        response.sendRedirect(request.getContextPath() + "/user/transactions?success=withdraw&ref=" + refNo + "&amt=" + amount);
    }

    private void handleTransfer(HttpServletRequest request, HttpServletResponse response, Connection con, int userId)
            throws Exception {

        String fromAccountIdStr = request.getParameter("fromAccountId");
        String toAccountNumber = request.getParameter("toAccountNumber");
        String amountStr = request.getParameter("amount");
        String description = request.getParameter("description");

        if (fromAccountIdStr == null || toAccountNumber == null || amountStr == null) {
            throw new IllegalArgumentException("Source account, recipient account, and amount are required.");
        }

        int fromAccountId = Integer.parseInt(fromAccountIdStr.trim());
        BigDecimal amount = new BigDecimal(amountStr.trim());
        String cleanToAccNum = toAccountNumber.trim();

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Transfer amount must be greater than zero.");
        }

        // 1. Verify Sender Account and Lock
        BigDecimal senderBalance = BigDecimal.ZERO;
        String senderAccNum = "";
        int senderBankId = 1;
        BigDecimal bankCommissionRate = new BigDecimal("0.50");

        String senderSql = """
                SELECT a.account_id, a.account_number, a.balance, a.bank_id,
                       COALESCE(b.commission_rate, 0.50) AS commission_rate
                FROM accounts a
                LEFT JOIN banks b ON a.bank_id = b.bank_id
                WHERE a.account_id = ? AND a.user_id = ? AND a.status = 'ACTIVE'
                FOR UPDATE
                """;
        try (PreparedStatement ps = con.prepareStatement(senderSql)) {
            ps.setInt(1, fromAccountId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    senderBalance = rs.getBigDecimal("balance");
                    senderAccNum = rs.getString("account_number");
                    senderBankId = rs.getInt("bank_id");
                    bankCommissionRate = rs.getBigDecimal("commission_rate");
                } else {
                    throw new IllegalStateException("Source account not found or access denied.");
                }
            }
        }

        if (senderAccNum.equals(cleanToAccNum)) {
            throw new IllegalArgumentException("Cannot transfer funds to the same account.");
        }

        // 2. Verify Recipient Account and Lock
        int toAccountId = 0;
        String recipientSql = "SELECT account_id, status FROM accounts WHERE account_number = ? FOR UPDATE";
        try (PreparedStatement ps = con.prepareStatement(recipientSql)) {
            ps.setString(1, cleanToAccNum);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (!"ACTIVE".equalsIgnoreCase(rs.getString("status"))) {
                        throw new IllegalStateException("Beneficiary account is currently not active.");
                    }
                    toAccountId = rs.getInt("account_id");
                } else {
                    throw new IllegalArgumentException("Beneficiary account #" + cleanToAccNum + " does not exist.");
                }
            }
        }

        // 3. Balance check
        if (senderBalance.compareTo(amount) < 0) {
            throw new IllegalArgumentException("Insufficient balance for transfer. Available: ₹" + senderBalance);
        }

        // 4. Calculate Platform Commission
        BigDecimal commissionAmount = amount.multiply(bankCommissionRate)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);

        // 5. Debit Sender Account
        String debitSql = "UPDATE accounts SET balance = balance - ? WHERE account_id = ?";
        try (PreparedStatement ps = con.prepareStatement(debitSql)) {
            ps.setBigDecimal(1, amount);
            ps.setInt(2, fromAccountId);
            ps.executeUpdate();
        }

        // 6. Credit Recipient Account
        String creditSql = "UPDATE accounts SET balance = balance + ? WHERE account_id = ?";
        try (PreparedStatement ps = con.prepareStatement(creditSql)) {
            ps.setBigDecimal(1, amount);
            ps.setInt(2, toAccountId);
            ps.executeUpdate();
        }

        // 7. Insert Transaction Record
        String refNo = generateReferenceNumber("TRF");
        int transactionId = 0;

        String transSql = """
                INSERT INTO transactions
                (reference_number, from_account_id, to_account_id, amount, transaction_type, status, description)
                VALUES (?, ?, ?, ?, 'TRANSFER', 'SUCCESS', ?)
                """;
        try (PreparedStatement ps = con.prepareStatement(transSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, refNo);
            ps.setInt(2, fromAccountId);
            ps.setInt(3, toAccountId);
            ps.setBigDecimal(4, amount);
            ps.setString(5, description != null && !description.trim().isEmpty()
                    ? description.trim()
                    : "Fund Transfer to Account #" + cleanToAccNum);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    transactionId = rs.getInt(1);
                }
            }
        }

        // 8. Record Platform Commission from Bank
        if (transactionId > 0 && senderBankId > 0 && commissionAmount.compareTo(BigDecimal.ZERO) > 0) {
            String commSql = """
                    INSERT INTO commissions
                    (bank_id, transaction_id, commission_rate, commission_amount)
                    VALUES (?, ?, ?, ?)
                    """;
            try (PreparedStatement ps = con.prepareStatement(commSql)) {
                ps.setInt(1, senderBankId);
                ps.setInt(2, transactionId);
                ps.setBigDecimal(3, bankCommissionRate);
                ps.setBigDecimal(4, commissionAmount);
                ps.executeUpdate();
            }
        }

        con.commit();
        response.sendRedirect(request.getContextPath() + "/user/transactions?success=transfer&ref=" + refNo + "&amt=" + amount);
    }

    private String generateReferenceNumber(String typePrefix) {
        Random random = new Random();
        long randomSuffix = 100000L + (long)(random.nextDouble() * 900000L);
        return "TXN" + typePrefix + System.currentTimeMillis() % 10000000L + randomSuffix;
    }
}
