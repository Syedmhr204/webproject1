<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    
    String adminEmail = "admin@fitlife.com";
    String adminPassword = "admin123"; 

    if (email.equals(adminEmail) && password.equals(adminPassword)) {
        session.setAttribute("admin_email", email);
        response.sendRedirect("admin_dashboard.jsp");
    } else {
        response.sendRedirect("adminlogin.jsp?error=1");
    }
%>