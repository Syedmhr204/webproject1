<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null; // Added declaration for ResultSet

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
        
        String sql = "SELECT email, role FROM users WHERE email = ? AND password = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        ps.setString(2, password);
        
        rs = ps.executeQuery(); // Now this will work
        
        if (rs.next()) {
            session.setAttribute("email", email); 
            session.setAttribute("role", rs.getString("role"));
            response.sendRedirect("profiles.jsp"); // Redirect to profile page
        } else {
            out.println("<script>alert('Invalid email or password');location.href='login.jsp';</script>");
        }
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        // Closing resources in the correct order
        if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
        if(ps != null) try { ps.close(); } catch(SQLException ignore) {}
        if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
    }
%>