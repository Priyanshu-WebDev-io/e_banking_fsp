package com.ebanking.account;

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
import java.util.Random;

@WebServlet("/account/create")
public class AccountCreateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        List<Map<String, Object>> banks = new ArrayList<>();
        String bankSql = "SELECT bank_id, bank_name, bank_code, ifsc_prefix FROM banks WHERE status = 'ACTIVE' ORDER BY bank_name ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(bankSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> b = new HashMap<>();
                b.put("bankId", rs.getInt("bank_id"));
                b.put("bankName", rs.getString("bank_name"));
                b.put("bankCode", rs.getString("bank_code"));
                b.put("ifscPrefix", rs.getString("ifsc_prefix"));
                banks.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("banks", banks);
        request.getRequestDispatcher("/account/create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String bankIdStr = request.getParameter("bankId");
        String accountType = request.getParameter("accountType");
        String depositStr = request.getParameter("initialDeposit");
        String branchName = request.getParameter("branchName");

        if (accountType == null || accountType.trim().isEmpty()) {
            accountType = "SAVINGS";
        }

        if (branchName == null || branchName.trim().isEmpty()) {
            branchName = "Main Branch - Mumbai";
        }

        int bankId = 1;
        String ifscCode = "SBIN000101";

        if (bankIdStr != null && !bankIdStr.trim().isEmpty()) {
            try {
                bankId = Integer.parseInt(bankIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        try (Connection con = DBConnection.getConnection()) {
            String bankQuery = "SELECT ifsc_prefix FROM banks WHERE bank_id = ?";
            try (PreparedStatement ps = con.prepareStatement(bankQuery)) {
                ps.setInt(1, bankId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ifscCode = rs.getString("ifsc_prefix");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        BigDecimal initialDeposit = BigDecimal.valueOf(500);
        try {
            if (depositStr != null && !depositStr.trim().isEmpty()) {
                initialDeposit = new BigDecimal(depositStr.trim());
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Please enter a valid numeric deposit amount.");
            doGet(request, response);
            return;
        }

        if (initialDeposit.compareTo(BigDecimal.valueOf(500)) < 0) {
            request.setAttribute("error", "Minimum initial deposit is ₹500.");
            doGet(request, response);
            return;
        }

        // Generate unique 12-digit account number (Prefix: 1001)
        Random random = new Random();
        long randomSuffix = 10000000L + (long)(random.nextDouble() * 90000000L);
        String accountNumber = "1001" + randomSuffix;

        String sql = """
                INSERT INTO accounts
                (account_number, user_id, bank_id, account_type, balance, branch_name, ifsc_code, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE')
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);
            ps.setInt(2, userId);
            ps.setInt(3, bankId);
            ps.setString(4, accountType);
            ps.setBigDecimal(5, initialDeposit);
            ps.setString(6, branchName);
            ps.setString(7, ifscCode);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/account/list?created=" + accountNumber);
            } else {
                request.setAttribute("error", "Failed to open account. Please try again.");
                doGet(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            doGet(request, response);
        }
    }
}
