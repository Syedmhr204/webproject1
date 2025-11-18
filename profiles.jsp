<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.UnsupportedEncodingException" %>

<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Variables to hold user data
    String userName = "";
    String userPhone = "";
    String userAddress = "";
    Integer userAge = null;
    String userGender = "";
    Double userHeight = null;
    Double userWeight = null;
    Double userActivity = null;
    String userGoal = "";
    Double userNeck = null;
    Double userWaist = null;
    Double userHip = null;
    
    // Calculation variables
    double bmi = 0;
    String bmiValue = "--";
    String bmiCategory = "";
    String calorieValue = "--";
    String proteinValue = "--";
    String bmrValue = "--";
    String bodyFatValue = "--";
    String dietPlanHtml = "";

    // HTML builders
    StringBuilder bookingHtml = new StringBuilder();
    // NEW: Builder for change notifications
    StringBuilder notificationHtml = new StringBuilder();

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");

        // 1. Fetch User Data
        String userSql = "SELECT * FROM users WHERE email = ?";
        ps = conn.prepareStatement(userSql);
        ps.setString(1, email);
        rs = ps.executeQuery();

        if (rs.next()) {
            userName = rs.getString("name") != null ? rs.getString("name") : "";
            userPhone = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
            userAddress = rs.getString("address") != null ? rs.getString("address") : "";
            userAge = rs.getObject("age") != null ? rs.getInt("age") : null;
            userGender = rs.getString("gender") != null ? rs.getString("gender") : "";
            userHeight = rs.getObject("height_cm") != null ? rs.getDouble("height_cm") : null;
            userWeight = rs.getObject("weight_kg") != null ? rs.getDouble("weight_kg") : null;
            userActivity = rs.getObject("activity_level") != null ? rs.getDouble("activity_level") : null;
            userGoal = rs.getString("fitness_goal") != null ? rs.getString("fitness_goal") : "";
            userNeck = rs.getObject("neck_cm") != null ? rs.getDouble("neck_cm") : null;
            userWaist = rs.getObject("waist_cm") != null ? rs.getDouble("waist_cm") : null;
            userHip = rs.getObject("hip_cm") != null ? rs.getDouble("hip_cm") : null;
        }
        rs.close();
        ps.close();

        // 2. Fetch Booking History (including status, and new columns for notification)
        String bookingSql = 
            "SELECT BOOKING_ID, TRAINER_NAME, SESSION_DATE, SESSION_TIME, STATUS, NEW_SESSION_DATE, NEW_SESSION_TIME, USER_ACTION_PENDING " +
            "FROM bookings1 " +
            "WHERE user_email = ? " +
            "ORDER BY session_date DESC, session_time DESC";
        
        ps = conn.prepareStatement(bookingSql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");

        if (!rs.isBeforeFirst()) { 
            bookingHtml.append("<p style='text-align:center; color:#888; margin:24px 0;'>You have no past or upcoming bookings1.</p>");
        } else {
            bookingHtml.append("<div class='booking-list-container' style='overflow-x:auto; margin-top:16px;'><table class='styled-booking-table' style='width:100%; border-collapse:collapse; background:#fff; border-radius:12px; box-shadow:0 2px 12px rgba(0,0,0,0.07);'><thead><tr style='background:linear-gradient(90deg,#667eea 0%,#764ba2 100%); color:#fff;'><th style='padding:14px 18px; text-align:left;'>Trainer</th><th style='padding:14px 18px; text-align:left;'>Date</th><th style='padding:14px 18px; text-align:left;'>Time</th><th style='padding:14px 18px; text-align:left;'>Status</th></tr></thead><tbody>");
            
            while (rs.next()) {
                int bookingId = rs.getInt("BOOKING_ID");
                String trainerName = rs.getString("trainer_name");
                String sessionDate = rs.getDate("session_date") != null ? dateFormatter.format(rs.getDate("session_date")) : "--";
                String sessionTime = rs.getString("session_time");
                String status = rs.getString("STATUS");
                String userActionPending = rs.getString("USER_ACTION_PENDING");

                // Check for pending changes for the notification pop-up
                if ("Y".equalsIgnoreCase(userActionPending)) {
                    String oldDate = sessionDate;
                    String oldTime = sessionTime;
                    String newDate = rs.getDate("NEW_SESSION_DATE") != null ? dateFormatter.format(rs.getDate("NEW_SESSION_DATE")) : "N/A";
                    String newTime = rs.getString("NEW_SESSION_TIME");
                    
                    // Build HTML for the notification card
                    notificationHtml.append("<div class='notification-card' data-booking-id='").append(bookingId).append("'>");
                    notificationHtml.append("<h4><i class='fas fa-exclamation-circle'></i> Proposed Change by Trainer ").append(trainerName).append("</h4>");
                    notificationHtml.append("<p>The trainer suggests moving your session from <b>").append(oldDate).append(" at ").append(oldTime).append("</b> to <b>").append(newDate).append(" at ").append(newTime).append("</b>.</p>");
                    
                    // Forms for Accept/Reject - These will hit a new handler JSP (e.g., handle_user_action.jsp)
                    String encodedTrainerName = URLEncoder.encode(trainerName, "UTF-8");
                    
                    notificationHtml.append("<div class='action-buttons-group'>");
                    
                    // Accept Button
                    notificationHtml.append("<form method='post' action='update_booking1.jsp' style='display:inline;'>");
                    notificationHtml.append("<input type='hidden' name='booking_id' value='").append(bookingId).append("'>");
                    notificationHtml.append("<input type='hidden' name='action' value='accept'>");
                    notificationHtml.append("<button type='submit' class='action-btn accept-btn' onclick='return confirm(\"Accept the new time of ").append(newDate).append(" at ").append(newTime).append("?\");'><i class='fas fa-check'></i> Accept Change</button>");
                    notificationHtml.append("</form>");
                    
                    // Reject Button
                    notificationHtml.append("<form method='post' action='update_booking1.jsp' style='display:inline;'>");
                    notificationHtml.append("<input type='hidden' name='booking_id' value='").append(bookingId).append("'>");
                    notificationHtml.append("<input type='hidden' name='action' value='reject'>");
                    notificationHtml.append("<button type='submit' class='action-btn reject-btn' onclick='return confirm(\"Reject this change? Your original time will remain.\");'><i class='fas fa-times'></i> Reject Change</button>");
                    notificationHtml.append("</form>");
                    
                    notificationHtml.append("</div>");
                    notificationHtml.append("</div>");
                    
                    // Update status for the table display
                    status = "<span style='color:orange; font-weight:bold;'>Pending User Action</span>";
                }


                bookingHtml.append("<tr style='border-bottom:1px solid #e5e7eb;'>");
                bookingHtml.append("<td style='padding:12px 18px; font-weight:500; color:#3730a3;'>").append(trainerName).append("</td>");
                bookingHtml.append("<td style='padding:12px 18px; color:#374151;'>").append(sessionDate).append("</td>");
                bookingHtml.append("<td style='padding:12px 18px; color:#059669; font-weight:500;'>").append(sessionTime).append("</td>");
                bookingHtml.append("<td style='padding:12px 18px; font-weight:600;'>").append(status).append("</td>");
                bookingHtml.append("</tr>");
            }
            bookingHtml.append("</tbody></table></div>");
        }
        
    } catch(Exception e) {
        System.err.println("Database Error: " + e.getMessage());
        bookingHtml = new StringBuilder("<p>Could not load your booking history due to a database error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // --- Calorie, BMI, BMR, Diet Plan Calculation Logic (Kept Original) ---
    // ... (Your original calculation logic here) ...
    if (userHeight != null && userWeight != null && userHeight > 0 && userAge != null && userGender != null && userActivity != null) {
        
        double heightM = userHeight / 100.0;
        bmi = userWeight / (heightM * heightM);
        bmiValue = String.format("%.1f", bmi);
        if (bmi < 18.5) bmiCategory = "Underweight";
        else if (bmi < 25) bmiCategory = "Normal";
        else if (bmi < 30) bmiCategory = "Overweight";
        else bmiCategory = "Obese";

        double bmr = 0;
        if ("male".equalsIgnoreCase(userGender)) {
            bmr = 10 * userWeight + 6.25 * userHeight - 5 * userAge + 5;
        } else if ("female".equalsIgnoreCase(userGender)) {
            bmr = 10 * userWeight + 6.25 * userHeight - 5 * userAge - 161;
        }
        bmrValue = String.format("%.0f", bmr);
        
        double calories = bmr * userActivity;
        if ("Weight Loss".equalsIgnoreCase(userGoal)) calories -= 500;
        if ("Muscle Gain".equalsIgnoreCase(userGoal)) calories += 300;
        calorieValue = String.format("%.0f", calories);
        
        double multiplier = 1.2;
        if ("Weight Loss".equalsIgnoreCase(userGoal)) multiplier = 1.6;
        else if ("Muscle Gain".equalsIgnoreCase(userGoal)) multiplier = 2.2;
        else if ("Athletic Performance".equalsIgnoreCase(userGoal)) multiplier = 2.0;
        double protein = userWeight * multiplier;
        proteinValue = String.format("%.0f g", protein);
        
        if (userNeck != null && userWaist != null) {
            if ("male".equalsIgnoreCase(userGender)) {
                double bodyFat = 495 / (1.0324 - 0.19077 * Math.log10(userWaist - userNeck) + 0.15456 * Math.log10(userHeight)) - 450;
                bodyFatValue = String.format("%.1f%%", bodyFat);
            } else if ("female".equalsIgnoreCase(userGender) && userHip != null) {
                double bodyFat = 495 / (1.29579 - 0.35004 * Math.log10(userWaist + userHip - userNeck) + 0.22100 * Math.log10(userHeight)) - 450;
                bodyFatValue = String.format("%.1f%%", bodyFat);
            } else {
                bodyFatValue = "--";
            }
        } else {
            bodyFatValue = "--";
        }

        Random rand = new Random();
        
        List<String> lowCalBreakfast = Arrays.asList("Oatmeal with berries.", "Scrambled eggs with spinach.", "A fruit smoothie.");
        List<String> lowCalLunch = Arrays.asList("Grilled chicken salad.", "Lentil soup with whole-grain bread.", "A turkey sandwich on whole-wheat bread.");
        List<String> lowCalDinner = Arrays.asList("Baked cod with steamed vegetables.", "Chicken stir-fry with a variety of vegetables.", "Quinoa bowl with chickpeas and roasted veggies.");
        List<String> lowCalSnack = Arrays.asList("An apple or pear.", "A handful of carrots.", "A small serving of Greek yogurt.");

        List<String> highProteinBreakfast = Arrays.asList("Three whole eggs with two slices of whole-wheat bread.", "Protein shake with oats and a banana.", "Greek yogurt with nuts and a scoop of whey protein.");
        List<String> highProteinLunch = Arrays.asList("Large serving of brown rice with ground turkey and black beans.", "Chicken and vegetable stir-fry with brown rice.", "Tuna salad sandwich on whole-wheat bread.");
        List<String> highProteinDinner = Arrays.asList("Steak with sweet potato and roasted broccoli.", "Salmon fillet with quinoa and steamed asparagus.", "Lean pork chops with a large salad.");
        List<String> highProteinSnack = Arrays.asList("A protein bar or a serving of Greek yogurt.", "A handful of almonds.", "Cottage cheese with pineapple.");

        List<String> balancedBreakfast = Arrays.asList("A bowl of oatmeal with a variety of seeds and nuts.", "Scrambled eggs with a side of fruit.", "A balanced smoothie with spinach, banana, and protein powder.");
        List<String> balancedLunch = Arrays.asList("Quinoa bowl with chickpeas, mixed vegetables, and a light dressing.", "A well-balanced plate with a lean protein and vegetables.", "Leftover stir-fry from dinner.");
        List<String> balancedDinner = Arrays.asList("Grilled chicken or fish with a side of mixed vegetables and a complex carb.", "A large salad with a variety of greens, protein, and a healthy fat source.", "Baked salmon with roasted asparagus and a sweet potato.");
        List<String> balancedSnack = Arrays.asList("A piece of fruit or a small handful of nuts.", "A small container of Greek yogurt.", "A small serving of cottage cheese.");

        List<String> breakfastList = null;
        List<String> lunchList = null;
        List<String> dinnerList = null;
        List<String> snackList = null;

        if (bmi >= 25 && "Weight Loss".equalsIgnoreCase(userGoal)) {
            breakfastList = lowCalBreakfast;
            lunchList = lowCalLunch;
            dinnerList = lowCalDinner;
            snackList = lowCalSnack;
        } else if (bmi < 25 && "Muscle Gain".equalsIgnoreCase(userGoal)) {
            breakfastList = highProteinBreakfast;
            lunchList = highProteinLunch;
            dinnerList = highProteinDinner;
            snackList = highProteinSnack;
        } else {
            breakfastList = balancedBreakfast;
            lunchList = balancedLunch;
            dinnerList = balancedDinner;
            snackList = balancedSnack;
        }

        if (breakfastList != null) {
            dietPlanHtml = "<p>Your plan includes 3 main meals and 1 snack per day. This is a sample plan based on your goals.</p>" +
                             "<div class='diet-plan-content'>" +
                             "<div class='meal-item'><h4>Breakfast</h4><p>" + breakfastList.get(rand.nextInt(breakfastList.size())) + "</p></div>" +
                             "<div class='meal-item'><h4>Lunch</h4><p>" + lunchList.get(rand.nextInt(lunchList.size())) + "</p></div>" +
                             "<div class='meal-item'><h4>Dinner</h4><p>" + dinnerList.get(rand.nextInt(dinnerList.size())) + "</p></div>" +
                             "<div class='meal-item'><h4>Snack</h4><p>" + snackList.get(rand.nextInt(snackList.size())) + "</p></div>" +
                             "</div>";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitLife - User Profile</title>
    <link rel="stylesheet" href="style.css"> 
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <style>
        /* ADDED STYLES FOR POP-UP MODAL AND NOTIFICATIONS */
        .modal-bg { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(0, 0, 0, 0.4); display: flex; align-items: center; 
            justify-content: center; z-index: 2000; 
        }
        .modal {
            background: #fff; padding: 30px; border-radius: 12px; 
            max-width: 500px; width: 90%; box-shadow: 0 8px 25px rgba(0,0,0,0.3);
            animation: fadeIn 0.3s ease-out;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
        .notification-card {
            border: 1px solid #f97316; /* Orange border for warning */
            background: #fff7ed; /* Light orange background */
            padding: 15px; margin-bottom: 15px; border-radius: 8px;
        }
        .notification-card h4 {
            color: #ea580c; margin-top: 0; font-size: 1.1em;
        }
        .action-buttons-group {
            margin-top: 15px; text-align: right;
        }
        .action-btn {
            border: none; padding: 8px 15px; border-radius: 6px; cursor: pointer; 
            margin-left: 8px; font-weight: 500; transition: background-color 0.2s;
        }
        .accept-btn { background: #10b981; color: #fff; }
        .accept-btn:hover { background: #059669; }
        .reject-btn { background: #ef4444; color: #fff; }
        .reject-btn:hover { background: #dc2626; }
        #closeNotificationModal {
            background: #6b7280; color: #fff; border: none; padding: 10px 20px; 
            border-radius: 6px; cursor: pointer; float: right;
        }
        .styled-booking-table th:last-child {
            width: 15%; /* Ensure status column is visible */
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-logo">
                <i class="fas fa-heartbeat"></i>
                <span>FitLife</span>
            </div>
            <div class="nav-menu" id="nav-menu">
                <a href="Adminindex.html" class="nav-link" data-section="home"> <i class="fas fa-home"></i> Home </a>
                <a href="trainer.jsp" class="nav-link" data-section="trainers"> <i class="fas fa-users"></i> Trainers </a>
                <a href="foodChart.jsp" class="nav-link" data-section="food-chart"> <i class="fas fa-apple-alt"></i> Food Chart </a>
                <a href="exercises.jsp" class="nav-link" data-section="exercise"> <i class="fas fa-dumbbell"></i> Exercise </a>
                <a href="profiles.jsp" class="nav-link active" data-section="profile" id="profile-link-nav"> <i class="fas fa-user-circle"></i> Profile </a>
                <a href="logout.jsp" class="nav-link" data-section="logout"> <i class="fas fa-sign-out-alt"></i> Logout </a>
            </div>
            <div class="nav-toggle" id="nav-toggle">
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
            </div>
        </div>
    </nav>

    <div class="profile-sidebar" id="profile-sidebar">
        <div class="sidebar-header">
            <h3>My Details</h3>
            <button id="close-sidebar-btn" class="close-btn"><i class="fas fa-times"></i></button>
        </div>
        <form action="userprofileupdate.jsp" method="post" class="calculator-form">
            <div class="input-row">
                <div class="input-group">
                    <label>Full Name</label>
                    <input type="text" id="user-name" name="user-name" placeholder="Enter your full name" value="<%= userName %>">
                </div>
                <div class="input-group">
                    <label>Email</label>
                    <input type="email" id="user-email" name="user-email" placeholder="user@example.com" value="<%= email %>" readonly>
                </div>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label>Phone Number</label>
                    <input type="tel" id="user-phone" name="user-phone" placeholder="Enter your phone number" value="<%= userPhone %>">
                </div>
                <div class="input-group">
                    <label>Address</label>
                    <input type="text" id="user-address" name="user-address" placeholder="Enter your address" value="<%= userAddress %>">
                </div>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label>Age (years)</label>
                    <input type="number" id="user-age" name="user-age" placeholder="Enter age" value="<%= userAge != null ? userAge : "" %>">
                </div>
                <div class="input-group">
                    <label>Gender</label>
                    <select id="user-gender" name="user-gender">
                        <option value="male" <%= "male".equalsIgnoreCase(userGender) ? "selected" : "" %>>Male</option>
                        <option value="female" <%= "female".equalsIgnoreCase(userGender) ? "selected" : "" %>>Female</option>
                    </select>
                </div>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label>Height (cm)</label>
                    <input type="number" id="user-height" name="user-height" placeholder="Enter height" value="<%= userHeight != null ? userHeight : "" %>">
                </div>
                <div class="input-group">
                    <label>Weight (kg)</label>
                    <input type="number" id="user-weight" name="user-weight" placeholder="Enter weight" value="<%= userWeight != null ? userWeight : "" %>">
                </div>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label>Activity Level</label>
                    <select id="user-activity" name="user-activity">
                        <option value="1.2" <%= userActivity != null && userActivity.toString().equals("1.2") ? "selected" : "" %>>Sedentary (little/no exercise)</option>
                        <option value="1.375" <%= userActivity != null && userActivity.toString().equals("1.375") ? "selected" : "" %>>Light activity (light exercise 1-3 days/week)</option>
                        <option value="1.55" <%= userActivity != null && userActivity.toString().equals("1.55") ? "selected" : "" %>>Moderate activity (moderate exercise 3-5 days/week)</option>
                        <option value="1.725" <%= userActivity != null && userActivity.toString().equals("1.725") ? "selected" : "" %>>Very active (hard exercise 6-7 days/week)</option>
                        <option value="1.9" <%= userActivity != null && userActivity.toString().equals("1.9") ? "selected" : "" %>>Extremely active (very hard exercise, physical job)</option>
                    </select>
                </div>
                <div class="input-group">
                    <label>Fitness Goal</label>
                    <select id="user-goal" name="user-goal">
                        <option value="General Health" <%= userGoal != null && userGoal.equalsIgnoreCase("General Health") ? "selected" : "" %>>General Health</option>
                        <option value="Weight Loss" <%= userGoal != null && userGoal.equalsIgnoreCase("Weight Loss") ? "selected" : "" %>>Weight Loss</option>
                        <option value="Muscle Gain" <%= userGoal != null && userGoal.equalsIgnoreCase("Muscle Gain") ? "selected" : "" %>>Muscle Gain</option>
                        <option value="Athletic Performance" <%= userGoal != null && userGoal.equalsIgnoreCase("Athletic Performance") ? "selected" : "" %>>Athletic Performance</option>
                    </select>
                </div>
            </div>
            <div class="input-row">
                <div class="input-group">
                    <label>Neck circumference (cm)</label>
                    <input type="number" id="user-neck" name="user-neck" placeholder="Enter neck circumference" value="<%= userNeck != null ? userNeck : "" %>">
                </div>
                <div class="input-group">
                    <label>Waist circumference (cm)</label>
                    <input type="number" id="user-waist" name="user-waist" placeholder="Enter waist circumference" value="<%= userWaist != null ? userWaist : "" %>">
                </div>
                <div class="input-group">
                    <label>Hip circumference (cm)</label>
                    <input type="number" id="user-hip" name="user-hip" placeholder="Enter hip circumference" value="<%= userHip != null ? userHip : "" %>">
                </div>
            </div>
            <button type="submit" class="primary-btn">Update & Calculate</button>
        </form>
    </div>
    
    <main class="profile-page" id="profile-main-content">
        <div class="container">
           <div class="section-header">
    <h1>My Health Dashboard</h1>
    <p>View your personalized health metrics and update your details anytime.</p>
    <div style="display: flex; gap: 12px; flex-wrap: wrap; justify-content: center; align-items: center; margin-top: 24px; margin-bottom: 24px;">
        <button id="open-sidebar-btn" class="primary-btn toggle-btn"><i class="fas fa-edit"></i> Update My Details</button>
        <button id="booking-history-btn" class="primary-btn" type="button"><i class="fas fa-calendar-alt"></i> Your Booking History</button>
    </div>
</div>
            
            <div class="profile-info-section calculator-card">
                <div class="calculator-header">
                    <div class="calculator-icon"><i class="fas fa-user-edit"></i></div>
                    <h3>Current Profile Information</h3>
                </div>
                <div class="profile-info-grid" id="profile-info-grid">
                    <div class="info-item"><label>Name:</label><span id="display-name"><%= userName.isEmpty() ? "--" : userName %></span></div>
                    <div class="info-item"><label>Email:</label><span id="display-email"><%= email %></span></div>
                    <div class="info-item"><label>Phone:</label><span id="display-phone"><%= userPhone.isEmpty() ? "--" : userPhone %></span></div>
                    <div class="info-item"><label>Address:</label><span id="display-address"><%= userAddress.isEmpty() ? "--" : userAddress %></span></div>
                    <div class="info-item"><label>Age:</label><span id="display-age"><%= userAge != null ? userAge : "--" %></span></div>
                    <div class="info-item"><label>Gender:</label><span id="display-gender"><%= userGender.isEmpty() ? "--" : userGender %></span></div>
                    <div class="info-item"><label>Height:</label><span id="display-height"><%= userHeight != null ? userHeight + " cm" : "-- cm" %></span></div>
                    <div class="info-item"><label>Weight:</label><span id="display-weight"><%= userWeight != null ? userWeight + " kg" : "-- kg" %></span></div>
                    <div class="info-item"><label>Activity Level:</label><span id="display-activity"><%= userActivity != null ? userActivity : "--" %></span></div>
                    <div class="info-item"><label>Fitness Goal:</label><span id="display-goal"><%= userGoal.isEmpty() ? "--" : userGoal %></span></div>
                    <div class="info-item"><label>Neck:</label><span id="display-neck"><%= userNeck != null ? userNeck + " cm" : "-- cm" %></span></div>
                    <div class="info-item"><label>Waist:</label><span id="display-waist"><%= userWaist != null ? userWaist + " cm" : "-- cm" %></span></div>
                    <div class="info-item"><label>Hip:</label><span id="display-hip"><%= userHip != null ? userHip + " cm" : "-- cm" %></span></div>
                </div>
            </div>

            <div class="calculators-grid profile-grid results-grid">
                <div class="calculator-card profile-card" id="bmi-card">
                    <div class="calculator-header"><h3>BMI</h3></div>
                    <div class="calculator-result"><div class="result-value"><%= bmiValue %></div><div class="result-category"><%= bmiCategory %></div></div>
                </div>
                <div class="calculator-card profile-card" id="calorie-card">
                    <div class="calculator-header"><h3>Daily Calories</h3></div>
                    <div class="calculator-result"><div class="result-value"><%= calorieValue %></div><div class="result-category">Calories per day</div></div>
                </div>
                <div class="calculator-card profile-card" id="protein-card">
                    <div class="calculator-header"><h3>Daily Protein</h3></div>
                    <div class="calculator-result"><div class="result-value"><%= proteinValue %></div><div class="result-category">Protein per day</div></div>
                </div>
                <div class="calculator-card profile-card" id="bmr-card">
                    <div class="calculator-header"><h3>BMR</h3></div>
                    <div class="calculator-result"><div class="result-value"><%= bmrValue %></div><div class="result-category">Basal Metabolic Rate</div></div>
                </div>
                <div class="calculator-card profile-card" id="bodyfat-card">
                    <div class="calculator-header"><h3>Body Fat %</h3></div>
                    <div class="calculator-result"><div class="result-value"><%= bodyFatValue %></div><div class="result-category">Body Fat Percentage</div></div>
                </div>
            </div>
            
            <div class="diet-plan-card">
                <div class="calculator-header">
                    <div class="calculator-icon"><i class="fas fa-apple-alt"></i></div>
                    <h3>Your Personalized Diet Plan</h3>
                </div>
                <%
                    if (!dietPlanHtml.isEmpty()) {
                %>
                <p>Based on your daily Protein required of <b><%= proteinValue %></b>, here is a sample diet plan to help you get started.</p>
                <%= dietPlanHtml %>
                <%
                    } else {
                %>
                <p>Please fill out all your profile details (age, gender, height, weight, activity level, and fitness goal) and click "Update & Calculate" to view your personalized diet plan.</p>
                <%
                    }
                %>
            </div>
            
            <div class="booking-card" id="booking-history-section">
                <div class="calculator-header">
                    <div class="calculator-icon"><i class="fas fa-calendar-alt"></i></div>
                    <h3>Your Booking History</h3>
                </div>
                <%= bookingHtml.toString() %>
            </div>
        </div>
    </main>
    
    <div class="sidebar-overlay" id="sidebar-overlay"></div>

    <div class="modal-bg" id="notificationModalBg" style="display: none;">
        <div class="modal">
            <h2 style="color:#40189e;"><i class="fas fa-calendar-times"></i> **Urgent Booking Updates!**</h2>
            <p>One or more of your trainers has proposed a change to a session time. Please review and respond.</p>
            <div id="notifications-content" style="max-height: 40vh; overflow-y: auto; padding-right: 10px;">
                <%= notificationHtml.toString() %>
            </div>
            <div style="text-align:right;margin-top:20px;">
                <button type="button" id="closeNotificationModal">Close</button>
            </div>
        </div>
    </div>
    
    <script src="profile.js"></script>
    <script>
        // Check if there are notifications and display the modal on load
        const notificationsContent = document.getElementById('notifications-content');
        if (notificationsContent.children.length > 0) {
            document.getElementById('notificationModalBg').style.display = 'flex';
        }

        // Close button for the modal
        document.getElementById('closeNotificationModal').onclick = () => {
            document.getElementById('notificationModalBg').style.display = 'none';
        };

        // Close modal when clicking outside (on the background)
        const modalBg = document.getElementById('notificationModalBg');
        modalBg.onclick = (e) => {
            if (e.target === modalBg) {
                modalBg.style.display = 'none';
            }
        };
        
        // You'll still need to create 'handle_user_action.jsp' to process the form submissions

        // --- Added: Booking history button behavior (scroll + temporary highlight) ---
        (function() {
            const bookingBtn = document.getElementById('booking-history-btn');
            const bookingSection = document.getElementById('booking-history-section');
            if (!bookingBtn || !bookingSection) return;

            bookingBtn.addEventListener('click', function () {
                // Ensure booking section is visible
                if (bookingSection.style.display === 'none') bookingSection.style.display = '';

                // Smooth scroll into view
                bookingSection.scrollIntoView({ behavior: 'smooth', block: 'start' });

                // Add temporary highlight to draw attention
                bookingSection.classList.add('highlight');
                // Remove highlight after 2.5s
                setTimeout(() => bookingSection.classList.remove('highlight'), 2500);

                // For keyboard users, move focus for accessibility
                bookingSection.setAttribute('tabindex', '-1');
                bookingSection.focus({ preventScroll: true });
                setTimeout(() => bookingSection.removeAttribute('tabindex'), 1000);
            });
        })();
    </script>
</body>
</html>