<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String action = request.getParameter("action");
    String bookingIdStr = request.getParameter("booking_id");
    
    // Determine the correct redirect page
    String redirectPage = "trainer_dashboards.jsp"; // Default for trainer actions
    boolean isUserAction = "accept".equalsIgnoreCase(action) || "reject".equalsIgnoreCase(action);
    
    if (isUserAction) {
        // If the action is from the user's dashboard, redirect to the user's profile
        redirectPage = "profiles.jsp";
    }
    
    // --- 1. Security Check ---
    // Check if the user/trainer is logged in. 
    // If it's a trainer action, check for trainer_id. If it's a user action, check for email.
    if (("delete".equalsIgnoreCase(action) || "complete".equalsIgnoreCase(action) || "changeTimeProposal".equalsIgnoreCase(action)) && session.getAttribute("trainer_id") == null) {
        response.sendRedirect("trainer_login.jsp");
        return;
    } else if (isUserAction && session.getAttribute("email") == null) {
        // Redirect to user login if it's a user action and user isn't logged in
        response.sendRedirect("login.jsp");
        return;
    }


    if (action == null || bookingIdStr == null) {
        session.setAttribute("message", "Error: Invalid action or booking ID.");
        response.sendRedirect(redirectPage);
        return;
    }
    
    int bookingId = -1;
    try {
        bookingId = Integer.parseInt(bookingIdStr);
    } catch (NumberFormatException e) {
        session.setAttribute("message", "Error: Invalid booking ID format.");
        response.sendRedirect(redirectPage);
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
        int rowsAffected = 0;
        String sql = "";

        // --- TRAINER ACTIONS (Existing Logic) ---
        if ("delete".equalsIgnoreCase(action)) {
            sql = "DELETE FROM bookings1 WHERE BOOKING_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bookingId);
            rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) session.setAttribute("message", "Booking " + bookingId + " successfully rejected.");

        } else if ("complete".equalsIgnoreCase(action)) {
            sql = "UPDATE bookings1 SET STATUS ='complete' WHERE BOOKING_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bookingId);
            rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) session.setAttribute("message", "Booking " + bookingId + " marked as complete.");

        } else if ("changeTimeProposal".equalsIgnoreCase(action)) {
            String newDateStr = request.getParameter("new_session_date");
            String newTime = request.getParameter("new_session_time");
            sql = "UPDATE bookings1 SET NEW_SESSION_DATE = TO_DATE(?, 'YYYY-MM-DD'), NEW_SESSION_TIME = ?, USER_ACTION_PENDING = 'Y' WHERE BOOKING_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newDateStr);
            pstmt.setString(2, newTime);
            pstmt.setInt(3, bookingId);
            rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) session.setAttribute("message", "New time proposed for Booking " + bookingId + ".");
            
        // --- USER ACTIONS (New Logic) ---
        } else if ("accept".equalsIgnoreCase(action)) {
            // SQL to move proposed date/time to official date/time and clear proposal fields
            sql = "UPDATE bookings1 SET SESSION_DATE = NEW_SESSION_DATE, SESSION_TIME = NEW_SESSION_TIME, " +
                  "NEW_SESSION_DATE = NULL, NEW_SESSION_TIME = NULL, USER_ACTION_PENDING = 'N', STATUS = 'pending' " +
                  "WHERE BOOKING_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bookingId);
            rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) session.setAttribute("message", "Booking " + bookingId + ": Time change accepted. New session confirmed!");
            
        } else if ("reject".equalsIgnoreCase(action)) {
            // SQL to clear proposal fields, keeping the original date/time
            sql = "UPDATE bookings1 SET NEW_SESSION_DATE = NULL, NEW_SESSION_TIME = NULL, USER_ACTION_PENDING = 'N' WHERE BOOKING_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bookingId);
            rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) session.setAttribute("message", "Booking " + bookingId + ": Time change rejected. Original time remains.");

        } else {
             session.setAttribute("message", "Error: Unknown action requested.");
        }

    } catch (Exception e) {
        session.setAttribute("message", "Database Error: " + e.getMessage());
        System.err.println("Error in update_booking.jsp: " + e.getMessage());
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // ✅ Redirect to the appropriate dashboard
    response.sendRedirect(redirectPage);
%>