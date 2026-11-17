<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List, java.util.Map, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
        <% Integer adminId=(Integer) session.getAttribute("adminId"); if (adminId==null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?role=admin" ); return; } String
            adminName=(String) session.getAttribute("adminName"); String adminUsername=(String)
            session.getAttribute("adminUsername"); Integer totalCustomers=(Integer)
            request.getAttribute("totalCustomers"); if (totalCustomers==null) totalCustomers=0; Integer
            totalAccounts=(Integer) request.getAttribute("totalAccounts"); if (totalAccounts==null) totalAccounts=0;
            Integer totalBanks=(Integer) request.getAttribute("totalBanks"); if (totalBanks==null) totalBanks=0;
            Integer totalTransactions=(Integer) request.getAttribute("totalTransactions"); if (totalTransactions==null) totalTransactions=0;
            BigDecimal totalCommissions=(BigDecimal) request.getAttribute("totalCommissions"); if (totalCommissions==null) totalCommissions=BigDecimal.ZERO;
            BigDecimal totalDeposits=(BigDecimal) request.getAttribute("totalDeposits"); if (totalDeposits==null)
            totalDeposits=BigDecimal.ZERO; NumberFormat currencyFormat=NumberFormat.getCurrencyInstance(new
            Locale("en", "IN" )); @SuppressWarnings("unchecked") List<Map<String, Object>> customers = (List<Map<String,
                Object>>) request.getAttribute("customers");

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> accounts = (List<Map<String, Object>>) request.getAttribute("accounts");

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> transactions = (List<Map<String, Object>>) request.getAttribute("transactions");

                Integer totalCards=(Integer) request.getAttribute("totalCards"); if (totalCards==null) totalCards=0;
                Integer blockedCards=(Integer) request.getAttribute("blockedCards"); if (blockedCards==null) blockedCards=0;

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> cards = (List<Map<String, Object>>) request.getAttribute("cards");
                        %>
                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Admin Dashboard - E-Banking</title>
                            <link rel="stylesheet" href="../css/style.css">
                            <style>
                                html {
                                    scroll-behavior: smooth;
                                }

                                .stats-grid {
                                    display: grid;
                                    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
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
                                    transition: transform 0.2s, box-shadow 0.2s;
                                }

                                .stat-card:hover {
                                    transform: translateY(-2px);
                                    box-shadow: var(--shadow-lg);
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

                                .section-header h3 {
                                    font-size: 1.25rem;
                                    color: var(--text-main);
                                    font-weight: 700;
                                }

                                .badge-status {
                                    padding: 4px 8px;
                                    border-radius: 4px;
                                    font-size: 0.75rem;
                                    font-weight: 700;
                                }

                                .badge-active {
                                    background-color: var(--success-bg);
                                    color: var(--success);
                                }

                                .badge-type {
                                    background-color: var(--primary-light);
                                    color: var(--primary);
                                    padding: 3px 8px;
                                    border-radius: 4px;
                                    font-size: 0.8rem;
                                    font-weight: 600;
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

                                .module-tag {
                                    display: inline-block;
                                    font-size: 0.75rem;
                                    font-weight: 700;
                                    padding: 2px 8px;
                                    border-radius: 4px;
                                    margin-top: 10px;
                                }

                                .module-tag-live {
                                    background: #dcfce7;
                                    color: #166534;
                                }

                                .module-tag-ready {
                                    background: #eff6ff;
                                    color: #1e40af;
                                }

                                .module-tag-pending {
                                    background: #fef3c7;
                                    color: #92400e;
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
                                        <span>Welcome, <strong>
                                                <%= adminName !=null ? adminName : adminUsername %>
                                            </strong></span>
                                        <a href="${pageContext.request.contextPath}/admin/dashboard"
                                            class="btn btn-primary"
                                            style="padding: 6px 14px; font-size: 0.85rem;">Dashboard</a>
                                        <a href="${pageContext.request.contextPath}/admin/banks"
                                            class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">🏛️
                                            Partner Banks</a>
                                        <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-secondary"
                                            style="padding: 6px 14px; font-size: 0.85rem;">🏠 Home</a>
                                        <a href="${pageContext.request.contextPath}/admin/logout"
                                            class="btn btn-secondary"
                                            style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
                                    </div>
                                </div>

                                <!-- Admin Welcome Header Card -->
                                <div class="card" style="margin-bottom: 24px;">
                                    <div
                                        style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                                        <div>
                                            <h3 style="font-size: 1.4rem; color: var(--text-main); margin-bottom: 4px;">
                                                Hello, <%= adminName !=null ? adminName : "System Administrator" %>! 👋
                                            </h3>
                                            <p style="color: var(--text-muted); font-size: 0.92rem;">
                                                Platform Governance Authority. Monitor partner banks, customer accounts,
                                                transactions, cards, loans, and platform commissions.
                                            </p>
                                        </div>
                                        <div>
                                            <span class="badge"
                                                style="background: #fef2f2; color: #991b1b; font-weight: 700; padding: 6px 14px; border-radius: 9999px; border: 1px solid #fecaca; font-size: 0.85rem;">
                                                🛡️ Central Platform Authority
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Stats Grid -->
                                <div class="stats-grid">
                                    <div class="stat-card" style="cursor: pointer;"
                                        onclick="document.getElementById('customers').scrollIntoView({behavior: 'smooth'})">
                                        <div class="stat-icon" style="background-color: #eff6ff; color: #1d4ed8;">👥
                                        </div>
                                        <div class="stat-info">
                                            <h4>Total Customers</h4>
                                            <div class="stat-value">
                                                <%= totalCustomers %>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="stat-card" style="cursor: pointer;"
                                        onclick="document.getElementById('accounts').scrollIntoView({behavior: 'smooth'})">
                                        <div class="stat-icon" style="background-color: #f0fdf4; color: #15803d;">🏦
                                        </div>
                                        <div class="stat-info">
                                            <h4>Total Bank Accounts</h4>
                                            <div class="stat-value">
                                                <%= totalAccounts %>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="stat-card" style="cursor: pointer;"
                                        onclick="location.href='${pageContext.request.contextPath}/admin/banks'">
                                        <div class="stat-icon" style="background-color: #f5f3ff; color: #7c3aed;">🏛️
                                        </div>
                                        <div class="stat-info">
                                            <h4>Partner Banks</h4>
                                            <div class="stat-value" style="color: #7c3aed;">
                                                <%= totalBanks %>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="stat-card">
                                        <div class="stat-icon" style="background-color: #fefce8; color: #a16207;">💰
                                        </div>
                                        <div class="stat-info">
                                            <h4>Total Deposits Managed</h4>
                                            <div class="stat-value" style="color: var(--success);">
                                                <%= currencyFormat.format(totalDeposits) %>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Platform Administration Modules (Full Grid like User Panel) -->
                                <h3 style="margin-bottom: 14px; color: var(--text-main); font-weight: 700;">Platform
                                    Administration Modules</h3>

                                <div class="dashboard-grid" style="margin-bottom: 32px;">
                                    <!-- 1. Partner Banks -->
                                    <a href="${pageContext.request.contextPath}/admin/banks" class="dashboard-card">
                                        <div class="card-icon">🏛️</div>
                                        <h3>Partner Banks</h3>
                                        <p>Onboard banks (SBI, HDFC, ICICI), configure commission %, and regulate
                                            institutional status</p>
                                        <span class="module-tag module-tag-live">Active • <%= totalBanks %> Partner
                                                Banks</span>
                                    </a>

                                    <!-- 2. Customer Management -->
                                    <a href="#customers" class="dashboard-card">
                                        <div class="card-icon">👥</div>
                                        <h3>Customer Management</h3>
                                        <p>Review customer KYC profiles, email/phone contact records, and regulate
                                            account access</p>
                                        <span class="module-tag module-tag-live">Active • <%= totalCustomers %>
                                                Registered Customers</span>
                                    </a>

                                    <!-- 3. Bank Accounts -->
                                    <a href="#accounts" class="dashboard-card">
                                        <div class="card-icon">🏦</div>
                                        <h3>Bank Accounts</h3>
                                        <p>System-wide view of Savings and Current accounts, monitor holding bank
                                            balances and IFSC codes</p>
                                        <span class="module-tag module-tag-live">Active • <%= totalAccounts %> Live
                                                Accounts</span>
                                    </a>

                                    <!-- 4. Transactions Ledger -->
                                    <a href="#transactions" class="dashboard-card">
                                        <div class="card-icon">💳</div>
                                        <h3>Transactions & Transfers</h3>
                                        <p>Audit cash deposits, withdrawals, and inter-bank customer fund transfers with
                                            reference IDs</p>
                                        <span class="module-tag module-tag-ready">Financial Ledger Ready</span>
                                    </a>

                                    <!-- 5. Commission Engine -->
                                    <a href="${pageContext.request.contextPath}/admin/banks" class="dashboard-card">
                                        <div class="card-icon">💰</div>
                                        <h3>Commission Engine</h3>
                                        <p>Configure per-bank transaction fee rates (0.50% - 1.00%) and monitor platform
                                            revenue cuts</p>
                                        <span class="module-tag module-tag-live">Configured per Bank</span>
                                    </a>

                                    <!-- 6. Loan Applications -->
                                    <a href="#loans" class="dashboard-card">
                                        <div class="card-icon">📜</div>
                                        <h3>Loans Management</h3>
                                        <p>Review customer loan applications, evaluate interest rates/tenures, and
                                            approve or reject disbursals</p>
                                        <span class="module-tag module-tag-pending">Application Review Desk</span>
                                    </a>

                                    <!-- 7. Cards Management -->
                                    <a href="#cards" class="dashboard-card">
                                        <div class="card-icon">🪪</div>
                                        <h3>Cards Management</h3>
                                        <p>Monitor customer Debit & Credit cards, view masked card numbers, and execute
                                            security block/unblock</p>
                                        <span class="module-tag module-tag-pending">Card Issuance & Security</span>
                                    </a>

                                    <!-- 8. Platform Reports & Audit -->
                                    <a href="#reports" class="dashboard-card">
                                        <div class="card-icon">📊</div>
                                        <h3>Reports & System Audit</h3>
                                        <p>Generate financial statements, view bank performance breakdowns, and review
                                            operational audit trail</p>
                                        <span class="module-tag module-tag-ready">System Compliance & Audit</span>
                                    </a>
                                </div>

                                <!-- 1. Customer Management Table -->
                                <div class="card" id="customers" style="margin-bottom: 28px;">
                                    <div class="section-header" style="margin-top: 0;">
                                        <h3>👥 Registered Customers (<%= customers !=null ? customers.size() : 0 %>)
                                        </h3>
                                        <span style="font-size: 0.85rem; color: var(--text-muted);">Real-time database
                                            records</span>
                                    </div>

                                    <div class="table-responsive">
                                        <table class="data-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 8%;">User ID</th>
                                                    <th style="width: 20%;">Full Name</th>
                                                    <th style="width: 24%;">Email Address</th>
                                                    <th style="width: 16%;">Phone Number</th>
                                                    <th style="width: 14%;">City, State</th>
                                                    <th style="width: 8%;">Status</th>
                                                    <th style="width: 10%;">Registered</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% if (customers !=null && !customers.isEmpty()) { for (Map<String,
                                                    Object> c : customers) {
                                                    String name = c.get("firstName") + " " + c.get("lastName");
                                                    String loc = (c.get("city") != null ? c.get("city") : "") +
                                                    (c.get("state") != null ? ", " + c.get("state") : "");
                                                    if (loc.trim().isEmpty() || loc.trim().equals(",")) loc = "-";
                                                    String regDate = c.get("createdAt") != null ?
                                                    c.get("createdAt").toString().substring(0, 10) : "-";
                                                    %>
                                                    <tr>
                                                        <td><strong>#<%= c.get("userId") %></strong></td>
                                                        <td><strong>
                                                                <%= name %>
                                                            </strong></td>
                                                        <td>
                                                            <%= c.get("email") %>
                                                        </td>
                                                        <td>
                                                            <%= c.get("phone") !=null ? c.get("phone") : "-" %>
                                                        </td>
                                                        <td>
                                                            <%= loc %>
                                                        </td>
                                                        <td><span class="badge-status badge-active">
                                                                <%= c.get("status") %>
                                                            </span></td>
                                                        <td style="font-size: 0.85rem; color: var(--text-muted);">
                                                            <%= regDate %>
                                                        </td>
                                                    </tr>
                                                    <% } } else { %>
                                                        <tr>
                                                            <td colspan="7"
                                                                style="text-align: center; padding: 24px; color: var(--text-muted);">
                                                                No customers registered yet.
                                                            </td>
                                                        </tr>
                                                        <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <!-- 2. Accounts Management Table -->
                                <div class="card" id="accounts" style="margin-bottom: 28px;">
                                    <div class="section-header" style="margin-top: 0;">
                                        <h3>🏦 Bank Accounts Across Partner Institutions (<%= accounts !=null ?
                                                accounts.size() : 0 %>)</h3>
                                        <span style="font-size: 0.85rem; color: var(--text-muted);">All active customer
                                            accounts</span>
                                    </div>

                                    <div class="table-responsive">
                                        <table class="data-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 8%;">Acc ID</th>
                                                    <th style="width: 20%;">Account Number & Bank</th>
                                                    <th style="width: 18%;">Account Holder</th>
                                                    <th style="width: 12%;">Account Type</th>
                                                    <th style="width: 16%;">Balance</th>
                                                    <th style="width: 16%;">IFSC / Branch</th>
                                                    <th style="width: 10%;">Status</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% if (accounts !=null && !accounts.isEmpty()) { for (Map<String,
                                                    Object> a : accounts) {
                                                    BigDecimal bal = (BigDecimal) a.get("balance");
                                                    if (bal == null) bal = BigDecimal.ZERO;
                                                    %>
                                                    <tr>
                                                        <td><strong>#<%= a.get("accountId") %></strong></td>
                                                        <td>
                                                            <strong
                                                                style="letter-spacing: 0.5px; color: var(--primary);">
                                                                <%= a.get("accountNumber") %>
                                                            </strong><br>
                                                            <span class="badge-type"
                                                                style="font-size: 0.72rem; padding: 2px 6px;">
                                                                🏛️ <%= a.get("bankName") !=null ? a.get("bankName")
                                                                    : "Partner Bank" %>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <strong>
                                                                <%= a.get("customerName") %>
                                                            </strong><br>
                                                            <small style="color: var(--text-muted);">
                                                                <%= a.get("customerEmail") %>
                                                            </small>
                                                        </td>
                                                        <td><span class="badge-type">
                                                                <%= a.get("accountType") %>
                                                            </span></td>
                                                        <td>
                                                            <strong style="color: var(--success); font-size: 1.05rem;">
                                                                <%= currencyFormat.format(bal) %>
                                                            </strong>
                                                        </td>
                                                        <td>
                                                            <small><strong>
                                                                    <%= a.get("ifscCode") %>
                                                                </strong></small><br>
                                                            <small style="color: var(--text-muted);">
                                                                <%= a.get("branchName") %>
                                                            </small>
                                                        </td>
                                                        <td><span class="badge-status badge-active">
                                                                <%= a.get("status") %>
                                                            </span></td>
                                                    </tr>
                                                    <% } } else { %>
                                                        <tr>
                                                            <td colspan="7"
                                                                style="text-align: center; padding: 24px; color: var(--text-muted);">
                                                                No bank accounts created yet.
                                                            </td>
                                                        </tr>
                                                        <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <!-- 3. Transactions & Ledger Section -->
    <div class="card" id="transactions" style="margin-bottom: 28px;">
        <div class="section-header" style="margin-top: 0;">
            <h3>💳 Platform Transactions & Fund Transfers (<%= transactions != null ? transactions.size() : 0 %>)</h3>
            <span class="badge" style="background: #f0fdf4; color: #166534; font-weight: 700; padding: 4px 10px; border-radius: 9999px;">
                💰 Platform Commissions: <%= currencyFormat.format(totalCommissions) %>
            </span>
        </div>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 16px;">
            Live audit ledger of customer deposits, withdrawals, and inter-bank transfers along with platform commission fees.
        </p>

        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 15%;">Date & Time</th>
                        <th style="width: 18%;">Reference ID</th>
                        <th style="width: 12%;">Type</th>
                        <th style="width: 25%;">Transaction Flow</th>
                        <th style="width: 16%;">Amount</th>
                        <th style="width: 14%;">Platform Cut</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (transactions != null && !transactions.isEmpty()) {
                        for (Map<String, Object> t : transactions) {
                            String ref = (String) t.get("referenceNumber");
                            BigDecimal amt = (BigDecimal) t.get("amount");
                            String type = (String) t.get("transactionType");
                            Object dateObj = t.get("createdAt");
                            String dateStr = dateObj != null ? dateObj.toString().substring(0, 19) : "-";
                            String fromAcc = (String) t.get("fromAccountNumber");
                            String toAcc = (String) t.get("toAccountNumber");
                            String fromBank = (String) t.get("fromBankName");
                            String toBank = (String) t.get("toBankName");
                            BigDecimal commAmt = (BigDecimal) t.get("commissionAmount");
                %>
                    <tr>
                        <td style="font-size: 0.85rem; color: var(--text-muted);"><%= dateStr %></td>
                        <td><code><%= ref %></code></td>
                        <td><span class="badge badge-type"><%= type %></span></td>
                        <td>
                            <% if ("TRANSFER".equalsIgnoreCase(type)) { %>
                                <small>#<%= fromAcc %> (<%= fromBank %>) &rarr; #<%= toAcc %> (<%= toBank %>)</small>
                            <% } else if ("DEPOSIT".equalsIgnoreCase(type)) { %>
                                <small>Cash in to #<%= toAcc %></small>
                            <% } else { %>
                                <small>Withdrawal from #<%= fromAcc %></small>
                            <% } %>
                        </td>
                        <td><strong style="color: var(--text-main);"><%= currencyFormat.format(amt != null ? amt : BigDecimal.ZERO) %></strong></td>
                        <td>
                            <% if (commAmt != null && commAmt.compareTo(BigDecimal.ZERO) > 0) { %>
                                <span style="color: #166534; font-weight: 700;">+<%= currencyFormat.format(commAmt) %></span>
                            <% } else { %>
                                <span style="color: var(--text-muted);">-</span>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 24px; color: var(--text-muted);">
                            No transactions executed yet. Customer deposits, withdrawals, and transfers will appear here in real time.
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 4. Loans, Cards & Reports Overview Grid -->
                                <div
                                    style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; margin-bottom: 40px;">
                                    <!-- Loans Panel -->
                                    <div class="card" id="loans">
                                        <div class="section-header" style="margin-top: 0;">
                                            <h3 style="font-size: 1.1rem;">📜 Loan Applications</h3>
                                            <span class="module-tag module-tag-pending">Review Desk</span>
                                        </div>
                                        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 14px;">
                                            Partner bank loan products (Personal, Home, Education) with tenure-based EMI
                                            calculation and admin approval workflow.
                                        </p>
                                        <div
                                            style="background: #f8fafc; padding: 14px; border-radius: 6px; font-size: 0.85rem; border: 1px solid var(--border);">
                                            <strong>Pending Applications:</strong> 0 | <strong>Active
                                                Disbursed:</strong> 0
                                        </div>
                                    </div>

                                    <!-- Cards Panel -->
        <div class="card" id="cards">
            <div class="section-header" style="margin-top: 0;">
                <h3 style="font-size: 1.15rem;">🪪 Cards Management (<%= totalCards %>)</h3>
                <span class="badge" style="background: #eff6ff; color: #1e40af; font-size: 0.8rem; padding: 4px 10px; border-radius: 9999px;">
                    Active: <%= totalCards - blockedCards %> | Blocked: <%= blockedCards %>
                </span>
            </div>
            <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 14px;">
                Platform-wide customer Debit & Credit cards with masked representations and status monitoring.
            </p>

            <div class="table-responsive">
                <table class="data-table" style="font-size: 0.85rem;">
                    <thead>
                        <tr>
                            <th>Cardholder & Account</th>
                            <th>Holding Bank</th>
                            <th>Masked Number</th>
                            <th>Type</th>
                            <th>Expires</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (cards != null && !cards.isEmpty()) {
                            for (Map<String, Object> card : cards) {
                                String maskedNum = (String) card.get("maskedNumber");
                                String cType = (String) card.get("cardType");
                                String cHolder = (String) card.get("cardHolderName");
                                String cExp = (String) card.get("expiryDate");
                                String cStatus = (String) card.get("status");
                                String cAcc = (String) card.get("accountNumber");
                                String cBank = (String) card.get("bankName");
                                boolean isCBlocked = "BLOCKED".equalsIgnoreCase(cStatus);
                    %>
                        <tr>
                            <td>
                                <strong><%= cHolder %></strong><br>
                                <small style="color: var(--text-muted);">Acc #<%= cAcc %></small>
                            </td>
                            <td><small>🏛️ <%= cBank %></small></td>
                            <td><code><%= maskedNum %></code></td>
                            <td><span class="badge badge-type" style="font-size: 0.72rem;"><%= cType %></span></td>
                            <td><%= cExp %></td>
                            <td>
                                <span class="badge <%= isCBlocked ? "badge-inactive" : "badge-active" %>" style="font-size: 0.72rem;">
                                    <%= cStatus %>
                                </span>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 16px; color: var(--text-muted);">
                                No cards issued yet.
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Reports Panel -->
                                    <div class="card" id="reports">
                                        <div class="section-header" style="margin-top: 0;">
                                            <h3 style="font-size: 1.1rem;">📊 Reports & Audit</h3>
                                            <span class="module-tag module-tag-ready">System Audit</span>
                                        </div>
                                        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 14px;">
                                            Platform compliance audit logs, institutional commission reports, and
                                            system-wide deposit tracking.
                                        </p>
                                        <div
                                            style="background: #f8fafc; padding: 14px; border-radius: 6px; font-size: 0.85rem; border: 1px solid var(--border);">
                                            <strong>Audited Institutions:</strong>
                                            <%= totalBanks %> | <strong>System Status:</strong> HEALTHY
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </body>

                        </html>