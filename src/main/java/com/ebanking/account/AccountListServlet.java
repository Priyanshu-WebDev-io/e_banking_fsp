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
                SELECT a.account_id, a.account_number, a.account_type, a.balance,
                       a.branch_name, a.ifsc_code, a.status, a.created_at,
                       COALESCE(b.bank_name, 'Partner Bank') AS bank_name,
                       COALESCE(b.bank_code, 'BANK') AS bank_code
                FROM accounts a
                LEFT JOIN banks b ON a.bank_id = b.bank_id
                WHERE a.user_id = ?
                ORDER BY a.created_at DESC
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
                    acc.put("bankName", rs.getString("bank_name"));
                    acc.put("bankCode", rs.getString("bank_code"));

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
