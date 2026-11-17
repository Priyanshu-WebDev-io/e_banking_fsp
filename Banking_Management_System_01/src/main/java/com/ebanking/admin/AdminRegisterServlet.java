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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp?role=admin");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            name = request.getParameter("fullName");
        }

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Name, email, and password are required.");
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (confirmPassword != null && !confirmPassword.trim().isEmpty() && !password.equals(confirmPassword)) {
            request.setAttribute("error", "Password and Confirm Password do not match.");
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        name = name.trim();

        // Generate username from email (e.g. "admin_john" from "admin_john@domain.com")
        String username = email.contains("@") ? email.substring(0, email.indexOf('@')) : email;

        String sql = """
                INSERT INTO admins (full_name, email, username, password_hash)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, username);
            ps.setString(4, password);

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
                errorMsg = "An administrator account with this email already exists.";
            } else {
                errorMsg = "Database error: " + e.getMessage();
            }
            request.setAttribute("error", errorMsg);
            request.setAttribute("selectedRole", "ADMIN");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
