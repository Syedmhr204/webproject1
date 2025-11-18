<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    String userEmail = (String) session.getAttribute("email");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String trainerName = request.getParameter("trainer-name");
    String sessionDateStr = request.getParameter("session-date");
    String sessionTime = request.getParameter("session-time");

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
        
        String sql = "INSERT INTO bookings1 (user_email, trainer_name, session_date, session_time) VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?)";
        ps = conn.prepareStatement(sql);

        ps.setString(1, userEmail);
        ps.setString(2, trainerName);
        ps.setString(3, sessionDateStr);
        ps.setString(4, sessionTime);

        int rowsAffected = ps.executeUpdate();

        if (rowsAffected > 0) {
            response.sendRedirect("trainer.jsp?status=success");
        } else {
            response.sendRedirect("trainer.jsp?status=error");
        }

    } catch (Exception e) {
        System.err.println("Database Error: " + e.getMessage());
        response.sendRedirect("trainer.jsp?status=error");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>