package com.ebanking.user;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

@WebServlet("/user/register")
public class UserRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/user/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        // Basic validation for required fields
        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "All required fields must be filled out.");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        String sql = """
                INSERT INTO users
                (first_name, last_name, email, phone, password_hash,
                 date_of_birth, address, city, state, pincode)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName.trim());
            ps.setString(2, lastName.trim());
            ps.setString(3, email.trim());
            ps.setString(4, phone.trim());
            ps.setString(5, password); // Raw for now, can be hashed with BCrypt later

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                ps.setNull(6, Types.DATE);
            } else {
                ps.setDate(6, Date.valueOf(dateOfBirth.trim()));
            }

            ps.setString(7, address != null ? address.trim() : null);
            ps.setString(8, city != null ? city.trim() : null);
            ps.setString(9, state != null ? state.trim() : null);
            ps.setString(10, pincode != null ? pincode.trim() : null);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/user/login.jsp?registered=true");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            String errorMsg = "Registration failed.";
            if (e.getErrorCode() == 1062 || e.getMessage().toLowerCase().contains("duplicate")) {
                errorMsg = "Registration failed: An account with this email or phone already exists.";
            } else {
                errorMsg = "Database error: " + e.getMessage();
            }
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
        }
    }
}
