package com.ebanking.account;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/account/details")
public class AccountDetailsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String accParam = request.getParameter("accountNumber");
        String idParam = request.getParameter("accountId");

        if ((accParam == null || accParam.trim().isEmpty()) &&
            (idParam == null || idParam.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/account/list");
            return;
        }

        String sql = """
                SELECT *
                FROM accounts
                WHERE (account_number = ? OR account_id = ?)
                  AND user_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accParam != null ? accParam.trim() : "");
            
            int accountIdVal = 0;
            try {
                if (idParam != null && !idParam.trim().isEmpty()) {
                    accountIdVal = Integer.parseInt(idParam.trim());
                }
            } catch (NumberFormatException ignored) {}
            ps.setInt(2, accountIdVal);
            ps.setInt(3, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    request.setAttribute("accountId", rs.getInt("account_id"));
                    request.setAttribute("accountNumber", rs.getString("account_number"));
                    request.setAttribute("accountType", rs.getString("account_type"));
                    request.setAttribute("balance", rs.getBigDecimal("balance"));
                    request.setAttribute("branchName", rs.getString("branch_name"));
                    request.setAttribute("ifscCode", rs.getString("ifsc_code"));
                    request.setAttribute("status", rs.getString("status"));
                    request.setAttribute("createdAt", rs.getTimestamp("created_at"));

                    request.getRequestDispatcher("/account/details.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Account not found or access denied.");
                    request.getRequestDispatcher("/account/list").forward(request, response);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/account/list").forward(request, response);
        }
    }
}
