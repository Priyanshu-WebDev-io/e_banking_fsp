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
        int totalCards = 0;
        int totalLoans = 0;
        BigDecimal disbursedLoansAmount = BigDecimal.ZERO;

        try (Connection con = DBConnection.getConnection()) {

            // 1. Total liquid balance and accounts
            String accSql = "SELECT COUNT(*), COALESCE(SUM(balance), 0) FROM accounts WHERE user_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalAccounts = rs.getInt(1);
                        totalBalance = rs.getBigDecimal(2);
                    }
                }
            }

            // 2. Active cards
            String cardSql = "SELECT COUNT(*) FROM cards WHERE user_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(cardSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                    }
                }
            }

            // 3. Active loans and disbursed amount
            String loanSql = "SELECT COUNT(*), COALESCE(SUM(principal_amount), 0) FROM loan_applications WHERE user_id = ? AND status = 'DISBURSED'";
            try (PreparedStatement ps = con.prepareStatement(loanSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        disbursedLoansAmount = rs.getBigDecimal(2);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("totalBalance", totalBalance != null ? totalBalance : BigDecimal.ZERO);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalCards", totalCards);
        request.setAttribute("totalLoans", totalLoans);
        request.setAttribute("disbursedLoansAmount", disbursedLoansAmount != null ? disbursedLoansAmount : BigDecimal.ZERO);

        request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
    }
}
