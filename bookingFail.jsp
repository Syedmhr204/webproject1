<html>
<head><title>Payment Failed</title><link rel="stylesheet" href="style.css"></head>
<body>
    <div style="text-align: center; padding: 50px;">
        <h1 style="color: red;">Payment Failed</h1>
        <p>Your payment could not be processed. Your booking was not confirmed.</p>
        <p>Reason: <%= request.getParameter("error") %></p>
        <a href="trainer.jsp" class="primary-btn">Try Again</a>
    </div>
</body>
</html>