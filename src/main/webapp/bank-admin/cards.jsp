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
    <title>Payment Cards Desk - Bank Admin</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
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
        .card-number-badge {
            font-family: monospace;
            font-size: 0.95rem;
            letter-spacing: 1px;
            background: #f1f5f9;
            padding: 4px 8px;
            border-radius: 6px;
            border: 1px solid var(--border);
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
        <a href="${pageContext.request.contextPath}/bank-admin/accounts" class="nav-link">🏦 Bank Accounts</a>
        <a href="${pageContext.request.contextPath}/bank-admin/loans" class="nav-link">📜 Loans Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/cards" class="nav-link active">🪪 Cards Desk</a>
        <a href="${pageContext.request.contextPath}/bank-admin/customers" class="nav-link">👥 Customer Directory</a>
    </div>

    <!-- Feedback Alerts -->
    <% if ("status_updated".equals(successParam)) { %>
        <div class="alert alert-success" style="margin-bottom: 20px;">
            ✅ Card status has been updated successfully.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 20px;">
            <%= errorParam %>
        </div>
    <% } %>

    <!-- KPI Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #1d4ed8;">🪪</div>
            <div class="stat-info">
                <h4>Total Issued Cards</h4>
                <div class="stat-value"><%= totalCards %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #dcfce7; color: #166534;">✅</div>
            <div class="stat-info">
                <h4>Active Cards</h4>
                <div class="stat-value" style="color: #166534;"><%= activeCards %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #fee2e2; color: #991b1b;">🚫</div>
            <div class="stat-info">
                <h4>Blocked Cards</h4>
                <div class="stat-value" style="color: #991b1b;"><%= blockedCards %></div>
            </div>
        </div>
    </div>

    <!-- Cards Table -->
    <div class="card">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Card Number</th>
                        <th>Cardholder</th>
                        <th>Type</th>
                        <th>Bank / Account</th>
                        <th>Expiry</th>
                        <th>Daily Limit</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (cards != null && !cards.isEmpty()) {
                        for (Map<String, Object> c : cards) {
                            String st = (String) c.get("status");
                            boolean isActive = "ACTIVE".equalsIgnoreCase(st);
                            int cardId = (Integer) c.get("cardId");
                    %>
                        <tr>
                            <td>
                                <span class="card-number-badge"><%= c.get("maskedNumber") %></span>
                            </td>
                            <td>
                                <div><strong><%= c.get("cardHolderName") %></strong></div>
                                <div style="font-size: 0.8rem; color: #64748b;"><%= c.get("customerEmail") %></div>
                            </td>
                            <td>
                                <span class="badge" style="<%= "CREDIT".equals(c.get("cardType")) ? "background: #fdf4ff; color: #a21caf;" : "background: #eff6ff; color: #1d4ed8;" %>">
                                    <%= c.get("cardType") %>
                                </span>
                            </td>
                            <td>
                                <div><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= c.get("bankName") %></span></div>
                                <div style="font-size: 0.78rem; color: #64748b;">Acc: <%= c.get("accountNumber") %></div>
                            </td>
                            <td style="font-family: monospace; font-weight: 700;"><%= c.get("expiryDate") %></td>
                            <td style="font-weight: 700; color: #166534;"><%= currencyFormat.format(c.get("dailyLimit")) %></td>
                            <td>
                                <span class="badge" style="<%= isActive ? "background: #dcfce7; color: #166534;" : "background: #fee2e2; color: #991b1b;" %>">
                                    <%= st %>
                                </span>
                            </td>
                            <td>
                                <form action="${pageContext.request.contextPath}/bank-admin/cards" method="post" style="display: inline-block;">
                                    <input type="hidden" name="cardId" value="<%= cardId %>">
                                    <input type="hidden" name="action" value="toggle">
                                    <button type="submit" class="btn <%= isActive ? "btn-danger" : "btn-success" %>" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Toggle status of this card?');">
                                        <%= isActive ? "🔒 Block Card" : "🔓 Unblock Card" %>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 24px; color: #64748b;">
                                No cards registered in the system yet.
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
