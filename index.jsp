<%@ page import="java.sql.*, java.util.Base64" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<html>
<head><title>E-Commerce Home</title></head>
<body>
<h2>Welcome to My E-Commerce Site</h2>

<%
    String username = (session != null) ? (String)session.getAttribute("username") : null;
    String role = (session != null) ? (String)session.getAttribute("role") : null;
%>

<% if(username == null) { %>
    <a href="user_login.jsp">User Login</a> | <a href="user_register.jsp">Register</a> | <a href="admin_login.jsp">Admin Login</a>
<% } else { %>
    Hello, <b><%= username %></b> | <a href="logout.jsp">Logout</a> |
    <a href="cart.jsp">Cart</a>
    <% if("admin".equals(role)) { %> | <a href="admin_home.jsp">Admin Dashboard</a> <% } %>
<% } %>

<hr/>

<%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a12345");
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id, name, price, description, image_data FROM products1");

        while (rs.next()) {
            int id = rs.getInt("id");
            String name = rs.getString("name");
            double price = rs.getDouble("price");
            String desc = rs.getString("description");

            Blob imageBlob = rs.getBlob("image_data");
            String base64Image = "";
            if(imageBlob != null) {
                byte[] imageBytes = imageBlob.getBytes(1, (int) imageBlob.length());
                base64Image = Base64.getEncoder().encodeToString(imageBytes);
            }
%>
            <div style="border:1px solid gray; margin:10px; padding:10px; width:350px; height:300px; float:left;">
                <h3><%= name %> - $<%= price %></h3>
                <p><%= desc %></p>
                <% if(!base64Image.isEmpty()) { %>
                    <img src="data:image/jpeg;base64,<%= base64Image %>" width="150" height="150" /><br>
                <% } else { %>
                    <p>No image</p>
                <% } %>

                <% if(username != null && !"admin".equals(role)) { %>
                    <form action="cart.jsp" method="post" style="margin-top:10px;">
                        <input type="hidden" name="productId" value="<%= id %>" />
                        Quantity: <input type="number" name="quantity" value="1" min="1" style="width:50px;" />
                        <input type="submit" value="Add to Cart" />
                    </form>
                <% } %>
            </div>
<%
        }
    } catch (Exception e) {
        out.println("Error: " + e);
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<div style="clear:both;"></div>
</body>
</html>
