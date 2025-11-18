<%@ page import="java.util.*, java.sql.*, java.net.*, java.io.*, org.json.JSONObject, javax.servlet.http.HttpSession, java.io.PrintWriter" %> 
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.DataOutputStream" %>
<%!
    // --- Database Connection Method ---
    // Update with your DB credentials if different from "TEST", "test"
    private Connection getDBConnection() throws Exception {
        // Ensure you have the Oracle JDBC driver in your classpath
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "TEST", "test");
    }
%>
<%
response.setContentType("text/html;charset=UTF-8");

// --- Session and User Check ---
HttpSession userSession = request.getSession(false);
String email = (String) userSession.getAttribute("email");
// Redirect if user is not logged in
if (userSession == null) {
    response.sendRedirect("login.jsp");
    return;
}
if (email == null) {
  response.sendRedirect("login.jsp");
 return;
}

// =========================================================================
//  PART 1: HANDLE NEW BOOKING (POST request -> Redirect to SSLCommerz)
// =========================================================================
if ("POST".equalsIgnoreCase(request.getMethod())) {

    // --- 1. Get Booking Details from Form Post ---
    String trainerName = request.getParameter("trainer_name");
    String trainerId = request.getParameter("trainer_id"); // New: Get Trainer ID
    String sessionPrice = request.getParameter("session_price");
    String sessionDate = request.getParameter("session_date");
    String sessionTime = request.getParameter("session_time");

    // Check for "Missing booking details" (Now includes trainerId check)
    if (sessionPrice == null || sessionDate == null || sessionTime == null || trainerName == null || trainerId == null) {
        out.println("<h3>Missing booking details. Cannot initiate payment.</h3>");
        out.println("<p>Please go back and ensure trainer name, price, date, and time are selected.</p>");
        // Debug: Print out what was missing
        out.println("<p style='font-size: small; color: #666;'>Debug Info: TrainerName=" + trainerName + ", Price=" + sessionPrice + ", Date=" + sessionDate + ", Time=" + sessionTime + ", TrainerID=" + trainerId + "</p>");
        return;
    }
    double totalAmount;
    try {
        totalAmount = Double.parseDouble(sessionPrice);
    } catch (NumberFormatException e) {
        out.println("<h3>Invalid session price format.</h3>");
        return;
    }

    // --- 2. FETCH User Details from YOUR 'USER' table for SSLCommerz ---
    String customerName = null;
    String phone = null;
    String address = null;
    
    // Safe defaults for mandatory SSLCommerz fields
    String city = "Dhaka"; 
    String postcode = "1205";
    String country = "Bangladesh";

    Connection connUser = null;
    PreparedStatement psUser = null;
    ResultSet rsUser = null;
    try {
        connUser = getDBConnection();
        // NOTE: Changed from 'USER' to 'USERS' - ensure this matches your DB schema or change it back if needed.
        String sqlUser = "SELECT NAME, PHONE_NUMBER, ADDRESS FROM USERS WHERE EMAIL = ?";
        psUser = connUser.prepareStatement(sqlUser);
        psUser.setString(1, email);
        rsUser = psUser.executeQuery();

        if (rsUser.next()) {
            customerName = rsUser.getString("NAME");
            phone = rsUser.getString("PHONE_NUMBER");
            address = rsUser.getString("ADDRESS");
        }

    } catch (Exception e) {
        System.err.println("DB Error fetching user details for SSLCommerz: " + e.getMessage());
    } finally {
        if (rsUser != null) try { rsUser.close(); } catch (Exception ignored) {}
        if (psUser != null) try { psUser.close(); } catch (Exception ignored) {}
        if (connUser != null) try { connUser.close(); } catch (Exception ignored) {}
    }

    // --- 3. Final Fallbacks (Prevents the "String.length()" error) ---
    if (customerName == null || customerName.trim().isEmpty()) customerName = "Client Name";
    if (phone == null || phone.trim().isEmpty()) phone = "01700000000";
    if (address == null || address.trim().isEmpty()) address = "N/A Address";


    // --- 4. Save Booking Details to Session (for success return) ---
    userSession.setAttribute("pending_booking_trainer_name", trainerName);
    userSession.setAttribute("pending_booking_trainer_id", trainerId); // Store Trainer ID
    userSession.setAttribute("pending_booking_price", sessionPrice);
    userSession.setAttribute("pending_booking_date", sessionDate);
    userSession.setAttribute("pending_booking_time", sessionTime);


    // --- 5. Prepare and Initiate SSLCommerz Payment ---
    String transactionId = "FIT" + System.currentTimeMillis();
    String productName = "Booking: " + trainerName + " on " + sessionDate;

    // --- ADD: save pending booking so callback can find it by tran_id ---
    Connection connPending = null;
    PreparedStatement psPending = null;
    try {
        connPending = getDBConnection();
        connPending.setAutoCommit(true);

        // NOTE: BOOKINGS table does not have TRAINER_ID in your schema — save TRAINER_NAME only
        String insertPending = "INSERT INTO BOOKINGS1 (USER_EMAIL, TRAINER_NAME, SESSION_DATE, SESSION_TIME, AMOUNT, STATUS, PAYMENT_STATUS, TRANSACTION_ID, BOOKED_AT) " +
                               "VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, 'Pending', 'pending', ?, SYSTIMESTAMP)";
        psPending = connPending.prepareStatement(insertPending);
        psPending.setString(1, email);
        psPending.setString(2, trainerName);
        psPending.setString(3, sessionDate);
        psPending.setString(4, sessionTime);
        psPending.setDouble(5, totalAmount);
        psPending.setString(6, transactionId);

        int inserted = psPending.executeUpdate();
        if (inserted <= 0) {
            log("Pending booking insert returned 0 rows for TRANSACTION_ID=" + transactionId);
            out.println("<h3>Server error: could not create booking record. Payment not initiated.</h3>");
            return; // DO NOT redirect to gateway
        }
        log("Pending booking saved. TRANSACTION_ID=" + transactionId + " rows=" + inserted);
    } catch (Exception ex) {
        // log full stacktrace to server logs for diagnosis
        log("Failed to save pending booking for TRANSACTION_ID=" + transactionId, ex);
        // show minimal debug info in response so you can see DB error (remove in production)
        out.println("<h3>Server error: could not create booking record. Payment not initiated.</h3>");
        out.println("<pre>" + ex.getMessage() + "</pre>");
        return; // DO NOT redirect to gateway
    } finally {
        if (psPending != null) try { psPending.close(); } catch (Exception ignored) {}
        if (connPending != null) try { connPending.close(); } catch (Exception ignored) {}
    }

    // Define callback URLs (build dynamically from the incoming request so casing/port/context are correct)
    String serverBase = request.getScheme() + "://" + request.getServerName()
            + ((request.getServerPort() == 80 || request.getServerPort() == 443) ? "" : ":" + request.getServerPort())
            + request.getContextPath();
    String successUrl = serverBase + "/bookingSuccess.jsp";
    String failUrl = serverBase + "/bookingFail.jsp";
    String cancelUrl = serverBase + "/bookingCancel.jsp";
    log("Callback URLs: success=" + successUrl + " fail=" + failUrl + " cancel=" + cancelUrl);

    try {
        String sslUrl = "https://sandbox.sslcommerz.com/gwprocess/v4/api.php";
        URL url = new URL(sslUrl);
        HttpURLConnection connSSL = (HttpURLConnection) url.openConnection();
        connSSL.setRequestMethod("POST");
        connSSL.setDoOutput(true);

        // Build the POST data string
        String postData = "store_id=ius6892e0cad91c6"
                + "&store_passwd=" + URLEncoder.encode("ius6892e0cad91c6@ssl", "UTF-8")
                + "&total_amount=" + totalAmount
                + "&currency=BDT"
                + "&tran_id=" + transactionId
                // Customer details (now guaranteed non-null)
                + "&cus_name=" + URLEncoder.encode(customerName, "UTF-8")
                + "&cus_email=" + URLEncoder.encode(email, "UTF-8")
                + "&cus_phone=" + URLEncoder.encode(phone, "UTF-8")
                + "&cus_add1=" + URLEncoder.encode(address, "UTF-8")
                + "&cus_city=" + URLEncoder.encode(city, "UTF-8") 
                + "&cus_postcode=" + URLEncoder.encode(postcode, "UTF-8") 
                + "&cus_country=" + URLEncoder.encode(country, "UTF-8") 
                // Product details
                + "&shipping_method=NO"
                + "&product_name=" + URLEncoder.encode(productName, "UTF-8")
                + "&product_category=Service"
                + "&product_profile=non-physical-goods"
                // Return URLs
                + "&success_url=" + URLEncoder.encode(successUrl, "UTF-8")
                + "&fail_url=" + URLEncoder.encode(failUrl, "UTF-8")
                + "&cancel_url=" + URLEncoder.encode(cancelUrl, "UTF-8")
                // Custom fields for redundancy/fallback 
                + "&value_a=" + URLEncoder.encode(trainerName, "UTF-8")
                + "&value_b=" + URLEncoder.encode(sessionDate, "UTF-8")
                + "&value_c=" + URLEncoder.encode(sessionTime, "UTF-8")
                + "&value_d=" + URLEncoder.encode(trainerId, "UTF-8"); // Pass Trainer ID as custom field

        DataOutputStream os = new DataOutputStream(connSSL.getOutputStream());
        os.write(postData.getBytes());
        os.flush();
        os.close();

        BufferedReader br = new BufferedReader(new InputStreamReader(connSSL.getInputStream()));
        String line;
        StringBuilder sb = new StringBuilder();
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();

        JSONObject json = new JSONObject(sb.toString());
        if ("SUCCESS".equalsIgnoreCase(json.getString("status"))) {
            response.sendRedirect(json.getString("GatewayPageURL"));
        } else {
            out.println("<h3>Payment initialization failed:</h3>");
            out.println("<p>" + json.optString("failedreason", "Unknown reason from SSLCommerz") + "</p>");
            out.println("<pre>" + sb.toString() + "</pre>"); // Debug info
        }

    } catch (Exception e) {
        out.println("<h3>Error during payment processing:</h3>");
        out.println("<pre>" + e.getMessage() + "</pre>");
        e.printStackTrace(new PrintWriter(out));
    }

// =========================================================================
//  PART 2: HANDLE PAYMENT SUCCESS (GET request from SSLCommerz -> Save Booking)
// =========================================================================
} else if ("GET".equalsIgnoreCase(request.getMethod())) {

    // (Styling omitted for brevity, focusing on logic)
%>
    <html><body><div class="container">
<%
    String paymentStatus = request.getParameter("status");
    String tranId = request.getParameter("tran_id");
    if (tranId == null || tranId.trim().isEmpty()) {
        out.println("<h1>Missing transaction id.</h1>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = getDBConnection();
        // find the pending booking saved earlier by tran_id
        String fetch = "SELECT USER_EMAIL, TRAINER_ID, TRAINER_NAME, TO_CHAR(SESSION_DATE,'YYYY-MM-DD') AS SDATE, SESSION_TIME, AMOUNT, STATUS " +
                       "FROM BOOKINGS1 WHERE TRANSACTION_ID = ?";
        ps = conn.prepareStatement(fetch);
        ps.setString(1, tranId);
        rs = ps.executeQuery();
        if (rs.next()) {
            String dbStatus = rs.getString("STATUS");
            String dbTrainerName = rs.getString("TRAINER_NAME");
            String dbDate = rs.getString("SDATE");
            String dbTime = rs.getString("SESSION_TIME");
            double dbAmount = rs.getDouble("AMOUNT");

            if (!"Confirmed".equalsIgnoreCase(dbStatus)) {
                // OPTIONAL: verify tran_id with SSLCommerz verify API here

                PreparedStatement upd = conn.prepareStatement("UPDATE BOOKINGS1 SET STATUS='Confirmed' WHERE TRANSACTION_ID = ?");
                upd.setString(1, tranId);
                upd.executeUpdate();
                upd.close();
            }

            out.println("<h1>Booking Confirmed!</h1>");
            out.println("<p>Trainer: " + dbTrainerName + "</p>");
            out.println("<p>Date/Time: " + dbDate + " " + dbTime + "</p>");
            out.println("<p>Amount: " + dbAmount + " | Tran ID: " + tranId + "</p>");

            // after successful update of BOOKINGS status:
            response.sendRedirect("bookingSuccess.jsp?tran_id=" + URLEncoder.encode(tranId,"UTF-8")
                + "&trainer=" + URLEncoder.encode(dbTrainerName,"UTF-8")
                + "&date=" + URLEncoder.encode(dbDate,"UTF-8")
                + "&time=" + URLEncoder.encode(dbTime,"UTF-8")
                + "&amount=" + URLEncoder.encode(String.valueOf(dbAmount),"UTF-8"));
            return;
        } else {
            out.println("<h1>No pending booking found for Tran ID: " + tranId + "</h1>");
            out.println("<p>If you started payment from another device or the session expired, contact support with the transaction id.</p>");
        }
    } catch (Exception e) {
        log("Error finalizing booking for tran_id=" + tranId, e);
        out.println("<h1>Error saving booking. Check server logs.</h1>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
    </div></body></html>
<%
} // End of GET block
%>





<%-- 








<%@ page import="java.util.*, java.sql.*, java.net.*, java.io.*, org.json.JSONObject, jakarta.servlet.http.HttpSession, java.io.PrintWriter" %> 
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.DataOutputStream" %>
<%!
    // --- Database Connection Method ---
    // Update with your DB credentials if different from "TEST", "test"
    private Connection getDBConnection() throws Exception {
        // Ensure you have the Oracle JDBC driver in your classpath
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "kona");
    }
%>
<%
response.setContentType("text/html;charset=UTF-8");

// --- Session and User Check ---
HttpSession userSession = request.getSession(false);
String email = (String) userSession.getAttribute("email");

// Redirect if user is not logged in
if (userSession == null || email == null) {
    response.sendRedirect("login.jsp");
    return;
}

// =========================================================================
//  PART 1: HANDLE NEW BOOKING (POST request -> Redirect to SSLCommerz)
// =========================================================================
if ("POST".equalsIgnoreCase(request.getMethod())) {

    // --- 1. Get Booking Details from Form Post ---
    String trainerName = request.getParameter("trainer_name");
    String trainerId = request.getParameter("trainer_id"); // New: Get Trainer ID
    String sessionPrice = request.getParameter("session_price");
    String sessionDate = request.getParameter("session_date");
    String sessionTime = request.getParameter("session_time");

    // Check for "Missing booking details" (Now includes trainerId check)
    if (sessionPrice == null || sessionDate == null || sessionTime == null || trainerName == null || trainerId == null) {
        out.println("<h3>Missing booking details. Cannot initiate payment.</h3>");
        out.println("<p>Please go back and ensure trainer name, price, date, and time are selected.</p>");
        // Debug: Print out what was missing
        out.println("<p style='font-size: small; color: #666;'>Debug Info: TrainerName=" + trainerName + ", Price=" + sessionPrice + ", Date=" + sessionDate + ", Time=" + sessionTime + ", TrainerID=" + trainerId + "</p>");
        return;
    }
    double totalAmount;
    try {
        totalAmount = Double.parseDouble(sessionPrice);
    } catch (NumberFormatException e) {
        out.println("<h3>Invalid session price format.</h3>");
        return;
    }

    // --- 2. FETCH User Details from YOUR 'USER' table for SSLCommerz ---
    String customerName = null;
    String phone = null;
    String address = null;
    
    // Safe defaults for mandatory SSLCommerz fields
    String city = "Dhaka"; 
    String postcode = "1205";
    String country = "Bangladesh";

    Connection connUser = null;
    PreparedStatement psUser = null;
    ResultSet rsUser = null;
    try {
        connUser = getDBConnection();
        // NOTE: Changed from 'USER' to 'USERS' - ensure this matches your DB schema or change it back if needed.
        String sqlUser = "SELECT NAME, PHONE_NUMBER, ADDRESS FROM USERS WHERE EMAIL = ?";
        psUser = connUser.prepareStatement(sqlUser);
        psUser.setString(1, email);
        rsUser = psUser.executeQuery();

        if (rsUser.next()) {
            customerName = rsUser.getString("NAME");
            phone = rsUser.getString("PHONE_NUMBER");
            address = rsUser.getString("ADDRESS");
        }

    } catch (Exception e) {
        System.err.println("DB Error fetching user details for SSLCommerz: " + e.getMessage());
    } finally {
        if (rsUser != null) try { rsUser.close(); } catch (Exception ignored) {}
        if (psUser != null) try { psUser.close(); } catch (Exception ignored) {}
        if (connUser != null) try { connUser.close(); } catch (Exception ignored) {}
    }

    // --- 3. Final Fallbacks (Prevents the "String.length()" error) ---
    if (customerName == null || customerName.trim().isEmpty()) customerName = "Client Name";
    if (phone == null || phone.trim().isEmpty()) phone = "01700000000";
    if (address == null || address.trim().isEmpty()) address = "N/A Address";


    // --- 4. Save Booking Details to Session (for success return) ---
    userSession.setAttribute("pending_booking_trainer_name", trainerName);
    userSession.setAttribute("pending_booking_trainer_id", trainerId); // Store Trainer ID
    userSession.setAttribute("pending_booking_price", sessionPrice);
    userSession.setAttribute("pending_booking_date", sessionDate);
    userSession.setAttribute("pending_booking_time", sessionTime);


    // --- 5. Prepare and Initiate SSLCommerz Payment ---
    String transactionId = "FIT" + System.currentTimeMillis();
    String productName = "Booking: " + trainerName + " on " + sessionDate;

    // --- ADD: save pending booking so callback can find it by tran_id ---
    Connection connPending = null;
    PreparedStatement psPending = null;
    try {
        connPending = getDBConnection();
        String insertPending = "INSERT INTO BOOKINGS1 (USER_EMAIL, TRAINER_ID, TRAINER_NAME, SESSION_DATE, SESSION_TIME, AMOUNT, STATUS, TRANSACTION_ID) " +
                               "VALUES (?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, 'pending_payment', ?)";
        psPending = connPending.prepareStatement(insertPending);
        psPending.setString(1, email);
        psPending.setInt(2, Integer.parseInt(trainerId));
        psPending.setString(3, trainerName);
        psPending.setString(4, sessionDate);
        psPending.setString(5, sessionTime);
        psPending.setDouble(6, totalAmount);
        psPending.setString(7, transactionId);
        psPending.executeUpdate();
    } catch (Exception ex) {
        log("Failed to save pending booking: " + ex.getMessage(), ex);
        // continue payment initiation (but callback needs this row to finalize)
    } finally {
        if (psPending != null) try { psPending.close(); } catch (Exception ignored) {}
        if (connPending != null) try { connPending.close(); } catch (Exception ignored) {}
    }

    // Define URLs
    String serverUrl = "http://localhost:8080/Fitlife1"; 
    String successUrl = serverUrl + "/bookingSuccess.jsp"; 
    String failUrl = serverUrl + "/bookingFail.jsp";
    String cancelUrl = serverUrl + "/bookingCancel.jsp";

    try {
        String sslUrl = "https://sandbox.sslcommerz.com/gwprocess/v4/api.php";
        URL url = new URL(sslUrl);
        HttpURLConnection connSSL = (HttpURLConnection) url.openConnection();
        connSSL.setRequestMethod("POST");
        connSSL.setDoOutput(true);

        // Build the POST data string
        String postData = "store_id=ius6892e0cad91c6"
                + "&store_passwd=" + URLEncoder.encode("ius6892e0cad91c6@ssl", "UTF-8")
                + "&total_amount=" + totalAmount
                + "&currency=BDT"
                + "&tran_id=" + transactionId
                // Customer details (now guaranteed non-null)
                + "&cus_name=" + URLEncoder.encode(customerName, "UTF-8")
                + "&cus_email=" + URLEncoder.encode(email, "UTF-8")
                + "&cus_phone=" + URLEncoder.encode(phone, "UTF-8")
                + "&cus_add1=" + URLEncoder.encode(address, "UTF-8")
                + "&cus_city=" + URLEncoder.encode(city, "UTF-8") 
                + "&cus_postcode=" + URLEncoder.encode(postcode, "UTF-8") 
                + "&cus_country=" + URLEncoder.encode(country, "UTF-8") 
                // Product details
                + "&shipping_method=NO"
                + "&product_name=" + URLEncoder.encode(productName, "UTF-8")
                + "&product_category=Service"
                + "&product_profile=non-physical-goods"
                // Return URLs
                + "&success_url=" + URLEncoder.encode(successUrl, "UTF-8")
                + "&fail_url=" + URLEncoder.encode(failUrl, "UTF-8")
                + "&cancel_url=" + URLEncoder.encode(cancelUrl, "UTF-8")
                // Custom fields for redundancy/fallback 
                + "&value_a=" + URLEncoder.encode(trainerName, "UTF-8")
                + "&value_b=" + URLEncoder.encode(sessionDate, "UTF-8")
                + "&value_c=" + URLEncoder.encode(sessionTime, "UTF-8")
                + "&value_d=" + URLEncoder.encode(trainerId, "UTF-8"); // Pass Trainer ID as custom field

        DataOutputStream os = new DataOutputStream(connSSL.getOutputStream());
        os.write(postData.getBytes());
        os.flush();
        os.close();

        BufferedReader br = new BufferedReader(new InputStreamReader(connSSL.getInputStream()));
        String line;
        StringBuilder sb = new StringBuilder();
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();

        JSONObject json = new JSONObject(sb.toString());
        if ("SUCCESS".equalsIgnoreCase(json.getString("status"))) {
            response.sendRedirect(json.getString("GatewayPageURL"));
        } else {
            out.println("<h3>Payment initialization failed:</h3>");
            out.println("<p>" + json.optString("failedreason", "Unknown reason from SSLCommerz") + "</p>");
            out.println("<pre>" + sb.toString() + "</pre>"); // Debug info
        }

    } catch (Exception e) {
        out.println("<h3>Error during payment processing:</h3>");
        out.println("<pre>" + e.getMessage() + "</pre>");
        e.printStackTrace(new PrintWriter(out));
    }

// =========================================================================
//  PART 2: HANDLE PAYMENT SUCCESS (GET request from SSLCommerz -> Save Booking)
// =========================================================================
} else if ("GET".equalsIgnoreCase(request.getMethod())) {

    // (Styling omitted for brevity, focusing on logic)
%>
    <html><body><div class="container">
<%
    String paymentStatus = request.getParameter("status");
    String tranId = request.getParameter("tran_id");
    if (tranId == null || tranId.trim().isEmpty()) {
        out.println("<h1>Missing transaction id.</h1>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = getDBConnection();
        // find the pending booking saved earlier by tran_id
        String fetch = "SELECT USER_EMAIL, TRAINER_ID, TRAINER_NAME, TO_CHAR(SESSION_DATE,'YYYY-MM-DD') AS SDATE, SESSION_TIME, AMOUNT, STATUS " +
                       "FROM BOOKINGS1 WHERE TRANSACTION_ID = ?";
        ps = conn.prepareStatement(fetch);
        ps.setString(1, tranId);
        rs = ps.executeQuery();
        if (rs.next()) {
            String dbStatus = rs.getString("STATUS");
            String dbTrainerName = rs.getString("TRAINER_NAME");
            String dbDate = rs.getString("SDATE");
            String dbTime = rs.getString("SESSION_TIME");
            double dbAmount = rs.getDouble("AMOUNT");

            if (!"Confirmed".equalsIgnoreCase(dbStatus)) {
                // OPTIONAL: verify tran_id with SSLCommerz verify API here

                PreparedStatement upd = conn.prepareStatement("UPDATE BOOKINGS1 SET STATUS='Confirmed' WHERE TRANSACTION_ID = ?");
                upd.setString(1, tranId);
                upd.executeUpdate();
                upd.close();
            }

            out.println("<h1>Booking Confirmed!</h1>");
            out.println("<p>Trainer: " + dbTrainerName + "</p>");
            out.println("<p>Date/Time: " + dbDate + " " + dbTime + "</p>");
            out.println("<p>Amount: " + dbAmount + " | Tran ID: " + tranId + "</p>");

            // after successful update of BOOKINGS1 status:
            response.sendRedirect("bookingSuccess.jsp?tran_id=" + URLEncoder.encode(tranId,"UTF-8")
                + "&trainer=" + URLEncoder.encode(dbTrainerName,"UTF-8")
                + "&date=" + URLEncoder.encode(dbDate,"UTF-8")
                + "&time=" + URLEncoder.encode(dbTime,"UTF-8")
                + "&amount=" + URLEncoder.encode(String.valueOf(dbAmount),"UTF-8"));
            return;
        } else {
            out.println("<h1>No pending booking found for Tran ID: " + tranId + "</h1>");
            out.println("<p>If you started payment from another device or the session expired, contact support with the transaction id.</p>");
        }
    } catch (Exception e) {
        log("Error finalizing booking for tran_id=" + tranId, e);
        out.println("<h1>Error saving booking. Check server logs.</h1>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
    </div></body></html>
<%
} // End of GET block
%> --%>