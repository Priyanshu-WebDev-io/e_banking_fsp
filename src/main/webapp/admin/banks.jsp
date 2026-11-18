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

    Integer totalBanks = (Integer) request.getAttribute("totalBanks");
    if (totalBanks == null) totalBanks = 0;

    Integer activeBanks = (Integer) request.getAttribute("activeBanks");
    if (activeBanks == null) activeBanks = 0;

    BigDecimal avgCommission = (BigDecimal) request.getAttribute("avgCommission");
    if (avgCommission == null) avgCommission = BigDecimal.ZERO;

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> banks = (List<Map<String, Object>>) request.getAttribute("banks");

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Partner Banks Management - E-Banking Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 18px;
        }
        .stat-icon {
            width: 54px;
            height: 54px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }
        .stat-info h4 {
            font-size: 0.82rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .stat-info .stat-value {
            font-size: 1.7rem;
            font-weight: 800;
            color: var(--text-main);
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            margin-top: 24px;
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
        .nav-admin-badge {
            background-color: #fee2e2;
            color: #991b1b;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            margin-right: 8px;
        }
        .commission-input-group {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .commission-input-group input {
            width: 80px;
            padding: 4px 8px;
            font-size: 0.85rem;
            border: 1px solid var(--border);
            border-radius: 4px;
            text-align: right;
        }
        .btn-sm {
            padding: 4px 10px;
            font-size: 0.8rem;
            border-radius: 4px;
            cursor: pointer;
            border: none;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-toggle-suspend {
            background-color: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        .btn-toggle-suspend:hover {
            background-color: #fee2e2;
        }
        .btn-toggle-activate {
            background-color: #f0fdf4;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }
        .btn-toggle-activate:hover {
            background-color: #dcfce7;
        }
        .card-add-bank {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }
    </style>
</head>
<body>

<div class="container-lg">
    <!-- Navbar -->
    <div class="navbar-custom">
        <h2>🛡️ E-Banking Admin Portal</h2>
        <div class="user-info">
            <span class="nav-admin-badge">Admin</span>
            <span>Welcome, <strong><%= adminName != null ? adminName : adminUsername %></strong></span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Sub-navigation Bar -->
    <div class="admin-nav-bar">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">📊 Command Center</a>
        <a href="${pageContext.request.contextPath}/admin/banks" class="nav-link active">🏛️ Partner Banks</a>
        <a href="${pageContext.request.contextPath}/admin/customers" class="nav-link">👥 Customers</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/admin/transactions" class="nav-link">💳 Transactions Ledger</a>
        <a href="${pageContext.request.contextPath}/admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("added".equals(successParam)) { %>
        <div class="alert alert-success">
            Partner Bank onboarded successfully onto the E-Banking platform!
        </div>
    <% } else if ("updated".equals(successParam)) { %>
        <div class="alert alert-success">
            Platform commission rate updated successfully for the bank.
        </div>
    <% } else if ("status".equals(successParam)) { %>
        <div class="alert alert-success">
            Bank operational status updated successfully.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger">
            Error processing request: <%= errorParam %>
        </div>
    <% } %>

    <!-- Header Description -->
    <div class="card" style="margin-bottom: 24px;">
        <div class="brand-header" style="text-align: left; margin-bottom: 0;">
            <h2 style="font-size: 1.5rem; margin-bottom: 6px;">🏛️ Partner Banks & Commission Configuration</h2>
            <p style="color: var(--text-muted); font-size: 0.95rem;">
                Manage partner banks onboarded to the multi-bank platform. Configure transaction commission rates, monitor deposits per institution, and regulate bank statuses.
            </p>
        </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #eff6ff; color: #2563eb;">🏛️</div>
            <div class="stat-info">
                <h4>Total Partner Banks</h4>
                <div class="stat-value"><%= totalBanks %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #f0fdf4; color: #16a34a;">✅</div>
            <div class="stat-info">
                <h4>Active Institutions</h4>
                <div class="stat-value" style="color: #16a34a;"><%= activeBanks %></div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #faf5ff; color: #9333ea;">📊</div>
            <div class="stat-info">
                <h4>Avg. Commission Rate</h4>
                <div class="stat-value" style="color: #9333ea;"><%= avgCommission %>%</div>
            </div>
        </div>
    </div>

    <!-- Onboard New Bank Card -->
    <div class="card-add-bank">
        <h3 style="font-size: 1.15rem; color: var(--text-main); margin-bottom: 6px;">➕ Onboard New Partner Bank</h3>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 16px;">
            Register a new banking institution onto the platform to offer accounts, cards, and loan products.
        </p>

        <form action="${pageContext.request.contextPath}/admin/banks" method="post">
            <input type="hidden" name="action" value="add">

            <div class="form-row">
                <div class="form-group">
                    <label for="bankName">Bank Name *</label>
                    <input type="text" id="bankName" name="bankName" placeholder="e.g. Kotak Mahindra Bank" required>
                </div>

                <div class="form-group">
                    <label for="bankCode">Bank Code *</label>
                    <input type="text" id="bankCode" name="bankCode" placeholder="e.g. KKBK" maxlength="10" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="ifscPrefix">IFSC Prefix *</label>
                    <input type="text" id="ifscPrefix" name="ifscPrefix" placeholder="e.g. KKBK000101" maxlength="11" required>
                </div>

                <div class="form-group">
                    <label for="commissionRate">Platform Commission Rate (%) *</label>
                    <input type="number" step="0.01" min="0.00" max="10.00" id="commissionRate" name="commissionRate" placeholder="e.g. 0.50" value="0.50" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="max-width: 240px; margin-top: 8px;">
                Onboard Bank to Platform
            </button>
        </form>
    </div>

    <!-- Partner Banks List -->
    <div class="section-header">
        <h3>Registered Partner Banks (<%= banks != null ? banks.size() : 0 %>)</h3>
    </div>

    <div class="card" style="padding: 0; overflow: hidden; margin-bottom: 40px;">
        <div class="table-responsive">
            <table class="data-table" style="margin: 0;">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Institution Name</th>
                        <th>Bank Code</th>
                        <th>IFSC Prefix</th>
                        <th>Total Accounts</th>
                        <th>Total Deposits</th>
                        <th>Platform Commission</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (banks == null || banks.isEmpty()) {
                %>
                    <tr>
                        <td colspan="9" style="text-align: center; padding: 30px; color: var(--text-muted);">
                            No partner banks registered on the platform yet.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Map<String, Object> b : banks) {
                            int bId = (Integer) b.get("bankId");
                            String bName = (String) b.get("bankName");
                            String bCode = (String) b.get("bankCode");
                            String ifsc = (String) b.get("ifscPrefix");
                            BigDecimal rate = (BigDecimal) b.get("commissionRate");
                            String status = (String) b.get("status");
                            int accCount = (Integer) b.get("totalAccounts");
                            BigDecimal deposits = (BigDecimal) b.get("totalDeposits");
                            boolean isActive = "ACTIVE".equalsIgnoreCase(status);
                %>
                    <tr>
                        <td><strong>#<%= bId %></strong></td>
                        <td>
                            <strong style="color: var(--primary);"><%= bName %></strong>
                        </td>
                        <td><code><%= bCode %></code></td>
                        <td><code><%= ifsc %></code></td>
                        <td><strong><%= accCount %></strong></td>
                        <td style="color: var(--success); font-weight: 700;">
                            <%= currencyFormat.format(deposits != null ? deposits : BigDecimal.ZERO) %>
                        </td>
                        <td>
                            <form action="${pageContext.request.contextPath}/admin/banks" method="post" style="margin: 0;">
                                <input type="hidden" name="action" value="update_commission">
                                <input type="hidden" name="bankId" value="<%= bId %>">
                                <div class="commission-input-group">
                                    <input type="number" step="0.01" min="0.00" max="10.00" name="commissionRate" value="<%= rate %>" required>
                                    <span style="font-size: 0.85rem; font-weight: 600;">%</span>
                                    <button type="submit" class="btn-sm btn-primary" title="Update Commission">Save</button>
                                </div>
                            </form>
                        </td>
                        <td>
                            <span class="badge <%= isActive ? "badge-active" : "badge-inactive" %>">
                                <%= status %>
                            </span>
                        </td>
                        <td>
                            <form action="${pageContext.request.contextPath}/admin/banks" method="post" style="display: inline; margin: 0;">
                                <input type="hidden" name="action" value="toggle_status">
                                <input type="hidden" name="bankId" value="<%= bId %>">
                                <input type="hidden" name="currentStatus" value="<%= status %>">
                                <% if (isActive) { %>
                                    <button type="submit" class="btn-sm btn-toggle-suspend" onclick="return confirm('Suspend operations for <%= bName %>?');">
                                        Suspend
                                    </button>
                                <% } else { %>
                                    <button type="submit" class="btn-sm btn-toggle-activate" onclick="return confirm('Activate operations for <%= bName %>?');">
                                        Activate
                                    </button>
                                <% } %>
                            </form>
                        </td>
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
