<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.Base64" %>
<%@ page import="javax.sql.rowset.serial.SerialClob" %> 
<%
    // --- SESSION CHECK ---
    String trainerName = (String) session.getAttribute("trainer_name");
    String trainerEmail = (String) session.getAttribute("trainer_email"); 
    Integer trainerId = (Integer) session.getAttribute("trainer_id");

    if (trainerName == null || trainerId == null) {
        response.sendRedirect("trainer_login.jsp");
        return;
    }
    
    if (trainerEmail == null) trainerEmail = "N/A";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // --- Trainer Profile Data Variables (Profile Image is now only displayed) ---
    String profileFullName = "";
    String profilePhone = "";
    String profileLocation = "";
    String profileSpecializations = ""; 
    String profileExperience = "";
    String profileBio = "";
    String profileCertifications = ""; 
    // profileSessionPrice is removed as requested.
    String profileImageBase64 = "https://via.placeholder.com/120?text=No+Image"; // Default placeholder
    String updateMessage = null; // Message for successful password change
    
    // --- DATABASE CONFIGURATION ---
    final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    final String DB_USER = "TEST";
    final String DB_PASS = "test"; 

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        
        // --- 1. Handle Profile Update (RESTRICTED TO PASSWORD ONLY) ---
        if ("updatePassword".equals(request.getParameter("action"))) {
            String newPassword = request.getParameter("trainer_password"); 

            if (newPassword != null && !newPassword.isEmpty()) {
                // Only allow password update in this block
                String updateSql = "UPDATE trainer_applications1 SET TRAINER_PASSWORD=? WHERE ID=?";

                pstmt = conn.prepareStatement(updateSql);
                // !!! SECURITY WARNING: HASH PASSWORD HERE BEFORE STORING !!!
                pstmt.setString(1, newPassword); 
                pstmt.setInt(2, trainerId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                     updateMessage = "<div style='color: green; text-align: center; font-weight: bold;'>Password updated successfully!</div>";
                } else {
                     updateMessage = "<div style='color: orange; text-align: center;'>Password update failed.</div>";
                }
                pstmt.close();
            }
        }

        // --- 2. Auto-complete old bookings ---
        String autoCompleteSql =
            "UPDATE bookings1 SET STATUS = 'complete' " +
            "WHERE TRAINER_NAME = ? AND UPPER(STATUS) = 'PENDING' " +
            "AND (SESSION_DATE < TRUNC(SYSDATE) OR " +
            "(SESSION_DATE = TRUNC(SYSDATE) AND TO_NUMBER(REPLACE(SESSION_TIME, ':', '')) < TO_NUMBER(TO_CHAR(SYSDATE,'HH24MI'))))";
        pstmt = conn.prepareStatement(autoCompleteSql);
        pstmt.setString(1, trainerName);
        pstmt.executeUpdate();
        if (pstmt != null) pstmt.close();

        // --- 3. Fetch Trainer Profile Data for Display (Image and profile data) ---
        String profileSql = "SELECT FULL_NAME, EMAIL, PHONE, LOCATION, SPECIALIZATIONS, EXPERIENCE, BIO, CERTIFICATIONS, IMAGE FROM trainer_applications1 WHERE ID = ?";
        pstmt = conn.prepareStatement(profileSql);
        pstmt.setInt(1, trainerId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            profileFullName = rs.getString("FULL_NAME");
            trainerEmail = rs.getString("EMAIL"); 
            profilePhone = rs.getString("PHONE");
            profileLocation = rs.getString("LOCATION");
            profileSpecializations = rs.getString("SPECIALIZATIONS");
            profileExperience = rs.getString("EXPERIENCE");
            
            // Handle CLOB for BIO
            Clob bioClob = rs.getClob("BIO");
            profileBio = (bioClob != null) ? bioClob.getSubString(1, (int) bioClob.length()) : "";
            
            profileCertifications = rs.getString("CERTIFICATIONS");
            
            // Handle BLOB for IMAGE
            Blob imageBlob = rs.getBlob("IMAGE");
            if (imageBlob != null) {
                byte[] imgBytes = imageBlob.getBytes(1, (int) imageBlob.length());
                profileImageBase64 = "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(imgBytes);
            } else {
                 profileImageBase64 = "https://via.placeholder.com/120?text=No+Image"; 
            }
        }
        if (rs != null) rs.close(); 
        if (pstmt != null) pstmt.close();

    } catch (Exception e) {
          out.println("<div style='color: red; text-align: center;'>Database Error: " + e.getMessage() + "</div>");
    } finally {
        // Resources will be closed in the final block below HTML content
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trainer Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        body { background:linear-gradient(135deg,#e0e7ff 0%,#f4f7fc 100%); font-family:'Segoe UI',Arial,sans-serif; margin:0; }
        .dashboard-container { max-width:1100px; margin:40px auto; background:#fff; border-radius:18px; box-shadow:0 8px 32px rgba(60,60,120,0.14); padding:36px 28px 28px; }
        h1 { text-align:center; color:#40189e; margin-bottom:10px; font-size:2.2em; }
        p { text-align:center; color:#666; margin-bottom:32px; font-size:1.1em; }
        
        /* Tabs Style */
        .tabs { display:flex; justify-content:center; margin-bottom:30px; }
        .tab-button { background:none; border:none; padding:10px 20px; font-size:1.1em; cursor:pointer; color:#666; border-bottom:3px solid transparent; transition:all 0.3s; }
        .tab-button.active { color:#40189e; border-bottom:3px solid #40189e; font-weight:600; }
        .tab-content { display:none; padding-top:10px; }
        .tab-content.active { display:block; }

        /* General Table/Form Styling */
        table { width:100%; border-collapse:collapse; margin-bottom:32px; background:#f7f8fa; border-radius:12px; overflow:hidden; }
        th,td { padding:14px 10px; font-size:1em; }
        th { background:#40189e; color:#fff; font-weight:600; }
        tr:hover { background:#e0e7ff; }
        .action-btn { border:none; padding:8px 16px; border-radius:6px; cursor:pointer; margin-right:6px; transition: background 0.2s; }
        .reject { background:#dc3545; color:#fff; }
        .reject:hover { background: #c82333; }
        .complete { background:#28a745; color:#fff; }
        .complete:hover { background: #1e7e34; }
        .change { background:#ff9800; color:#fff; }
        .change:hover { background: #e68900; }
        .logout { display:block; width:140px; margin:30px auto 0; text-align:center; background:#40189e; color:#fff; padding:12px 0; border-radius:8px; text-decoration:none; font-size:1.1em; }
        .completed-row td { background:#e8f5e9; color:#2e7d32; }
        
        /* Profile Form Styling */
        .profile-form-group { margin-bottom: 20px; display: flex; align-items: center; }
        .profile-form-group label { flex: 1; font-weight: 600; color: #40189e; }
        .profile-form-group input[type="text"], 
        .profile-form-group input[type="number"], 
        .profile-form-group textarea,
        .profile-form-group input[type="password"] {
            flex: 3;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            width: 100%;
            box-sizing: border-box;
            background: #fff;
        }
        .profile-form-group textarea { resize: vertical; min-height: 100px; }
        .profile-form-group input:disabled, .profile-form-group textarea:disabled { 
            background: #e9ecef; /* Light gray for disabled fields */
            color: #6c757d;
        }
        .profile-image-container { text-align: center; margin-bottom: 30px; }
        .profile-image { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 4px solid #40189e; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .save-profile-btn { background:#40189e; color:#fff; padding:12px 25px; border:none; border-radius:8px; cursor:pointer; font-size:1.1em; transition: background 0.2s; }
        .save-profile-btn:hover { background:#300a7e; }

        /* Modal Styles */
        .modal-bg { display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.4); align-items:center; justify-content:center; z-index:1000; }
        .modal { background:#fff; padding:30px; border-radius:12px; min-width:300px; max-width:400px; box-shadow:0 4px 20px rgba(0,0,0,0.2); }
        .modal h2 { margin-top:0; color:#40189e; }
        .modal label, .modal input { display:block; margin-bottom:10px; }
        .modal input { width:100%; padding:8px; box-sizing:border-box; border:1px solid #ccc; border-radius:4px; }
        .modal button { padding:10px 15px; border:none; border-radius:6px; cursor:pointer; font-weight:500; }
        #closeModalBtn { background:#6c757d; color:#fff; }
        .modal button[type="submit"] { background:#40189e; color:#fff; margin-left:10px; }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <h1><i class="fas fa-dumbbell"></i> Welcome, <%= trainerName %>!</h1>
        
        <% if (updateMessage != null) { out.print(updateMessage); } %>

        <div class="tabs">
            <button class="tab-button active" data-tab="bookings"><i class="fas fa-calendar-alt"></i> Bookings</button>
            <button class="tab-button" data-tab="profile"><i class="fas fa-user-circle"></i> Profile</button>
        </div>

        <div id="bookings" class="tab-content active">
            <p>Manage your **pending** session requests and propose booking time changes.</p>

            <h2 style="color:#40189e;"><i class="fas fa-clock"></i> Pending Bookings</h2>
            <table>
                <thead>
                    <tr>
                        <th>User Name</th>
                        <th>Session Date</th>
                        <th>Session Time</th>
                        <th>User Email</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    // Bookings fetch logic...
                    try {
                         if (conn == null || conn.isClosed()) {
                             conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                         }
                        
                        String sql = "SELECT b.BOOKING_ID, u.NAME AS user_name, b.USER_EMAIL, b.SESSION_DATE, b.SESSION_TIME, b.STATUS " +
                                     "FROM bookings1 b JOIN users u ON b.USER_EMAIL = u.EMAIL " +
                                     "WHERE b.TRAINER_NAME = ? AND UPPER(b.STATUS) = 'PENDING' " +
                                     "ORDER BY b.SESSION_DATE, b.SESSION_TIME";

                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, trainerName);
                        rs = pstmt.executeQuery();

                        while (rs.next()) {
                            java.sql.Date sessionDate = rs.getDate("SESSION_DATE");
                            String formattedDate = (sessionDate != null) ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(sessionDate) : "";
                %>
                    <tr>
                        <td><%= rs.getString("user_name") %></td>
                        <td><%= formattedDate %></td>
                        <td><%= rs.getString("SESSION_TIME") %></td>
                        <td><%= rs.getString("USER_EMAIL") %></td>
                        <td><%= rs.getString("STATUS") %></td>
                        <td>
                            <form method="get" action="update_booking1.jsp" style="display:inline;">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="booking_id" value="<%= rs.getInt("BOOKING_ID") %>">
                                <button type="submit" class="action-btn complete" onclick="return confirm('Mark this booking as complete?');"><i class="fas fa-check"></i> Complete</button>
                            </form>
                            <form method="get" action="update_booking1.jsp" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="booking_id" value="<%= rs.getInt("BOOKING_ID") %>">
                                <button type="submit" class="action-btn reject" onclick="return confirm('Delete this booking? The user will be notified.');"><i class="fas fa-trash-alt"></i> Reject</button>
                            </form>
                            <button class="action-btn change" 
                                data-booking-id="<%= rs.getInt("BOOKING_ID") %>" 
                                data-date="<%= formattedDate %>" 
                                data-time="<%= rs.getString("SESSION_TIME") %>">
                                <i class="fas fa-calendar-alt"></i> Change Time
                            </button>
                        </td>
                    </tr>
                <%
                        }
                        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
                        if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
                    } catch (Exception e) {
                        out.println("<tr><td colspan='6' style='color:red;'>Error fetching pending bookings: " + e.getMessage() + "</td></tr>");
                    }
                %>
                </tbody>
            </table>

            <h2 style="color:#40189e;"><i class="fas fa-check-circle"></i> Completed Bookings</h2>
            <table>
                <thead>
                    <tr>
                        <th>User Name</th>
                        <th>Session Date</th>
                        <th>Session Time</th>
                        <th>User Email</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        if (conn == null || conn.isClosed()) {
                            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                        }
                        
                        String sql = "SELECT b.BOOKING_ID, u.NAME AS user_name, b.USER_EMAIL, b.SESSION_DATE, b.SESSION_TIME, b.STATUS " +
                                     "FROM bookings1 b JOIN users u ON b.USER_EMAIL = u.EMAIL " +
                                     "WHERE b.TRAINER_NAME = ? AND UPPER(b.STATUS) = 'COMPLETE' " +
                                     "ORDER BY b.SESSION_DATE DESC, b.SESSION_TIME DESC";

                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, trainerName);
                        rs = pstmt.executeQuery();

                        while (rs.next()) {
                %>
                    <tr class="completed-row">
                        <td><%= rs.getString("user_name") %></td>
                        <td><%= rs.getDate("SESSION_DATE") %></td>
                        <td><%= rs.getString("SESSION_TIME") %></td>
                        <td><%= rs.getString("USER_EMAIL") %></td>
                        <td><%= rs.getString("STATUS") %></td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='5' style='color:red;'>Error fetching completed bookings: " + e.getMessage() + "</td></tr>");
                    }
                %>
                </tbody>
            </table>

        </div>
        
        <div id="profile" class="tab-content">
            <h2 style="color:#40189e;"><i class="fas fa-user-edit"></i> Trainer Profile View</h2>
            <p>Your profile details are managed by the administrator, except for your password.</p>
            
            
            <div class="profile-image-container">
                <img src="<%= profileImageBase64 %>" alt="Trainer Image" class="profile-image">
                <p style="text-align:center; margin-top:10px; color:#555;">Current Profile Image</p>
            </div>
            
            <hr style="margin: 40px 0;">

            <h3 style="color:#40189e;"><i class="fas fa-eye"></i> Profile Details (Read-Only)</h3>
            
            <div class="profile-form-group">
                <label>Full Name:</label>
                <input type="text" value="<%= profileFullName %>" disabled>
            </div>
            <div class="profile-form-group">
                <label>Email (Read-only):</label>
                <input type="text" value="<%= trainerEmail %>" disabled>
            </div>
            <div class="profile-form-group">
                <label>Phone:</label>
                <input type="text" value="<%= profilePhone %>" disabled>
            </div>
            <div class="profile-form-group">
                <label>Location:</label>
                <input type="text" value="<%= profileLocation %>" disabled>
            </div>
            <div class="profile-form-group">
                <label>Specializations:</label>
                <input type="text" value="<%= profileSpecializations %>" disabled>
            </div>
            <div class="profile-form-group">
                <label>Experience:</label>
                <input type="text" value="<%= profileExperience %>" disabled>
            </div>
            <div class="profile-form-group" style="align-items: flex-start;">
                <label>Bio (CLOB):</label>
                <textarea disabled><%= profileBio %></textarea>
            </div>
            <div class="profile-form-group">
                <label>Certifications:</label>
                <input type="text" value="<%= profileCertifications %>" disabled>
            </div>
            
            <hr style="margin: 40px 0;">

            <h3 style="color:#40189e;"><i class="fas fa-key"></i> Change Password</h3>
            <p>You can securely update your password here.</p>
            <form method="post" action="trainer_dashboards.jsp">
                <input type="hidden" name="action" value="updatePassword">
                <div class="profile-form-group">
                    <label>New Password:</label>
                    <input type="password" name="trainer_password" placeholder="Enter new password" required>
                </div>
                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="save-profile-btn" style="background: #007bff;"><i class="fas fa-lock"></i> Change Password</button>
                </div>
            </form>
        </div>
        <a href="logout.jsp" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="modal-bg" id="changeTimeModalBg">
        <div class="modal">
            <h2>Propose New Booking Time</h2>
            <p style="text-align:left;font-size:0.9em;color:#555;margin-bottom:15px;">This will notify the user of the proposed change. The original time remains until the user accepts the update.</p>
            <form method="post" action="update_booking1.jsp">
                <input type="hidden" name="action" value="changeTimeProposal">
                <input type="hidden" name="booking_id" id="modalBookingId">
                <label for="modalSessionDate">New Date:</label>
                <input type="date" name="new_session_date" id="modalSessionDate" required>
                <label for="modalSessionTime">New Time:</label>
                <input type="time" name="new_session_time" id="modalSessionTime" required>
                <div style="text-align:right;margin-top:20px;">
                    <button type="button" id="closeModalBtn">Cancel</button>
                    <button type="submit" onclick="return confirm('Propose this new time to the user?');"><i class="fas fa-share-square"></i> Propose Change</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    // --- Tab Switching Logic ---
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.tab-button').forEach(button => {
            button.addEventListener('click', (e) => {
                const targetTab = e.target.dataset.tab;

                document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

                e.target.classList.add('active');
                document.getElementById(targetTab).classList.add('active');
            });
        });
        
        // Ensure profile tab activates if a password update message is displayed
        const updateMsg = <%= updateMessage != null ? "true" : "false" %>;
        if (updateMsg) {
             document.querySelector('.tab-button[data-tab="bookings"]').classList.remove('active');
             document.getElementById('bookings').classList.remove('active');
                 
             document.querySelector('.tab-button[data-tab="profile"]').classList.add('active');
             document.getElementById('profile').classList.add('active');
        }
    });

    // --- Modal Logic ---
    document.querySelectorAll('.change').forEach(btn=>{
        btn.addEventListener('click',()=>{
            document.getElementById('changeTimeModalBg').style.display='flex';
            document.getElementById('modalBookingId').value=btn.dataset.bookingId;
            document.getElementById('modalSessionDate').value=btn.dataset.date;
            document.getElementById('modalSessionTime').value=btn.dataset.time;
        });
    });
    document.getElementById('closeModalBtn').onclick=()=>{document.getElementById('changeTimeModalBg').style.display='none';};
    window.onclick=(e)=>{if(e.target===document.getElementById('changeTimeModalBg'))document.getElementById('changeTimeModalBg').style.display='none';};
    </script>
</body>
</html>

<%
    // Final closing of resources
    try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
%>