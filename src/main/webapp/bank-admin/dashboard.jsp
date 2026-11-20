<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer bankAdminId = (Integer) session.getAttribute("bankAdminId");
    if (bankAdminId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=bank_admin");
        return;
    }

    String bankAdminName = (String) session.getAttribute("bankAdminName");
    String bankAdminUsername = (String) session.getAttribute("bankAdminUsername");
    String bankAdminBankName = (String) session.getAttribute("bankAdminBankName");
    if (bankAdminBankName == null || bankAdminBankName.isEmpty()) {
        bankAdminBankName = "All Partner Banks (Lead Operations)";
    }

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    Integer activeAccounts = (Integer) request.getAttribute("activeAccounts");
    if (activeAccounts == null) activeAccounts = 0;

    Integer pendingAccounts = (Integer) request.getAttribute("pendingAccounts");
    if (pendingAccounts == null) pendingAccounts = 0;

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    Integer totalLoans = (Integer) request.getAttribute("totalLoans");
    if (totalLoans == null) totalLoans = 0;

    Integer pendingLoans = (Integer) request.getAttribute("pendingLoans");
    if (pendingLoans == null) pendingLoans = 0;

    Integer disbursedLoans = (Integer) request.getAttribute("disbursedLoans");
    if (disbursedLoans == null) disbursedLoans = 0;

    BigDecimal totalDisbursedAmount = (BigDecimal) request.getAttribute("totalDisbursedAmount");
    if (totalDisbursedAmount == null) totalDisbursedAmount = BigDecimal.ZERO;

    Integer totalCards = (Integer) request.getAttribute("totalCards");
    if (totalCards == null) totalCards = 0;

    Integer activeCards = (Integer) request.getAttribute("activeCards");
    if (activeCards == null) activeCards = 0;

    Integer pendingCards = (Integer) request.getAttribute("pendingCards");
    if (pendingCards == null) pendingCards = 0;

    Integer blockedCards = (Integer) request.getAttribute("blockedCards");
    if (blockedCards == null) blockedCards = 0;

    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    if (totalCustomers == null) totalCustomers = 0;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentLoans = (List<Map<String, Object>>) request.getAttribute("recentLoans");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentAccounts = (List<Map<String, Object>>) request.getAttribute("recentAccounts");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Operations Center - Bank Admin</title>
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
        .stat-card.alert-card {
            border: 2px solid #f59e0b;
            background: #fffbeb;
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
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 18px;
            margin-bottom: 32px;
        }
        .module-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            text-decoration: none;
            color: inherit;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .module-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: #059669;
        }
        .module-icon {
            font-size: 2.2rem;
            margin-bottom: 12px;
        }
        .module-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 6px;
        }
        .module-desc {
            color: var(--text-muted);
            font-size: 0.88rem;
            line-height: 1.5;
            margin-bottom: 16px;
        }
        .module-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 14px;
            border-top: 1px solid var(--border);
            font-weight: 700;
            font-size: 0.85rem;
            color: #059669;
        }
        .status-badge {
            display: inline-block;
            font-size: 0.76rem;
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
        <h2>🏦 Bank Admin Operations Portal</h2>
        <div class="user-info">
            <span class="badge" style="background: #d1fae5; color: #065f46; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">
                🏛️ <%= bankAdminBankName %>
            </span>
            <span>Signed in as: <strong><%= bankAdminName != null ? bankAdminName : bankAdminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/bank-admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="bank-nav-bar">
        <a href="${pageContext.request.contextPath}/bank-admin/dashboard" class="nav-link active">📊 Operations Command</a>
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link">
            🏦 Bank Accounts <% if (pendingAccounts > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingAccounts %> Pending</span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link">
            📜 Loans Desk <% if (pendingLoans > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingLoans %> Pending</span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link">
            🪪 Cards Desk <% if (pendingCards > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingCards %> Pending</span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="nav-link">👥 Customer Directory</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("loan_approved".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Loan application approved! Funds disbursed into customer account and recorded in transaction ledger.
        </div>
    <% } else if ("loan_rejected".equals(successParam)) { %>
        <div class="alert alert-warning" style="margin-bottom: 20px;">
            Loan application was rejected with admin remarks recorded.
        </div>
    <% } else if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Account status updated successfully.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
        </div>
    <% } %>

    <!-- Action Required Alert Banner if Pending Tasks -->
    <% if (pendingAccounts > 0 || pendingLoans > 0 || pendingCards > 0) { %>
        <div class="card" style="margin-bottom: 24px; background: #fffbeb; border: 1px solid #fde68a;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <span style="font-size: 1.8rem;">⚠️</span>
                    <div>
                        <h4 style="margin: 0; color: #92400e; font-size: 1.05rem;">
                            Action Required: Institutional Confirmations & Underwriting Awaiting Review
                        </h4>
                        <p style="margin: 4px 0 0; color: #b45309; font-size: 0.88rem;">
                            You have <strong><%= pendingAccounts %> account(s)</strong> awaiting activation, <strong><%= pendingCards %> card(s)</strong> awaiting confirmation, and <strong><%= pendingLoans %> loan(s)</strong> awaiting underwriting.
                        </p>
                    </div>
                </div>
                <div style="display: flex; gap: 8px;">
                    <% if (pendingAccounts > 0) { %>
                        <a href="${pageContext.request.contextPath}/bank-admin/accounts?status=PENDING" class="btn btn-primary" style="background-color: #059669; padding: 6px 14px; font-size: 0.85rem;">
                            Review Accounts (<%= pendingAccounts %>)
                        </a>
                    <% } %>
                    <% if (pendingCards > 0) { %>
                        <a href="${pageContext.request.contextPath}/bank-admin/cards?status=PENDING" class="btn btn-primary" style="background-color: #7c3aed; padding: 6px 14px; font-size: 0.85rem;">
                            Review Cards (<%= pendingCards %>)
                        </a>
                    <% } %>
                    <% if (pendingLoans > 0) { %>
                        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=PENDING" class="btn btn-primary" style="background-color: #d97706; padding: 6px 14px; font-size: 0.85rem;">
                            Review Loans (<%= pendingLoans %>)
                        </a>
                    <% } %>
                </div>
            </div>
        </div>
    <% } %>

    <!-- Welcome Header Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h3 style="font-size: 1.4rem; color: var(--text-main); margin-bottom: 4px;">
                    Welcome, <%= bankAdminName != null ? bankAdminName : "Bank Administrator" %>! 👨‍💼
                </h3>
                <p style="color: var(--text-muted); font-size: 0.92rem; margin: 0;">
                    Institutional Banking Authority for <strong><%= bankAdminBankName %></strong>. You have exclusive jurisdiction to verify & activate customer accounts, underwrite loans, and regulate payment cards.
                </p>
            </div>
            <div>
                <span class="badge" style="background: #ecfdf5; color: #047857; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #a7f3d0; font-size: 0.85rem;">
                    🛡️ Institutional Banking Desk
                </span>
            </div>
        </div>
    </div>

    <!-- High-level KPI Stats Grid -->
    <div class="stats-grid">
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">🏦</div>
            <div class="stat-info">
                <h4>Total Accounts</h4>
                <div class="stat-value"><%= totalAccounts %></div>
                <div style="font-size: 0.78rem; color: #059669; font-weight: 600;"><%= activeAccounts %> Active Accounts</div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/bank-admin/accounts?status=PENDING" class="stat-card <%= pendingAccounts > 0 ? "alert-card" : "" %>">
            <div class="stat-icon" style="background-color: #fef3c7; color: #b45309;">⏳</div>
            <div class="stat-info">
                <h4>Pending Accounts</h4>
                <div class="stat-value" style="color: #b45309;"><%= pendingAccounts %></div>
                <div style="font-size: 0.78rem; color: #b45309; font-weight: 600;">Requires Activation</div>
            </div>
        </a>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">💰</div>
            <div class="stat-info">
                <h4>Customer Deposits</h4>
                <div class="stat-value" style="color: #15803d; font-size: 1.35rem;"><%= currencyFormat.format(totalDeposits) %></div>
                <div style="font-size: 0.78rem; color: #64748b;">Liquid Held Capital</div>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/bank-admin/loans?status=PENDING" class="stat-card <%= pendingLoans > 0 ? "alert-card" : "" %>">
            <div class="stat-icon" style="background-color: #fff7ed; color: #ea580c;">📜</div>
            <div class="stat-info">
                <h4>Pending Loans</h4>
                <div class="stat-value" style="color: #ea580c;"><%= pendingLoans %></div>
                <div style="font-size: 0.78rem; color: #ea580c; font-weight: 600;">Awaiting Underwrite</div>
            </div>
        </a>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">💳</div>
            <div class="stat-info">
                <h4>Disbursed Capital</h4>
                <div class="stat-value" style="color: #1d4ed8; font-size: 1.35rem;"><%= currencyFormat.format(totalDisbursedAmount) %></div>
                <div style="font-size: 0.78rem; color: #64748b;"><%= disbursedLoans %> Loans Disbursed</div>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="stat-card">
            <div class="stat-icon" style="background-color: #faf5ff; color: #9333ea;">🪪</div>
            <div class="stat-info">
                <h4>Active Cards</h4>
                <div class="stat-value" style="color: #9333ea;"><%= activeCards %> <span style="font-size: 0.85rem; color: #64748b; font-weight: normal;">/ <%= totalCards %></span></div>
                <div style="font-size: 0.78rem; color: #64748b;"><%= blockedCards %> Blocked</div>
            </div>
        </a>
    </div>

    <!-- Bank Operations Modules -->
    <h3 style="font-size: 1.25rem; font-weight: 700; color: #0f172a; margin-bottom: 16px;">Operational Control Desks</h3>
    <div class="modules-grid">
        <!-- 1. Accounts Desk -->
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="module-card">
            <div>
                <div class="module-icon">🏦</div>
                <div class="module-title">Bank Accounts Registry</div>
                <div class="module-desc">
                    Supervise customer Savings & Current accounts, audit opening balances, branch IFSCs, and toggle account activation or fraud lock.
                </div>
            </div>
            <div class="module-footer">
                <span><%= totalAccounts %> Accounts Under Management</span>
                <span>Open Desk &rarr;</span>
            </div>
        </a>

        <!-- 2. Loans Desk -->
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="module-card">
            <div>
                <div class="module-icon">📜</div>
                <div class="module-title">Loan Underwriting & Disbursement</div>
                <div class="module-desc">
                    Review incoming loan applications, verify borrower monthly EMI terms, disburse principal directly into customer accounts, or reject.
                </div>
            </div>
            <div class="module-footer">
                <span style="color: <%= pendingLoans > 0 ? "#b45309" : "#059669" %>;">
                    <%= pendingLoans %> Pending Underwriting
                </span>
                <span>Review Loans &rarr;</span>
            </div>
        </a>

        <!-- 3. Cards Desk -->
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="module-card">
            <div>
                <div class="module-icon">🪪</div>
                <div class="module-title">Payment Cards Desk</div>
                <div class="module-desc">
                    Manage customer debit & credit cards, monitor daily spending limits, review expiry dates, and toggle immediate freeze/unfreeze protection.
                </div>
            </div>
            <div class="module-footer">
                <span><%= totalCards %> Total Issued Cards</span>
                <span>Manage Cards &rarr;</span>
            </div>
        </a>

        <!-- 4. Customer Directory -->
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="module-card">
            <div>
                <div class="module-icon">👥</div>
                <div class="module-title">Customer Directory</div>
                <div class="module-desc">
                    View customer profiles, linked accounts, contact details, total balances held across partner banks, and regulate customer account access.
                </div>
            </div>
            <div class="module-footer">
                <span><%= totalCustomers %> Registered Customers</span>
                <span>View Directory &rarr;</span>
            </div>
        </a>
    </div>

    <!-- Recent Pending Loan Applications Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">⚡ Action Required: Loan Applications</h4>
            <a href="${pageContext.request.contextPath}/bank-admin/loans" class="btn btn-secondary" style="font-size: 0.85rem; padding: 6px 14px;">Full Loans Desk &rarr;</a>
        </div>

        <% if (recentLoans != null && !recentLoans.isEmpty()) { %>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Application #</th>
                            <th>Applicant Name</th>
                            <th>Bank</th>
                            <th>Type</th>
                            <th>Principal Amount</th>
                            <th>EMI Term</th>
                            <th>Status</th>
                            <th>Submitted At</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> l : recentLoans) { %>
                            <tr>
                                <td><strong><%= l.get("applicationNumber") %></strong></td>
                                <td>
                                    <div><strong><%= l.get("customerName") %></strong></div>
                                    <div style="font-size: 0.78rem; color: #64748b;"><%= l.get("customerEmail") %></div>
                                </td>
                                <td><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= l.get("bankName") %></span></td>
                                <td><strong><%= l.get("loanType") %></strong></td>
                                <td style="font-weight: 700; color: #1d4ed8;"><%= currencyFormat.format(l.get("principalAmount")) %></td>
                                <td style="font-size: 0.82rem;"><%= l.get("tenureMonths") %> Months @ <%= l.get("interestRate") %>%</td>
                                <td>
                                    <% String st = (String) l.get("status"); %>
                                    <span class="status-badge <%= "PENDING".equals(st) ? "pending" : ("DISBURSED".equals(st) ? "active" : "blocked") %>">
                                        <%= st %>
                                    </span>
                                </td>
                                <td style="font-size: 0.82rem; color: #64748b;"><%= l.get("createdAt") %></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/bank-admin/loans#loan-<%= l.get("loanId") %>" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.8rem; background-color: #059669;">Underwrite</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="padding: 24px; text-align: center; color: #64748b;">
                ✅ No pending loan applications at this time. All submissions have been processed.
            </div>
        <% } %>
    </div>

    <!-- Recent Bank Accounts & Verification Desk Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">🏦 Customer Bank Accounts & Verification Desk</h4>
            <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="btn btn-secondary" style="font-size: 0.85rem; padding: 6px 14px;">All Accounts &rarr;</a>
        </div>

        <% if (recentAccounts != null && !recentAccounts.isEmpty()) { %>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Account Number</th>
                            <th>Customer Name</th>
                            <th>Partner Bank</th>
                            <th>Branch & IFSC</th>
                            <th>Type</th>
                            <th>Balance</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> a : recentAccounts) { %>
                            <tr>
                                <td><strong><%= a.get("accountNumber") %></strong></td>
                                <td>
                                    <div><strong><%= a.get("customerName") %></strong></div>
                                    <div style="font-size: 0.78rem; color: #64748b;"><%= a.get("customerEmail") != null ? a.get("customerEmail") : "" %></div>
                                </td>
                                <td><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= a.get("bankName") %></span></td>
                                <td>
                                    <div style="font-size: 0.84rem;"><%= a.get("branchName") != null ? a.get("branchName") : "Main Branch" %></div>
                                    <code style="font-size: 0.75rem;"><%= a.get("ifscCode") != null ? a.get("ifscCode") : "" %></code>
                                </td>
                                <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= a.get("accountType") %></span></td>
                                <td style="font-weight: 700; color: #15803d;"><%= currencyFormat.format(a.get("balance")) %></td>
                                <td>
                                    <% String accSt = (String) a.get("status"); %>
                                    <span class="status-badge <%= "ACTIVE".equals(accSt) ? "active" : ("PENDING".equals(accSt) ? "pending" : "blocked") %>">
                                        <%= accSt %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("PENDING".equals(accSt)) { %>
                                        <form action="${pageContext.request.contextPath}/bank-admin/accounts" method="post" style="display:inline;">
                                            <input type="hidden" name="accountId" value="<%= a.get("accountId") %>">
                                            <input type="hidden" name="action" value="set_status">
                                            <input type="hidden" name="status" value="ACTIVE">
                                            <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.78rem; background-color: #059669;">Activate</button>
                                        </form>
                                    <% } else { %>
                                        <a href="${pageContext.request.contextPath}/bank-admin/accounts#acc-<%= a.get("accountId") %>" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.78rem;">Inspect</a>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="padding: 24px; text-align: center; color: #64748b;">
                No customer bank accounts registered under this bank yet.
            </div>
        <% } %>
    </div>
</div>

</body>
</html>
