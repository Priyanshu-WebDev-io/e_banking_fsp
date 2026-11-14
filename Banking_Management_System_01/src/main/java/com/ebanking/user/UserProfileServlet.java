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

@WebServlet("/user/profile")
public class UserProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String sql = "SELECT * FROM users WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String email = rs.getString("email");
                    String phone = rs.getString("phone");
                    String dob = rs.getString("date_of_birth");
                    String address = rs.getString("address");
                    String city = rs.getString("city");
                    String state = rs.getString("state");
                    String pincode = rs.getString("pincode");
                    String status = rs.getString("status");

                    // Set request attributes
                    request.setAttribute("userId", userId);
                    request.setAttribute("firstName", firstName);
                    request.setAttribute("lastName", lastName);
                    request.setAttribute("email", email);
                    request.setAttribute("phone", phone);
                    request.setAttribute("dateOfBirth", dob);
                    request.setAttribute("address", address);
                    request.setAttribute("city", city);
                    request.setAttribute("state", state);
                    request.setAttribute("pincode", pincode);
                    request.setAttribute("status", status);

                    // Refresh session attributes
                    session.setAttribute("firstName", firstName);
                    session.setAttribute("lastName", lastName);
                    session.setAttribute("email", email);
                    session.setAttribute("phone", phone);
                    session.setAttribute("dateOfBirth", dob);
                    session.setAttribute("address", address);
                    session.setAttribute("city", city);
                    session.setAttribute("state", state);
                    session.setAttribute("pincode", pincode);
                    session.setAttribute("status", status);

                    Map<String, Object> userMap = new HashMap<>();
                    userMap.put("userId", userId);
                    userMap.put("firstName", firstName);
                    userMap.put("lastName", lastName);
                    userMap.put("email", email);
                    userMap.put("phone", phone);
                    userMap.put("dateOfBirth", dob);
                    userMap.put("address", address);
                    userMap.put("city", city);
                    userMap.put("state", state);
                    userMap.put("pincode", pincode);
                    userMap.put("status", status);
                    session.setAttribute("user", userMap);

                    request.getRequestDispatcher("/user/profile.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "User profile not found.");
                    request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
