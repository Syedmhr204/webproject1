<%@ page import="java.sql.*" %>
<%
    // DB connection config - change if needed
    String DB_URL  = "jdbc:oracle:thin:@localhost:1521:xe";
    String DB_USER = "system" ;
    String DB_PASS = "kona";

    Connection conn = null;
    try {
       Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
    } // /dbConnection.jsp
// ...
    catch (Exception e) {
        // Correct way to display exception details to JspWriter:
        out.println("<pre>DB Connection error: " + e.getMessage() + "</pre>");
        // Option 1: Print the full stack trace to the System console (standard server logging)
        e.printStackTrace(); 
        // Option 2 (Less recommended for JSP): Print the exception string
        // out.println("<pre>" + e.toString() + "</pre>"); 
    }
// ...
%>
