<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    String firstName = (String) request.getAttribute("firstName");
    if (firstName == null) firstName = (String) session.getAttribute("firstName");
    if (firstName == null) firstName = "";

    String lastName = (String) request.getAttribute("lastName");
    if (lastName == null) lastName = (String) session.getAttribute("lastName");
    if (lastName == null) lastName = "";

    String email = (String) request.getAttribute("email");
    if (email == null) email = (String) session.getAttribute("email");
    if (email == null) email = "";

    String phone = (String) request.getAttribute("phone");
    if (phone == null) phone = (String) session.getAttribute("phone");
    if (phone == null) phone = "";

    String dateOfBirth = (String) request.getAttribute("dateOfBirth");
    if (dateOfBirth == null) dateOfBirth = (String) session.getAttribute("dateOfBirth");
    if (dateOfBirth == null) dateOfBirth = "";

    String address = (String) request.getAttribute("address");
    if (address == null) address = (String) session.getAttribute("address");
    if (address == null) address = "";

    String city = (String) request.getAttribute("city");
    if (city == null) city = (String) session.getAttribute("city");
    if (city == null) city = "";

    String state = (String) request.getAttribute("state");
    if (state == null) state = (String) session.getAttribute("state");
    if (state == null) state = "";

    String pincode = (String) request.getAttribute("pincode");
    if (pincode == null) pincode = (String) session.getAttribute("pincode");
    if (pincode == null) pincode = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - E-Banking</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card">
        <div class="brand-header">
            <h2>Edit Profile</h2>
            <p>Update your personal information below</p>
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

        <form action="${pageContext.request.contextPath}/user/update-profile" method="post">
            <input type="hidden" name="userId" value="<%= userId %>">

            <div class="form-row">
                <div class="form-group">
                    <label for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" value="<%= firstName %>" required>
                </div>

                <div class="form-group">
                    <label for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" value="<%= lastName %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email Address (Read-only)</label>
                    <input type="email" id="email" value="<%= email %>" readonly>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="text" id="phone" name="phone" value="<%= phone %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth" value="<%= dateOfBirth %>">
                </div>

                <div class="form-group">
                    <label for="city">City</label>
                    <input type="text" id="city" name="city" value="<%= city %>">
                </div>
            </div>

            <div class="form-group">
                <label for="address">Address</label>
                <textarea id="address" name="address"><%= address %></textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="state">State</label>
                    <input type="text" id="state" name="state" value="<%= state %>">
                </div>

                <div class="form-group">
                    <label for="pincode">Pincode</label>
                    <input type="text" id="pincode" name="pincode" value="<%= pincode %>">
                </div>
            </div>

            <div class="actions-bar">
                <button type="submit" class="btn btn-primary" style="flex: 1;">Save Changes</button>
                <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-secondary" style="flex: 1;">Cancel</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
