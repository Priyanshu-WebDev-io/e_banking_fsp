<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal, java.text.NumberFormat, java.util.Locale, java.util.List, java.util.Map" %>
<%
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=platform_admin");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");
    String adminUsername = (String) session.getAttribute("adminUsername");

    BigDecimal totalCommissions = (BigDecimal) request.getAttribute("totalCommissions");
    if (totalCommissions == null) totalCommissions = BigDecimal.ZERO;

    BigDecimal loanCommissions = (BigDecimal) request.getAttribute("loanCommissions");
    if (loanCommissions == null) loanCommissions = BigDecimal.ZERO;

    Integer loanCommissionCount = (Integer) request.getAttribute("loanCommissionCount");
    if (loanCommissionCount == null) loanCommissionCount = 0;

    BigDecimal transCommissions = (BigDecimal) request.getAttribute("transCommissions");
    if (transCommissions == null) transCommissions = BigDecimal.ZERO;

    Integer transCommissionCount = (Integer) request.getAttribute("transCommissionCount");
    if (transCommissionCount == null) transCommissionCount = 0;

    BigDecimal totalVolume = (BigDecimal) request.getAttribute("totalVolume");
    if (totalVolume == null) totalVolume = BigDecimal.ZERO;

    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    if (totalTransactions == null) totalTransactions = 0;

    Integer totalBanks = (Integer) request.getAttribute("totalBanks");
    if (totalBanks == null) totalBanks = 0;

    BigDecimal avgCommissionRate = (BigDecimal) request.getAttribute("avgCommissionRate");
    if (avgCommissionRate == null) avgCommissionRate = BigDecimal.ZERO;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> bankBreakdown = (List<Map<String, Object>>) request.getAttribute("bankBreakdown");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentCommissions = (List<Map<String, Object>>) request.getAttribute("recentCommissions");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Commission Governance - Platform Admin</title>
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
            background: #7c2d12;
            color: #ffffff;
        }
        .info-notice {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            padding: 14px 18px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🛡️ Platform Commission Authority</h2>
        <div class="user-info">
            <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">
                Platform Admin
            </span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Platform Admin Navigation Bar (Restricted strictly to Commissions & Partner Banks) -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link active">📊 Commission Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link">🏛️ Partner Banks & Fee Rates</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💰 Commission Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Commission Analytics & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            ⚠️ <%= errorParam %>
        </div>
    <% } %>

    <!-- Welcome Header Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h3 style="font-size: 1.4rem; color: var(--text-main); margin-bottom: 4px;">
                    Hello, <%= adminName != null ? adminName : "Platform Administrator" %>! 👋
                </h3>
                <p style="color: var(--text-muted); font-size: 0.92rem; margin: 0;">
                    Central Platform Revenue Authority. This portal is exclusively focused on tracking, collecting, and regulating <strong>platform commissions</strong> generated across partner bank transactions.
                </p>
            </div>
            <div>
                <span class="badge" style="background: #fef2f2; color: #991b1b; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #fecaca; font-size: 0.85rem;">
                    📈 Platform Revenue Governance
                </span>
            </div>
        </div>
    </div>

    <!-- Segregation Notice Banner -->
    <div class="info-notice">
        <div style="font-size: 0.88rem; color: #475569;">
            ℹ️ <strong>System Architecture Note:</strong> Banking operations (Customer Accounts, Loan Underwriting, and Payment Cards) are handled exclusively by <strong>Bank Administrators</strong> in the <a href="${pageContext.request.contextPath}/bank-admin/login.jsp" style="color: #059669; font-weight: 700; text-decoration: underline;">Bank Admin Portal</a>.
        </div>
        <a href="${pageContext.request.contextPath}/bank-admin/login.jsp" class="btn btn-secondary" style="font-size: 0.8rem; padding: 6px 12px; color: #059669; border-color: #059669;">
            🏦 Switch to Bank Admin Portal
        </a>
    </div>

    <!-- Platform Commission KPI Stats -->
    <div class="stats-grid">
        <div class="stat-card" style="border-left: 4px solid #059669;">
            <div class="stat-icon" style="background-color: #ecfdf5; color: #059669;">💰</div>
            <div class="stat-info">
                <h4>Total Platform Commissions</h4>
                <div class="stat-value" style="color: #059669; font-size: 1.7rem;"><%= currencyFormat.format(totalCommissions) %></div>
                <div style="font-size: 0.78rem; color: #64748b; font-weight: 600;">All institutional revenue</div>
            </div>
        </div>

        <div class="stat-card" style="border-left: 4px solid #d97706;">
            <div class="stat-icon" style="background-color: #fef3c7; color: #d97706;">📜</div>
            <div class="stat-info">
                <h4>Commissions on Loans Sanctioned</h4>
                <div class="stat-value" style="color: #b45309; font-size: 1.5rem;"><%= currencyFormat.format(loanCommissions) %></div>
                <div style="font-size: 0.78rem; color: #b45309; font-weight: 600;"><%= loanCommissionCount %> Loan Disbursal(s)</div>
            </div>
        </div>

        <div class="stat-card" style="border-left: 4px solid #2563eb;">
            <div class="stat-icon" style="background-color: #eff6ff; color: #2563eb;">💳</div>
            <div class="stat-info">
                <h4>Commissions on Transactions Done</h4>
                <div class="stat-value" style="color: #1d4ed8; font-size: 1.5rem;"><%= currencyFormat.format(transCommissions) %></div>
                <div style="font-size: 0.78rem; color: #1d4ed8; font-weight: 600;"><%= transCommissionCount %> Transfer Event(s)</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">📊</div>
            <div class="stat-info">
                <h4>Gross Transaction Volume</h4>
                <div class="stat-value" style="color: #a16207; font-size: 1.35rem;"><%= currencyFormat.format(totalVolume) %></div>
                <div style="font-size: 0.78rem; color: #64748b;"><%= totalTransactions %> Transacted Entries</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #faf5ff; color: #7c3aed;">🏛️</div>
            <div class="stat-info">
                <h4>Partner Banks & Rates</h4>
                <div class="stat-value" style="color: #7c3aed;"><%= totalBanks %> Banks</div>
                <div style="font-size: 0.78rem; color: #7c3aed; font-weight: 600;">Avg. Rate: <%= avgCommissionRate %>%</div>
            </div>
        </div>
    </div>

    <!-- Partner Banks Commission Revenue Breakdown Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <div>
                <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">🏛️ Bank-Related Commissions & Institutional Breakdown</h4>
                <p style="margin: 4px 0 0; font-size: 0.85rem; color: var(--text-muted);">
                    Platform revenue generated across partner banks segregated by loan sanctions and customer transactions.
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/banks" class="btn btn-secondary" style="font-size: 0.85rem; padding: 6px 14px;">Manage Partner Bank Rates &rarr;</a>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Partner Bank</th>
                        <th>Bank Code</th>
                        <th>Commission Fee Rate</th>
                        <th>Accounts & Volume</th>
                        <th>Loan Sanctions Commission</th>
                        <th>Transactions Commission</th>
                        <th>Total Platform Commission</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bankBreakdown != null && !bankBreakdown.isEmpty()) {
                        for (Map<String, Object> b : bankBreakdown) {
                            BigDecimal bComm = (BigDecimal) b.get("commissionsGenerated");
                            if (bComm == null) bComm = BigDecimal.ZERO;
                            BigDecimal lComm = (BigDecimal) b.get("loanCommissionsGenerated");
                            if (lComm == null) lComm = BigDecimal.ZERO;
                            BigDecimal tComm = bComm.subtract(lComm);
                            if (tComm.compareTo(BigDecimal.ZERO) < 0) tComm = BigDecimal.ZERO;
                    %>
                        <tr>
                            <td><strong><%= b.get("bankName") %></strong></td>
                            <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= b.get("bankCode") %></span></td>
                            <td style="font-weight: 700; color: #ea580c;"><%= b.get("commissionRate") %>%</td>
                            <td>
                                <div><strong><%= b.get("accountCount") %></strong> Accounts</div>
                                <div style="font-size: 0.78rem; color: #64748b;"><%= currencyFormat.format(b.get("totalDeposits")) %></div>
                            </td>
                            <td style="font-weight: 700; color: #b45309;"><%= currencyFormat.format(lComm) %></td>
                            <td style="font-weight: 700; color: #1d4ed8;"><%= currencyFormat.format(tComm) %></td>
                            <td style="font-weight: 800; color: #059669; font-size: 1.05rem;"><%= currencyFormat.format(bComm) %></td>
                            <td>
                                <span class="badge" style="<%= "ACTIVE".equals(b.get("status")) ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;" %>">
                                    <%= b.get("status") %>
                                </span>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No partner banks registered yet.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Platform Commission Events Table -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <div>
                <h4 style="margin: 0; font-size: 1.15rem; font-weight: 700;">⚡ Recent Platform Commission Events</h4>
                <p style="margin: 4px 0 0; font-size: 0.85rem; color: var(--text-muted);">
                    Real-time commission fees harvested from loans sanctioned and transfer transactions.
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/transactions" class="btn btn-secondary" style="font-size: 0.85rem; padding: 6px 14px;">Full Ledger &rarr;</a>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Txn Ref #</th>
                        <th>Revenue Stream</th>
                        <th>Origin Bank</th>
                        <th>Destination Bank</th>
                        <th>Transacted Amount</th>
                        <th>Commission Rate</th>
                        <th>Commission Fee Earned</th>
                        <th>Timestamp</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (recentCommissions != null && !recentCommissions.isEmpty()) {
                        for (Map<String, Object> rc : recentCommissions) {
                            String stype = (String) rc.get("sourceType");
                    %>
                        <tr>
                            <td>
                                <strong><%= rc.get("referenceNumber") %></strong>
                                <div style="font-size: 0.75rem; color: #64748b;"><%= rc.get("description") != null ? rc.get("description") : "" %></div>
                            </td>
                            <td>
                                <% if ("LOAN_SANCTION".equals(stype)) { %>
                                    <span class="badge" style="background: #fef3c7; color: #92400e; font-weight: 700;">📜 Loan Sanction</span>
                                <% } else { %>
                                    <span class="badge" style="background: #dbeafe; color: #1e40af; font-weight: 700;">💳 Transaction</span>
                                <% } %>
                            </td>
                            <td><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= rc.get("fromBankName") %></span></td>
                            <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= rc.get("toBankName") %></span></td>
                            <td style="font-weight: 600;"><%= currencyFormat.format(rc.get("transactionAmount")) %></td>
                            <td style="color: #ea580c; font-weight: 700;"><%= rc.get("commissionRate") %>%</td>
                            <td style="font-weight: 800; color: #059669; font-size: 1rem;"><%= currencyFormat.format(rc.get("commissionAmount")) %></td>
                            <td style="font-size: 0.82rem; color: #64748b;"><%= rc.get("createdAt") %></td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No commission transactions recorded yet. Commissions are generated automatically when loans are disbursed or customer transactions occur.
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
