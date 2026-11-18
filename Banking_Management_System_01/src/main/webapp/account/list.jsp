<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("accounts");
    BigDecimal totalBalance = (BigDecimal) request.getAttribute("totalBalance");
    if (totalBalance == null) totalBalance = BigDecimal.ZERO;

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
    String createdAcc = request.getParameter("created");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bank Accounts - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .account-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: var(--shadow);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .account-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }
        .account-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 14px;
            margin-bottom: 16px;
        }
        .account-balance-large {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--success);
            margin: 10px 0;
        }
        .account-meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
            margin-top: 14px;
            background: #f8fafc;
            padding: 14px;
            border-radius: 8px;
        }
        .account-meta-item small {
            display: block;
            color: var(--text-muted);
            font-size: 0.8rem;
            text-transform: uppercase;
            font-weight: 600;
        }
        .account-meta-item span {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-main);
        }
        .total-summary-card {
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 100%);
            color: #ffffff;
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: gap;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <div class="navbar-custom">
        <h2>🏦 My Bank Accounts</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Accounts</a>
            <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Transactions</a>
            <a href="${pageContext.request.contextPath}/user/cards" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Cards</a>
            <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Loans</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <% if (createdAcc != null) { %>
        <div class="alert alert-success">
            <strong>Success!</strong> Your new bank account <strong>#<%= createdAcc %></strong> has been successfully opened!
        </div>
    <% } %>

    <!-- Summary Banner -->
    <div class="total-summary-card">
        <div>
            <span style="opacity: 0.85; font-size: 0.95rem; text-transform: uppercase; letter-spacing: 0.5px;">Combined Total Balance</span>
            <div style="font-size: 2.2rem; font-weight: 800;"><%= currencyFormat.format(totalBalance) %></div>
            <span style="opacity: 0.85; font-size: 0.9rem;">Total Active Accounts: <%= accounts != null ? accounts.size() : 0 %></span>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/account/create" class="btn" style="background-color: #ffd54f; color: #0d47a1; font-weight: 700; padding: 12px 24px;">
                + Open New Account
            </a>
        </div>
    </div>

    <!-- Accounts Listing -->
    <%
        if (accounts == null || accounts.isEmpty()) {
    %>
        <div class="card text-center" style="text-align: center; padding: 50px 20px;">
            <div style="font-size: 3.5rem; margin-bottom: 12px;">🏦</div>
            <h3>No Accounts Found</h3>
            <p style="color: var(--text-muted); max-width: 500px; margin: 10px auto 24px;">
                You don't have any active accounts yet. Click below to open your first Savings or Current account with our bank.
            </p>
            <a href="${pageContext.request.contextPath}/account/create" class="btn btn-primary" style="max-width: 250px; margin: 0 auto;">
                Open Your First Account
            </a>
        </div>
    <%
        } else {
            for (Map<String, Object> acc : accounts) {
                String accNum = (String) acc.get("accountNumber");
                String accType = (String) acc.get("accountType");
                BigDecimal bal = (BigDecimal) acc.get("balance");
                String branch = (String) acc.get("branchName");
                String ifsc = (String) acc.get("ifscCode");
                String status = (String) acc.get("status");
                String bankName = (String) acc.get("bankName");
    %>
        <div class="account-card">
            <div class="account-header">
                <div>
                    <span style="font-size: 1.15rem; font-weight: 700; color: var(--primary);">
                        Account #<%= accNum %>
                    </span>
                    <span class="badge badge-active" style="margin-left: 8px;">
                        <%= accType %>
                    </span>
                    <span class="badge" style="background: #eff6ff; color: #1d4ed8; margin-left: 6px;">
                        🏛️ <%= bankName != null ? bankName : "Partner Bank" %>
                    </span>
                </div>
                <div>
                    <span class="badge badge-<%= status != null ? status.toLowerCase() : "active" %>">
                        <%= status %>
                    </span>
                </div>
            </div>

            <div>
                <small style="color: var(--text-muted); font-size: 0.85rem;">Available Balance</small>
                <div class="account-balance-large">
                    <%= currencyFormat.format(bal) %>
                </div>
            </div>

            <div class="account-meta-grid">
                <div class="account-meta-item">
                    <small>Branch</small>
                    <span><%= branch %></span>
                </div>
                <div class="account-meta-item">
                    <small>IFSC Code</small>
                    <span><%= ifsc %></span>
                </div>
                <div class="account-meta-item">
                    <small>Account ID</small>
                    <span>#<%= acc.get("accountId") %></span>
                </div>
                <div class="account-meta-item">
                    <small>Opened On</small>
                    <span><%= acc.get("createdAt") != null ? acc.get("createdAt").toString().substring(0, 10) : "-" %></span>
                </div>
            </div>

            <div class="actions-bar" style="margin-top: 16px;">
                <a href="${pageContext.request.contextPath}/account/details?accountNumber=<%= accNum %>" class="btn btn-outline" style="flex: 1;">
                    View Details
                </a>
                <a href="${pageContext.request.contextPath}/user/transactions?accountNumber=<%= accNum %>" class="btn btn-primary" style="flex: 1;">
                    💳 Transfers & Passbook
                </a>
                <a href="${pageContext.request.contextPath}/account/create" class="btn btn-secondary" style="flex: 1;">
                    + Open Another
                </a>
            </div>
        </div>
    <%
            }
        }
    %>

    <div style="margin-top: 24px; text-align: center;">
        <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-secondary" style="max-width: 250px;">
            &larr; Back to Dashboard
        </a>
    </div>
</div>

</body>
</html>
