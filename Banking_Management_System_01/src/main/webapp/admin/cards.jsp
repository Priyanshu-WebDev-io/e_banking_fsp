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

    Integer totalCards = (Integer) request.getAttribute("totalCards");
    if (totalCards == null) totalCards = 0;

    Integer activeCards = (Integer) request.getAttribute("activeCards");
    if (activeCards == null) activeCards = 0;

    Integer blockedCards = (Integer) request.getAttribute("blockedCards");
    if (blockedCards == null) blockedCards = 0;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> cards = (List<Map<String, Object>>) request.getAttribute("cards");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cards Management Desk - E-Banking Admin</title>
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
        <a href="${pageContext.request.contextPath}/admin/cards" class="nav-link active">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">📈 Reports & Audit</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Card operational security status updated successfully!
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            ❌ Card Action Error: <%= errorParam %>
        </div>
    <% } %>

    <!-- Cards Metrics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">🪪</div>
            <div class="stat-info">
                <h4>Total Issued Cards</h4>
                <div class="stat-value"><%= totalCards %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #f0fdf4; color: #15803d;">✅</div>
            <div class="stat-info">
                <h4>Active Functional Cards</h4>
                <div class="stat-value" style="color: var(--success);"><%= activeCards %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fef2f2; color: #b91c1c;">🔒</div>
            <div class="stat-info">
                <h4>Blocked / Restricted Cards</h4>
                <div class="stat-value" style="color: var(--danger);"><%= blockedCards %></div>
            </div>
        </div>
    </div>

    <!-- Cards Table Card -->
    <div class="card" style="margin-bottom: 40px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 18px;">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main);">🪪 Platform Virtual Cards Desk (<%= cards != null ? cards.size() : 0 %>)</h3>
                <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 2px;">
                    Monitor platform Debit & Credit cards, spending limits, expiration dates, and security freeze toggles.
                </p>
            </div>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="font-size: 0.85rem;">
                <thead>
                    <tr>
                        <th>Cardholder & Account</th>
                        <th>Holding Bank</th>
                        <th>Masked Number</th>
                        <th>Type</th>
                        <th>Daily Limit</th>
                        <th>Expires</th>
                        <th>Status</th>
                        <th>Security Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (cards != null && !cards.isEmpty()) {
                        for (Map<String, Object> card : cards) {
                            Integer cId = (Integer) card.get("cardId");
                            String maskedNum = (String) card.get("maskedNumber");
                            String cType = (String) card.get("cardType");
                            String cHolder = (String) card.get("cardHolderName");
                            String cExp = (String) card.get("expiryDate");
                            String cStatus = (String) card.get("status");
                            String cAcc = (String) card.get("accountNumber");
                            String cBank = (String) card.get("bankName");
                            BigDecimal cLimit = (BigDecimal) card.get("dailyLimit");
                            boolean isBlocked = "BLOCKED".equalsIgnoreCase(cStatus);
                %>
                    <tr>
                        <td>
                            <strong><%= cHolder %></strong><br>
                            <small style="color: var(--text-muted);">Acc #<%= cAcc %></small>
                        </td>
                        <td><small>🏛️ <%= cBank %></small></td>
                        <td><code><%= maskedNum %></code></td>
                        <td><span class="badge badge-type" style="font-size: 0.72rem;"><%= cType %></span></td>
                        <td><%= cLimit != null ? currencyFormat.format(cLimit) : "N/A" %></td>
                        <td><%= cExp %></td>
                        <td>
                            <span class="badge <%= isBlocked ? "badge-inactive" : "badge-active" %>" style="font-size: 0.72rem;">
                                <%= cStatus %>
                            </span>
                        </td>
                        <td>
                            <form action="${pageContext.request.contextPath}/admin/cards" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="cardId" value="<%= cId %>">
                                <button type="submit" class="btn <%= isBlocked ? "btn-primary" : "btn-secondary" %>"
                                        style="padding: 4px 10px; font-size: 0.75rem; <%= isBlocked ? "background: var(--success);" : "color: var(--danger); border-color: var(--danger);" %>"
                                        onclick="return confirm('<%= isBlocked ? "Unlock and activate" : "Freeze and block" %> card ending in <%= maskedNum.substring(maskedNum.length() - 4) %>?')">
                                    <%= isBlocked ? "🔓 Activate" : "🔒 Freeze" %>
                                </button>
                            </form>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No virtual cards issued on the platform yet.
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
