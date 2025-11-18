<%@ page import="javax.servlet.http.HttpSession" %>

<%
   
    session.invalidate();
    
   
    response.sendRedirect("login.jsp");
%>