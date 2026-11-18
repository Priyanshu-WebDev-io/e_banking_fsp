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

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    Integer savingsCount = (Integer) request.getAttribute("savingsCount");
    if (savingsCount == null) savingsCount = 0;

    Integer currentCount = (Integer) request.getAttribute("currentCount");
    if (currentCount == null) currentCount = 0;

    String selectedBank = (String) request.getAttribute("selectedBank");
    String selectedType = (String) request.getAttribute("selectedType");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("accounts");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> banks = (List<Map<String, Object>>) request.getAttribute("banks");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Accounts Registry - E-Banking Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
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
        <a href="${pageContext.request.contextPath}/admin/customers" class="nav-link">👥 Customers</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link active">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">🏦</div>
            <div class="stat-info">
                <h4>Total Bank Accounts</h4>
                <div class="stat-value"><%= totalAccounts %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f0fdf4; color: #15803d;">💰</div>
            <div class="stat-info">
                <h4>Total Deposits Held</h4>
                <div class="stat-value" style="color: var(--success); font-size: 1.35rem;"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fefce8; color: #a16207;">🌱</div>
            <div class="stat-info">
                <h4>Savings Accounts</h4>
                <div class="stat-value"><%= savingsCount %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f5f3ff; color: #7c3aed;">🏢</div>
            <div class="stat-info">
                <h4>Current Accounts</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= currentCount %></div>
            </div>
        </div>
    </div>

    <!-- Accounts Table Card -->
    <div class="card" style="margin-bottom: 40px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 18px;">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main);">🏦 System-wide Accounts Registry (<%= accounts != null ? accounts.size() : 0 %>)</h3>
                <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 2px;">
                    Central repository of Savings and Current accounts linked across all partner institutions.
                </p>
            </div>

            <!-- Filter Form -->
            <form action="${pageContext.request.contextPath}/admin/accounts" method="get" style="display: flex; gap: 8px; flex-wrap: wrap;">
                <select name="bankId" style="padding: 6px 10px; font-size: 0.85rem; border: 1px solid var(--border); border-radius: 6px;">
                    <option value="ALL">All Partner Banks</option>
                    <% if (banks != null) {
                        for (Map<String, Object> b : banks) {
                            String bIdStr = String.valueOf(b.get("bankId"));
                            boolean isSel = bIdStr.equals(selectedBank);
                    %>
                        <option value="<%= bIdStr %>" <%= isSel ? "selected" : "" %>><%= b.get("bankName") %></option>
                    <%  }
                    } %>
                </select>

                <select name="type" style="padding: 6px 10px; font-size: 0.85rem; border: 1px solid var(--border); border-radius: 6px;">
                    <option value="ALL" <%= "ALL".equals(selectedType) ? "selected" : "" %>>All Account Types</option>
                    <option value="SAVINGS" <%= "SAVINGS".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Savings</option>
                    <option value="CURRENT" <%= "CURRENT".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Current</option>
                </select>

                <button type="submit" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Filter</button>
                <% if ((selectedBank != null && !"ALL".equals(selectedBank)) || (selectedType != null && !"ALL".equals(selectedType))) { %>
                    <a href="${pageContext.request.contextPath}/admin/accounts" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.85rem;">Reset</a>
                <% } %>
            </form>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Account Number</th>
                        <th>Customer Details</th>
                        <th>Holding Bank</th>
                        <th>Type</th>
                        <th>Branch & IFSC</th>
                        <th>Current Balance</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (accounts != null && !accounts.isEmpty()) {
                        for (Map<String, Object> a : accounts) {
                            String accNum = (String) a.get("accountNumber");
                            String cName = (String) a.get("customerName");
                            String cEmail = (String) a.get("customerEmail");
                            String bName = (String) a.get("bankName");
                            String aType = (String) a.get("accountType");
                            String branch = (String) a.get("branchName");
                            String ifsc = (String) a.get("ifscCode");
                            BigDecimal bal = (BigDecimal) a.get("balance");
                            String status = (String) a.get("status");
                            java.sql.Timestamp created = (java.sql.Timestamp) a.get("createdAt");
                %>
                    <tr>
                        <td>
                            <code><%= accNum %></code><br>
                            <small style="color: var(--text-muted);"><%= created != null ? created.toString().substring(0, 10) : "" %></small>
                        </td>
                        <td>
                            <strong><%= cName %></strong><br>
                            <small style="color: var(--text-muted);"><%= cEmail %></small>
                        </td>
                        <td>
                            <small>🏛️ <%= bName %></small>
                        </td>
                        <td>
                            <span class="badge badge-type" style="font-size: 0.72rem;"><%= aType %></span>
                        </td>
                        <td>
                            <small><%= branch != null ? branch : "" %><br><code><%= ifsc %></code></small>
                        </td>
                        <td>
                            <strong style="color: var(--success); font-size: 0.95rem;"><%= currencyFormat.format(bal) %></strong>
                        </td>
                        <td>
                            <span class="badge badge-active" style="font-size: 0.72rem;"><%= status %></span>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No bank accounts found matching the selected filter.
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
