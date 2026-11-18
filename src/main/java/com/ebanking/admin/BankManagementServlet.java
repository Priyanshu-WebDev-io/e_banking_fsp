package com.ebanking.admin;

import com.ebanking.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/banks")
public class BankManagementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        List<Map<String, Object>> banks = new ArrayList<>();
        int activeCount = 0;
        BigDecimal sumCommission = BigDecimal.ZERO;

        String sql = """
                SELECT b.bank_id,
                       b.bank_name,
                       b.bank_code,
                       b.ifsc_prefix,
                       b.commission_rate,
                       b.status,
                       b.created_at,
                       (SELECT COUNT(*) FROM accounts a WHERE a.bank_id = b.bank_id) AS total_accounts,
                       (SELECT COALESCE(SUM(a.balance), 0) FROM accounts a WHERE a.bank_id = b.bank_id) AS total_deposits
                FROM banks b
                ORDER BY b.bank_id ASC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> bank = new HashMap<>();
                int bankId = rs.getInt("bank_id");
                String bankName = rs.getString("bank_name");
                String bankCode = rs.getString("bank_code");
                String ifscPrefix = rs.getString("ifsc_prefix");
                BigDecimal commissionRate = rs.getBigDecimal("commission_rate");
                String status = rs.getString("status");
                int totalAccounts = rs.getInt("total_accounts");
                BigDecimal totalDeposits = rs.getBigDecimal("total_deposits");

                bank.put("bankId", bankId);
                bank.put("bankName", bankName);
                bank.put("bankCode", bankCode);
                bank.put("ifscPrefix", ifscPrefix);
                bank.put("commissionRate", commissionRate);
                bank.put("status", status);
                bank.put("createdAt", rs.getTimestamp("created_at"));
                bank.put("totalAccounts", totalAccounts);
                bank.put("totalDeposits", totalDeposits);

                banks.add(bank);

                if ("ACTIVE".equalsIgnoreCase(status)) {
                    activeCount++;
                }
                if (commissionRate != null) {
                    sumCommission = sumCommission.add(commissionRate);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading partner banks: " + e.getMessage());
        }

        BigDecimal avgCommission = BigDecimal.ZERO;
        if (!banks.isEmpty()) {
            avgCommission = sumCommission.divide(new BigDecimal(banks.size()), 2, RoundingMode.HALF_UP);
        }

        request.setAttribute("banks", banks);
        request.setAttribute("totalBanks", banks.size());
        request.setAttribute("activeBanks", activeCount);
        request.setAttribute("avgCommission", avgCommission);

        request.getRequestDispatcher("/admin/banks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/banks");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            if ("add".equalsIgnoreCase(action)) {
                String bankName = request.getParameter("bankName");
                String bankCode = request.getParameter("bankCode");
                String ifscPrefix = request.getParameter("ifscPrefix");
                String commissionRateStr = request.getParameter("commissionRate");

                if (bankName == null || bankName.trim().isEmpty() ||
                    bankCode == null || bankCode.trim().isEmpty() ||
                    ifscPrefix == null || ifscPrefix.trim().isEmpty() ||
                    commissionRateStr == null || commissionRateStr.trim().isEmpty()) {

                    response.sendRedirect(request.getContextPath() + "/admin/banks?error=missing_fields");
                    return;
                }

                BigDecimal commissionRate = new BigDecimal(commissionRateStr.trim());

                String insertSql = """
                        INSERT INTO banks (bank_name, bank_code, ifsc_prefix, commission_rate, status)
                        VALUES (?, UPPER(?), UPPER(?), ?, 'ACTIVE')
                        """;

                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setString(1, bankName.trim());
                    ps.setString(2, bankCode.trim());
                    ps.setString(3, ifscPrefix.trim());
                    ps.setBigDecimal(4, commissionRate);
                    ps.executeUpdate();
                }

                response.sendRedirect(request.getContextPath() + "/admin/banks?success=added");
                return;

            } else if ("update_commission".equalsIgnoreCase(action)) {
                String bankIdStr = request.getParameter("bankId");
                String commissionRateStr = request.getParameter("commissionRate");

                if (bankIdStr != null && commissionRateStr != null) {
                    int bankId = Integer.parseInt(bankIdStr.trim());
                    BigDecimal commissionRate = new BigDecimal(commissionRateStr.trim());

                    String updateSql = "UPDATE banks SET commission_rate = ? WHERE bank_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                        ps.setBigDecimal(1, commissionRate);
                        ps.setInt(2, bankId);
                        ps.executeUpdate();
                    }
                }

                response.sendRedirect(request.getContextPath() + "/admin/banks?success=updated");
                return;

            } else if ("toggle_status".equalsIgnoreCase(action)) {
                String bankIdStr = request.getParameter("bankId");
                String currentStatus = request.getParameter("currentStatus");

                if (bankIdStr != null) {
                    int bankId = Integer.parseInt(bankIdStr.trim());
                    String nextStatus = "ACTIVE".equalsIgnoreCase(currentStatus) ? "SUSPENDED" : "ACTIVE";

                    String statusSql = "UPDATE banks SET status = ? WHERE bank_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(statusSql)) {
                        ps.setString(1, nextStatus);
                        ps.setInt(2, bankId);
                        ps.executeUpdate();
                    }
                }

                response.sendRedirect(request.getContextPath() + "/admin/banks?success=status");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/banks?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/banks");
    }
}
