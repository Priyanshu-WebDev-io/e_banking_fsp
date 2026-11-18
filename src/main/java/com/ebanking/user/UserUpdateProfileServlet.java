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
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/user/update-profile")
public class UserUpdateProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        // Fetch latest details to populate edit form
        String sql = "SELECT * FROM users WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    session.setAttribute("firstName", rs.getString("first_name"));
                    session.setAttribute("lastName", rs.getString("last_name"));
                    session.setAttribute("email", rs.getString("email"));
                    session.setAttribute("phone", rs.getString("phone"));
                    session.setAttribute("dateOfBirth", rs.getString("date_of_birth"));
                    session.setAttribute("address", rs.getString("address"));
                    session.setAttribute("city", rs.getString("city"));
                    session.setAttribute("state", rs.getString("state"));
                    session.setAttribute("pincode", rs.getString("pincode"));
                    session.setAttribute("status", rs.getString("status"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/user/edit-profile.jsp").forward(request, response);
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

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phone = request.getParameter("phone");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {

            request.setAttribute("error", "First name, last name, and phone cannot be empty.");
            request.getRequestDispatcher("/user/edit-profile.jsp").forward(request, response);
            return;
        }

        String sql = """
                UPDATE users
                SET first_name = ?,
                    last_name = ?,
                    phone = ?,
                    date_of_birth = ?,
                    address = ?,
                    city = ?,
                    state = ?,
                    pincode = ?
                WHERE user_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName.trim());
            ps.setString(2, lastName.trim());
            ps.setString(3, phone.trim());

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                ps.setNull(4, Types.DATE);
            } else {
                ps.setDate(4, Date.valueOf(dateOfBirth.trim()));
            }

            ps.setString(5, address != null ? address.trim() : null);
            ps.setString(6, city != null ? city.trim() : null);
            ps.setString(7, state != null ? state.trim() : null);
            ps.setString(8, pincode != null ? pincode.trim() : null);
            ps.setInt(9, userId);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                // Update session attributes
                session.setAttribute("firstName", firstName.trim());
                session.setAttribute("lastName", lastName.trim());
                session.setAttribute("phone", phone.trim());
                session.setAttribute("dateOfBirth", dateOfBirth);
                session.setAttribute("address", address);
                session.setAttribute("city", city);
                session.setAttribute("state", state);
                session.setAttribute("pincode", pincode);

                // Update user map in session
                @SuppressWarnings("unchecked")
                Map<String, Object> userMap = (Map<String, Object>) session.getAttribute("user");
                if (userMap != null) {
                    userMap.put("firstName", firstName.trim());
                    userMap.put("lastName", lastName.trim());
                    userMap.put("phone", phone.trim());
                    userMap.put("dateOfBirth", dateOfBirth);
                    userMap.put("address", address);
                    userMap.put("city", city);
                    userMap.put("state", state);
                    userMap.put("pincode", pincode);
                }

                response.sendRedirect(request.getContextPath() + "/user/profile");
            } else {
                request.setAttribute("error", "Profile update failed. User not found.");
                request.getRequestDispatcher("/user/edit-profile.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/user/edit-profile.jsp").forward(request, response);
        }
    }
}
