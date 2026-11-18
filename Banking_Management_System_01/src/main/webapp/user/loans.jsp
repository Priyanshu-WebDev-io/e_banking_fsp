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
    List<Map<String, Object>> loanProducts = (List<Map<String, Object>>) request.getAttribute("loanProducts");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> loans = (List<Map<String, Object>>) request.getAttribute("loans");

    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    String refParam = request.getParameter("ref");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loans & EMI Calculator - E-Banking</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }
        .product-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            border-top: 4px solid var(--primary);
        }
        .product-card h4 {
            font-size: 1.1rem;
            color: var(--text-main);
            margin-bottom: 4px;
        }
        .product-rate {
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--primary);
            margin: 10px 0;
        }
        .calc-preview-box {
            background: #f8fafc;
            border: 1px dashed var(--border);
            border-radius: 8px;
            padding: 16px;
            margin-top: 16px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px;
            text-align: center;
        }
        .calc-metric-label {
            font-size: 0.75rem;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 600;
        }
        .calc-metric-val {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--text-main);
            margin-top: 2px;
        }
        .badge-pending {
            background: #fef3c7;
            color: #92400e;
        }
        .badge-disbursed {
            background: #dcfce7;
            color: #166534;
        }
        .badge-rejected {
            background: #fee2e2;
            color: #991b1b;
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
            <a href="${pageContext.request.contextPath}/account/list" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Accounts</a>
            <a href="${pageContext.request.contextPath}/user/transactions" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Transactions</a>
            <a href="${pageContext.request.contextPath}/user/cards" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">My Cards</a>
            <a href="${pageContext.request.contextPath}/user/loans" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Loans</a>
            <a href="${pageContext.request.contextPath}/user/logout" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.85rem;">Logout</a>
        </div>
    </div>

    <!-- Feedback Alerts -->
    <% if ("applied".equals(successParam)) { %>
        <div class="alert alert-success">
            ✅ Loan application submitted successfully! Reference Number: <code><%= refParam != null ? refParam : "" %></code>. The Bank Administrator will review and disburse your funds.
        </div>
    <% } else if (errorParam != null) { %>
        <div class="alert alert-danger">
            ❌ Application error: <%= errorParam %>
        </div>
    <% } %>

    <!-- Banner -->
    <div class="card" style="margin-bottom: 24px;">
        <div class="brand-header" style="text-align: left; margin-bottom: 0;">
            <h2 style="font-size: 1.5rem; margin-bottom: 4px;">📜 Loan Products & Instant EMI Calculator</h2>
            <p style="color: var(--text-muted); font-size: 0.95rem;">
                Explore loan offerings from partner banks, compute monthly repayment installments, and apply for instant direct disbursal.
            </p>
        </div>
    </div>

    <!-- Loan Products Shelf -->
    <h3 style="margin-bottom: 14px; color: var(--text-main); font-weight: 700;">Featured Partner Bank Loan Products</h3>
    <div class="products-grid">
        <%
            if (loanProducts != null) {
                for (Map<String, Object> prod : loanProducts) {
                    BigDecimal rate = (BigDecimal) prod.get("interestRate");
                    BigDecimal minAmt = (BigDecimal) prod.get("minAmount");
                    BigDecimal maxAmt = (BigDecimal) prod.get("maxAmount");
                    int minT = (Integer) prod.get("minTenureMonths");
                    int maxT = (Integer) prod.get("maxTenureMonths");
        %>
            <div class="product-card">
                <div>
                    <h4><%= prod.get("productName") %></h4>
                    <span class="badge badge-type" style="font-size: 0.72rem;"><%= prod.get("loanType") %> LOAN</span>
                    <div class="product-rate"><%= rate %>% <small style="font-size: 0.8rem; font-weight: 500; color: var(--text-muted);">p.a.</small></div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">
                        Amount: <strong><%= currencyFormat.format(minAmt) %></strong> to <strong><%= currencyFormat.format(maxAmt) %></strong><br>
                        Tenure: <strong><%= minT %></strong> to <strong><%= maxT %></strong> months
                    </div>
                </div>
                <button type="button" class="btn btn-secondary" style="margin-top: 16px; font-size: 0.85rem;"
                        onclick="selectProduct('<%= prod.get("productId") %>', '<%= rate %>', '<%= minAmt %>', '<%= maxAmt %>', '<%= minT %>', '<%= maxT %>')">
                    Select & Calculate &rarr;
                </button>
            </div>
        <%
                }
            }
        %>
    </div>

    <!-- Loan Application & Live EMI Calculator Form -->
    <div class="card" style="margin-bottom: 32px;" id="applyForm">
        <h3 style="font-size: 1.25rem; color: var(--text-main); margin-bottom: 4px;">Apply for Loan & EMI Calculator</h3>
        <p style="color: var(--text-muted); font-size: 0.85rem; margin-bottom: 20px;">
            Adjust the amount and tenure to calculate your exact monthly EMI before submitting your application.
        </p>

        <form action="${pageContext.request.contextPath}/loan" method="post">
            <input type="hidden" name="action" value="apply">

            <div class="form-row">
                <div class="form-group">
                    <label for="productId">Select Loan Scheme *</label>
                    <select id="productId" name="productId" required onchange="onProductChange()">
                    <%
                        if (loanProducts != null) {
                            for (Map<String, Object> p : loanProducts) {
                    %>
                        <option value="<%= p.get("productId") %>" data-rate="<%= p.get("interestRate") %>" data-min="<%= p.get("minAmount") %>" data-max="<%= p.get("maxAmount") %>" data-mint="<%= p.get("minTenureMonths") %>" data-maxt="<%= p.get("maxTenureMonths") %>">
                            <%= p.get("productName") %> (<%= p.get("interestRate") %>% p.a.)
                        </option>
                    <%
                            }
                        }
                    %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="accountId">Disbursement Account (Credited on approval) *</label>
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
                        <option value="">No active bank accounts available</option>
                    <%
                        }
                    %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="loanAmount">Loan Principal Amount (₹) *</label>
                    <input type="number" id="loanAmount" name="amount" value="100000" min="10000" step="5000" required oninput="calculateEmi()">
                </div>

                <div class="form-group">
                    <label for="tenureMonths">Tenure (in Months) *</label>
                    <input type="number" id="tenureMonths" name="tenureMonths" value="12" min="6" max="240" step="1" required oninput="calculateEmi()">
                </div>
            </div>

            <div class="form-group">
                <label for="purpose">Loan Purpose / Remarks</label>
                <input type="text" id="purpose" name="purpose" placeholder="e.g. Higher education semester fee / Home renovation">
            </div>

            <!-- Live Calculation Preview -->
            <div class="calc-preview-box">
                <div>
                    <div class="calc-metric-label">Interest Rate</div>
                    <div class="calc-metric-val" id="dispRate" style="color: var(--primary);">10.50%</div>
                </div>
                <div>
                    <div class="calc-metric-label">Monthly EMI</div>
                    <div class="calc-metric-val" id="dispEmi" style="color: #16a34a;">₹8,815</div>
                </div>
                <div>
                    <div class="calc-metric-label">Total Repayable</div>
                    <div class="calc-metric-val" id="dispTotal">₹105,780</div>
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="max-width: 260px; margin-top: 20px;">
                Submit Loan Application &rarr;
            </button>
        </form>
    </div>

    <!-- My Loan Applications & Active Loans Table -->
    <div class="card" style="padding: 0; overflow: hidden; margin-bottom: 40px;">
        <div style="padding: 20px 24px; border-bottom: 1px solid var(--border);">
            <h3 style="font-size: 1.25rem; color: var(--text-main); margin-bottom: 2px;">
                📜 My Loan Portfolio & Applications (<%= loans != null ? loans.size() : 0 %>)
            </h3>
            <span style="font-size: 0.85rem; color: var(--text-muted);">Track approval statuses and repayment dues</span>
        </div>

        <div class="table-responsive">
            <table class="data-table" style="margin: 0;">
                <thead>
                    <tr>
                        <th>Application Ref</th>
                        <th>Loan Scheme</th>
                        <th>Principal</th>
                        <th>Interest & Tenure</th>
                        <th>Monthly EMI</th>
                        <th>Total Repayable</th>
                        <th>Status</th>
                        <th>Disbursement Account</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (loans == null || loans.isEmpty()) {
                %>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 36px 20px; color: var(--text-muted);">
                            <div style="font-size: 2.5rem; margin-bottom: 8px;">📜</div>
                            <strong>No loan applications submitted yet.</strong><br>
                            Use the form above to calculate your EMI and apply for personal or home financing.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Map<String, Object> l : loans) {
                            String appRef = (String) l.get("applicationNumber");
                            String pName = (String) l.get("productName");
                            BigDecimal prin = (BigDecimal) l.get("principalAmount");
                            BigDecimal r = (BigDecimal) l.get("interestRate");
                            int tenure = (Integer) l.get("tenureMonths");
                            BigDecimal emi = (BigDecimal) l.get("monthlyEmi");
                            BigDecimal total = (BigDecimal) l.get("totalRepayable");
                            String status = (String) l.get("status");
                            String accNo = (String) l.get("accountNumber");
                            String bName = (String) l.get("bankName");

                            String badgeClass = "badge-pending";
                            if ("DISBURSED".equalsIgnoreCase(status) || "APPROVED".equalsIgnoreCase(status)) {
                                badgeClass = "badge-disbursed";
                            } else if ("REJECTED".equalsIgnoreCase(status)) {
                                badgeClass = "badge-rejected";
                            }
                %>
                    <tr>
                        <td><code><%= appRef %></code></td>
                        <td>
                            <strong><%= pName %></strong>
                        </td>
                        <td><strong><%= currencyFormat.format(prin != null ? prin : BigDecimal.ZERO) %></strong></td>
                        <td><%= r %>% p.a. • <%= tenure %> mos</td>
                        <td style="color: #16a34a; font-weight: 700;"><%= currencyFormat.format(emi != null ? emi : BigDecimal.ZERO) %></td>
                        <td><%= currencyFormat.format(total != null ? total : BigDecimal.ZERO) %></td>
                        <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                        <td><small>#<%= accNo %> (<%= bName %>)</small></td>
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

<script>
    function onProductChange() {
        var sel = document.getElementById('productId');
        var opt = sel.options[sel.selectedIndex];
        var rate = opt.getAttribute('data-rate');
        var minAmt = opt.getAttribute('data-min');
        var maxAmt = opt.getAttribute('data-max');
        var minT = opt.getAttribute('data-mint');
        var maxT = opt.getAttribute('data-maxt');

        if (rate) {
            document.getElementById('dispRate').textContent = rate + '%';
        }
        var amtInput = document.getElementById('loanAmount');
        if (minAmt) amtInput.min = minAmt;
        if (maxAmt) amtInput.max = maxAmt;

        var tenureInput = document.getElementById('tenureMonths');
        if (minT) tenureInput.min = minT;
        if (maxT) tenureInput.max = maxT;

        calculateEmi();
    }

    function selectProduct(pId, rate, minAmt, maxAmt, minT, maxT) {
        var sel = document.getElementById('productId');
        for (var i = 0; i < sel.options.length; i++) {
            if (sel.options[i].value === pId) {
                sel.selectedIndex = i;
                break;
            }
        }
        document.getElementById('loanAmount').value = minAmt;
        document.getElementById('tenureMonths').value = minT;
        onProductChange();
        document.getElementById('applyForm').scrollIntoView({ behavior: 'smooth' });
    }

    function calculateEmi() {
        var sel = document.getElementById('productId');
        var opt = sel ? sel.options[sel.selectedIndex] : null;
        var annualRate = opt ? parseFloat(opt.getAttribute('data-rate')) : 10.50;

        var p = parseFloat(document.getElementById('loanAmount').value) || 0;
        var n = parseInt(document.getElementById('tenureMonths').value) || 12;

        if (p <= 0 || n <= 0) return;

        var r = (annualRate / 100) / 12;
        var emi = (p * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
        if (isNaN(emi) || !isFinite(emi)) {
            emi = (p + (p * (annualRate / 100) * (n / 12))) / n;
        }

        var total = emi * n;

        document.getElementById('dispRate').textContent = annualRate.toFixed(2) + '%';
        document.getElementById('dispEmi').textContent = '₹' + Math.round(emi).toLocaleString('en-IN');
        document.getElementById('dispTotal').textContent = '₹' + Math.round(total).toLocaleString('en-IN');
    }

    window.addEventListener('DOMContentLoaded', function() {
        onProductChange();
    });
</script>

</body>
</html>
