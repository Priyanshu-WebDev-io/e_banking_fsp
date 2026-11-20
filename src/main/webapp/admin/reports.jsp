<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
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

    BigDecimal totalVolume = (BigDecimal) request.getAttribute("totalVolume");
    if (totalVolume == null) totalVolume = BigDecimal.ZERO;

    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    if (totalTransactions == null) totalTransactions = 0;

    Integer totalBanks = (Integer) request.getAttribute("totalBanks");
    if (totalBanks == null) totalBanks = 0;

    BigDecimal avgCommissionYield = (BigDecimal) request.getAttribute("avgCommissionYield");
    if (avgCommissionYield == null) avgCommissionYield = BigDecimal.ZERO;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> bankBreakdown = (List<Map<String, Object>>) request.getAttribute("bankBreakdown");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> topCommissionTransactions = (List<Map<String, Object>>) request.getAttribute("topCommissionTransactions");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Commission Audit & Reports - Platform Admin</title>
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
            background: #7c2d12;
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
        <h2>🛡️ Platform Commission Authority</h2>
        <div class="user-info">
            <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.8rem; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">Platform Admin</span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">📊 Commission Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link">🏛️ Partner Banks & Fee Rates</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💰 Commission Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link active">📈 Commission Analytics & Audit</a>
    </div>

    <!-- Header Action Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
            <div>
                <h3 style="font-size: 1.35rem; color: var(--text-main); margin-bottom: 4px;">📊 Platform Commission Yield & Audit Trail</h3>
                <p style="color: var(--text-muted); font-size: 0.9rem; margin: 0;">
                    Executive revenue reports, fee commission reconciliation by partner bank, and transaction yield metrics.
                </p>
            </div>
            <button type="button" class="btn btn-secondary no-print" onclick="window.print()" style="padding: 8px 18px; font-size: 0.9rem;">
                🖨️ Print Commission Audit
            </button>
        </div>
    </div>

    <!-- High-level KPI Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #ecfdf5; color: #059669;">💰</div>
            <div class="stat-info">
                <h4>Total Commissions Earned</h4>
                <div class="stat-value" style="color: #059669; font-size: 1.45rem;"><%= currencyFormat.format(totalCommissions) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">💳</div>
            <div class="stat-info">
                <h4>Total Transacted Volume</h4>
                <div class="stat-value" style="color: #1d4ed8; font-size: 1.35rem;"><%= currencyFormat.format(totalVolume) %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">📊</div>
            <div class="stat-info">
                <h4>Processed Transactions</h4>
                <div class="stat-value" style="color: #a16207;"><%= totalTransactions %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #fff7ed; color: #ea580c;">📈</div>
            <div class="stat-info">
                <h4>Platform Commission Yield</h4>
                <div class="stat-value" style="color: #ea580c;"><%= avgCommissionYield %>%</div>
            </div>
        </div>
    </div>

    <!-- Institutional Commission Breakdown per Partner Bank -->
    <div class="card" style="margin-bottom: 24px;">
        <h4 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 16px;">🏛️ Commission Revenue Breakdown by Partner Bank</h4>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Bank Name</th>
                        <th>Bank Code</th>
                        <th>Commission Rate</th>
                        <th>Active Accounts</th>
                        <th>Total Customer Deposits</th>
                        <th>Commission Transactions</th>
                        <th>Total Commission Generated</th>
                        <th>Yield Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bankBreakdown != null && !bankBreakdown.isEmpty()) {
                        for (Map<String, Object> b : bankBreakdown) {
                            BigDecimal bComm = (BigDecimal) b.get("commissionsGenerated");
                            if (bComm == null) bComm = BigDecimal.ZERO;
                    %>
                        <tr>
                            <td><strong><%= b.get("bankName") %></strong></td>
                            <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= b.get("bankCode") %></span></td>
                            <td style="font-weight: 700; color: #ea580c;"><%= b.get("commissionRate") %>%</td>
                            <td><%= b.get("accountCount") %></td>
                            <td style="color: #64748b;"><%= currencyFormat.format(b.get("totalDeposits")) %></td>
                            <td><%= b.get("transCount") %></td>
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

    <!-- Top Commission Generating Transactions -->
    <div class="card" style="margin-bottom: 24px;">
        <h4 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 16px;">⚡ Top Commission-Generating Transactions</h4>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Reference #</th>
                        <th>Origin Bank</th>
                        <th>Destination Bank</th>
                        <th>Transaction Type</th>
                        <th>Volume</th>
                        <th>Commission Rate</th>
                        <th>Commission Earned</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (topCommissionTransactions != null && !topCommissionTransactions.isEmpty()) {
                        for (Map<String, Object> t : topCommissionTransactions) {
                    %>
                        <tr>
                            <td><strong><%= t.get("referenceNumber") %></strong></td>
                            <td><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= t.get("fromBankName") %></span></td>
                            <td><span class="badge" style="background: #f1f5f9; color: #334155;"><%= t.get("toBankName") %></span></td>
                            <td><%= t.get("transactionType") %></td>
                            <td style="font-weight: 600;"><%= currencyFormat.format(t.get("amount")) %></td>
                            <td style="color: #ea580c; font-weight: 700;"><%= t.get("commissionRate") %>%</td>
                            <td style="font-weight: 800; color: #059669;"><%= currencyFormat.format(t.get("commissionAmount")) %></td>
                            <td style="font-size: 0.8rem; color: #64748b;"><%= t.get("createdAt") %></td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No transactions with commissions found yet.
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
