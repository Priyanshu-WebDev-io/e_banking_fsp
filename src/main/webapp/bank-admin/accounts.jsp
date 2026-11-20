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

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    Integer pendingAccounts = (Integer) request.getAttribute("pendingAccounts");
    if (pendingAccounts == null) pendingAccounts = 0;

    Integer activeAccounts = (Integer) request.getAttribute("activeAccounts");
    if (activeAccounts == null) activeAccounts = 0;

    Integer blockedAccounts = (Integer) request.getAttribute("blockedAccounts");
    if (blockedAccounts == null) blockedAccounts = 0;

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    Integer savingsCount = (Integer) request.getAttribute("savingsCount");
    if (savingsCount == null) savingsCount = 0;

    Integer currentCount = (Integer) request.getAttribute("currentCount");
    if (currentCount == null) currentCount = 0;

    String selectedBank = (String) request.getAttribute("selectedBank");
    String selectedType = (String) request.getAttribute("selectedType");
    String selectedStatus = (String) request.getAttribute("selectedStatus");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("accounts");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> banks = (List<Map<String, Object>>) request.getAttribute("banks");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Accounts Registry - Bank Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
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
        .filter-panel {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 16px;
            margin-bottom: 20px;
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            align-items: flex-end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .filter-group label {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--text-muted);
        }
        .filter-group select {
            padding: 7px 12px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-size: 0.88rem;
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
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link active">
            🏦 Bank Accounts <% if (pendingAccounts > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingAccounts %></span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="nav-link">👥 Customer Directory</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("account_confirmed".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Bank account confirmed and activated successfully! The customer may now transact with this account.
        </div>
    <% } else if ("account_rejected".equals(successParam)) { %>
        <div class="alert alert-warning" style="margin-bottom: 20px;">
            Account application was rejected by administrator.
        </div>
    <% } else if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Bank account status updated successfully.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
        </div>
    <% } %>

    <!-- KPI Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #fef3c7; color: #d97706;">⏳</div>
            <div class="stat-info">
                <h4>Pending Confirmation</h4>
                <div class="stat-value" style="color: #b45309;"><%= pendingAccounts %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #dcfce7; color: #166534;">✅</div>
            <div class="stat-info">
                <h4>Active Accounts</h4>
                <div class="stat-value" style="color: #166534;"><%= activeAccounts %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">🏦</div>
            <div class="stat-info">
                <h4>Total Accounts</h4>
                <div class="stat-value"><%= totalAccounts %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f0fdf4; color: #15803d;">💰</div>
            <div class="stat-info">
                <h4>Total Deposits</h4>
                <div class="stat-value" style="color: #15803d; font-size: 1.3rem;"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <form action="${pageContext.request.contextPath}/bank-admin/accounts" method="get" class="filter-panel">
        <div class="filter-group">
            <label for="bankFilter">Filter by Partner Bank</label>
            <select name="bankId" id="bankFilter">
                <option value="ALL">All Banks</option>
                <% if (banks != null) {
                    for (Map<String, Object> b : banks) {
                        String bid = String.valueOf(b.get("bankId"));
                        boolean sel = bid.equals(selectedBank);
                %>
                    <option value="<%= bid %>" <%= sel ? "selected" : "" %>><%= b.get("bankName") %> (<%= b.get("bankCode") %>)</option>
                <%  } } %>
            </select>
        </div>

        <div class="filter-group">
            <label for="typeFilter">Account Type</label>
            <select name="type" id="typeFilter">
                <option value="ALL">All Types</option>
                <option value="SAVINGS" <%= "SAVINGS".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Savings</option>
                <option value="CURRENT" <%= "CURRENT".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Current</option>
                <option value="SALARY" <%= "SALARY".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Salary</option>
                <option value="FIXED_DEPOSIT" <%= "FIXED_DEPOSIT".equalsIgnoreCase(selectedType) ? "selected" : "" %>>Fixed Deposit</option>
            </select>
        </div>

        <div class="filter-group">
            <label for="statusFilter">Status</label>
            <select name="status" id="statusFilter">
                <option value="ALL">All Statuses</option>
                <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>PENDING (Awaiting Confirmation)</option>
                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>ACTIVE</option>
                <option value="BLOCKED" <%= "BLOCKED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>BLOCKED</option>
                <option value="CLOSED" <%= "CLOSED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>CLOSED</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary" style="padding: 8px 18px;">Apply Filters</button>
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="btn btn-secondary" style="padding: 8px 14px;">Reset</a>
    </form>

    <!-- Accounts Table -->
    <div class="card">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Account #</th>
                        <th>Customer</th>
                        <th>Bank / Branch</th>
                        <th>Type</th>
                        <th>Balance</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>Admin Decision</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (accounts != null && !accounts.isEmpty()) {
                        for (Map<String, Object> a : accounts) {
                            String st = (String) a.get("status");
                            boolean isPending = "PENDING".equalsIgnoreCase(st);
                            boolean isActive = "ACTIVE".equalsIgnoreCase(st);
                            boolean isBlocked = "BLOCKED".equalsIgnoreCase(st);
                            int accId = (Integer) a.get("accountId");
                    %>
                        <tr style="<%= isPending ? "background-color: #fffbeb;" : "" %>">
                            <td><strong><%= a.get("accountNumber") %></strong></td>
                            <td>
                                <div><strong><%= a.get("customerName") %></strong></div>
                                <div style="font-size: 0.8rem; color: #64748b;"><%= a.get("customerEmail") %></div>
                            </td>
                            <td>
                                <div><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= a.get("bankName") %></span></div>
                                <div style="font-size: 0.78rem; color: #64748b;"><%= a.get("branchName") %> (<%= a.get("ifscCode") %>)</div>
                            </td>
                            <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= a.get("accountType") %></span></td>
                            <td style="font-weight: 700; color: #166534;"><%= currencyFormat.format(a.get("balance")) %></td>
                            <td>
                                <span class="badge" style="<%= isPending ? "background: #fef3c7; color: #92400e;" : (isActive ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;") %>">
                                    <%= isPending ? "⏳ PENDING" : st %>
                                </span>
                            </td>
                            <td><%= a.get("createdAt") %></td>
                            <td>
                                <% if (isPending) { %>
                                    <form action="${pageContext.request.contextPath}/bank-admin/accounts" method="post" style="display: flex; gap: 6px;">
                                        <input type="hidden" name="accountId" value="<%= accId %>">
                                        <button type="submit" name="action" value="confirm" class="btn btn-success" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Confirm and activate this bank account?');">
                                            ✅ Confirm
                                        </button>
                                        <button type="submit" name="action" value="reject" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Reject this account application?');">
                                            ❌ Reject
                                        </button>
                                    </form>
                                <% } else if (isActive) { %>
                                    <form action="${pageContext.request.contextPath}/bank-admin/accounts" method="post" style="display: inline-block;">
                                        <input type="hidden" name="accountId" value="<%= accId %>">
                                        <input type="hidden" name="action" value="toggle_block">
                                        <button type="submit" class="btn btn-warning" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Block this account?');">
                                            🔒 Block
                                        </button>
                                    </form>
                                <% } else if (isBlocked) { %>
                                    <form action="${pageContext.request.contextPath}/bank-admin/accounts" method="post" style="display: inline-block;">
                                        <input type="hidden" name="accountId" value="<%= accId %>">
                                        <input type="hidden" name="action" value="toggle_block">
                                        <button type="submit" class="btn btn-success" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Unblock this account?');">
                                            🔓 Unblock
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span style="font-size: 0.8rem; color: #64748b;">Archived</span>
                                <% } %>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No bank accounts found matching the specified filters.
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
