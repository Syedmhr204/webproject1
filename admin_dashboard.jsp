<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.Base64" %>
<%
    // Ensure all non-breaking spaces are replaced with standard spaces.

    if (session.getAttribute("admin_email") == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmtAction = null;
    Statement stmtUsers = null, stmtTrainers = null, stmtBookings = null, stmtExercises = null, stmtFoods = null ;
    ResultSet rsUsers = null, rsTrainers = null, rsBookings = null, rsExercises = null, rsFoods = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");

        if (request.getParameter("updateUser") != null) {
            String originalEmail = request.getParameter("original_email");
            String newEmail = request.getParameter("email");
            String name = request.getParameter("name");
            String phone = request.getParameter("phone_number");
            phone = phone != null ? phone.replaceAll("[^0-9]", "") : "";

            int age = 0;
            double height = 0, weight = 0, activity = 0, neck = 0, waist = 0, hip = 0;
            try { age = Integer.parseInt(request.getParameter("age")); } catch(Exception e) {}
            try { height = Double.parseDouble(request.getParameter("height_cm")); } catch(Exception e) {}
            try { weight = Double.parseDouble(request.getParameter("weight_kg")); } catch(Exception e) {}
            try { activity = Double.parseDouble(request.getParameter("activity_level")); } catch(Exception e) {}
            try { neck = Double.parseDouble(request.getParameter("neck_cm")); } catch(Exception e) {}
            try { waist = Double.parseDouble(request.getParameter("waist_cm")); } catch(Exception e) {}
            try { hip = Double.parseDouble(request.getParameter("hip_cm")); } catch(Exception e) {}

            String gender = request.getParameter("gender");
            String goal = request.getParameter("fitness_goal");

            pstmtAction = conn.prepareStatement(
                "UPDATE users SET name=?, phone_number=?, age=?, gender=?, height_cm=?, weight_kg=?, activity_level=?, fitness_goal=?, neck_cm=?, waist_cm=?, hip_cm=?, email=? WHERE email=?"
            );
            pstmtAction.setString(1, name);
            pstmtAction.setString(2, phone);
            pstmtAction.setInt(3, age);
            pstmtAction.setString(4, gender);
            pstmtAction.setDouble(5, height);
            pstmtAction.setDouble(6, weight);
            pstmtAction.setDouble(7, activity);
            pstmtAction.setString(8, goal);
            pstmtAction.setDouble(9, neck);
            pstmtAction.setDouble(10, waist);
            pstmtAction.setDouble(11, hip);
            pstmtAction.setString(12, newEmail);
            pstmtAction.setString(13, originalEmail);
            pstmtAction.executeUpdate();
            response.sendRedirect("admin_dashboard.jsp");
        }

        if (request.getParameter("updateTrainer") != null) {
            // Get all trainer fields, including the new ones
            String email = request.getParameter("email");
            String fullName = request.getParameter("full_name");
            String phone = request.getParameter("phone");
            String location = request.getParameter("location");
            String status = request.getParameter("status");
            String specializations = request.getParameter("specializations");
            String experience = request.getParameter("experience");
            String bio = request.getParameter("bio");
            String certifications = request.getParameter("certifications");
            // Assuming SESSION_PRICE is present and needs to be parsed
            double sessionPrice = 0;
            try { sessionPrice = Double.parseDouble(request.getParameter("session_price")); } catch(Exception e) {}


            pstmtAction = conn.prepareStatement(
                // UPDATED SQL to include all trainer fields
                "UPDATE trainer_applications1 SET full_name=?, phone=?, location=?, specializations=?, experience=?, bio=?, certifications=?, APPLICATION_STATUS=?, SESSION_PRICE=? WHERE email=?"
            );
            pstmtAction.setString(1, fullName);
            pstmtAction.setString(2, phone);
            pstmtAction.setString(3, location);
            pstmtAction.setString(4, specializations);
            pstmtAction.setString(5, experience);
            pstmtAction.setString(6, bio);
            pstmtAction.setString(7, certifications);
            pstmtAction.setString(8, status);
            pstmtAction.setDouble(9, sessionPrice);
            pstmtAction.setString(10, email);
            pstmtAction.executeUpdate();
            response.sendRedirect("admin_dashboard.jsp");
        }


        if (request.getParameter("updateBooking") != null) {
            int bookingId = Integer.parseInt(request.getParameter("booking_id"));
            String userEmail = request.getParameter("user_email");
            String trainerName = request.getParameter("trainer_name");
            String sessionDate = request.getParameter("session_date");
            String sessionTime = request.getParameter("session_time");

            pstmtAction = conn.prepareStatement(
                "UPDATE bookings1 SET user_email=?, trainer_name=?, session_date=TO_DATE(?,'YYYY-MM-DD'), session_time=? WHERE booking_id=?"
            );
            pstmtAction.setString(1, userEmail);
            pstmtAction.setString(2, trainerName);
            pstmtAction.setString(3, sessionDate);
            pstmtAction.setString(4, sessionTime);
            pstmtAction.setInt(5, bookingId);
            pstmtAction.executeUpdate();
            response.sendRedirect("admin_dashboard.jsp");
        }

// === Update Existing Exercise ===
if (request.getParameter("updateExercise") != null) {
    // Assuming the hidden field is named 'id'
    int exerciseId = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");
    String target = request.getParameter("target");
    String duration = request.getParameter("duration");
    String instructions = request.getParameter("instructions");
    String lottie = request.getParameter("lottie_url");

    pstmtAction = conn.prepareStatement(
        "UPDATE exercises SET name=?, target=?, duration=?, instructions=?, lottie_url=? WHERE id=?" 
    );
    pstmtAction.setString(1, name);
    pstmtAction.setString(2, target);
    pstmtAction.setString(3, duration);
    pstmtAction.setString(4, instructions);
    pstmtAction.setString(5, lottie);
    pstmtAction.setInt(6, exerciseId);
    pstmtAction.executeUpdate();
    response.sendRedirect("admin_dashboard.jsp");
}

// === Add New Exercise ===
if (request.getParameter("addExercise") != null) {
    String name = request.getParameter("name");
    String target = request.getParameter("target");
    String duration = request.getParameter("duration");
    String instructions = request.getParameter("instructions");
    String lottie = request.getParameter("lottie_url");

    pstmtAction = conn.prepareStatement(
        "INSERT INTO exercises (name, target, duration, instructions, lottie_url) VALUES (?, ?, ?, ?, ?)"
    );
    pstmtAction.setString(1, name);
    pstmtAction.setString(2, target);
    pstmtAction.setString(3, duration);
    pstmtAction.setString(4, instructions);
    pstmtAction.setString(5, lottie);
    pstmtAction.executeUpdate();
    response.sendRedirect("admin_dashboard.jsp");
}

// === Update Food ===
if (request.getParameter("updateFood") != null) {
    int foodId = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");
    String category = request.getParameter("category");
    double calories = Double.parseDouble(request.getParameter("calories"));
    double protein = Double.parseDouble(request.getParameter("protein"));
    double carbs = Double.parseDouble(request.getParameter("carbs"));
    double fat = Double.parseDouble(request.getParameter("fat"));

    pstmtAction = conn.prepareStatement(
        "UPDATE foods SET name=?, category=?, calories=?, protein=?, carbs=?, fat=? WHERE id=?"
    );
    pstmtAction.setString(1, name);
    pstmtAction.setString(2, category);
    pstmtAction.setDouble(3, calories);
    pstmtAction.setDouble(4, protein);
    pstmtAction.setDouble(5, carbs);
    pstmtAction.setDouble(6, fat);
    pstmtAction.setInt(7, foodId);
    pstmtAction.executeUpdate();
    response.sendRedirect("admin_dashboard.jsp");
}

// === Add New Food ===
if (request.getParameter("addFood") != null) {
    String name = request.getParameter("name");
    String category = request.getParameter("category");
    double calories = Double.parseDouble(request.getParameter("calories"));
    double protein = Double.parseDouble(request.getParameter("protein"));
    double carbs = Double.parseDouble(request.getParameter("carbs"));
    double fat = Double.parseDouble(request.getParameter("fat"));

    pstmtAction = conn.prepareStatement(
        "INSERT INTO foods (name, category, calories, protein, carbs, fat) VALUES (?, ?, ?, ?, ?, ?)"
    );
    pstmtAction.setString(1, name);
    pstmtAction.setString(2, category);
    pstmtAction.setDouble(3, calories);
    pstmtAction.setDouble(4, protein);
    pstmtAction.setDouble(5, carbs);
    pstmtAction.setDouble(6, fat);
    pstmtAction.executeUpdate();
    response.sendRedirect("admin_dashboard.jsp");
}


        stmtUsers = conn.createStatement();
        stmtTrainers = conn.createStatement();
        stmtBookings = conn.createStatement();
        stmtExercises = conn.createStatement();
        stmtFoods = conn.createStatement();

        rsUsers = stmtUsers.executeQuery(
            "SELECT name, email, phone_number, age, gender, height_cm, weight_kg, activity_level, fitness_goal, neck_cm, waist_cm, hip_cm FROM users WHERE role != 'ADMIN'"
        );

        // FIX: UPDATED SQL to select IMAGE column for Base64 conversion
        rsTrainers = stmtTrainers.executeQuery(
            "SELECT id, full_name, email, phone, location, specializations, experience, bio, certifications, APPLICATION_STATUS, SESSION_PRICE, IMAGE FROM trainer_applications1"
        );

        rsBookings = stmtBookings.executeQuery(
            "SELECT booking_id, user_email, trainer_name, session_date, session_time FROM bookings1"
        );

        rsExercises = stmtExercises.executeQuery(
            "SELECT id, name, target, duration, instructions, lottie_url FROM exercises"
        );

        rsFoods = stmtFoods.executeQuery(
            "SELECT id, name, category, calories, protein, carbs, fat FROM foods"
        );


%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial; background:#f1f1f1; margin:0; }
        header { background:#efe0e0; padding:15px 20px; display:flex; justify-content:space-between; }
        header h1 { color:black; margin:0; font-family:Cursive; }
        header a { background:linear-gradient(135deg, #667eea, #764ba2); color:white; padding:8px 12px; border-radius:5px; text-decoration:none; }
        .container { padding:20px; max-width:1200px; margin:auto; }
        .cards { display:flex; gap:20px; margin-bottom:20px; }
        .card { flex:1; background:white; border-radius:10px; padding:20px; text-align:center; box-shadow:0 2px 6px rgba(0,0,0,0.1); }
        .tabs { display:flex; gap:10px; margin-bottom:20px; }
        .tabs button { padding:10px 20px; border:none; border-radius:6px; cursor:pointer; background:#3498db; color:white; }
        .tabs button.active { background:#2ecc71; }
        .table-section { display:none; margin-top:20px; }
        table { width:100%; border-collapse:collapse; background:white; border-radius:8px; overflow:hidden; }
        th, td { padding:12px; border-bottom:1px solid #ddd; text-align:left; }
        th { background:#3498db; color:white; }
        tr:nth-child(even) { background:#f9f9f9; }
        input, select { width:100%; padding:6px; box-sizing:border-box; }
        .approve-btn { background:#2ecc71; color:white; border:none; padding:6px 10px; border-radius:5px; cursor:pointer; }
        textarea { width: 100%; box-sizing: border-box; resize: vertical; }
    </style>
</head>
<body>
<header>
    <h1>Admin Dashboard</h1>
    <a href="logout.jsp">Logout</a>
</header>

<div class="container">
    <div class="cards">
        <div class="card"><h2 id="userCount">0</h2><p>Total Users</p></div>
        <div class="card"><h2 id="trainerCount">0</h2><p>Total Trainers</p></div>
        <div class="card"><h2 id="bookingCount">0</h2><p>Total Bookings</p></div>
    </div>

    <canvas id="summaryChart" height="120"></canvas>

    <div class="tabs">
        <button onclick="showSection(event,'users')" class="active">Users</button>
        <button onclick="showSection(event,'trainers')">Trainers</button>
        <button onclick="showSection(event,'bookings1')">Bookings</button>
        <button onclick="showSection(event,'exercises')">Exercises</button>
        <button onclick="showSection(event,'foods')">Foods</button>
    </div>

    <div id="users" class="table-section" style="display:block;">
        <h2>Users</h2>
        <table>
            <tr>
                <th>Name</th><th>Email</th><th>Phone</th><th>Age</th><th>Gender</th>
                <th>Height</th><th>Weight</th><th>Activity</th><th>Goal</th>
                <th>Neck</th><th>Waist</th><th>Hip</th><th>Action</th>
            </tr>
            <% while(rsUsers.next()) { %>
            <tr>
                <form method="post">
                    <td><input type="text" name="name" value="<%= rsUsers.getString("name") %>" disabled></td>
                    <td><%= rsUsers.getString("email") %><input type="hidden" name="email" value="<%= rsUsers.getString("email") %>">
                        <input type="hidden" name="original_email" value="<%= rsUsers.getString("email") %>"></td>
                    <td><input type="text" name="phone_number" value="<%= rsUsers.getString("phone_number") %>" disabled></td>
                    <td><input type="number" name="age" value="<%= rsUsers.getInt("age") %>" disabled min="0"></td>
                    <td>
                        <select name="gender" disabled>
                            <option value="Male" <%= "Male".equals(rsUsers.getString("gender")) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equals(rsUsers.getString("gender")) ? "selected" : "" %>>Female</option>
                        </select>
                    </td>
                    <td><input type="number" step="0.01" name="height_cm" value="<%= rsUsers.getDouble("height_cm") %>" disabled></td>
                    <td><input type="number" step="0.01" name="weight_kg" value="<%= rsUsers.getDouble("weight_kg") %>" disabled></td>
                    <td><input type="number" step="0.01" name="activity_level" value="<%= rsUsers.getDouble("activity_level") %>" disabled></td>
                    <td><input type="text" name="fitness_goal" value="<%= rsUsers.getString("fitness_goal") %>" disabled></td>
                    <td><input type="number" step="0.01" name="neck_cm" value="<%= rsUsers.getDouble("neck_cm") %>" disabled></td>
                    <td><input type="number" step="0.01" name="waist_cm" value="<%= rsUsers.getDouble("waist_cm") %>" disabled></td>
                    <td><input type="number" step="0.01" name="hip_cm" value="<%= rsUsers.getDouble("hip_cm") %>" disabled></td>
                    <td>
                        <button type="button" class="approve-btn editBtn">Edit</button>
                        <button type="submit" name="updateUser" class="approve-btn saveBtn" style="display:none;">Save</button>
                    </td>
                </form>
            </tr>
            <% } %>
        </table>
    </div>

<div id="trainers" class="table-section">
    <h2>Trainers</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Location</th>
            <th>Specializations</th>
            <th>Experience</th>
            <th>Bio</th>
            <th>Certifications</th>
            <th>Price</th>
            <th>Status</th>
            <th>Image</th> 
            <th>Action</th>
        </tr>
        <% 
        while(rsTrainers.next()) { 
            // FIX: Image logic MUST be executed inside the loop before using trainerImagePath
            String trainerImagePath = "default-trainer.jpg";
            try {
                // Ensure the rsTrainers query selects the 'IMAGE' column (Blob)
                Blob trainerImgBlob = rsTrainers.getBlob("IMAGE"); 
                if (trainerImgBlob != null) {
                    byte[] imgBytes = trainerImgBlob.getBytes(1, (int) trainerImgBlob.length());
                    String base64Image = Base64.getEncoder().encodeToString(imgBytes);
                    trainerImagePath = "data:image/jpeg;base64," + base64Image;
                }
            } catch(Exception e) {
                // Handle case where IMAGE column might be null or missing
            }
        %>
        <tr>
            <form method="post">
                <td><%= rsTrainers.getInt("id") %></td>
                <td><input type="text" name="full_name" value="<%= rsTrainers.getString("full_name") %>" disabled></td>
                <td><%= rsTrainers.getString("email") %><input type="hidden" name="email" value="<%= rsTrainers.getString("email") %>"></td>
                <td><input type="text" name="phone" value="<%= rsTrainers.getString("phone") %>" disabled></td>
                <td><input type="text" name="location" value="<%= rsTrainers.getString("location") %>" disabled></td>
                <td><textarea name="specializations" rows="1" disabled><%= rsTrainers.getString("specializations") != null ? rsTrainers.getString("specializations") : "" %></textarea></td>
                <td><input type="text" name="experience" value="<%= rsTrainers.getString("experience") %>" disabled></td>
                <td><textarea name="bio" rows="2" disabled><%= rsTrainers.getString("bio") != null ? rsTrainers.getString("bio") : "" %></textarea></td>
                <td><textarea name="certifications" rows="2" disabled><%= rsTrainers.getString("certifications") != null ? rsTrainers.getString("certifications") : "" %></textarea></td>
                
                <td><input type="number" step="0.01" name="session_price" value="<%= rsTrainers.getDouble("SESSION_PRICE") %>" disabled></td>
                
                <td>
                    <select name="status" disabled>
                        <option value="pending" <%= "pending".equals(rsTrainers.getString("APPLICATION_STATUS")) ? "selected" : "" %>>Pending</option>
                        <option value="accepted" <%= "accepted".equals(rsTrainers.getString("APPLICATION_STATUS")) ? "selected" : "" %>>Accepted</option>
                        <option value="rejected" <%= "rejected".equals(rsTrainers.getString("APPLICATION_STATUS")) ? "selected" : "" %>>Rejected</option>
                    </select>
                </td>
                
                <td><img src="<%= trainerImagePath %>" alt="Trainer Photo" style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%;"/></td>
                
                <td>
                    <button type="button" class="approve-btn editBtn">Edit</button>
                    <button type="submit" name="updateTrainer" class="approve-btn saveBtn" style="display:none;">Save</button>
                </td>
            </form>
        </tr>
        <% } %>
    </table>
</div>

    <div id="bookings1" class="table-section">
        <h2>Bookings</h2>
        <table>
            <tr><th>ID</th><th>User Email</th><th>Trainer</th><th>Date</th><th>Time</th><th>Action</th></tr>
            <% while(rsBookings.next()) { %>
            <tr>
                <form method="post">
                    <td><%= rsBookings.getInt("booking_id") %><input type="hidden" name="booking_id" value="<%= rsBookings.getInt("booking_id") %>"></td>
                    <td><input type="text" name="user_email" value="<%= rsBookings.getString("user_email") %>" disabled></td>
                    <td><input type="text" name="trainer_name" value="<%= rsBookings.getString("trainer_name") %>" disabled></td>
                    <td><input type="date" name="session_date" value="<%= rsBookings.getDate("session_date") %>" disabled></td>
                    <td><input type="time" name="session_time" value="<%= rsBookings.getString("session_time") %>" disabled></td>
                    <td>
                        <button type="button" class="approve-btn editBtn">Edit</button>
                        <button type="submit" name="updateBooking" class="approve-btn saveBtn" style="display:none;">Save</button>
                    </td>
                </form>
            </tr>
            <% } %>
        </table>
    </div>

    <div id="exercises" class="table-section">
    <h2>Exercises</h2>
    <table>
        <tr>
            <th>ID</th><th>Name</th><th>Target</th><th>Duration</th>
            <th>Instructions</th><th>Lottie URL</th><th>Action</th>
        </tr>
        <% while (rsExercises.next()) { %>
        <tr>
            <form method="post">
                <td><%= rsExercises.getInt("id") %>
                    <input type="hidden" name="id" value="<%= rsExercises.getInt("id") %>"> </td>
                <td><input type="text" name="name" value="<%= rsExercises.getString("name") %>" disabled></td>
                <td><input type="text" name="target" value="<%= rsExercises.getString("target") %>" disabled></td>
                <td><input type="text" name="duration" value="<%= rsExercises.getString("duration") %>" disabled></td>
                <td><textarea name="instructions" rows="2" disabled><%= rsExercises.getString("instructions") %></textarea></td>
                <td><input type="text" name="lottie_url" value="<%= rsExercises.getString("lottie_url") %>" disabled></td>
                <td>
                    <button type="button" class="approve-btn editBtn">Edit</button>
                    <button type="submit" name="updateExercise" class="approve-btn saveBtn" style="display:none;">Save</button>
                </td>
            </form>
        </tr>
        <% } %>
    </table>

    <h3 style="margin-top:30px;"> Add New Exercise</h3>
    <form method="post">
        <table>
            <tr>
                <td><input type="text" name="name" placeholder="Exercise Name" required></td>
                <td><input type="text" name="target" placeholder="Target Muscle"></td>
                <td><input type="text" name="duration" placeholder="Duration"></td>
                <td><textarea name="instructions" placeholder="Instructions"></textarea></td>
                <td><input type="text" name="lottie_url" placeholder="Lottie URL"></td>
                <td><button type="submit" name="addExercise" class="approve-btn">Add</button></td>
            </tr>
        </table>
    </form>
</div>

<div id="foods" class="table-section">
    <h2>Foods</h2>
    <table>
        <tr>
            <th>ID</th><th>Name</th><th>Category</th><th>Calories</th>
            <th>Protein</th><th>Carbs</th><th>Fat</th><th>Action</th>
        </tr>
        <% while (rsFoods.next()) { %>
        <tr>
            <form method="post">
                <td><%= rsFoods.getInt("id") %>
                    <input type="hidden" name="id" value="<%= rsFoods.getInt("id") %>"> </td>


                <td><input type="text" name="name" value="<%= rsFoods.getString("name") %>" disabled></td>
                <td><input type="text" name="category" value="<%= rsFoods.getString("category") %>" disabled></td>
                <td><input type="number" step="0.01" name="calories" value="<%= rsFoods.getDouble("calories") %>" disabled></td>
                <td><input type="number" step="0.01" name="protein" value="<%= rsFoods.getDouble("protein") %>" disabled></td>
                <td><input type="number" step="0.01" name="carbs" value="<%= rsFoods.getDouble("carbs") %>" disabled></td>
                <td><input type="number" step="0.01" name="fat" value="<%= rsFoods.getDouble("fat") %>" disabled></td>
                <td>
                    <button type="button" class="approve-btn editBtn">Edit</button>
                    <button type="submit" name="updateFood" class="approve-btn saveBtn" style="display:none;">Save</button>
                </td>
            </form>
        </tr>
        <% } %>
    </table>

    <h3 style="margin-top:30px;">Add New Food</h3>
    <form method="post">
        <table>
            <tr>
                <td><input type="text" name="name" placeholder="Food Name" required></td>
                <td><input type="text" name="category" placeholder="Category" required></td>
                <td><input type="number" step="0.01" name="calories" placeholder="Calories"></td>
                <td><input type="number" step="0.01" name="protein" placeholder="Protein"></td>
                <td><input type="number" step="0.01" name="carbs" placeholder="Carbs"></td>
                <td><input type="number" step="0.01" name="fat" placeholder="Fat"></td>
                <td><button type="submit" name="addFood" class="approve-btn">Add</button></td>
            </tr>
        </table>
    </form>
</div>


</div>

<script>
function showSection(event,id){
    document.querySelectorAll(".table-section").forEach(s=>s.style.display="none");
    document.querySelectorAll(".tabs button").forEach(b=>b.classList.remove("active"));
    document.getElementById(id).style.display="block";
    event.target.classList.add("active");
}

document.querySelectorAll(".editBtn").forEach(btn=>{
    btn.addEventListener("click",()=>{
        let row=btn.closest("tr");
        // Also enable/disable textarea fields
        row.querySelectorAll("input,select,textarea").forEach(i=>i.disabled=false);
        btn.style.display="none";
        row.querySelector(".saveBtn").style.display="inline-block";
    });
});

// Update the counters
document.getElementById("userCount").innerText = document.querySelectorAll("#users table tr").length-1;
document.getElementById("trainerCount").innerText = document.querySelectorAll("#trainers table tr").length-1;
document.getElementById("bookingCount").innerText = document.querySelectorAll("#bookings1 table tr").length-1;
// ADD A DUMMY ELEMENT FOR EXERCISE COUNT CARD (Needed for the chart logic)
const exerciseCount = document.querySelectorAll("#exercises table tr").length - 1;


const ctx=document.getElementById("summaryChart").getContext("2d");
new Chart(ctx,{
    type:"bar",
    data:{
        // FIXED: Added "Exercises" label
        labels:["Users","Trainers","Bookings", "Exercises"],
        datasets:[{
            label:"Summary",
            data:[
                document.getElementById("userCount").innerText,
                document.getElementById("trainerCount").innerText,
                document.getElementById("bookingCount").innerText,
                exerciseCount // FIXED: Added the exercise count variable
            ],
            // Added a fourth color for Exercises
            backgroundColor:["#3498db","#2ecc71","#e67e22", "#9b59b6"]
        }]
    },
    options:{responsive:true,plugins:{legend:{display:false}}}
});
</script>

</body>
</html>

<%
    } catch(Exception e){
        out.println("Error: "+e.getMessage());
    } finally {
        if(rsUsers!=null) try{rsUsers.close();}catch(Exception ignore){}
        if(rsTrainers!=null) try{rsTrainers.close();}catch(Exception ignore){}
        if(rsBookings!=null) try{rsBookings.close();}catch(Exception ignore){}
        if(stmtUsers!=null) try{stmtUsers.close();}catch(Exception ignore){}
        if(stmtTrainers!=null) try{stmtTrainers.close();}catch(Exception ignore){}
        if(stmtBookings!=null) try{stmtBookings.close();}catch(Exception ignore){}

        // Ensure all exercise-related objects are closed properly
        if (rsExercises != null) try { rsExercises.close(); } catch (Exception ignore) {}
        if (stmtExercises != null) try { stmtExercises.close(); } catch (Exception ignore) {}

        // Ensure all food-related objects are closed properly
        if (rsFoods != null) try { rsFoods.close(); } catch (Exception ignore) {}
        if (stmtFoods != null) try { stmtFoods.close(); } catch (Exception ignore) {}

        if(pstmtAction!=null) try{pstmtAction.close();}catch(Exception ignore){}
        if(conn!=null) try{conn.close();}catch(Exception ignore){}

    }
%>