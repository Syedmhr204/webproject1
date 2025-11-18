<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.text.SimpleDateFormat" %> 
<%@ page import="java.util.Date" %> 
<%@ page import="java.io.*" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("email") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String email = (String) userSession.getAttribute("email");

    // Minimum date for booking
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    String minDate = dateFormat.format(new Date());
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FitLife - Trainers</title>
<link rel="stylesheet" href="style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
.booking-modal {
    display: none; position: fixed; z-index: 1000;
    left: 0; top: 0; width: 100%; height: 100%;
    background-color: rgba(0,0,0,0.5);
    align-items: center; justify-content: center;
}
.modal-content {
    background-color: #fff; padding: 20px;
    border-radius: 8px; width: 90%; max-width: 450px;
    position: relative;
}
.close-btn {
    color: #888; position: absolute;
    top: 10px; right: 20px; font-size: 28px;
    font-weight: bold; cursor: pointer;
}
</style>
</head>
<body>

<nav class="navbar">
<div class="nav-container">
    <div class="nav-logo"><i class="fas fa-heartbeat"></i> <span>FitLife</span></div>
    <div class="nav-menu" id="nav-menu">
        <a href="Adminindex.html" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="trainer.jsp" class="nav-link active"><i class="fas fa-users"></i> Trainers</a>
        <a href="foodChart.jsp" class="nav-link"><i class="fas fa-apple-alt"></i> Food Chart</a>
        <a href="exercises.jsp" class="nav-link"><i class="fas fa-dumbbell"></i> Exercise</a>
        <a href="profiles.jsp" class="nav-link"><i class="fas fa-user-circle"></i> Profile</a>
    </div>
    <div class="nav-toggle" id="nav-toggle">
        <span class="bar"></span><span class="bar"></span><span class="bar"></span>
    </div>
</div>
</nav>

<main id="main-content">
<section id="trainers" class="section">
<div class="container">
    <div class="section-header">
        <h1>Meet Our Expert Trainers</h1>
        <p>Work with certified fitness professionals who are passionate about helping you achieve your goals.</p>
    </div>
    <div class="trainers-grid" id="trainers-grid">
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
                String trainerSql = "SELECT ID, FULL_NAME, SPECIALIZATIONS, EXPERIENCE, LOCATION, BIO, IMAGE, SESSION_PRICE, IMAGE_NAME FROM TRAINER_APPLICATIONS1 WHERE APPLICATION_STATUS = 'accepted'";
                pstmt = conn.prepareStatement(trainerSql);
                rs = pstmt.executeQuery();

                while (rs.next()) {
                    String imgPath = "default-trainer.jpg";
                    Blob imgBlob = rs.getBlob("IMAGE");
                    if (imgBlob != null) {
                        byte[] imgBytes = imgBlob.getBytes(1, (int) imgBlob.length());
                        String base64Image = java.util.Base64.getEncoder().encodeToString(imgBytes);
                        imgPath = "data:image/jpeg;base64," + base64Image;
                    }
        %>
        <div class="trainer-card">
            <div class="trainer-image">
                <img src="<%= imgPath %>" alt="Trainer Photo" />
            </div>
            <div class="trainer-info">
                <h3 class="trainer-name"><%= rs.getString("full_name") %></h3>
                <p class="trainer-specialty"><%= rs.getString("specializations") %></p>
                <div class="trainer-details">
                    <p><i class="fas fa-briefcase"></i> <%= rs.getString("experience") %></p>
                    <p><i class="fas fa-map-marker-alt"></i> <%= rs.getString("location") %></p>
                    <p><i class="fas fa-dollar-sign"></i> BDT <%= rs.getDouble("session_price") %> / session</p>
                </div>
                <p class="trainer-bio"><%= rs.getString("bio") %></p>
                <button class="book-btn" 
                        data-trainer-id="<%= rs.getInt("id") %>"
                        data-trainer-name="<%= rs.getString("full_name") %>"
                        data-session-price="<%= rs.getDouble("session_price") %>">
                    Book Now
                </button>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>");
                e.printStackTrace(new java.io.PrintWriter(out));
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception ignored) {}
                if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }
        %>
    </div>
</div>
</section>

<!-- Apply as Trainer -->
<section class="apply-trainer-section">
    <div class="container">
        <h2>Are You a Fitness Professional?</h2>
        <p>Join our team of expert trainers and help others achieve their fitness dreams.</p>
        <a href="applytrainer.jsp" class="primary-btn">Apply Now</a>
    </div>
</section>
</main>

<!-- Booking Modal -->
<div class="booking-modal" id="booking-modal">
    <div class="modal-content">
        <span class="close-btn" id="close-booking-modal">&times;</span>
        <h2>Book a Session</h2>
        
        <form id="booking-form" action="bookingHandler.jsp" method="post">
            <div class="form-group">
                <label>Trainer:</label>
                <input type="text" id="trainer-name" name="trainer_name" readonly required>
            </div>
            <div class="form-group">
                <label>Your Email:</label>
                <input type="email" id="user-email" name="email" readonly value="<%= email %>" required>
            </div>
            <div class="form-group">
                <label>Date:</label>
                <input type="date" id="session-date" name="session_date" required min="<%= minDate %>">
            </div>
            <div class="form-group">
                <label>Time:</label>
                <input type="time" id="session-time" name="session_time" required>
            </div>
            <input type="hidden" id="trainer-id" name="trainer_id">
            <input type="hidden" id="session-price" name="session_price">
            <button type="submit" class="primary-btn">Proceed to Payment</button>
        </form>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const bookingModal = document.getElementById('booking-modal');
    const closeBookingBtn = document.getElementById('close-booking-modal');
    const bookBtns = document.querySelectorAll('.book-btn');

    bookBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            document.getElementById('trainer-id').value = this.dataset.trainerId;
            document.getElementById('trainer-name').value = this.dataset.trainerName;
            document.getElementById('session-price').value = this.dataset.sessionPrice;
            bookingModal.style.display = 'flex';
        });
    });

    closeBookingBtn.onclick = () => bookingModal.style.display = 'none';
    window.onclick = e => { if(e.target === bookingModal) bookingModal.style.display = 'none'; };

    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    navToggle.addEventListener('click', () => navMenu.classList.toggle('active'));
});
</script>
</body>
</html>
