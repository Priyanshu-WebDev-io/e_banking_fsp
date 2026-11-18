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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/customers")
public class AdminCustomersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String search = request.getParameter("search");
        int totalUsers = 0;
        int activeUsers = 0;
        int suspendedUsers = 0;

        List<Map<String, Object>> customers = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            // 1. Metrics
            String metricSql = """
                    SELECT COUNT(*),
                           COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END), 0),
                           COALESCE(SUM(CASE WHEN status = 'SUSPENDED' THEN 1 ELSE 0 END), 0)
                    FROM users
                    """;
            try (PreparedStatement ps = con.prepareStatement(metricSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalUsers = rs.getInt(1);
                    activeUsers = rs.getInt(2);
                    suspendedUsers = rs.getInt(3);
                }
            }

            // 2. Customers List with Account Count
            StringBuilder sql = new StringBuilder("""
                    SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone,
                           u.address, u.city, u.state, u.pincode, u.status, u.created_at,
                           (SELECT COUNT(*) FROM accounts a WHERE a.user_id = u.user_id) AS account_count,
                           (SELECT COALESCE(SUM(balance), 0) FROM accounts a WHERE a.user_id = u.user_id) AS total_balance
                    FROM users u
                    """);

            boolean hasSearch = (search != null && !search.trim().isEmpty());
            if (hasSearch) {
                sql.append(" WHERE u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ? ");
            }
            sql.append(" ORDER BY u.user_id DESC");

            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                if (hasSearch) {
                    String pattern = "%" + search.trim() + "%";
                    ps.setString(1, pattern);
                    ps.setString(2, pattern);
                    ps.setString(3, pattern);
                    ps.setString(4, pattern);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> c = new HashMap<>();
                        c.put("userId", rs.getInt("user_id"));
                        c.put("firstName", rs.getString("first_name"));
                        c.put("lastName", rs.getString("last_name"));
                        c.put("email", rs.getString("email"));
                        c.put("phone", rs.getString("phone"));
                        c.put("address", rs.getString("address"));
                        c.put("city", rs.getString("city"));
                        c.put("state", rs.getString("state"));
                        c.put("pincode", rs.getString("pincode"));
                        c.put("status", rs.getString("status"));
                        c.put("createdAt", rs.getTimestamp("created_at"));
                        c.put("accountCount", rs.getInt("account_count"));
                        c.put("totalBalance", rs.getBigDecimal("total_balance"));
                        customers.add(c);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("suspendedUsers", suspendedUsers);
        request.setAttribute("customers", customers);
        request.setAttribute("searchQuery", search != null ? search.trim() : "");

        request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String userIdStr = request.getParameter("userId");
        String action = request.getParameter("action");

        if ("toggle_status".equalsIgnoreCase(action) && userIdStr != null) {
            try (Connection con = DBConnection.getConnection()) {
                int userId = Integer.parseInt(userIdStr.trim());
                String sql = "UPDATE users SET status = CASE WHEN status = 'ACTIVE' THEN 'SUSPENDED' ELSE 'ACTIVE' END WHERE user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getContextPath() + "/admin/customers?success=status_updated");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/customers?error=" +
                        java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Update failed", "UTF-8"));
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }
}
