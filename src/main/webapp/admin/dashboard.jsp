<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    String adminUsername = (String) session.getAttribute("adminUsername");

    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    if (totalCustomers == null) totalCustomers = 0;

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    Integer totalBanks = (Integer) request.getAttribute("totalBanks");
    if (totalBanks == null) totalBanks = 0;

    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    if (totalTransactions == null) totalTransactions = 0;

    BigDecimal totalCommissions = (BigDecimal) request.getAttribute("totalCommissions");
    if (totalCommissions == null) totalCommissions = BigDecimal.ZERO;

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    Integer totalCards = (Integer) request.getAttribute("totalCards");
    if (totalCards == null) totalCards = 0;

    Integer blockedCards = (Integer) request.getAttribute("blockedCards");
    if (blockedCards == null) blockedCards = 0;

    Integer totalLoans = (Integer) request.getAttribute("totalLoans");
    if (totalLoans == null) totalLoans = 0;

    Integer pendingLoans = (Integer) request.getAttribute("pendingLoans");
    if (pendingLoans == null) pendingLoans = 0;

    Integer disbursedLoans = (Integer) request.getAttribute("disbursedLoans");
    if (disbursedLoans == null) disbursedLoans = 0;

    BigDecimal totalDisbursedAmount = (BigDecimal) request.getAttribute("totalDisbursedAmount");
    if (totalDisbursedAmount == null) totalDisbursedAmount = BigDecimal.ZERO;

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Command Center - E-Banking Admin</title>
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
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(290px, 1fr));
            gap: 20px;
            margin-bottom: 36px;
        }
        .module-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .module-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
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
            margin-bottom: 18px;
        }
        .module-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 14px;
            border-top: 1px solid var(--border);
        }
        .module-badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
        }
        .badge-live {
            background: #eff6ff;
            color: #1d4ed8;
        }
        .badge-pending {
            background: #fef3c7;
            color: #92400e;
        }
        .badge-ready {
            background: #f0fdf4;
            color: #15803d;
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
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active">📊 Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link">🏛️ Partner Banks</a>
        <a href="${pageContext.request.contextPath}/admin/customers" class="nav-link">👥 Customers</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("loan_approved".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Loan application approved! Funds have been directly disbursed to customer's account and recorded in ledger.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            ❌ Platform Error: <%= errorParam %>
        </div>
    <% } %>

    <!-- Welcome Header Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h3 style="font-size: 1.4rem; color: var(--text-main); margin-bottom: 4px;">
                    Hello, <%= adminName != null ? adminName : "System Administrator" %>! 👋
                </h3>
                <p style="color: var(--text-muted); font-size: 0.92rem;">
                    Central Platform Governance Authority. Select an administration module below to manage partner banks, audit ledgers, review loans, and regulate customer accounts.
                </p>
            </div>
            <div>
                <span class="badge" style="background: #fef2f2; color: #991b1b; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #fecaca; font-size: 0.85rem;">
                    🛡️ Central Platform Authority
                </span>
            </div>
        </div>
    </div>

    <!-- High-level KPI Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">👥</div>
            <div class="stat-info">
                <h4>Total Customers</h4>
                <div class="stat-value"><%= totalCustomers %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">🏦</div>
            <div class="stat-info">
                <h4>Total Bank Accounts</h4>
                <div class="stat-value"><%= totalAccounts %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f5f3ff; color: #7c3aed;">🏛️</div>
            <div class="stat-info">
                <h4>Partner Banks</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= totalBanks %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">💰</div>
            <div class="stat-info">
                <h4>Deposits Managed</h4>
                <div class="stat-value" style="color: var(--success); font-size: 1.35rem;"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #ecfdf5; color: #059669;">📈</div>
            <div class="stat-info">
                <h4>Platform Commissions</h4>
                <div class="stat-value" style="color: #059669; font-size: 1.35rem;"><%= currencyFormat.format(totalCommissions) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fff7ed; color: #ea580c;">📜</div>
            <div class="stat-info">
                <h4>Loan Capital Outlay</h4>
                <div class="stat-value" style="color: #ea580c; font-size: 1.35rem;"><%= currencyFormat.format(totalDisbursedAmount) %></div>
            </div>
        </div>
    </div>

    <!-- Choose an Administration Section Grid -->
    <h3 style="margin-bottom: 16px; color: var(--text-main); font-weight: 700;">Platform Administration Modules</h3>

    <div class="modules-grid">
        <!-- 1. Partner Banks -->
        <div class="module-card">
            <div>
                <div class="module-icon">🏛️</div>
                <div class="module-title">Partner Banks</div>
                <div class="module-desc">
                    Onboard registered banking institutions (SBI, HDFC, ICICI, Axis, PNB), adjust commission rate fees, and regulate operational status.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-live"><%= totalBanks %> Institutions</span>
                <a href="${pageContext.request.contextPath}/admin/banks" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Manage Banks &rarr;
                </a>
            </div>
        </div>

        <!-- 2. Customer Management -->
        <div class="module-card">
            <div>
                <div class="module-icon">👥</div>
                <div class="module-title">Customer Management</div>
                <div class="module-desc">
                    Review registered customer profiles, search by name or contact, verify KYC records, monitor account balances, and toggle access status.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-live"><%= totalCustomers %> Customers</span>
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Customers Desk &rarr;
                </a>
            </div>
        </div>

        <!-- 3. Bank Accounts Desk -->
        <div class="module-card">
            <div>
                <div class="module-icon">🏦</div>
                <div class="module-title">Bank Accounts Desk</div>
                <div class="module-desc">
                    System-wide ledger of all Savings & Current accounts across partner banks. Filter by institution, inspect balances, and verify IFSC routing.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-live"><%= totalAccounts %> Accounts</span>
                <a href="${pageContext.request.contextPath}/admin/accounts" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Accounts Desk &rarr;
                </a>
            </div>
        </div>

        <!-- 4. Transactions Ledger -->
        <div class="module-card">
            <div>
                <div class="module-icon">💳</div>
                <div class="module-title">Transactions & Ledger</div>
                <div class="module-desc">
                    Audit cash deposits, ATM withdrawals, and inter-bank customer fund transfers with reference numbers, status tracking, and commission cuts.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-ready"><%= totalTransactions %> Executed</span>
                <a href="${pageContext.request.contextPath}/admin/transactions" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Ledger &rarr;
                </a>
            </div>
        </div>

        <!-- 5. Loans Review Desk -->
        <div class="module-card">
            <div>
                <div class="module-icon">📜</div>
                <div class="module-title">Loans & Disbursal Desk</div>
                <div class="module-desc">
                    Review pending customer loan applications, evaluate interest rates & tenures, and execute atomic approval with instant balance credit.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge <%= pendingLoans > 0 ? "badge-pending" : "badge-ready" %>">
                    <%= pendingLoans > 0 ? pendingLoans + " Pending Review" : disbursedLoans + " Disbursed" %>
                </span>
                <a href="${pageContext.request.contextPath}/admin/loans" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Open Loans Desk &rarr;
                </a>
            </div>
        </div>

        <!-- 6. Cards Management -->
        <div class="module-card">
            <div>
                <div class="module-icon">🪪</div>
                <div class="module-title">Cards Management</div>
                <div class="module-desc">
                    Platform-wide virtual Debit & Credit card registry. View masked card numbers, monitor daily limits, and manage fraud security lock status.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-live"><%= totalCards %> Issued (<%= blockedCards %> Blocked)</span>
                <a href="${pageContext.request.contextPath}/admin/cards" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    Manage Cards &rarr;
                </a>
            </div>
        </div>

        <!-- 7. Reports & Audit -->
        <div class="module-card">
            <div>
                <div class="module-icon">📊</div>
                <div class="module-title">Reports & Audit Trail</div>
                <div class="module-desc">
                    Institutional performance breakdown, fee commission reconciliation by partner bank, liquidity distribution, and printable financial audit statements.
                </div>
            </div>
            <div class="module-footer">
                <span class="module-badge badge-ready">System Health: Normal</span>
                <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                    View Reports &rarr;
                </a>
            </div>
        </div>
    </div>

    <!-- Platform System Status Card -->
    <div class="card" style="margin-bottom: 30px; background: #f8fafc; border: 1px solid var(--border);">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <span style="display: inline-block; width: 12px; height: 12px; background: #16a34a; border-radius: 50%;"></span>
                <span style="font-size: 0.9rem; font-weight: 600; color: var(--text-main);">
                    Platform Core Engine: Operational • Database Cluster Connected • Security Encryption Enabled
                </span>
            </div>
            <span style="font-size: 0.82rem; color: var(--text-muted);">
                Server Timestamp: <%= new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm:ss").format(new java.util.Date()) %>
            </span>
        </div>
    </div>
</div>

</body>
</html>
