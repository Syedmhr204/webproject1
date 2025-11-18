<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="dbConnection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>FitLife - Exercise Library</title>
    <link rel="stylesheet" href="style.css"/>
    <script src="https://unpkg.com/@lottiefiles/dotlottie-wc@0.6.2/dist/dotlottie-wc.js" type="module"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-logo">
                <i class="fas fa-heartbeat"></i>
                <span>FitLife</span>
            </div>
           <div class="nav-menu" id="nav-menu">
                <a href="Adminindex.html" class="nav-link" data-section="home">
                    <i class="fas fa-home"></i> Home
                </a>
                <a href="trainer.jsp" class="nav-link" data-section="trainers">
                    <i class="fas fa-users"></i> Trainers
                </a>
                <a href="foodChart.jsp" class="nav-link" data-section="food-chart">
                    <i class="fas fa-apple-alt"></i> Food Chart
                </a>
                <a href="exercises.jsp" class="nav-link" data-section="exercise">
                    <i class="fas fa-dumbbell"></i> Exercise
                </a>
                <a href="profiles.jsp" class="nav-link active" data-section="profile" id="profile-link-nav">
                    <i class="fas fa-user-circle"></i> Profile
                </a>
            </div>
            <div class="nav-toggle" id="nav-toggle">
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
            </div>
        </div>
    </nav>

    <main id="main-content">
        <section id="exercise" class="section">
            <div class="container">
                <div class="section-header">
                    <h1>Exercise Library</h1>
                    <p>Comprehensive exercise database with detailed instructions and targeted muscle groups</p>
                </div>

                <div class="container1">
                <%
                    // Define resources outside the try block
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    if (conn != null) {
                        try {
                            String sql = "SELECT id, name, target, duration, instructions, lottie_url FROM exercises ORDER BY created_at DESC";
                            ps = conn.prepareStatement(sql);
                            rs = ps.executeQuery();
                            
                            while (rs.next()) {
                                // Data extraction
                                // int id = rs.getInt("id"); // ID isn't used for display, but retrieval is fine
                                String name = rs.getString("name");
                                String target = rs.getString("target");
                                String duration = rs.getString("duration");
                                String instructions = rs.getString("instructions");
                                String lottie = rs.getString("lottie_url");
                %>
                    <div class="exercise-card">
                        <div class="lottie-container exercise-image" style="height:200px;">
                            <% if (lottie != null && lottie.trim().length() > 0) { %>
                                <dotlottie-wc src="<%= lottie %>" style="width:100%; height:100%" speed="1" autoplay loop></dotlottie-wc>
                            <% } else { %>
                                <img src="fallback.jpg" alt="<%= name %>"/>
                            <% } %>
                        </div>
                        <h3><%= name %></h3>
                        <p><strong>Target:</strong> <%= target %></p>
                        <p><strong>Time Duration:</strong> <%= duration %></p>
                        <p><strong>How to:</strong> <%= instructions %></p>
                    </div>
                <%
                            } // end while
                        } catch (Exception e) {
                            // CORRECTED: Display user-friendly error and log the stack trace to the server.
                            out.println("<div class='error-message'>Query error: " + e.getMessage() + "</div>");
                            e.printStackTrace(); 
                        } finally {
                            // CORRECTED: Removed extra opening curly brace after 'finally'
                            if (rs != null) try { rs.close(); } catch(Exception ignored) {}
                            if (ps != null) try { ps.close(); } catch(Exception ignored) {}
                            // Close DB connection only if it's not null
                            if (conn != null) try { conn.close(); } catch(Exception ignored) {}
                        }
                    } else {
                        out.println("<div class='error-message'>Database connection unavailable.</div>");
                    }
                %>
                </div>

            </div>
        </section>
    </main>

</body>
</html>