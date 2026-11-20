<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer bankAdminId = (Integer) session.getAttribute("bankAdminId");
    if (bankAdminId == null) {
        response.sendRedirect(request.getContextPath() + "/bank-admin/login.jsp");
        return;
    }

    String bankAdminName = (String) session.getAttribute("bankAdminName");
    String bankAdminBankName = (String) session.getAttribute("bankAdminBankName");
    if (bankAdminBankName == null || bankAdminBankName.isEmpty()) {
        bankAdminBankName = "All Partner Banks";
    }

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
    <title>Customer Directory - Bank Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 18px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .stat-info h4 {
            font-size: 0.78rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .bank-nav-bar {
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
        .bank-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .bank-nav-bar .nav-link:hover {
            background: #ecfdf5;
            color: #047857;
        }
        .bank-nav-bar .nav-link.active {
            background: #059669;
            color: #ffffff;
        }
        .search-box {
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
        }
        .search-box input {
            flex: 1;
            padding: 9px 14px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🏦 Bank Admin Operations Portal</h2>
        <div class="user-info">
            <span class="badge" style="background: #d1fae5; color: #065f46; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">
                🏛️ <%= bankAdminBankName %>
            </span>
            <span>Welcome, <strong><%= bankAdminName %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/bank-admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="bank-nav-bar">
        <a href="${pageContext.request.contextPath}/bank-admin/dashboard" class="nav-link">📊 Operations Command</a>
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="nav-link active">👥 Customer Directory</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Customer account status updated.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
        </div>
    <% } %>

    <!-- KPI Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">👥</div>
            <div class="stat-info">
                <h4>Registered Customers</h4>
                <div class="stat-value"><%= totalUsers %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #dcfce7; color: #166534;">✅</div>
            <div class="stat-info">
                <h4>Active Customers</h4>
                <div class="stat-value" style="color: #166534;"><%= activeUsers %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fee2e2; color: #991b1b;">⚠️</div>
            <div class="stat-info">
                <h4>Suspended Customers</h4>
                <div class="stat-value" style="color: #991b1b;"><%= suspendedUsers %></div>
            </div>
        </div>
    </div>

    <!-- Search Form -->
    <form action="${pageContext.request.contextPath}/bank-admin/customers" method="get" class="search-box">
        <input type="text" name="search" value="<%= searchQuery %>" placeholder="Search customer by name, email, or phone number...">
        <button type="submit" class="btn btn-primary" style="padding: 9px 18px;">Search</button>
        <% if (!searchQuery.isEmpty()) { %>
            <a href="${pageContext.request.contextPath}/bank-admin/customers" class="btn btn-secondary" style="padding: 9px 14px;">Clear</a>
        <% } %>
    </form>

    <!-- Customers Table -->
    <div class="card">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Customer ID</th>
                        <th>Full Name</th>
                        <th>Email & Phone</th>
                        <th>City / State</th>
                        <th>Linked Accounts</th>
                        <th>Total Balance</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (customers != null && !customers.isEmpty()) {
                        for (Map<String, Object> c : customers) {
                            String st = (String) c.get("status");
                            boolean isActive = "ACTIVE".equalsIgnoreCase(st);
                            int userId = (Integer) c.get("userId");
                    %>
                        <tr>
                            <td>#<%= userId %></td>
                            <td><strong><%= c.get("firstName") %> <%= c.get("lastName") %></strong></td>
                            <td>
                                <div><%= c.get("email") %></div>
                                <div style="font-size: 0.8rem; color: #64748b;"><%= c.get("phone") != null ? c.get("phone") : "-" %></div>
                            </td>
                            <td><%= c.get("city") != null ? c.get("city") : "-" %>, <%= c.get("state") != null ? c.get("state") : "" %></td>
                            <td>
                                <span class="badge" style="background: #e0f2fe; color: #0369a1;">
                                    <%= c.get("accountCount") %> Account(s)
                                </span>
                            </td>
                            <td style="font-weight: 700; color: #166534;"><%= currencyFormat.format(c.get("totalBalance")) %></td>
                            <td>
                                <span class="badge" style="<%= isActive ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;" %>">
                                    <%= st %>
                                </span>
                            </td>
                            <td>
                                <form action="${pageContext.request.contextPath}/bank-admin/customers" method="post" style="display: inline-block;">
                                    <input type="hidden" name="userId" value="<%= userId %>">
                                    <input type="hidden" name="action" value="toggle_status">
                                    <button type="submit" class="btn <%= isActive ? "btn-danger" : "btn-success" %>" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Toggle status for this customer?');">
                                        <%= isActive ? "Suspend" : "Activate" %>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No customers found.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
