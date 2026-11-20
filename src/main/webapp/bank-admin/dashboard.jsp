<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer bankAdminId = (Integer) session.getAttribute("bankAdminId");
    if (bankAdminId == null) {
        response.sendRedirect(request.getContextPath() + "/bank-admin/login.jsp");
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
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
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
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link">
            📜 Loans Desk <% if (pendingLoans > 0) { %><span class="badge" style="background: #f59e0b; color: #fff; padding: 2px 6px; font-size: 0.72rem; border-radius: 9999px;"><%= pendingLoans %></span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link">🪪 Cards Desk</a>
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
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
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
                    Bank Operations Authority for <strong><%= bankAdminBankName %></strong>. You have exclusive authority to approve/disburse loans, regulate bank accounts, and manage debit/credit cards.
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
                <h4>Customer Deposits</h4>
                <div class="stat-value" style="color: #15803d; font-size: 1.35rem;"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fef3c7; color: #d97706;">⏳</div>
            <div class="stat-info">
                <h4>Pending Loans</h4>
                <div class="stat-value" style="color: #b45309;"><%= pendingLoans %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">📜</div>
            <div class="stat-info">
                <h4>Disbursed Capital</h4>
                <div class="stat-value" style="color: #1d4ed8; font-size: 1.35rem;"><%= currencyFormat.format(totalDisbursedAmount) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #faf5ff; color: #9333ea;">🪪</div>
            <div class="stat-info">
                <h4>Active Cards</h4>
                <div class="stat-value" style="color: #9333ea;"><%= activeCards %> <span style="font-size: 0.85rem; color: #64748b; font-weight: normal;">/ <%= totalCards %></span></div>
            </div>
        </div>
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
                    Supervise customer Savings & Current accounts, audit opening balances, branch IFSCs, and toggle account lock status.
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
                    Review incoming loan applications, verify repayment terms, disburse loan principal directly to accounts, or reject applications.
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
                    Manage customer debit & credit cards, monitor daily spending limits, review expiry dates, and block/unblock compromised cards.
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
                    View customer profiles, linked accounts, contact details, total balances held, and regulate customer account access.
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
            <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">⚡ Action Required: Pending Loan Applications</h4>
            <a href="${pageContext.request.contextPath}/bank-admin/loans?status=PENDING" class="btn btn-secondary" style="font-size: 0.85rem; padding: 6px 14px;">View All Loans</a>
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
                            <th>Status</th>
                            <th>Submitted At</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> l : recentLoans) { %>
                            <tr>
                                <td><strong><%= l.get("applicationNumber") %></strong></td>
                                <td><%= l.get("customerName") %></td>
                                <td><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= l.get("bankName") %></span></td>
                                <td><%= l.get("loanType") %></td>
                                <td style="font-weight: 700; color: #1d4ed8;"><%= currencyFormat.format(l.get("principalAmount")) %></td>
                                <td>
                                    <% String st = (String) l.get("status"); %>
                                    <span class="badge" style="<%= "PENDING".equals(st) ? "background: #fef3c7; color: #92400e;" : ("DISBURSED".equals(st) ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;") %>">
                                        <%= st %>
                                    </span>
                                </td>
                                <td><%= l.get("createdAt") %></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/bank-admin/loans#loan-<%= l.get("loanId") %>" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.8rem;">Review</a>
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
</div>

</body>
</html>
