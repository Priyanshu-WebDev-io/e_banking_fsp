<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    String accountNumber = (String) request.getAttribute("accountNumber");
    if (accountNumber == null) {
        response.sendRedirect(request.getContextPath() + "/account/list");
        return;
    }

    BigDecimal balance = (BigDecimal) request.getAttribute("balance");
    if (balance == null) balance = BigDecimal.ZERO;
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String accountType = (String) request.getAttribute("accountType");
    String branchName = (String) request.getAttribute("branchName");
    String ifscCode = (String) request.getAttribute("ifscCode");
    String status = (String) request.getAttribute("status");
    String bankName = (String) request.getAttribute("bankName");
    Object createdAt = request.getAttribute("createdAt");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Details - #<%= accountNumber %></title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="navbar-custom">
        <h2>Account Details</h2>
        <div class="user-info">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Accounts</a>
            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
        </div>
    </div>

    <div class="card">
        <div class="brand-header">
            <h2>Account Details</h2>
            <p>Complete information for Bank Account #<%= accountNumber %></p>
        </div>

        <div style="background: #e8f5e9; border: 1px solid #c8e6c9; border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 24px;">
            <small style="color: var(--text-muted); font-size: 0.85rem; text-transform: uppercase; font-weight: 600;">Current Available Balance</small>
            <div style="font-size: 2.2rem; font-weight: 800; color: var(--success); margin-top: 4px;">
                <%= currencyFormat.format(balance) %>
            </div>
        </div>

        <div class="table-responsive">
            <table class="data-table">
                <tr>
                    <th>Account Number</th>
                    <td><strong><%= accountNumber %></strong></td>
                </tr>
                <tr>
                    <th>Holding Bank</th>
                    <td><strong style="color: var(--primary);">🏛️ <%= bankName != null ? bankName : "Partner Bank" %></strong></td>
                </tr>
                <tr>
                    <th>Account Type</th>
                    <td><span class="badge badge-active"><%= accountType %></span></td>
                </tr>
                <tr>
                    <th>Branch</th>
                    <td><%= branchName %></td>
                </tr>
                <tr>
                    <th>IFSC Code</th>
                    <td><code><%= ifscCode %></code></td>
                </tr>
                <tr>
                    <th>Account Status</th>
                    <td><span class="badge badge-<%= status != null ? status.toLowerCase() : "active" %>"><%= status %></span></td>
                </tr>
                <tr>
                    <th>Date Opened</th>
                    <td><%= createdAt != null ? createdAt.toString() : "-" %></td>
                </tr>
            </table>
        </div>

        <div class="actions-bar">
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="flex: 1;">&larr; Back to Accounts</a>
            <a href="${pageContext.request.contextPath}/user/transactions?accountNumber=<%= accountNumber %>" class="btn btn-primary" style="flex: 1;">💳 View Passbook & Transfers</a>
            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-secondary" style="flex: 1;">Dashboard</a>
        </div>
    </div>
</div>

</body>
</html>
