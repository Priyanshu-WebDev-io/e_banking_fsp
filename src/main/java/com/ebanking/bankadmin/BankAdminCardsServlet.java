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

@WebServlet("/bank-admin/cards")
public class BankAdminCardsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        Integer assignedBankId = (Integer) session.getAttribute("bankAdminBankId");

        int totalCards = 0;
        int pendingCards = 0;
        int activeCards = 0;
        int blockedCards = 0;

        List<Map<String, Object>> cards = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            StringBuilder metricSql = new StringBuilder("""
                    SELECT COUNT(c.card_id),
                           COALESCE(SUM(CASE WHEN c.status = 'ACTIVE' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN c.status = 'BLOCKED' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN c.status = 'PENDING' THEN 1 ELSE 0 END), 0)
                    FROM cards c
                    JOIN accounts a ON c.account_id = a.account_id
                    WHERE 1=1
                    """);
            if (assignedBankId != null) {
                metricSql.append(" AND a.bank_id = ?");
            }
            try (PreparedStatement ps = con.prepareStatement(metricSql.toString())) {
                if (assignedBankId != null) {
                    ps.setInt(1, assignedBankId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                        activeCards = rs.getInt(2);
                        blockedCards = rs.getInt(3);
                        pendingCards = rs.getInt(4);
                    }
                }
            }

            // 2. Cards List
            StringBuilder cardsListSql = new StringBuilder("""
                    SELECT c.card_id, c.card_number, c.card_type, c.card_holder_name,
                           c.expiry_date, c.daily_limit, c.status, c.created_at,
                           a.account_number, u.first_name, u.last_name, u.email,
                           COALESCE(b.bank_name, 'Partner Bank') AS bank_name
                    FROM cards c
                    JOIN accounts a ON c.account_id = a.account_id
                    JOIN users u ON c.user_id = u.user_id
                    LEFT JOIN banks b ON a.bank_id = b.bank_id
                    WHERE 1=1
                    """);
            if (assignedBankId != null) {
                cardsListSql.append(" AND a.bank_id = ?");
            }
            cardsListSql.append(" ORDER BY CASE WHEN c.status = 'PENDING' THEN 0 ELSE 1 END, c.created_at DESC");

            try (PreparedStatement ps = con.prepareStatement(cardsListSql.toString())) {
                if (assignedBankId != null) {
                    ps.setInt(1, assignedBankId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> card = new HashMap<>();
                        card.put("cardId", rs.getInt("card_id"));
                        String rawNum = rs.getString("card_number");
                        card.put("cardNumber", rawNum);

                        String masked = "**** **** **** ****";
                        if (rawNum != null && rawNum.length() >= 16) {
                            String[] parts = rawNum.split(" ");
                            if (parts.length == 4) {
                                masked = parts[0] + " •••• •••• " + parts[3];
                            }
                        }
                        card.put("maskedNumber", masked);
                        card.put("cardType", rs.getString("card_type"));
                        card.put("cardHolderName", rs.getString("card_holder_name"));
                        card.put("expiryDate", rs.getString("expiry_date"));
                        card.put("dailyLimit", rs.getBigDecimal("daily_limit"));
                        card.put("status", rs.getString("status"));
                        card.put("createdAt", rs.getTimestamp("created_at"));
                        card.put("accountNumber", rs.getString("account_number"));
                        card.put("bankName", rs.getString("bank_name"));
                        card.put("customerName", rs.getString("first_name") + " " + rs.getString("last_name"));
                        card.put("customerEmail", rs.getString("email"));
                        cards.add(card);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalCards", totalCards);
        request.setAttribute("pendingCards", pendingCards);
        request.setAttribute("activeCards", activeCards);
        request.setAttribute("blockedCards", blockedCards);
        request.setAttribute("cards", cards);

        request.getRequestDispatcher("/bank-admin/cards.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("bankAdminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
            return;
        }

        String cardIdStr = request.getParameter("cardId");
        String action = request.getParameter("action");

        if (cardIdStr != null && action != null) {
            try (Connection con = DBConnection.getConnection()) {
                int cardId = Integer.parseInt(cardIdStr.trim());

                if ("confirm".equalsIgnoreCase(action) || "approve".equalsIgnoreCase(action)) {
                    String sql = "UPDATE cards SET status = 'ACTIVE' WHERE card_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, cardId);
                        ps.executeUpdate();
                    }
                    response.sendRedirect(request.getContextPath() + "/bank-admin/cards?success=card_confirmed");
                    return;
                } else if ("reject".equalsIgnoreCase(action)) {
                    String sql = "UPDATE cards SET status = 'REJECTED' WHERE card_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, cardId);
                        ps.executeUpdate();
                    }
                    response.sendRedirect(request.getContextPath() + "/bank-admin/cards?success=card_rejected");
                    return;
                } else if ("toggle".equalsIgnoreCase(action)) {
                    String sql = "UPDATE cards SET status = CASE WHEN status = 'ACTIVE' THEN 'BLOCKED' ELSE 'ACTIVE' END WHERE card_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, cardId);
                        ps.executeUpdate();
                    }
                    response.sendRedirect(request.getContextPath() + "/bank-admin/cards?success=status_updated");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/bank-admin/cards?error=" +
                        java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Card update failed", "UTF-8"));
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/bank-admin/cards");
    }
}
