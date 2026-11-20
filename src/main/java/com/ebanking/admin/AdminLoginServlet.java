package com.ebanking.admin;

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

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("adminId") != null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Please provide both admin username and password.");
            request.setAttribute("selectedRole", "PLATFORM_ADMIN");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String sql = """
                SELECT admin_id, username, password_hash, full_name, email
                FROM admins
                WHERE username = ? OR email = ?
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
                        session.setAttribute("adminId", rs.getInt("admin_id"));
                        session.setAttribute("adminUsername", rs.getString("username"));
                        session.setAttribute("adminName", rs.getString("full_name"));
                        session.setAttribute("adminEmail", rs.getString("email"));
                        session.setAttribute("role", "PLATFORM_ADMIN");

                        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                        return;
                    }
                }
            }

            request.setAttribute("error", "Invalid administrator credentials. Please try again.");
            request.setAttribute("selectedRole", "PLATFORM_ADMIN");
            request.getRequestDispatcher("/login.jsp").forward(request, response);

        } catch (SQLException e) {
            log("Admin login error", e);
            request.setAttribute("error", "Database connection failed. Please contact technical support.");
            request.setAttribute("selectedRole", "PLATFORM_ADMIN");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
