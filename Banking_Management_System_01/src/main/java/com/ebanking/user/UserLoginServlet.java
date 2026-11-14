package com.ebanking.user;

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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/user/login")
public class UserLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Please enter both email and password.");
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
            return;
        }

        String sql = """
                SELECT *
                FROM users
                WHERE email = ?
                  AND password_hash = ?
                  AND status = 'ACTIVE'
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = request.getSession();

                    int userId = rs.getInt("user_id");
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String userEmail = rs.getString("email");
                    String phone = rs.getString("phone");
                    String dob = rs.getString("date_of_birth");
                    String address = rs.getString("address");
                    String city = rs.getString("city");
                    String state = rs.getString("state");
                    String pincode = rs.getString("pincode");
                    String status = rs.getString("status");

                    // Store attributes directly in session
                    session.setAttribute("userId", userId);
                    session.setAttribute("firstName", firstName);
                    session.setAttribute("lastName", lastName);
                    session.setAttribute("email", userEmail);
                    session.setAttribute("phone", phone);
                    session.setAttribute("dateOfBirth", dob);
                    session.setAttribute("address", address);
                    session.setAttribute("city", city);
                    session.setAttribute("state", state);
                    session.setAttribute("pincode", pincode);
                    session.setAttribute("status", status);

                    // Also store a map for flexible JSP Expression Language access
                    Map<String, Object> userMap = new HashMap<>();
                    userMap.put("userId", userId);
                    userMap.put("firstName", firstName);
                    userMap.put("lastName", lastName);
                    userMap.put("email", userEmail);
                    userMap.put("phone", phone);
                    userMap.put("dateOfBirth", dob);
                    userMap.put("address", address);
                    userMap.put("city", city);
                    userMap.put("state", state);
                    userMap.put("pincode", pincode);
                    userMap.put("status", status);
                    session.setAttribute("user", userMap);

                    response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
                } else {
                    request.setAttribute("error", "Invalid email or password, or account is inactive.");
                    request.getRequestDispatcher("/user/login.jsp").forward(request, response);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database connection error: " + e.getMessage());
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
        }
    }
}
