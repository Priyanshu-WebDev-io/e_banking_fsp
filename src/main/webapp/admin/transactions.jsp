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

    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    if (totalTransactions == null) totalTransactions = 0;

    BigDecimal totalCommissions = (BigDecimal) request.getAttribute("totalCommissions");
    if (totalCommissions == null) totalCommissions = BigDecimal.ZERO;

    BigDecimal totalVolume = (BigDecimal) request.getAttribute("totalVolume");
    if (totalVolume == null) totalVolume = BigDecimal.ZERO;

    String selectedType = (String) request.getAttribute("selectedType");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> transactions = (List<Map<String, Object>>) request.getAttribute("transactions");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Transactions Ledger - E-Banking Admin</title>
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
        .filter-btn {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid var(--border);
            background: #ffffff;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .filter-btn.active {
            background: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
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
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link active">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">💳</div>
            <div class="stat-info">
                <h4>Total Executed Ledger Entries</h4>
                <div class="stat-value"><%= totalTransactions %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #ecfdf5; color: #059669;">📈</div>
            <div class="stat-info">
                <h4>Platform Commissions Earned</h4>
                <div class="stat-value" style="color: #059669; font-size: 1.35rem;"><%= currencyFormat.format(totalCommissions) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fefce8; color: #a16207;">💰</div>
            <div class="stat-info">
                <h4>Cumulative Volume Processed</h4>
                <div class="stat-value" style="color: var(--text-main); font-size: 1.35rem;"><%= currencyFormat.format(totalVolume) %></div>
            </div>
        </div>
    </div>

    <!-- Ledger Table Card -->
    <div class="card" style="margin-bottom: 40px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 18px;">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main);">💳 Real-Time Platform Transaction Ledger (<%= transactions != null ? transactions.size() : 0 %>)</h3>
                <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 2px;">
                    Immutable double-entry transaction records, deposit tracking, cash withdrawals, and inter-bank commissions.
                </p>
            </div>

            <!-- Filter Pills -->
            <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/admin/transactions" class="filter-btn <%= selectedType == null || selectedType.isEmpty() || "ALL".equalsIgnoreCase(selectedType) ? "active" : "" %>">All</a>
                <a href="${pageContext.request.contextPath}/admin/transactions?type=TRANSFER" class="filter-btn <%= "TRANSFER".equalsIgnoreCase(selectedType) ? "active" : "" %>">Transfers</a>
                <a href="${pageContext.request.contextPath}/admin/transactions?type=DEPOSIT" class="filter-btn <%= "DEPOSIT".equalsIgnoreCase(selectedType) ? "active" : "" %>">Deposits</a>
                <a href="${pageContext.request.contextPath}/admin/transactions?type=WITHDRAWAL" class="filter-btn <%= "WITHDRAWAL".equalsIgnoreCase(selectedType) ? "active" : "" %>">Withdrawals</a>
            </div>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Reference & Date</th>
                        <th>Transaction Flow</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Platform Fee Cut</th>
                        <th>Status</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (transactions != null && !transactions.isEmpty()) {
                        for (Map<String, Object> t : transactions) {
                            String ref = (String) t.get("referenceNumber");
                            BigDecimal amt = (BigDecimal) t.get("amount");
                            String tType = (String) t.get("transactionType");
                            String status = (String) t.get("status");
                            String desc = (String) t.get("description");
                            java.sql.Timestamp created = (java.sql.Timestamp) t.get("createdAt");
                            String fromAcc = (String) t.get("fromAccountNumber");
                            String toAcc = (String) t.get("toAccountNumber");
                            String fromBank = (String) t.get("fromBankName");
                            String toBank = (String) t.get("toBankName");
                            BigDecimal commAmt = (BigDecimal) t.get("commissionAmount");
                            BigDecimal commRate = (BigDecimal) t.get("commissionRate");
                %>
                    <tr>
                        <td>
                            <code><%= ref %></code><br>
                            <small style="color: var(--text-muted);"><%= created != null ? created.toString().substring(0, 16) : "" %></small>
                        </td>
                        <td>
                            <% if ("TRANSFER".equalsIgnoreCase(tType)) { %>
                                <small><strong>From:</strong> #<%= fromAcc %> (<%= fromBank %>)</small><br>
                                <small><strong>To:</strong> #<%= toAcc %> (<%= toBank %>)</small>
                            <% } else if ("DEPOSIT".equalsIgnoreCase(tType)) { %>
                                <small>Direct Cash Deposit &rarr; #<%= toAcc %></small>
                            <% } else { %>
                                <small>Cash Withdrawal &larr; #<%= fromAcc %></small>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge badge-type" style="font-size: 0.72rem;"><%= tType %></span>
                        </td>
                        <td>
                            <strong><%= currencyFormat.format(amt) %></strong>
                        </td>
                        <td>
                            <% if (commAmt != null && commAmt.compareTo(BigDecimal.ZERO) > 0) { %>
                                <span style="color: #166534; font-weight: 700;">+<%= currencyFormat.format(commAmt) %></span><br>
                                <small style="color: var(--text-muted);">(<%= commRate %>%)</small>
                            <% } else { %>
                                <span style="color: var(--text-muted);">-</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge badge-active" style="font-size: 0.72rem;"><%= status %></span>
                        </td>
                        <td>
                            <small style="color: var(--text-muted);"><%= desc != null ? desc : "" %></small>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No transactions found matching your criteria.
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
