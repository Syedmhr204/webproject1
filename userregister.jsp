<%@ page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","TEST", "test");
        ps = conn.prepareStatement("INSERT INTO users (email, password, role) VALUES (?, ?, 'customer')");
        ps.setString(1, email);
        ps.setString(2, password);
        ps.executeUpdate();
         out.println("<h1>Registration Successful!</h1>");
        // Redirect to login.jsp after successful registration
        response.sendRedirect("login.jsp");
        
    } catch(SQLIntegrityConstraintViolationException e) {
        // Handle duplicate email or other constraint violations
        out.println("Error: The email address is already registered. Please use a different one.");
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if(ps != null) ps.close();
        if(conn != null) conn.close();
    }
%>