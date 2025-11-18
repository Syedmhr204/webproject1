<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trainer Application Status</title>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f7f7f7;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .status-box {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            text-align: center;
        }
        h1 { font-size: 1.5rem; margin-bottom: 1rem; }
        p { margin-bottom: 1.5rem; }
        .success { color: #059669; }
        .error { color: #EF4444; }
        .back-link {
            display: inline-block;
            padding: 0.6rem 1.2rem;
            background-color: #1F2937;
            color: white;
            text-decoration: none;
            border-radius: 0.5rem;
        }
        .back-link:hover { background-color: #4B5563; }
    </style>
</head>
<body>
<div class="status-box">
<%
    Connection conn = null;
    PreparedStatement ps = null;
    String status = "error";
    String message = "Application failed to submit.";

    try {
        // Handle multipart form data
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> items = upload.parseRequest(request);

        // Initialize form variables
        String fullName = "", email = "", phone = "", location = "", specializations = "",
               experience = "", certifications = "", bio = "", password = "", confirmPassword = "", imageName = "";
        InputStream imageData = null;

        for (FileItem item : items) {
            if (item.isFormField()) {
                switch (item.getFieldName()) {
                    case "fullName": fullName = item.getString(); break;
                    case "email": email = item.getString(); break;
                    case "phone": phone = item.getString(); break;
                    case "location": location = item.getString(); break;
                    case "specializations": specializations = item.getString(); break;
                    case "experience": experience = item.getString(); break;
                    case "certifications": certifications = item.getString(); break;
                    case "bio": bio = item.getString(); break;
                    case "password": password = item.getString(); break;
                    case "confirmPassword": confirmPassword = item.getString(); break;
                }
            } else {
                imageName = item.getName();
                imageData = item.getInputStream();
            }
        }

        // Validate passwords
        if (!password.equals(confirmPassword)) {
            throw new Exception("Passwords do not match!");
        }

        // Oracle connection
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");

        // Insert into TRAINER_APPLICATIONS1 (excluding ID, SUBMITTED_AT, SESSION_PRICE)
        String sql = "INSERT INTO TRAINER_APPLICATIONS1 (" +
                     "FULL_NAME, EMAIL, PHONE, LOCATION, SPECIALIZATIONS, EXPERIENCE, BIO, " +
                     "CERTIFICATIONS, TRAINER_PASSWORD, APPLICATION_STATUS, IMAGE, IMAGE_NAME) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        ps = conn.prepareStatement(sql);
        ps.setString(1, fullName);
        ps.setString(2, email);
        ps.setString(3, phone);
        ps.setString(4, location);
        ps.setString(5, specializations);
        ps.setString(6, experience);
        ps.setString(7, bio);
        ps.setString(8, certifications);
        ps.setString(9, password);
        ps.setString(10, "PENDING");
        ps.setBlob(11, imageData);
        ps.setString(12, imageName);

        int rows = ps.executeUpdate();

        if (rows > 0) {
            status = "success";
            message = "🎉 Application submitted successfully! Your application status is now PENDING review.";
        }

    } catch (Exception e) {
        status = "error";
        message = "Error: " + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<h1 class="<%= status %>"><%= status.equals("success") ? "Success!" : "Submission Failed" %></h1>
<p><%= message %></p>
<a href="trainer.jsp" class="back-link">Return to Trainer List</a>
</div>
</body>
</html>
