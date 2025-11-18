<%@ page import="java.sql.*" %>
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