<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?role=user");
        return;
    }

    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String userFullName = (firstName != null ? firstName : "Customer") + (lastName != null ? " " + lastName : "");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("userAccounts");

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
    <title>My Cards - E-Banking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .cards-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }
        .virtual-card {
            border-radius: 16px;
            padding: 24px;
            color: #ffffff;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 215px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .virtual-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 32px rgba(0, 0, 0, 0.22);
        }
        .card-debit {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #0369a1 100%);
        }
        .card-credit {
            background: linear-gradient(135deg, #312e81 0%, #581c87 50%, #831843 100%);
        }
        .card-blocked-overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.85);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 16px;
            z-index: 10;
        }
        .card-top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .chip-icon {
            width: 44px;
            height: 32px;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 50%, #94a3b8 100%);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            color: #334155;
            box-shadow: inset 0 0 4px rgba(0,0,0,0.2);
            border: 1px solid #e2e8f0;
        }
        .card-number-display {
            font-family: 'Courier New', Courier, monospace;
            font-size: 1.35rem;
            letter-spacing: 2.5px;
            font-weight: 700;
            margin: 20px 0;
            text-shadow: 0 2px 4px rgba(0,0,0,0.4);
        }
        .card-bottom-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }
        .card-meta-label {
            font-size: 0.65rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.75;
            display: block;
            margin-bottom: 2px;
        }
        .card-meta-value {
            font-size: 0.9rem;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .card-network-logo {
            font-size: 1.1rem;
            font-weight: 800;
            letter-spacing: 1px;
            font-style: italic;
        }
        .card-actions-wrapper {
            background: #ffffff;
            border: 1px solid var(--border);
            border-top: none;
            border-radius: 0 0 var(--radius) var(--radius);
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: -8px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
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
            <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Accounts</a>
            <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Transactions</a>
            <a href="${pageContext.request.contextPath}/user/cards" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Cards</a>
            <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Loans</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Feedback Alerts -->
    <% if ("applied_pending".equals(successParam)) { %>
        <div class="alert alert-warning" style="background: #fef3c7; color: #92400e; border: 1px solid #fde68a;">
            ⏳ Card application submitted! Your card request is pending verification and confirmation by <strong>Bank Administrators</strong>.
        </div>
    <% } else if ("applied".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ New card issued successfully! Your virtual card is activated and ready for use.
        </div>
    <% } else if ("status".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ Card status updated successfully.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger">
            ❌ Card operation failed: <%= errorParam %>
        </div>
    <% } %>

    <!-- Header Banner -->
    <div class="card" style="margin-bottom: 24px;">
        <div class="brand-header" style="text-align: left; margin-bottom: 0;">
            <h2 style="font-size: 1.5rem; margin-bottom: 4px;">🪪 Virtual Debit & Credit Cards</h2>
            <p style="color: var(--text-muted); font-size: 0.95rem;">
                Manage simulated payment cards linked directly to your holding bank accounts. Toggle instant security locks and view daily expenditure limits.
            </p>
        </div>
    </div>

    <!-- Cards Section -->
    <h3 style="margin-bottom: 14px; color: var(--text-main); font-weight: 700;">
        Active Cards (<%= cards != null ? cards.size() : 0 %>)
    </h3>

    <% if (cards == null || cards.isEmpty()) { %>
        <div class="card text-center" style="text-align: center; padding: 40px 20px; margin-bottom: 30px;">
            <div style="font-size: 3rem; margin-bottom: 10px;">🪪</div>
            <h3>No Cards Issued Yet</h3>
            <p style="color: var(--text-muted); max-width: 480px; margin: 8px auto 20px;">
                You don't have any debit or credit cards linked to your accounts. Apply below for instant virtual card issuance.
            </p>
        </div>
    <% } else { %>
        <div class="cards-container">
            <%
                for (Map<String, Object> card : cards) {
                    int cardId = (Integer) card.get("cardId");
                    String masked = (String) card.get("maskedNumber");
                    String type = (String) card.get("cardType");
                    String holder = (String) card.get("cardHolderName");
                    String exp = (String) card.get("expiryDate");
                    String status = (String) card.get("status");
                    String accNum = (String) card.get("accountNumber");
                    String bName = (String) card.get("bankName");
                    BigDecimal limit = (BigDecimal) card.get("dailyLimit");
                    boolean isPending = "PENDING".equalsIgnoreCase(status);
                    boolean isBlocked = "BLOCKED".equalsIgnoreCase(status);
                    boolean isCredit = "CREDIT".equalsIgnoreCase(type);
            %>
            <div>
                <!-- Simulated Physical Card Widget -->
                <div class="virtual-card <%= isCredit ? "card-credit" : "card-debit" %>">
                    <% if (isPending) { %>
                        <div class="card-blocked-overlay" style="background: rgba(15, 23, 42, 0.88);">
                            <span style="font-size: 2.2rem; margin-bottom: 4px;">⏳</span>
                            <strong style="color: #fde047; letter-spacing: 1px;">PENDING CONFIRMATION</strong>
                            <small style="opacity: 0.85;">Awaiting Bank Admin Approval</small>
                        </div>
                    <% } else if (isBlocked) { %>
                        <div class="card-blocked-overlay">
                            <span style="font-size: 2.2rem; margin-bottom: 4px;">🔒</span>
                            <strong style="color: #f87171; letter-spacing: 1px;">CARD BLOCKED</strong>
                            <small style="opacity: 0.85;">Temporarily locked for security</small>
                        </div>
                    <% } %>

                    <div class="card-top-row">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div class="chip-icon">⚡</div>
                            <span style="font-size: 1.1rem; opacity: 0.85;">📡</span>
                        </div>
                        <div style="text-align: right;">
                            <span style="font-size: 0.8rem; font-weight: 700; letter-spacing: 0.5px; opacity: 0.95;">
                                🏛️ <%= bName != null ? bName : "Partner Bank" %>
                            </span><br>
                            <span class="badge" style="background: rgba(255,255,255,0.2); color: #fff; font-size: 0.7rem; padding: 2px 6px;">
                                <%= type %> CARD
                            </span>
                        </div>
                    </div>

                    <div class="card-number-display">
                        <%= masked %>
                    </div>

                    <div class="card-bottom-row">
                        <div>
                            <span class="card-meta-label">Card Holder</span>
                            <span class="card-meta-value"><%= holder %></span>
                        </div>
                        <div>
                            <span class="card-meta-label">Expires</span>
                            <span class="card-meta-value"><%= exp %></span>
                        </div>
                        <div class="card-network-logo">
                            <%= isCredit ? "Mastercard" : "VISA" %>
                        </div>
                    </div>
                </div>

                <!-- Card Meta Bar & Toggle Actions -->
                <div class="card-actions-wrapper">
                    <div style="font-size: 0.82rem; color: var(--text-muted);">
                        <span>Linked Account: <strong>#<%= accNum %></strong></span><br>
                        <span>Daily Limit: <strong><%= currencyFormat.format(limit != null ? limit : BigDecimal.ZERO) %></strong></span>
                    </div>

                    <% if (isPending) { %>
                        <span class="badge" style="background: #fef3c7; color: #92400e; padding: 6px 12px; font-weight: 700; border-radius: 6px;">
                            ⏳ Pending Bank Admin Confirmation
                        </span>
                    <% } else { %>
                        <form action="${pageContext.request.contextPath}/card" method="post" style="margin: 0;">
                            <input type="hidden" name="action" value="toggle_status">
                            <input type="hidden" name="cardId" value="<%= cardId %>">
                            <input type="hidden" name="currentStatus" value="<%= status %>">
                            <% if (isBlocked) { %>
                                <button type="submit" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.8rem; color: #16a34a; border-color: #86efac;">
                                    🔓 Unblock Card
                                </button>
                            <% } else { %>
                                <button type="submit" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.8rem; color: #dc2626; border-color: #fca5a5;" onclick="return confirm('Lock and block this card?');">
                                    🔒 Block Card
                                </button>
                            <% } %>
                        </form>
                    <% } %>
                </div>
            </div>
            <%
                }
            %>
        </div>
    <% } %>

    <!-- Apply for New Card Form Card -->
    <div class="card" style="margin-bottom: 40px;">
        <h3 style="font-size: 1.2rem; color: var(--text-main); margin-bottom: 6px;">
            ➕ Apply for a New Card
        </h3>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 20px;">
            Select an active bank account to link your new virtual Debit or Credit card.
        </p>

        <form action="${pageContext.request.contextPath}/card" method="post">
            <input type="hidden" name="action" value="apply">

            <div class="form-row">
                <div class="form-group">
                    <label for="accountId">Select Linked Account *</label>
                    <select id="accountId" name="accountId" required>
                    <%
                        if (accounts != null && !accounts.isEmpty()) {
                            for (Map<String, Object> a : accounts) {
                    %>
                        <option value="<%= a.get("accountId") %>">
                            #<%= a.get("accountNumber") %> (<%= a.get("bankName") %> - <%= a.get("accountType") %>)
                        </option>
                    <%
                            }
                        } else {
                    %>
                        <option value="">No active accounts available</option>
                    <%
                        }
                    %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="cardType">Card Category *</label>
                    <select id="cardType" name="cardType" required>
                        <option value="DEBIT" selected>Debit Card (Visa - ₹50,000 Daily Limit)</option>
                        <option value="CREDIT">Credit Card (Mastercard - ₹100,000 Daily Limit)</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="cardHolderName">Name on Card (Optional, defaults to your name)</label>
                <input type="text" id="cardHolderName" name="cardHolderName" placeholder="e.g. <%= userFullName.toUpperCase() %>">
            </div>

            <button type="submit" class="btn btn-primary" style="max-width: 240px; margin-top: 8px;">
                Issue Virtual Card &rarr;
            </button>
        </form>
    </div>
</div>

</body>
</html>
