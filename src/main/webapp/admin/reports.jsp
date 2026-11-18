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

    BigDecimal totalDeposits = (BigDecimal) request.getAttribute("totalDeposits");
    if (totalDeposits == null) totalDeposits = BigDecimal.ZERO;

    BigDecimal totalCommissions = (BigDecimal) request.getAttribute("totalCommissions");
    if (totalCommissions == null) totalCommissions = BigDecimal.ZERO;

    BigDecimal totalLoansDisbursed = (BigDecimal) request.getAttribute("totalLoansDisbursed");
    if (totalLoansDisbursed == null) totalLoansDisbursed = BigDecimal.ZERO;

    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    if (totalAccounts == null) totalAccounts = 0;

    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    if (totalCustomers == null) totalCustomers = 0;

    Integer totalBanks = (Integer) request.getAttribute("totalBanks");
    if (totalBanks == null) totalBanks = 0;

    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    if (totalTransactions == null) totalTransactions = 0;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> bankBreakdown = (List<Map<String, Object>>) request.getAttribute("bankBreakdown");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> loanProductBreakdown = (List<Map<String, Object>>) request.getAttribute("loanProductBreakdown");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Institutional Audit & Platform Reports - E-Banking Admin</title>
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
            font-size: 1.5rem;
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
        @media print {
            .navbar-custom, .admin-nav-bar, .no-print {
                display: none !important;
            }
            body {
                background: #ffffff;
                padding: 0;
            }
            .card {
                box-shadow: none;
                border: 1px solid #000;
            }
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
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link active">📈 Reports & Audit</a>
    </div>

    <!-- Header Action Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
            <div>
                <h3 style="font-size: 1.35rem; color: var(--text-main); margin-bottom: 4px;">📊 Platform Institutional Reports & Audit Trail</h3>
                <p style="color: var(--text-muted); font-size: 0.9rem;">
                    Institutional performance breakdown, fee commission reconciliation by partner bank, and capital allocation statements.
                </p>
            </div>
            <button type="button" class="btn btn-secondary no-print" onclick="window.print()" style="padding: 8px 18px; font-size: 0.9rem;">
                🖨️ Print Audit Statement
            </button>
        </div>
    </div>

    <!-- Financial Liquidity & Health Overview -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">💰</div>
            <div class="stat-info">
                <h4>Total Platform Liquidity</h4>
                <div class="stat-value" style="color: var(--success);"><%= currencyFormat.format(totalDeposits) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #ecfdf5; color: #059669;">📈</div>
            <div class="stat-info">
                <h4>Accumulated Commission Fee</h4>
                <div class="stat-value" style="color: #059669;"><%= currencyFormat.format(totalCommissions) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fff7ed; color: #ea580c;">📜</div>
            <div class="stat-info">
                <h4>Disbursed Loan Capital</h4>
                <div class="stat-value" style="color: #ea580c;"><%= currencyFormat.format(totalLoansDisbursed) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f5f3ff; color: #7c3aed;">🏛️</div>
            <div class="stat-info">
                <h4>Onboarded Partner Banks</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= totalBanks %> Institutions</div>
            </div>
        </div>
    </div>

    <!-- Institutional Breakdown Table -->
    <div class="card" style="margin-bottom: 32px;">
        <h3 style="font-size: 1.2rem; color: var(--text-main); margin-bottom: 6px;">🏛️ Partner Bank Deposit & Fee Contribution Breakdown</h3>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 18px;">
            Comparison of institutional liquidity, hosted customer account portfolios, and platform fee revenues by partner bank.
        </p>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Partner Bank</th>
                        <th>Institution Code</th>
                        <th>Status</th>
                        <th>Commission Rate</th>
                        <th>Hosted Accounts</th>
                        <th>Total Deposits Managed</th>
                        <th>Platform Fee Revenue</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (bankBreakdown != null && !bankBreakdown.isEmpty()) {
                        for (Map<String, Object> b : bankBreakdown) {
                            String bName = (String) b.get("bankName");
                            String bCode = (String) b.get("bankCode");
                            String status = (String) b.get("status");
                            BigDecimal rate = (BigDecimal) b.get("commissionRate");
                            Integer accCount = (Integer) b.get("accountCount");
                            BigDecimal deposits = (BigDecimal) b.get("totalDeposits");
                            BigDecimal commGen = (BigDecimal) b.get("commissionsGenerated");
                %>
                    <tr>
                        <td><strong><%= bName %></strong></td>
                        <td><code><%= bCode %></code></td>
                        <td><span class="badge <%= "ACTIVE".equalsIgnoreCase(status) ? "badge-active" : "badge-inactive" %>" style="font-size: 0.72rem;"><%= status %></span></td>
                        <td><strong><%= rate %>%</strong></td>
                        <td><%= accCount %> accounts</td>
                        <td><strong style="color: var(--success);"><%= currencyFormat.format(deposits) %></strong></td>
                        <td><span style="color: #166534; font-weight: 700;">+<%= currencyFormat.format(commGen) %></span></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Loan Product Distribution Table -->
    <div class="card" style="margin-bottom: 40px;">
        <h3 style="font-size: 1.2rem; color: var(--text-main); margin-bottom: 6px;">📜 Loan Portfolio Capital Allocation</h3>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 18px;">
            Distribution of loan schemes, annual percentage rates, and total active capital disbursed.
        </p>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Loan Scheme</th>
                        <th>Category</th>
                        <th>Annual Rate</th>
                        <th>Total Applications</th>
                        <th>Disbursed Count</th>
                        <th>Total Capital Outlay</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (loanProductBreakdown != null && !loanProductBreakdown.isEmpty()) {
                        for (Map<String, Object> lp : loanProductBreakdown) {
                            String pName = (String) lp.get("productName");
                            String lType = (String) lp.get("loanType");
                            BigDecimal rate = (BigDecimal) lp.get("interestRate");
                            Integer totalApps = (Integer) lp.get("totalApplications");
                            Integer disbCount = (Integer) lp.get("disbursedCount");
                            BigDecimal disbAmt = (BigDecimal) lp.get("disbursedAmount");
                %>
                    <tr>
                        <td><strong><%= pName %></strong></td>
                        <td><span class="badge badge-type" style="font-size: 0.72rem;"><%= lType %></span></td>
                        <td><%= rate %>% p.a.</td>
                        <td><%= totalApps %></td>
                        <td><%= disbCount %></td>
                        <td><strong style="color: var(--primary);"><%= currencyFormat.format(disbAmt) %></strong></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
