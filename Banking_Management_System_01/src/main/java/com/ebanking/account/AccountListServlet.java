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

@WebServlet("/account/list")
public class AccountListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String sql = """
                SELECT account_id, account_number, account_type, balance,
                       branch_name, ifsc_code, status, created_at
                FROM accounts
                WHERE user_id = ?
                ORDER BY created_at DESC
                """;

        List<Map<String, Object>> accounts = new ArrayList<>();
        BigDecimal totalBalance = BigDecimal.ZERO;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> acc = new HashMap<>();
                    acc.put("accountId", rs.getInt("account_id"));
                    acc.put("accountNumber", rs.getString("account_number"));
                    acc.put("accountType", rs.getString("account_type"));
                    
                    BigDecimal bal = rs.getBigDecimal("balance");
                    acc.put("balance", bal);
                    totalBalance = totalBalance.add(bal);

                    acc.put("branchName", rs.getString("branch_name"));
                    acc.put("ifscCode", rs.getString("ifsc_code"));
                    acc.put("status", rs.getString("status"));
                    acc.put("createdAt", rs.getTimestamp("created_at"));

                    accounts.add(acc);
                }
            }

            request.setAttribute("accounts", accounts);
            request.setAttribute("totalBalance", totalBalance);
            request.getRequestDispatcher("/account/list.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error loading accounts: " + e.getMessage());
            request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
