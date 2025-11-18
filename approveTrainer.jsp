<%@ page import="java.sql.*" %>
<%
    
    String tempPassword = "WelcomeTrainer123!"; 
    int appId = Integer.parseInt(request.getParameter("id"));
    Connection conn = null;
    PreparedStatement pstmt1 = null;
    PreparedStatement pstmt2 = null;
    ResultSet rs = null;

    try {
      

        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","TEST", "test");
        stmt = conn.createStatement();
  
        String selectSql = "SELECT full_name, email, specializations, bio, profile_image_path FROM trainer_applications WHERE application_id = ?";
        pstmt1 = conn.prepareStatement(selectSql);
        pstmt1.setInt(1, appId);
        rs = pstmt1.executeQuery();

        if (rs.next()) {
          
            String insertSql = "INSERT INTO trainers (full_name, email, password_hash, specializations, bio, profile_image_path, application_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt2 = conn.prepareStatement(insertSql);
            pstmt2.setString(1, rs.getString("full_name"));
            pstmt2.setString(2, rs.getString("email"));
            pstmt2.setString(3, tempPassword);
            pstmt2.setString(4, rs.getString("specializations"));
            pstmt2.setString(5, rs.getString("bio"));
            pstmt2.setString(6, rs.getString("profile_image_path"));
            pstmt2.setInt(7, appId);
            pstmt2.executeUpdate();

          
            String updateSql = "UPDATE trainer_applications1 SET Application_status = 'ACCEPTED' WHERE application_id = ?";
          
            
            response.sendRedirect("admin_dashboard.jsp");
        }
    } catch (Exception e) {
     
    } finally {
     
    }
%>