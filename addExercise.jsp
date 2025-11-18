<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="dbConnection.jsp" %>

<%
    // === Step 1: Ensure proper character handling ===
    request.setCharacterEncoding("UTF-8");

    // === Step 2: Read parameters from the form ===
    String name = request.getParameter("name");
    String target = request.getParameter("target");
    String duration = request.getParameter("duration");
    String instructions = request.getParameter("instructions");
    String lottie = request.getParameter("lottie_url");

    boolean formSubmitted = (name != null && !name.trim().isEmpty());
    boolean success = false;
    String errorMsg = "";

    // === Step 3: If form submitted, insert into Oracle ===
    if (formSubmitted) {
        if (conn == null) {
            errorMsg = "Database connection unavailable.";
        } else {
            PreparedStatement ps = null;
            try {
                // Disable autocommit for Oracle (optional safety)
                conn.setAutoCommit(false);

                String sql = "INSERT INTO exercises (name, target, duration, instructions, lottie_url) VALUES (?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, target);
                ps.setString(3, duration);
                ps.setString(4, instructions);
                ps.setString(5, lottie);

                int inserted = ps.executeUpdate();
                if (inserted > 0) {
                    conn.commit();
                    success = true;
                } else {
                    errorMsg = "Insert failed — no rows affected.";
                }

            } catch (SQLException e) {
                errorMsg = e.getMessage();
                try { conn.rollback(); } catch (SQLException ignore) {}
            } finally {
                if (ps != null) try { ps.close(); } catch (Exception ignore) {}
                if (conn != null) try { conn.close(); } catch (Exception ignore) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <title>Add Exercise - FitLife</title>
    <link rel="stylesheet" href="style.css"/>
</head>
<body>
    <div class="container">
        <h1>Add Exercise</h1>

        <%-- Step 4: Output after submission --%>
        <% if (formSubmitted) { %>
            <% if (success) { %>
                <p style="color:green;">✅ Exercise "<%= name %>" added successfully!</p>
                <p><a href="exercises.jsp">Back to Exercise Library</a></p>
            <% } else { %>
                <p style="color:red;">❌ Error: <%= errorMsg %></p>
                <p><a href="addExercise.jsp">Try Again</a></p>
            <% } %>
        <% } else { %>

            <%-- Step 5: Show form if not yet submitted --%>
            <form method="post">
                <label>Exercise Name</label><br/>
                <input type="text" name="name" required maxlength="200"/><br/>

                <label>Target</label><br/>
                <input type="text" name="target" maxlength="255"/><br/>

                <label>Duration</label><br/>
                <input type="text" name="duration" maxlength="100"/><br/>

                <label>Instructions</label><br/>
                <textarea name="instructions" rows="6" cols="60"></textarea><br/>

                <label>Lottie URL</label><br/>
                <input type="url" name="lottie_url" maxlength="400"/><br/><br/>

                <button type="submit">Add Exercise</button>
            </form>
            <p><a href="exercises.jsp">Back to library</a></p>
        <% } %>
    </div>
</body>
</html>
