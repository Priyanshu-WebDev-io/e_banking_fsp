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
import java.sql.SQLException;
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

        String accountType = request.getParameter("accountType");
        String depositStr = request.getParameter("initialDeposit");
        String branchName = request.getParameter("branchName");

        if (accountType == null || accountType.trim().isEmpty()) {
            accountType = "SAVINGS";
        }

        if (branchName == null || branchName.trim().isEmpty()) {
            branchName = "Main Branch - Mumbai";
        }

        BigDecimal initialDeposit = BigDecimal.valueOf(500);
        try {
            if (depositStr != null && !depositStr.trim().isEmpty()) {
                initialDeposit = new BigDecimal(depositStr.trim());
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Please enter a valid numeric deposit amount.");
            request.getRequestDispatcher("/account/create.jsp").forward(request, response);
            return;
        }

        if (initialDeposit.compareTo(BigDecimal.valueOf(500)) < 0) {
            request.setAttribute("error", "Minimum initial deposit is ₹500.");
            request.getRequestDispatcher("/account/create.jsp").forward(request, response);
            return;
        }

        // Generate unique 12-digit account number (Prefix: 1001)
        Random random = new Random();
        long randomSuffix = 10000000L + (long)(random.nextDouble() * 90000000L);
        String accountNumber = "1001" + randomSuffix;

        // IFSC code based on branch
        String ifscCode = "EBANK000101";
        if (branchName.contains("Delhi")) {
            ifscCode = "EBANK000201";
        } else if (branchName.contains("Bengaluru")) {
            ifscCode = "EBANK000301";
        } else if (branchName.contains("Kolkata")) {
            ifscCode = "EBANK000401";
        } else if (branchName.contains("Hyderabad")) {
            ifscCode = "EBANK000501";
        }

        String sql = """
                INSERT INTO accounts
                (account_number, user_id, account_type, balance, branch_name, ifsc_code, status)
                VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);
            ps.setInt(2, userId);
            ps.setString(3, accountType);
            ps.setBigDecimal(4, initialDeposit);
            ps.setString(5, branchName);
            ps.setString(6, ifscCode);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/account/list?created=" + accountNumber);
            } else {
                request.setAttribute("error", "Failed to open account. Please try again.");
                request.getRequestDispatcher("/account/create.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/account/create.jsp").forward(request, response);
        }
    }
}
