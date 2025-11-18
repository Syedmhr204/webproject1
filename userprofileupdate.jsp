<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // Ensure the user is logged in
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get form data from the request.
    // Use a null-safe check before trying to use the values.
    String name = request.getParameter("user-name");
    String phone = request.getParameter("user-phone");
    String address = request.getParameter("user-address");
    
    String ageStr = request.getParameter("user-age");
    String gender = request.getParameter("user-gender");
    String heightStr = request.getParameter("user-height");
    String weightStr = request.getParameter("user-weight");
    String activityLevelStr = request.getParameter("user-activity");
    String fitnessGoalValue = request.getParameter("user-goal");
    String neckStr = request.getParameter("user-neck");
    String waistStr = request.getParameter("user-waist");

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","TEST", "test");

        String hipStr = request.getParameter("user-hip");
        Double hip = (hipStr != null && !hipStr.isEmpty()) ? Double.parseDouble(hipStr) : null;

        String sql = "UPDATE users SET name=?, phone_number=?, address=?, age=?, gender=?, height_cm=?, weight_kg=?, activity_level=?, fitness_goal=?, neck_cm=?, waist_cm=?, hip_cm=? WHERE email=?";
        ps = conn.prepareStatement(sql);

        // Set parameters for the SQL query.
        // The ternary operator ( ? : ) safely handles null or empty strings.
        ps.setString(1, name);
        ps.setString(2, phone);
        ps.setString(3, address);
        ps.setObject(4, (ageStr != null && !ageStr.isEmpty()) ? Integer.valueOf(ageStr) : null);
        ps.setString(5, gender);
        ps.setObject(6, (heightStr != null && !heightStr.isEmpty()) ? Double.valueOf(heightStr) : null);
        ps.setObject(7, (weightStr != null && !weightStr.isEmpty()) ? Double.valueOf(weightStr) : null);
        ps.setObject(8, (activityLevelStr != null && !activityLevelStr.isEmpty()) ? Double.valueOf(activityLevelStr) : null);
        
        // Map the numeric goal value to a descriptive string
        String fitnessGoal = "General Health";
        if ("1.6".equals(fitnessGoalValue)) fitnessGoal = "Weight Loss";
        else if ("2.2".equals(fitnessGoalValue)) fitnessGoal = "Muscle Gain";
        else if ("2.0".equals(fitnessGoalValue)) fitnessGoal = "Athletic Performance";
        
        ps.setString(9, fitnessGoal);
        ps.setObject(10, (neckStr != null && !neckStr.isEmpty()) ? Double.valueOf(neckStr) : null);
        ps.setObject(11, (waistStr != null && !waistStr.isEmpty()) ? Double.valueOf(waistStr) : null);
        if (hip != null) ps.setDouble(12, hip); else ps.setNull(12, java.sql.Types.DOUBLE);
        ps.setString(13, email); // WHERE clause uses the session email

        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            // Success: redirect back to the profile page to show the updated data
            response.sendRedirect("profiles.jsp");
        } else {
            out.println("Error: No user found with that email.");
        }
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if(ps != null) try { ps.close(); } catch(SQLException ignore) {}
        if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
    }
%>