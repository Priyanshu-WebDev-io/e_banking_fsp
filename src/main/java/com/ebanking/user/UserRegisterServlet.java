package com.ebanking.user;

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

@WebServlet("/user/register")
public class UserRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp?role=user");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            String f = request.getParameter("firstName");
            String l = request.getParameter("lastName");
            name = (f != null ? f.trim() : "") + (l != null ? " " + l.trim() : "");
        }

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Basic validation for required fields: name, email, password, confirmPassword
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Name, email, and password are required.");
            request.setAttribute("selectedRole", "USER");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate password confirmation if provided
        if (confirmPassword != null && !confirmPassword.trim().isEmpty() && !password.equals(confirmPassword)) {
            request.setAttribute("error", "Password and Confirm Password do not match.");
            request.setAttribute("selectedRole", "USER");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        name = name.trim();
        String firstName = name;
        String lastName = "";
        int spaceIdx = name.indexOf(' ');
        if (spaceIdx > 0) {
            firstName = name.substring(0, spaceIdx).trim();
            lastName = name.substring(spaceIdx + 1).trim();
        }

        String sql = """
                INSERT INTO users (first_name, last_name, email, password_hash)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email.trim());
            ps.setString(4, password);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true&role=user");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.setAttribute("selectedRole", "USER");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            log("User registration error", e);
            String errorMsg = "Registration failed.";
            if (e.getErrorCode() == 1062 || (e.getMessage() != null && e.getMessage().toLowerCase().contains("duplicate"))) {
                errorMsg = "An account with this email address already exists. Please login instead.";
            } else {
                errorMsg = "Database error: " + e.getMessage();
            }
            request.setAttribute("error", errorMsg);
            request.setAttribute("selectedRole", "USER");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
