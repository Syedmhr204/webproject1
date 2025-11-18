<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test"
        );

        // Only allow trainers with accepted status to login
        String sql = "SELECT ID, FULL_NAME FROM TRAINER_APPLICATIONS1 WHERE EMAIL = ? AND TRAINER_PASSWORD = ? AND APPLICATION_STATUS = 'accepted'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, email);
        pstmt.setString(2, password);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // login success
            session.setAttribute("trainer_id", rs.getInt("ID"));
            session.setAttribute("trainer_name", rs.getString("FULL_NAME"));
            response.sendRedirect("trainer_dashboards.jsp");
        } else {
            // invalid login
            response.sendRedirect("trainer_login.jsp?error=1");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("trainer_login.jsp?error=2");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>
