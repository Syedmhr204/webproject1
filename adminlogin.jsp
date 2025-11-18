<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
 <link rel="stylesheet" href="style.css">
<head>
    <title>Admin Login</title>
</head>
<body>
<div class="auth-wrapper">
  <div class="auth-card">
    <h1>Admin Portal Login</h1>

    <% 
        String error = request.getParameter("error");
        if ("1".equals(error)) { 
    %>
        <p style="color:red;">Invalid email or password.</p>
    <% 
        } else if ("2".equals(error)) { 
    %>
        <p style="color:red;">Server error. Please try again later.</p>
    <% } %>

    <form action="process_admin_login.jsp" method="post">
        <label>Email:</label>
        <input type="email" name="email" required><br><br>
        
        <label>Password:</label>
        <input type="password" name="password" required><br><br>
        
        <button type="submit">Login</button>
    </form>
</body>
</html>
