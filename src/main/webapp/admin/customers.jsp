<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    String adminUsername = (String) session.getAttribute("adminUsername");

    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    if (totalUsers == null) totalUsers = 0;

    Integer activeUsers = (Integer) request.getAttribute("activeUsers");
    if (activeUsers == null) activeUsers = 0;

    Integer suspendedUsers = (Integer) request.getAttribute("suspendedUsers");
    if (suspendedUsers == null) suspendedUsers = 0;

    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> customers = (List<Map<String, Object>>) request.getAttribute("customers");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Management Desk - E-Banking Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
        }
        .stat-info h4 {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .admin-nav-bar {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 24px;
            background: #ffffff;
            padding: 10px 16px;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
        }
        .admin-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .admin-nav-bar .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
        }
        .admin-nav-bar .nav-link.active {
            background: var(--primary);
            color: #ffffff;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🛡️ E-Banking Admin Portal</h2>
        <div class="user-info">
            <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">Admin</span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">📊 Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link">🏛️ Partner Banks</a>
        <a href="${pageContext.request.contextPath}/admin/customers" class="nav-link active">👥 Customers</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Customer operational status updated successfully!
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            ❌ Customer Action Error: <%= errorParam %>
        </div>
    <% } %>

    <!-- Customer Metrics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">👥</div>
            <div class="stat-info">
                <h4>Total Registered Customers</h4>
                <div class="stat-value"><%= totalUsers %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f0fdf4; color: #15803d;">✅</div>
            <div class="stat-info">
                <h4>Active Accounts</h4>
                <div class="stat-value" style="color: var(--success);"><%= activeUsers %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fef2f2; color: #b91c1c;">🚫</div>
            <div class="stat-info">
                <h4>Suspended Customers</h4>
                <div class="stat-value" style="color: var(--danger);"><%= suspendedUsers %></div>
            </div>
        </div>
    </div>

    <!-- Customer Management Table Card -->
    <div class="card" style="margin-bottom: 40px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 18px;">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main);">👥 Registered Customer Accounts (<%= customers != null ? customers.size() : 0 %>)</h3>
                <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 2px;">
                    Full platform customer registry with KYC location data, total holdings, and account regulation.
                </p>
            </div>

            <!-- Search Form -->
            <form action="${pageContext.request.contextPath}/admin/customers" method="get" style="display: flex; gap: 8px;">
                <input type="text" name="search" value="<%= searchQuery %>" placeholder="Search name, email, phone..." style="padding: 6px 12px; font-size: 0.85rem; border: 1px solid var(--border); border-radius: 6px; width: 220px;">
                <button type="submit" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Search</button>
                <% if (!searchQuery.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.85rem;">Clear</a>
                <% } %>
            </form>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>ID & Joined</th>
                        <th>Customer Name</th>
                        <th>Email & Phone</th>
                        <th>Residential Address</th>
                        <th>Accounts & Balance</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (customers != null && !customers.isEmpty()) {
                        for (Map<String, Object> c : customers) {
                            Integer uId = (Integer) c.get("userId");
                            String fName = (String) c.get("firstName");
                            String lName = (String) c.get("lastName");
                            String email = (String) c.get("email");
                            String phone = (String) c.get("phone");
                            String addr = (String) c.get("address");
                            String city = (String) c.get("city");
                            String state = (String) c.get("state");
                            String pin = (String) c.get("pincode");
                            String status = (String) c.get("status");
                            java.sql.Timestamp created = (java.sql.Timestamp) c.get("createdAt");
                            Integer accCount = (Integer) c.get("accountCount");
                            BigDecimal totBal = (BigDecimal) c.get("totalBalance");

                            boolean isActive = "ACTIVE".equalsIgnoreCase(status);
                %>
                    <tr>
                        <td>
                            <strong>#<%= uId %></strong><br>
                            <small style="color: var(--text-muted);"><%= created != null ? created.toString().substring(0, 10) : "" %></small>
                        </td>
                        <td>
                            <strong><%= fName %> <%= lName %></strong>
                        </td>
                        <td>
                            <span><%= email %></span><br>
                            <small style="color: var(--text-muted);">📞 <%= phone != null ? phone : "-" %></small>
                        </td>
                        <td>
                            <small><%= addr != null ? addr : "" %><br><%= city != null ? city : "" %>, <%= state != null ? state : "" %> <%= pin != null ? pin : "" %></small>
                        </td>
                        <td>
                            <strong><%= accCount != null ? accCount : 0 %></strong> accounts<br>
                            <strong style="color: var(--success);"><%= totBal != null ? currencyFormat.format(totBal) : "₹0.00" %></strong>
                        </td>
                        <td>
                            <span class="badge <%= isActive ? "badge-active" : "badge-inactive" %>" style="font-size: 0.72rem;">
                                <%= status %>
                            </span>
                        </td>
                        <td>
                            <form action="${pageContext.request.contextPath}/admin/customers" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="toggle_status">
                                <input type="hidden" name="userId" value="<%= uId %>">
                                <button type="submit" class="btn <%= isActive ? "btn-secondary" : "btn-primary" %>"
                                        style="padding: 4px 10px; font-size: 0.75rem; <%= isActive ? "color: var(--danger); border-color: var(--danger);" : "background: var(--success);" %>"
                                        onclick="return confirm('Change status of customer <%= fName %> <%= lName %> to <%= isActive ? "SUSPENDED" : "ACTIVE" %>?')">
                                    <%= isActive ? "Suspend" : "Activate" %>
                                </button>
                            </form>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No customers found matching your criteria.
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
