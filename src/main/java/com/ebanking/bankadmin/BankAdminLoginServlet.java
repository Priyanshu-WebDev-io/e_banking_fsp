package com.ebanking.bankadmin;

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

@WebServlet({"/bank-admin/login", "/bank-admin/auth"})
public class BankAdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("bankAdminId") != null) {
            response.sendRedirect(request.getContextPath() + "/bank-admin/dashboard");
            return;
        }
        request.getRequestDispatcher("/bank-admin/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Please provide both bank admin username/email and password.");
            request.getRequestDispatcher("/bank-admin/login.jsp").forward(request, response);
            return;
        }

        String sql = """
                SELECT ba.bank_admin_id, ba.bank_id, ba.username, ba.password_hash,
                       ba.full_name, ba.email,
                       b.bank_name, b.bank_code
                FROM bank_admins ba
                LEFT JOIN banks b ON ba.bank_id = b.bank_id
                WHERE ba.username = ? OR ba.email = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String identifier = username.trim();
            ps.setString(1, identifier);
            ps.setString(2, identifier);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password_hash");

                    if (storedPassword != null && storedPassword.equals(password)) {
                        HttpSession oldSession = request.getSession(false);
                        if (oldSession != null) {
                            oldSession.invalidate();
                        }

                        HttpSession session = request.getSession(true);
                        session.setAttribute("bankAdminId", rs.getInt("bank_admin_id"));
                        session.setAttribute("bankAdminUsername", rs.getString("username"));
                        session.setAttribute("bankAdminName", rs.getString("full_name"));
                        session.setAttribute("bankAdminEmail", rs.getString("email"));

                        int bankId = rs.getInt("bank_id");
                        if (!rs.wasNull()) {
                            session.setAttribute("bankAdminBankId", bankId);
                            session.setAttribute("bankAdminBankName", rs.getString("bank_name"));
                            session.setAttribute("bankAdminBankCode", rs.getString("bank_code"));
                        } else {
                            session.setAttribute("bankAdminBankId", null);
                            session.setAttribute("bankAdminBankName", "All Partner Banks");
                            session.setAttribute("bankAdminBankCode", "ALL");
                        }
                        session.setAttribute("role", "BANK_ADMIN");

                        response.sendRedirect(request.getContextPath() + "/bank-admin/dashboard");
                        return;
                    }
                }
            }

            request.setAttribute("error", "Invalid bank administrator credentials. Please try again.");
            request.getRequestDispatcher("/bank-admin/login.jsp").forward(request, response);

        } catch (SQLException e) {
            log("Bank Admin login error", e);
            request.setAttribute("error", "Database connection error: " + e.getMessage());
            request.getRequestDispatcher("/bank-admin/login.jsp").forward(request, response);
        }
    }
}
