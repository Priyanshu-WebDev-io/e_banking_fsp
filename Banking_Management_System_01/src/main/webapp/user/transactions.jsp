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
    List<Map<String, Object>> transactions = (List<Map<String, Object>>) request.getAttribute("transactions");

    String filterAccount = (String) request.getAttribute("filterAccount");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    String refParam = request.getParameter("ref");
    String amtParam = request.getParameter("amt");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transactions & Transfers - E-Banking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .txn-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(310px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .txn-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 22px;
            box-shadow: var(--shadow);
        }
        .txn-card h3 {
            font-size: 1.15rem;
            color: var(--text-main);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .txn-card p {
            color: var(--text-muted);
            font-size: 0.85rem;
            margin-bottom: 16px;
        }
        .amount-credit {
            color: #16a34a;
            font-weight: 700;
        }
        .amount-debit {
            color: #dc2626;
            font-weight: 700;
        }
        .badge-deposit {
            background-color: #dcfce7;
            color: #15803d;
        }
        .badge-withdrawal {
            background-color: #fee2e2;
            color: #b91c1c;
        }
        .badge-transfer {
            background-color: #eff6ff;
            color: #1d4ed8;
        }
        .filter-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 16px;
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
            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">My Accounts</a>
            <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Transactions</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Feedback Alerts -->
    <% if ("deposit".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ Cash deposit successful! Reference: <code><%= refParam != null ? refParam : "" %></code>. Amount: ₹<%= amtParam != null ? amtParam : "" %>.
        </div>
    <% } else if ("withdraw".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ Cash withdrawal successful! Reference: <code><%= refParam != null ? refParam : "" %></code>. Amount: ₹<%= amtParam != null ? amtParam : "" %>.
        </div>
    <% } else if ("transfer".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ Fund transfer processed successfully! Reference: <code><%= refParam != null ? refParam : "" %></code>. Amount: ₹<%= amtParam != null ? amtParam : "" %>.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger">
            ❌ Transaction failed: <%= errorParam %>
        </div>
    <% } %>

    <!-- Header Description Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div class="brand-header" style="text-align: left; margin-bottom: 0;">
            <h2 style="font-size: 1.5rem; margin-bottom: 4px;">💳 Financial Operations & Passbook</h2>
            <p style="color: var(--text-muted); font-size: 0.95rem;">
                Perform deposits, cash withdrawals, and transfer money between accounts with atomic double-entry security.
            </p>
        </div>
    </div>

    <!-- Quick Operations Forms Grid -->
    <div class="txn-actions-grid">
        <!-- 1. Quick Deposit -->
        <div class="txn-card">
            <h3><span>📥</span> Deposit Funds</h3>
            <p>Add cash funds directly into any of your active bank accounts.</p>

            <form action="${pageContext.request.contextPath}/transaction" method="post">
                <input type="hidden" name="action" value="deposit">

                <div class="form-group">
                    <label for="depAccount">Deposit To Account *</label>
                    <select id="depAccount" name="accountId" required>
                    <%
                        if (accounts != null && !accounts.isEmpty()) {
                            for (Map<String, Object> a : accounts) {
                                BigDecimal bal = (BigDecimal) a.get("balance");
                    %>
                        <option value="<%= a.get("accountId") %>">
                            #<%= a.get("accountNumber") %> (<%= a.get("bankName") %> - Bal: <%= currencyFormat.format(bal != null ? bal : BigDecimal.ZERO) %>)
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
                    <label for="depAmount">Deposit Amount (₹) *</label>
                    <input type="number" id="depAmount" name="amount" min="100" step="50" placeholder="e.g. 5000" required>
                </div>

                <div class="form-group">
                    <label for="depDesc">Remark / Description</label>
                    <input type="text" id="depDesc" name="description" placeholder="e.g. Salary deposit / Cash in">
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 6px;">
                    Deposit Funds
                </button>
            </form>
        </div>

        <!-- 2. Quick Withdrawal -->
        <div class="txn-card">
            <h3><span>📤</span> Withdraw Cash</h3>
            <p>Withdraw cash from your bank account with live balance verification.</p>

            <form action="${pageContext.request.contextPath}/transaction" method="post">
                <input type="hidden" name="action" value="withdraw">

                <div class="form-group">
                    <label for="wthAccount">Withdraw From Account *</label>
                    <select id="wthAccount" name="accountId" required>
                    <%
                        if (accounts != null && !accounts.isEmpty()) {
                            for (Map<String, Object> a : accounts) {
                                BigDecimal bal = (BigDecimal) a.get("balance");
                    %>
                        <option value="<%= a.get("accountId") %>">
                            #<%= a.get("accountNumber") %> (<%= a.get("bankName") %> - Bal: <%= currencyFormat.format(bal != null ? bal : BigDecimal.ZERO) %>)
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
                    <label for="wthAmount">Withdrawal Amount (₹) *</label>
                    <input type="number" id="wthAmount" name="amount" min="100" step="50" placeholder="e.g. 2000" required>
                </div>

                <div class="form-group">
                    <label for="wthDesc">Remark / Description</label>
                    <input type="text" id="wthDesc" name="description" placeholder="e.g. ATM withdrawal / Petty cash">
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 6px; background-color: #d97706; border-color: #d97706;">
                    Withdraw Funds
                </button>
            </form>
        </div>

        <!-- 3. Fund Transfer -->
        <div class="txn-card">
            <h3><span>🔄</span> Transfer Money</h3>
            <p>Send money to any customer by entering their 12-digit account number.</p>

            <form action="${pageContext.request.contextPath}/transaction" method="post">
                <input type="hidden" name="action" value="transfer">

                <div class="form-group">
                    <label for="fromAccount">From Account *</label>
                    <select id="fromAccount" name="fromAccountId" required>
                    <%
                        if (accounts != null && !accounts.isEmpty()) {
                            for (Map<String, Object> a : accounts) {
                                BigDecimal bal = (BigDecimal) a.get("balance");
                    %>
                        <option value="<%= a.get("accountId") %>">
                            #<%= a.get("accountNumber") %> (<%= a.get("bankName") %> - Bal: <%= currencyFormat.format(bal != null ? bal : BigDecimal.ZERO) %>)
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
                    <label for="toAccount">Beneficiary Account Number *</label>
                    <input type="text" id="toAccount" name="toAccountNumber" placeholder="12-digit recipient account #" maxlength="20" required>
                </div>

                <div class="form-group">
                    <label for="trfAmount">Transfer Amount (₹) *</label>
                    <input type="number" id="trfAmount" name="amount" min="1" step="10" placeholder="e.g. 3500" required>
                </div>

                <div class="form-group">
                    <label for="trfDesc">Transfer Purpose</label>
                    <input type="text" id="trfDesc" name="description" placeholder="e.g. Rent payment / Project fees">
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 6px;">
                    Send Money &rarr;
                </button>
            </form>
        </div>
    </div>

    <!-- Passbook / Statement Table -->
    <div class="card" style="padding: 0; overflow: hidden; margin-bottom: 40px;">
        <div style="padding: 20px 24px; border-bottom: 1px solid var(--border);" class="filter-bar">
            <div>
                <h3 style="font-size: 1.25rem; color: var(--text-main); margin-bottom: 2px;">📜 Passbook & Transaction Statement</h3>
                <span style="font-size: 0.85rem; color: var(--text-muted);">Real-time ledger entries for your bank accounts</span>
            </div>

            <form action="${pageContext.request.contextPath}/user/transactions" method="get" style="display: flex; gap: 8px; align-items: center; margin: 0;">
                <label for="accFilter" style="margin: 0; font-size: 0.85rem; font-weight: 600;">Filter:</label>
                <select name="accountNumber" id="accFilter" onchange="this.form.submit()" style="padding: 6px 10px; font-size: 0.85rem; width: auto;">
                    <option value="">All Accounts</option>
                    <%
                        if (accounts != null) {
                            for (Map<String, Object> a : accounts) {
                                String aNum = (String) a.get("accountNumber");
                                boolean isSel = aNum != null && aNum.equals(filterAccount);
                    %>
                        <option value="<%= aNum %>" <%= isSel ? "selected" : "" %>>
                            #<%= aNum %> (<%= a.get("bankName") %>)
                        </option>
                    <%
                            }
                        }
                    %>
                </select>
                <% if (filterAccount != null && !filterAccount.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-secondary" style="padding: 5px 10px; font-size: 0.8rem;">Clear</a>
                <% } %>
            </form>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="margin: 0;">
                <thead>
                    <tr>
                        <th style="width: 15%;">Date & Time</th>
                        <th style="width: 18%;">Reference ID</th>
                        <th style="width: 12%;">Type</th>
                        <th style="width: 25%;">Transaction Details</th>
                        <th style="width: 18%;">Amount (₹)</th>
                        <th style="width: 12%;">Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (transactions == null || transactions.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
                            <div style="font-size: 2.5rem; margin-bottom: 8px;">💳</div>
                            <strong>No transactions recorded yet.</strong><br>
                            Make your first deposit or fund transfer using the forms above.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Map<String, Object> t : transactions) {
                            String ref = (String) t.get("referenceNumber");
                            BigDecimal amt = (BigDecimal) t.get("amount");
                            String type = (String) t.get("transactionType");
                            String status = (String) t.get("status");
                            String desc = (String) t.get("description");
                            Object dateObj = t.get("createdAt");
                            String dateStr = dateObj != null ? dateObj.toString().substring(0, 19) : "-";
                            boolean isDebit = Boolean.TRUE.equals(t.get("isDebit"));

                            String fromAcc = (String) t.get("fromAccountNumber");
                            String toAcc = (String) t.get("toAccountNumber");
                            String fromBank = (String) t.get("fromBankName");
                            String toBank = (String) t.get("toBankName");

                            String typeBadgeClass = "badge-transfer";
                            if ("DEPOSIT".equalsIgnoreCase(type)) {
                                typeBadgeClass = "badge-deposit";
                            } else if ("WITHDRAWAL".equalsIgnoreCase(type)) {
                                typeBadgeClass = "badge-withdrawal";
                            }
                %>
                    <tr>
                        <td style="font-size: 0.85rem; color: var(--text-muted);"><%= dateStr %></td>
                        <td><code><%= ref %></code></td>
                        <td>
                            <span class="badge <%= typeBadgeClass %>">
                                <%= type %>
                            </span>
                        </td>
                        <td>
                            <strong><%= desc != null ? desc : "-" %></strong><br>
                            <small style="color: var(--text-muted); font-size: 0.8rem;">
                                <% if ("TRANSFER".equalsIgnoreCase(type)) { %>
                                    From #<%= fromAcc %> (<%= fromBank %>) &rarr; To #<%= toAcc %> (<%= toBank %>)
                                <% } else if ("DEPOSIT".equalsIgnoreCase(type)) { %>
                                    Credited into #<%= toAcc != null ? toAcc : fromAcc %>
                                <% } else if ("WITHDRAWAL".equalsIgnoreCase(type)) { %>
                                    Debited from #<%= fromAcc %>
                                <% } %>
                            </small>
                        </td>
                        <td>
                            <span class="<%= isDebit ? "amount-debit" : "amount-credit" %>" style="font-size: 1.05rem;">
                                <%= isDebit ? "- " : "+ " %><%= currencyFormat.format(amt != null ? amt : BigDecimal.ZERO) %>
                            </span>
                        </td>
                        <td>
                            <span class="badge badge-active">
                                <%= status %>
                            </span>
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
