<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale, java.util.List, java.util.Map, java.util.ArrayList, java.util.HashMap, com.ebanking.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
        return;
    }

    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String userFullName = (firstName != null ? firstName : "Customer") + (lastName != null ? " " + lastName : "");

    BigDecimal totalBalance = (BigDecimal) request.getAttribute("totalBalance");
    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    Integer pendingAccounts = (Integer) request.getAttribute("pendingAccounts");
    Integer totalCards = (Integer) request.getAttribute("totalCards");
    Integer pendingCards = (Integer) request.getAttribute("pendingCards");
    Integer totalLoans = (Integer) request.getAttribute("totalLoans");
    Integer pendingLoans = (Integer) request.getAttribute("pendingLoans");
    BigDecimal disbursedLoansAmount = (BigDecimal) request.getAttribute("disbursedLoansAmount");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accountsList = (List<Map<String, Object>>) request.getAttribute("accountsList");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentTransactions = (List<Map<String, Object>>) request.getAttribute("recentTransactions");

    // Fallback if accessed directly via /user/dashboard.jsp without servlet
    if (totalBalance == null || totalAccounts == null) {
        totalBalance = BigDecimal.ZERO;
        totalAccounts = 0;
        pendingAccounts = 0;
        totalCards = 0;
        pendingCards = 0;
        totalLoans = 0;
        pendingLoans = 0;
        disbursedLoansAmount = BigDecimal.ZERO;
        accountsList = new ArrayList<>();
        recentTransactions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            String accSql = "SELECT COUNT(*), COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN balance ELSE 0 END), 0) FROM accounts WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(accSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalAccounts = rs.getInt(2);
                        pendingAccounts = rs.getInt(3);
                        totalBalance = rs.getBigDecimal(4);
                    }
                }
            }
            String cardSql = "SELECT COALESCE(SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0) FROM cards WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(cardSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCards = rs.getInt(1);
                        pendingCards = rs.getInt(2);
                    }
                }
            }
            String loanSql = "SELECT COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status = 'DISBURSED' THEN principal_amount ELSE 0 END), 0) FROM loan_applications WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(loanSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalLoans = rs.getInt(1);
                        pendingLoans = rs.getInt(2);
                        disbursedLoansAmount = rs.getBigDecimal(3);
                    }
                }
            }
            String accListSql = "SELECT a.account_id, a.account_number, a.account_type, a.balance, a.branch_name, a.ifsc_code, a.status, a.created_at, COALESCE(b.bank_name, 'Partner Bank') AS bank_name, COALESCE(b.bank_code, 'BANK') AS bank_code FROM accounts a LEFT JOIN banks b ON a.bank_id = b.bank_id WHERE a.user_id = ? ORDER BY a.account_id DESC";
            try (PreparedStatement ps = con.prepareStatement(accListSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> acc = new HashMap<>();
                        acc.put("accountId", rs.getInt("account_id"));
                        acc.put("accountNumber", rs.getString("account_number"));
                        acc.put("accountType", rs.getString("account_type"));
                        acc.put("balance", rs.getBigDecimal("balance"));
                        acc.put("branchName", rs.getString("branch_name"));
                        acc.put("ifscCode", rs.getString("ifsc_code"));
                        acc.put("status", rs.getString("status"));
                        acc.put("bankName", rs.getString("bank_name"));
                        acc.put("bankCode", rs.getString("bank_code"));
                        accountsList.add(acc);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (pendingAccounts == null) pendingAccounts = 0;
    if (pendingLoans == null) pendingLoans = 0;
    if (pendingCards == null) pendingCards = 0;

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
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
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            color: inherit;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.7rem;
            flex-shrink: 0;
        }
        .stat-info h4 {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.55rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .user-nav-bar {
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
        .user-nav-bar .nav-link {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            color: var(--text-main);
            transition: all 0.2s;
        }
        .user-nav-bar .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
        }
        .user-nav-bar .nav-link.active {
            background: var(--primary);
            color: #ffffff;
        }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 18px;
            margin-bottom: 36px;
        }
        .service-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .service-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }
        .service-icon {
            font-size: 2.2rem;
            margin-bottom: 12px;
        }
        .service-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 6px;
        }
        .service-desc {
            color: var(--text-muted);
            font-size: 0.86rem;
            line-height: 1.5;
            margin-bottom: 16px;
        }
        .service-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 14px;
            border-top: 1px solid var(--border);
        }
        .status-badge {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 9999px;
            text-transform: uppercase;
        }
        .status-badge.active {
            background: #dcfce7;
            color: #15803d;
        }
        .status-badge.pending {
            background: #fef3c7;
            color: #b45309;
        }
        .status-badge.blocked {
            background: #fee2e2;
            color: #991b1b;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>E-Banking Customer Portal</h2>
        <div class="user-info">
            <span>Welcome, <strong><%= userFullName %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="user-nav-bar">
        <a href="${pageContext.request.contextPath}/user/dashboard" class="nav-link active">🏠 Overview</a>
        <a href="${pageContext.request.contextPath}/account/list" class="nav-link">
            🏦 My Accounts <% if (pendingAccounts > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingAccounts %> Pending</span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/account/create" class="nav-link">➕ Open Account</a>
        <a href="${pageContext.request.contextPath}/user/transactions" class="nav-link">💳 Transactions</a>
        <a href="${pageContext.request.contextPath}/user/cards" class="nav-link">🪪 My Cards</a>
        <a href="${pageContext.request.contextPath}/user/loans" class="nav-link">
            💰 Loans & EMI <% if (pendingLoans > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingLoans %> Reviewing</span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/user/profile" class="nav-link">👤 Profile</a>
    </div>

    <!-- Pending Notifications / Alerts -->
    <% if (pendingAccounts > 0) { %>
        <div class="card" style="margin-bottom: 20px; background: #fffbeb; border: 1px solid #fde68a;">
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <span style="font-size: 1.5rem;">⏳</span>
                    <div>
                        <strong style="color: #92400e;">Account Application Under Institutional Review</strong>
                        <p style="margin: 2px 0 0; color: #b45309; font-size: 0.88rem;">
                            You have <strong><%= pendingAccounts %> account(s)</strong> awaiting activation by your bank administrator. Your account number is reserved and will be activated once verified.
                        </p>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/account/list" class="btn btn-primary" style="font-size: 0.82rem; padding: 5px 12px; background: #d97706;">View Status</a>
            </div>
        </div>
    <% } %>

    <% if (pendingLoans > 0) { %>
        <div class="card" style="margin-bottom: 20px; background: #eff6ff; border: 1px solid #bfdbfe;">
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <span style="font-size: 1.5rem;">📜</span>
                    <div>
                        <strong style="color: #1e40af;">Loan Application Under Underwriting</strong>
                        <p style="margin: 2px 0 0; color: #1d4ed8; font-size: 0.88rem;">
                            You have <strong><%= pendingLoans %> loan application(s)</strong> being reviewed by bank officers. Funds will disburse immediately upon approval.
                        </p>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-primary" style="font-size: 0.82rem; padding: 5px 12px;">Check Loan Desk</a>
            </div>
        </div>
    <% } %>

    <!-- Welcome Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h3 style="font-size: 1.35rem; color: var(--text-main); margin-bottom: 4px;">
                    Hello, <%= firstName != null ? firstName : "Customer" %>! 👋
                </h3>
                <p style="color: var(--text-muted); font-size: 0.92rem; margin: 0;">
                    Welcome to your personal banking dashboard. Supervise your accounts across partner banks, initiate instant transfers, or apply for credit.
                </p>
            </div>
            <div>
                <span class="badge" style="background: #f0fdf4; color: #15803d; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #bbf7d0; font-size: 0.85rem;">
                    ✓ KYC Verified Customer
                </span>
            </div>
        </div>
    </div>

    <!-- User KPI Financial Summary Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">💰</div>
            <div class="stat-info">
                <h4>Total Liquid Balance</h4>
                <div class="stat-value" style="color: var(--success);"><%= currencyFormat.format(totalBalance) %></div>
                <div style="font-size: 0.78rem; color: #64748b;">Active Accounts Combined</div>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/account/list" class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">🏦</div>
            <div class="stat-info">
                <h4>Bank Accounts</h4>
                <div class="stat-value"><%= totalAccounts %> Active</div>
                <% if (pendingAccounts > 0) { %>
                    <div style="font-size: 0.78rem; color: #b45309; font-weight: 600;"><%= pendingAccounts %> Pending Activation</div>
                <% } else { %>
                    <div style="font-size: 0.78rem; color: #64748b;">Multi-Bank Support</div>
                <% } %>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/user/cards" class="stat-card">
            <div class="stat-icon" style="background-color: #f5f3ff; color: #7c3aed;">🪪</div>
            <div class="stat-info">
                <h4>Virtual Cards</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= totalCards %> Active</div>
                <div style="font-size: 0.78rem; color: #64748b;">Debit & Credit Cards</div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/user/loans" class="stat-card">
            <div class="stat-icon" style="background-color: #fff7ed; color: #ea580c;">📜</div>
            <div class="stat-info">
                <h4>Loans & Credit</h4>
                <div class="stat-value" style="color: #ea580c;"><%= totalLoans %> Disbursed</div>
                <% if (pendingLoans > 0) { %>
                    <div style="font-size: 0.78rem; color: #ea580c; font-weight: 600;"><%= pendingLoans %> Under Review</div>
                <% } else { %>
                    <div style="font-size: 0.78rem; color: #64748b;">Instant EMI Options</div>
                <% } %>
            </div>
        </a>
    </div>

    <!-- 1. My Bank Accounts Overview Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">🏦 My Bank Accounts</h4>
            <div style="display: flex; gap: 8px;">
                <a href="${pageContext.request.contextPath}/account/create" class="btn btn-primary" style="font-size: 0.82rem; padding: 5px 12px;">+ Open New Account</a>
                <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="font-size: 0.82rem; padding: 5px 12px;">Manage All</a>
            </div>
        </div>

        <% if (accountsList != null && !accountsList.isEmpty()) { %>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Account Number</th>
                            <th>Partner Bank</th>
                            <th>Branch & IFSC</th>
                            <th>Type</th>
                            <th>Balance</th>
                            <th>Status</th>
                            <th>Quick Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> acc : accountsList) { %>
                            <tr>
                                <td><strong><%= acc.get("accountNumber") %></strong></td>
                                <td>
                                    <span class="badge" style="background: #e0f2fe; color: #0369a1; font-weight: 600;">
                                        <%= acc.get("bankName") %>
                                    </span>
                                </td>
                                <td>
                                    <div><%= acc.get("branchName") %></div>
                                    <code style="font-size: 0.75rem;"><%= acc.get("ifscCode") %></code>
                                </td>
                                <td>
                                    <span class="badge" style="background: #f1f5f9; color: #334155;">
                                        <%= acc.get("accountType") %>
                                    </span>
                                </td>
                                <td style="font-weight: 700; color: #15803d;">
                                    <%= currencyFormat.format(acc.get("balance")) %>
                                </td>
                                <td>
                                    <% String aStatus = (String) acc.get("status"); %>
                                    <span class="status-badge <%= "ACTIVE".equals(aStatus) ? "active" : ("PENDING".equals(aStatus) ? "pending" : "blocked") %>">
                                        <%= aStatus %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("ACTIVE".equals(aStatus)) { %>
                                        <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-primary" style="padding: 3px 10px; font-size: 0.78rem;">Transfer</a>
                                    <% } else if ("PENDING".equals(aStatus)) { %>
                                        <span style="font-size: 0.78rem; color: #b45309; font-weight: 600;">Pending Bank Admin</span>
                                    <% } else { %>
                                        <span style="font-size: 0.78rem; color: #991b1b; font-weight: 600;">Contact Bank</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="padding: 24px; text-align: center; color: #64748b;">
                You don't have any registered bank accounts yet.
                <div style="margin-top: 10px;">
                    <a href="${pageContext.request.contextPath}/account/create" class="btn btn-primary" style="font-size: 0.85rem; padding: 6px 16px;">
                        Open Your First Bank Account &rarr;
                    </a>
                </div>
            </div>
        <% } %>
    </div>

    <!-- 2. Recent Transaction Activity Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">💳 Recent Account Activity</h4>
            <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-secondary" style="font-size: 0.82rem; padding: 5px 12px;">Full Passbook Ledger &rarr;</a>
        </div>

        <% if (recentTransactions != null && !recentTransactions.isEmpty()) { %>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Txn Ref #</th>
                            <th>Type</th>
                            <th>Description / Counterparty</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> tr : recentTransactions) { 
                            String tType = (String) tr.get("transactionType");
                            boolean isSender = Boolean.TRUE.equals(tr.get("isSender"));
                            boolean isCredit = "DEPOSIT".equals(tType) || (!isSender && "TRANSFER".equals(tType));
                        %>
                            <tr>
                                <td><strong><%= tr.get("referenceNumber") %></strong></td>
                                <td>
                                    <span class="badge" style="<%= "DEPOSIT".equals(tType) ? "background: #dcfce7; color: #166534;" : ("WITHDRAWAL".equals(tType) ? "background: #fee2e2; color: #991b1b;" : "background: #eff6ff; color: #1e40af;") %>">
                                        <%= tType %>
                                    </span>
                                </td>
                                <td>
                                    <div><%= tr.get("description") != null ? tr.get("description") : "Online Transfer" %></div>
                                    <div style="font-size: 0.75rem; color: #64748b;">
                                        <% if (tr.get("fromAccNum") != null) { %>From: <%= tr.get("fromAccNum") %><% } %>
                                        <% if (tr.get("toAccNum") != null) { %> &rarr; To: <%= tr.get("toAccNum") %><% } %>
                                    </div>
                                </td>
                                <td style="font-weight: 800; color: <%= isCredit ? "#15803d" : "#b91c1c" %>;">
                                    <%= isCredit ? "+ " : "- " %><%= currencyFormat.format(tr.get("amount")) %>
                                </td>
                                <td>
                                    <span class="status-badge <%= "SUCCESS".equals(tr.get("status")) ? "active" : "blocked" %>">
                                        <%= tr.get("status") %>
                                    </span>
                                </td>
                                <td style="font-size: 0.82rem; color: #64748b;"><%= tr.get("createdAt") %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="padding: 24px; text-align: center; color: #64748b;">
                No transaction activity recorded yet. Initiate a deposit or fund transfer to see live records here.
            </div>
        <% } %>
    </div>

    <!-- Choice of Banking Services Grid -->
    <h3 style="margin-bottom: 16px; color: var(--text-main); font-weight: 700;">Banking Services & Quick Navigation</h3>

    <div class="services-grid">
        <!-- 1. My Accounts -->
        <div class="service-card">
            <div>
                <div class="service-icon">🏦</div>
                <div class="service-title">My Bank Accounts</div>
                <div class="service-desc">
                    View your active accounts across partner banks (SBI, HDFC, ICICI), check available liquid balances, and inspect IFSC routing details.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #eff6ff; color: #1d4ed8; font-weight: 600;"><%= totalAccounts %> Active</span>
                <a href="${pageContext.request.contextPath}/account/list" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    View Accounts &rarr;
                </a>
            </div>
        </div>

        <!-- 2. Open Account -->
        <div class="service-card">
            <div>
                <div class="service-icon">➕</div>
                <div class="service-title">Open New Account</div>
                <div class="service-desc">
                    Open a new Savings or Current account with instant 12-digit account number generation and institutional bank selection.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f0fdf4; color: #15803d; font-weight: 600;">Partner Banks</span>
                <a href="${pageContext.request.contextPath}/account/create" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Account &rarr;
                </a>
            </div>
        </div>

        <!-- 3. Transactions & Transfers -->
        <div class="service-card">
            <div>
                <div class="service-icon">💳</div>
                <div class="service-title">Transactions & Transfers</div>
                <div class="service-desc">
                    Deposit funds, withdraw cash, and transfer money between accounts with automated platform commission calculation and live passbook.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #eff6ff; color: #1e40af; font-weight: 600;">Live Passbook</span>
                <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Transfers & Ledger &rarr;
                </a>
            </div>
        </div>

        <!-- 4. Virtual Cards -->
        <div class="service-card">
            <div>
                <div class="service-icon">🪪</div>
                <div class="service-title">Virtual Cards Desk</div>
                <div class="service-desc">
                    Manage virtual Debit & Credit cards with metallic gradient UI, view masked numbers, and toggle immediate fraud lock protection.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f5f3ff; color: #7c3aed; font-weight: 600;"><%= totalCards %> Cards</span>
                <a href="${pageContext.request.contextPath}/user/cards" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Manage Cards &rarr;
                </a>
            </div>
        </div>

        <!-- 5. Loans & EMI -->
        <div class="service-card">
            <div>
                <div class="service-icon">💰</div>
                <div class="service-title">Loans & EMI Calculator</div>
                <div class="service-desc">
                    Explore interest rates for Personal, Home, and Vehicle loans, calculate exact monthly EMI with live sliders, and apply for direct disbursal.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #fefce8; color: #a16207; font-weight: 600;">Institutional Credit</span>
                <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Loans & EMI &rarr;
                </a>
            </div>
        </div>

        <!-- 6. Profile -->
        <div class="service-card">
            <div>
                <div class="service-icon">👤</div>
                <div class="service-title">KYC & Personal Profile</div>
                <div class="service-desc">
                    Inspect your registered personal details, update phone number, and modify your residential delivery address and city records.
                </div>
            </div>
            <div class="service-footer">
                <span class="badge" style="background: #f1f5f9; color: var(--text-muted); font-weight: 600;">Profile Settings</span>
                <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    View Profile &rarr;
                </a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
