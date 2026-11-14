<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Registration - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card">
        <div class="brand-header">
            <h2>Create Bank Account</h2>
            <p>Fill in your details below to register your account</p>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <%
            }
        %>

        <form action="${pageContext.request.contextPath}/user/register" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" placeholder="Enter first name" required>
                </div>

                <div class="form-group">
                    <label for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" placeholder="Enter last name" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" id="email" name="email" placeholder="example@bank.com" required>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="text" id="phone" name="phone" placeholder="10-digit mobile number" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" placeholder="Create password" required>
                </div>

                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth">
                </div>
            </div>

            <div class="form-group">
                <label for="address">Address</label>
                <textarea id="address" name="address" placeholder="Residential street address"></textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="city">City</label>
                    <input type="text" id="city" name="city" placeholder="City">
                </div>

                <div class="form-group">
                    <label for="state">State</label>
                    <input type="text" id="state" name="state" placeholder="State">
                </div>

                <div class="form-group">
                    <label for="pincode">Pincode</label>
                    <input type="text" id="pincode" name="pincode" placeholder="Postal code">
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Register</button>
        </form>

        <div class="auth-links">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>
</div>

</body>
</html>
