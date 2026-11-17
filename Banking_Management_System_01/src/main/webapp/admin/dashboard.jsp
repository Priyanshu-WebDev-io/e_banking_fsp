<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    String adminUsername = (String) session.getAttribute("adminUsername");

    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    if (totalCustomers == null) totalCustomers = 0;

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> customers = (List<Map<String, Object>>) request.getAttribute("customers");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("accounts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 18px;
        }
        .stat-icon {
            width: 54px;
            height: 54px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }
        .stat-info h4 {
            font-size: 0.82rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.7rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            margin-top: 24px;
        }
        .section-header h3 {
            font-size: 1.25rem;
            color: var(--text-main);
            font-weight: 700;
        }
        .badge-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .badge-active {
            background-color: var(--success-bg);
            color: var(--success);
        }
        .badge-type {
            background-color: var(--primary-light);
            color: var(--primary);
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .nav-admin-badge {
            background-color: #fee2e2;
            color: #991b1b;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            margin-right: 8px;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🛡️ E-Banking Admin Portal</h2>
        <div class="user-info">
            <span class="nav-admin-badge">Admin</span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">👥</div>
            <div class="stat-info">
                <h4>Total Customers</h4>
                <div class="stat-value"><%= totalCustomers %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">🏦</div>
            <div class="stat-info">
                <h4>Total Bank Accounts</h4>
                <div class="stat-value"><%= totalAccounts %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">💰</div>
            <div class="stat-info">
                <h4>Total Deposits Managed</h4>
                <div class="stat-value" style="color: var(--success);"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>
    </div>

    <!-- Customer Management Table -->
    <div class="card" id="customers" style="margin-bottom: 24px;">
        <div class="section-header">
            <h3>👥 Registered Customers (<%= customers != null ? customers.size() : 0 %>)</h3>
            <span style="font-size: 0.85rem; color: var(--text-muted);">Real-time database records</span>
        </div>

        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 8%;">User ID</th>
                        <th style="width: 20%;">Full Name</th>
                        <th style="width: 24%;">Email Address</th>
                        <th style="width: 16%;">Phone Number</th>
                        <th style="width: 14%;">City, State</th>
                        <th style="width: 8%;">Status</th>
                        <th style="width: 10%;">Registered</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (customers != null && !customers.isEmpty()) {
                            for (Map<String, Object> c : customers) {
                                String name = c.get("firstName") + " " + c.get("lastName");
                                String loc = (c.get("city") != null ? c.get("city") : "") +
                                             (c.get("state") != null ? ", " + c.get("state") : "");
                                if (loc.trim().isEmpty() || loc.trim().equals(",")) loc = "-";
                                String regDate = c.get("createdAt") != null ? c.get("createdAt").toString().substring(0, 10) : "-";
                    %>
                        <tr>
                            <td><strong>#<%= c.get("userId") %></strong></td>
                            <td><strong><%= name %></strong></td>
                            <td><%= c.get("email") %></td>
                            <td><%= c.get("phone") %></td>
                            <td><%= loc %></td>
                            <td><span class="badge-status badge-active"><%= c.get("status") %></span></td>
                            <td style="font-size: 0.85rem; color: var(--text-muted);"><%= regDate %></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                                No customers registered yet.
                            </td>
                        </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Accounts Management Table -->
    <div class="card" id="accounts">
        <div class="section-header">
            <h3>🏦 Bank Accounts (<%= accounts != null ? accounts.size() : 0 %>)</h3>
            <span style="font-size: 0.85rem; color: var(--text-muted);">All active customer accounts</span>
        </div>

        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 8%;">Acc ID</th>
                        <th style="width: 18%;">Account Number</th>
                        <th style="width: 20%;">Account Holder</th>
                        <th style="width: 14%;">Account Type</th>
                        <th style="width: 16%;">Balance</th>
                        <th style="width: 14%;">IFSC / Branch</th>
                        <th style="width: 10%;">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (accounts != null && !accounts.isEmpty()) {
                            for (Map<String, Object> a : accounts) {
                                BigDecimal bal = (BigDecimal) a.get("balance");
                                if (bal == null) bal = BigDecimal.ZERO;
                    %>
                        <tr>
                            <td><strong>#<%= a.get("accountId") %></strong></td>
                            <td>
                                <strong style="letter-spacing: 0.5px; color: var(--primary);">
                                    <%= a.get("accountNumber") %>
                                </strong>
                            </td>
                            <td>
                                <strong><%= a.get("customerName") %></strong><br>
                                <small style="color: var(--text-muted);"><%= a.get("customerEmail") %></small>
                            </td>
                            <td><span class="badge-type"><%= a.get("accountType") %></span></td>
                            <td>
                                <strong style="color: var(--success); font-size: 1.05rem;">
                                    <%= currencyFormat.format(bal) %>
                                </strong>
                            </td>
                            <td>
                                <small><strong><%= a.get("ifscCode") %></strong></small><br>
                                <small style="color: var(--text-muted);"><%= a.get("branchName") %></small>
                            </td>
                            <td><span class="badge-status badge-active"><%= a.get("status") %></span></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                                No bank accounts created yet.
                            </td>
                        </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
