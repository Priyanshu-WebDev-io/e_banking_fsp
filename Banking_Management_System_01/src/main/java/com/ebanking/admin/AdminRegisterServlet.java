package com.ebanking.admin;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/admin/register")
public class AdminRegisterServlet extends HttpServlet {

    private static final String ADMIN_SECRET_KEY = "ADMIN2026";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp?role=admin");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String adminKey = request.getParameter("adminKey");

        if (fullName == null || fullName.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Full name, admin username, and password are required.");
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate admin secret authorization key
        if (adminKey == null || !ADMIN_SECRET_KEY.equalsIgnoreCase(adminKey.trim())) {
            request.setAttribute("error", "Invalid Admin Security Key. Use the authorized system key (ADMIN2026).");
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        String sql = """
                INSERT INTO admins (username, password_hash, full_name, email)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setString(2, password); // Raw password in line with project specification
            ps.setString(3, fullName.trim());
            ps.setString(4, (email != null && !email.trim().isEmpty()) ? email.trim() : null);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true&role=admin");
            } else {
                request.setAttribute("error", "Admin registration failed. Please try again.");
                request.setAttribute("selectedRole", "ADMIN");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            log("Admin registration error", e);
            String errorMsg = "Admin registration failed.";
            if (e.getErrorCode() == 1062 || (e.getMessage() != null && e.getMessage().toLowerCase().contains("duplicate"))) {
                errorMsg = "An administrator account with this username or email already exists.";
            } else {
                errorMsg = "Database error: " + e.getMessage();
            }
            request.setAttribute("error", errorMsg);
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
