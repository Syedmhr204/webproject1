<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Login | FitLife</title>
         <link rel="stylesheet" href="style.css">    
</head>
<body>

<div class="auth-wrapper">
  <div class="auth-card">
    <h2>Login to FitLife</h2>

 
    <form id="loginForm" action="userlogin.jsp" method="post">
      <input type="email" id="email" name="email" placeholder="Email" required />
      <input type="password" id="password" name="password" placeholder="Password" required />
      <button type="submit">User Login</button>
    </form>

    <form action="trainer_login.jsp" method="post" style="margin-top: 10px;">
      <button type="submit">Trainer Login</button>
    </form>

    <form action="adminlogin.jsp" method="post" style="margin-top: 10px;">
      <button type="submit">Admin Login</button>
    </form>

    <p style="margin-top: 20px;">Don’t have an account? <a href="register.html">Register here</a></p>
  </div>
</div>

</body>
</html>


