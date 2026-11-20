package com.ebanking.card;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@WebServlet(urlPatterns = {"/card", "/user/cards"})
public class CardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        List<Map<String, Object>> userAccounts = new ArrayList<>();
        List<Map<String, Object>> userCards = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Fetch user's active accounts (for card application dropdown)
            String accSql = """
                    SELECT a.account_id, a.account_number, a.account_type, a.balance,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
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
                        userAccounts.add(acc);
                    }
                }
            }

            // 2. Fetch user's cards with holding bank info
            String cardSql = """
                    SELECT c.card_id, c.card_number, c.card_type, c.card_holder_name,
                           c.expiry_date, c.daily_limit, c.status, c.created_at,
                           a.account_number,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                           COALESCE(b.bank_code, 'BANK') AS bank_code
                    FROM cards c
                    JOIN accounts a ON c.account_id = a.account_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE c.user_id = ?
                    ORDER BY c.created_at DESC
                    """;
            try (PreparedStatement ps = con.prepareStatement(cardSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> card = new HashMap<>();
                        card.put("cardId", rs.getInt("card_id"));
                        String rawNum = rs.getString("card_number");
                        card.put("cardNumber", rawNum);

                        // Masked representation: "4532 •••• •••• 7890"
                        card.put("maskedNumber", maskCardNumber(rawNum));

                        card.put("cardType", rs.getString("card_type"));
                        card.put("cardHolderName", rs.getString("card_holder_name"));
                        card.put("expiryDate", rs.getString("expiry_date"));
                        card.put("dailyLimit", rs.getBigDecimal("daily_limit"));
                        card.put("status", rs.getString("status"));
                        card.put("createdAt", rs.getTimestamp("created_at"));
                        card.put("accountNumber", rs.getString("account_number"));
                        card.put("bankName", rs.getString("bank_name"));
                        card.put("bankCode", rs.getString("bank_code"));
                        userCards.add(card);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error loading cards: " + e.getMessage());
        }

        request.setAttribute("userAccounts", userAccounts);
        request.setAttribute("cards", userCards);

        request.getRequestDispatcher("/user/cards.jsp").forward(request, response);
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

        try (Connection con = DBConnection.getConnection()) {

            if ("apply".equalsIgnoreCase(action)) {
                String accountIdStr = request.getParameter("accountId");
                String cardType = request.getParameter("cardType");
                String cardHolderName = request.getParameter("cardHolderName");

                if (accountIdStr == null || accountIdStr.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/user/cards?error=select_account");
                    return;
                }

                int accountId = Integer.parseInt(accountIdStr.trim());
                if (cardType == null || (!"CREDIT".equalsIgnoreCase(cardType) && !"DEBIT".equalsIgnoreCase(cardType))) {
                    cardType = "DEBIT";
                }

                if (cardHolderName == null || cardHolderName.trim().isEmpty()) {
                    String fn = (String) session.getAttribute("firstName");
                    String ln = (String) session.getAttribute("lastName");
                    cardHolderName = ((fn != null ? fn : "CUSTOMER") + (ln != null ? " " + ln : "")).toUpperCase();
                } else {
                    cardHolderName = cardHolderName.trim().toUpperCase();
                }

                // Verify account ownership
                String verifySql = "SELECT account_id FROM accounts WHERE account_id = ? AND user_id = ? AND status = 'ACTIVE'";
                try (PreparedStatement ps = con.prepareStatement(verifySql)) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect(request.getContextPath() + "/user/cards?error=invalid_account");
                            return;
                        }
                    }
                }

                // Generate simulated 16-digit card number
                String cardNumber = generateCardNumber(cardType);

                // Expiry date: 4 years from now (e.g. 11/30)
                LocalDate now = LocalDate.now();
                int expMonth = now.getMonthValue();
                int expYear = (now.getYear() + 4) % 100;
                String expiryDate = String.format("%02d/%02d", expMonth, expYear);

                // Simulated CVV hash
                Random rand = new Random();
                int mockCvv = 100 + rand.nextInt(900);
                String cvvHash = sha256(String.valueOf(mockCvv));

                BigDecimal dailyLimit = "CREDIT".equalsIgnoreCase(cardType)
                        ? new BigDecimal("100000.00")
                        : new BigDecimal("50000.00");

                String insertSql = """
                        INSERT INTO cards
                        (card_number, card_type, account_id, user_id, card_holder_name, expiry_date, cvv_hash, daily_limit, status)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')
                        """;
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setString(1, cardNumber);
                    ps.setString(2, cardType.toUpperCase());
                    ps.setInt(3, accountId);
                    ps.setInt(4, userId);
                    ps.setString(5, cardHolderName);
                    ps.setString(6, expiryDate);
                    ps.setString(7, cvvHash);
                    ps.setBigDecimal(8, dailyLimit);
                    ps.executeUpdate();
                }

                response.sendRedirect(request.getContextPath() + "/user/cards?success=applied_pending");
                return;

            } else if ("toggle_status".equalsIgnoreCase(action)) {
                String cardIdStr = request.getParameter("cardId");
                String currentStatus = request.getParameter("currentStatus");

                if (cardIdStr != null && currentStatus != null) {
                    int cardId = Integer.parseInt(cardIdStr.trim());
                    String targetStatus = "ACTIVE".equalsIgnoreCase(currentStatus) ? "BLOCKED" : "ACTIVE";

                    String updateSql = "UPDATE cards SET status = ? WHERE card_id = ? AND user_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                        ps.setString(1, targetStatus);
                        ps.setInt(2, cardId);
                        ps.setInt(3, userId);
                        ps.executeUpdate();
                    }
                }

                response.sendRedirect(request.getContextPath() + "/user/cards?success=status");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user/cards?error=" +
                    java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Card operation error", "UTF-8"));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/user/cards");
    }

    private String generateCardNumber(String cardType) {
        Random rand = new Random();
        String prefix = "CREDIT".equalsIgnoreCase(cardType) ? "5412" : "4532";
        int b1 = 1000 + rand.nextInt(9000);
        int b2 = 1000 + rand.nextInt(9000);
        int b3 = 1000 + rand.nextInt(9000);
        return prefix + " " + b1 + " " + b2 + " " + b3;
    }

    private String maskCardNumber(String raw) {
        if (raw == null || raw.length() < 16) return "**** **** **** ****";
        String[] parts = raw.split(" ");
        if (parts.length == 4) {
            return parts[0] + " •••• •••• " + parts[3];
        }
        return "•••• •••• •••• " + raw.substring(raw.length() - 4);
    }

    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            return "mock_cvv_hash_" + input.hashCode();
        }
    }
}
