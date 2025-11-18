
<%@ include file="dbConnection.jsp" %>
<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%
response.setContentType("text/html;charset=UTF-8");

String tranId = request.getParameter("tran_id");
if (tranId == null || tranId.trim().isEmpty()) {
    out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Booking Not Found</title></head><body>");
    out.println("<h2>Missing transaction id.</h2><p>No booking to display.</p>");
    out.println("</body></html>");
    return;
}

// Ensure DB connection is available (dbConnection.jsp should provide 'conn')
if (conn == null) {
    out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>DB Error</title></head><body>");
    out.println("<h2>Database connection not available.</h2>");
    out.println("</body></html>");
    return;
}

int bookingId = 0;
String userEmail = null;
String trainer = null;
String date = null;
String time = null;
double amount = 0.0;
String status = null;
String paymentStatus = null;
boolean found = false;

try (PreparedStatement ps = conn.prepareStatement(
        "SELECT BOOKING_ID, USER_EMAIL, TRAINER_NAME, TO_CHAR(SESSION_DATE,'YYYY-MM-DD') AS SDATE, SESSION_TIME, AMOUNT, STATUS, PAYMENT_STATUS " +
        "FROM BOOKINGS1 WHERE TRANSACTION_ID = ?")) {
    ps.setString(1, tranId);
    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            found = true;
            bookingId = rs.getInt("BOOKING_ID");
            userEmail = rs.getString("USER_EMAIL");
            trainer = rs.getString("TRAINER_NAME");
            date = rs.getString("SDATE");
            time = rs.getString("SESSION_TIME");
            amount = rs.getDouble("AMOUNT");
            status = rs.getString("STATUS");
            paymentStatus = rs.getString("PAYMENT_STATUS");
        }
    }
} catch (Exception e) {
    log("Error querying booking for tran_id=" + tranId, e);
    out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Error</title></head><body>");
    out.println("<h2>Error fetching booking.</h2><pre>" + e.getMessage() + "</pre>");
    out.println("</body></html>");
    return;
}

if (!found) {
    out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Booking Not Found</title></head><body>");
    out.println("<h2>Booking record not found.</h2>");
    out.println("<p>The payment completed (Tran ID: " + tranId + ") but the booking was not found on the server.</p>");
    out.println("<p>If you started payment from another device or the session expired, contact support and provide Transaction ID: <strong>" + tranId + "</strong></p>");
    out.println("</body></html>");
    return;
}

// Idempotent update: mark payment as confirmed if not already
if (paymentStatus == null || !"confirmed".equalsIgnoreCase(paymentStatus)) {
    try (PreparedStatement upd = conn.prepareStatement("UPDATE BOOKINGS1 SET PAYMENT_STATUS = 'confirmed', STATUS = 'Confirmed' WHERE TRANSACTION_ID = ?")) {
        upd.setString(1, tranId);
        upd.executeUpdate();
        paymentStatus = "confirmed";
        status = "Confirmed";
    } catch (Exception e) {
        log("Failed to update payment status for tran_id=" + tranId, e);
        // continue to display booking even if update failed
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Booking Confirmed</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div style="text-align:center; padding:50px;">
        <h1 style="color:green;">Booking Confirmed ✅</h1>
        <p>Thank you. Your payment was received and booking is confirmed.</p>

        <div style="margin:30px auto; display:inline-block; text-align:left; border:1px solid #ddd; padding:20px 40px; border-radius:10px; background-color:#f9f9f9;">
            <p><strong>Booking ID:</strong> <%= bookingId %></p>
            <p><strong>Transaction ID:</strong> <%= tranId %></p>
            <p><strong>Booked By:</strong> <%= (userEmail != null ? userEmail : "N/A") %></p>
            <p><strong>Trainer:</strong> <%= (trainer != null ? trainer : "N/A") %></p>
            <p><strong>Date / Time:</strong> <%= (date != null ? date : "") %> <%= (time != null ? time : "") %></p>
            <p><strong>Amount:</strong> <%= String.format("%.2f", amount) %> BDT</p>
            <p><strong>Booking status:</strong> <%= (status != null ? status : "N/A") %></p>
            <p><strong>Payment status:</strong> <%= (paymentStatus != null ? paymentStatus : "N/A") %></p>
        </div>

        <br><br>
        <a href="trainer.jsp" class="primary-btn">Back to Trainers</a>
    </div>
</body>
</html>

<%-- <%@ page import="java.sql.*" %>
<%
    String tranId = request.getParameter("tran_id");
    String msg = "Booking confirmed.";
    String trainer = request.getParameter("trainer") != null ? request.getParameter("trainer") : "";
    String date = request.getParameter("date") != null ? request.getParameter("date") : "";
    String time = request.getParameter("time") != null ? request.getParameter("time") : "";
    String amount = request.getParameter("amount") != null ? request.getParameter("amount") : "";
%>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Booking Confirmed</title></head>
<body>
    <h1 style="color:green;">Booking Confirmed</h1>
    <p><strong>Transaction ID:</strong> <%= tranId %></p>
    <p><strong>Trainer:</strong> <%= trainer %></p>
    <p><strong>Date / Time:</strong> <%= date %> <%= time %></p>
    <p><strong>Amount:</strong> <%= amount %></p>
    <p>Thank you. A confirmation email will be sent shortly (if enabled).</p>
    <a href="trainer.jsp">Back to Trainers</a>
</body>
</html> --%>