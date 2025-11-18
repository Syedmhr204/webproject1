<%@ page import="java.sql.*" %>
<%@ include file="dbConnection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Nutrition Food Chart - FitLife</title>
  <link rel="stylesheet" href="style.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>

  <!-- ✅ NAVBAR -->
  <nav class="navbar">
    <div class="nav-container">
      <div class="nav-logo">
        <i class="fas fa-heartbeat"></i>
        <span>FitLife</span>
      </div>
      <div class="nav-menu">
        <a href="Adminindex.html" class="nav-link"><i class="fas fa-home"></i> Home</a>
        <a href="trainer.jsp" class="nav-link"><i class="fas fa-users"></i> Trainers</a>
        <a href="foodChart.jsp" class="nav-link active"><i class="fas fa-apple-alt"></i> Food Chart</a>
        <a href="exercises.jsp" class="nav-link"><i class="fas fa-dumbbell"></i> Exercise</a>
        <a href="profiles.jsp" class="nav-link"><i class="fas fa-user-circle"></i> Profile</a>
      </div>
    </div>
  </nav>

  <!-- ✅ MAIN CONTENT -->
  <main id="main-content">
    <section id="food-chart" class="section">
      <div class="container">

        <div class="section-header">
          <h1>Nutrition Food Chart</h1>
          <p>Discover healthy meals and analyze their nutritional values.</p>
        </div>

        <!-- ✅ Search + Category Filters -->
        <div class="food-controls">
          <div class="search-box">
            <input type="text" id="searchInput" placeholder="Search for food...">
          </div>

          <div class="category-filters">
            <button class="category-btn active" data-category="all">All</button>
            <button class="category-btn" data-category="protein">Protein</button>
            <button class="category-btn" data-category="carbs">Carbs</button>
            <button class="category-btn" data-category="fruits">Fruits</button>
            <button class="category-btn" data-category="vegetables">Vegetables</button>
            <button class="category-btn" data-category="fats">Fats</button>
          </div>
        </div>

        <!-- ✅ Add Food Button -->
        <%-- <a href="addFood.jsp" class="primary-btn" style="margin-bottom:20px; display:inline-block;">+ Add Food</a> --%>

        <!-- ✅ Food Grid -->
        <div class="food-grid" id="food-grid">
          <%
            Statement st = null;
            ResultSet rs = null;
            try {
              String sql = "SELECT * FROM foods ORDER BY category";
              st = conn.createStatement();
              rs = st.executeQuery(sql);

              while (rs.next()) {
                String name = rs.getString("name");
                String category = rs.getString("category");
                double calories = rs.getDouble("calories");
                double protein = rs.getDouble("protein");
                double carbs = rs.getDouble("carbs");
                double fat = rs.getDouble("fat");
                double fiber = rs.getDouble("fiber");

                String icon = "utensils";
                String bgColor = "background: #ffffff;";
                if ("protein".equalsIgnoreCase(category)) { }
                else if ("carbs".equalsIgnoreCase(category)) {  }
                else if ("fruits".equalsIgnoreCase(category)) { }
                else if ("vegetables".equalsIgnoreCase(category)) { }
                else if ("fats".equalsIgnoreCase(category)) {  }

          %>

          <div class="food-card" data-category="<%=category.toLowerCase()%>">
            <div class="food-header">
              <div class="food-icon" style="<%=bgColor%>">
                <i class="fas fa-<%=icon%>"></i>
              </div>
              <div>
                <div class="food-name"><%=name%></div>
                <div class="food-category"><%=category%></div>
              </div>
            </div>

            <div class="food-calories">
              <span><strong>Calories:</strong></span>
              <span><%=calories%> kcal</span>
            </div>

            <div class="food-macros">
              <div class="macro protein-macro">
                <div class="macro-value"><%=protein%>g</div>
                <div class="macro-label">Protein</div>
              </div>
              <div class="macro carbs-macro">
                <div class="macro-value"><%=carbs%>g</div>
                <div class="macro-label">Carbs</div>
              </div>
              <div class="macro fat-macro">
                <div class="macro-value"><%=fat%>g</div>
                <div class="macro-label">Fat</div>
              </div>
              <div class="macro fiber-macro">
                <div class="macro-value"><%=fiber%>g</div>
                <div class="macro-label">Fiber</div>
              </div>
            </div>
          </div>

          <% 
              }
            } catch (Exception e) {
              out.println("<p>Error loading data: " + e.getMessage() + "</p>");
            } finally {
              if (rs != null) rs.close();
              if (st != null) st.close();
              if (conn != null) conn.close();
            }
          %>
        </div>
      </div>
    </section>
  </main>

  <!-- ✅ JavaScript for Search & Filter -->
  
  
  <!-- ✅ JavaScript for Search & Filter -->
  <script>
    const searchInput = document.getElementById("searchInput");
    const buttons = document.querySelectorAll(".category-btn");
    const cards = document.querySelectorAll(".food-card");

    // Filter by category
    buttons.forEach(btn => {
      btn.addEventListener("click", () => {
        buttons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");

        const category = btn.dataset.category;
        cards.forEach(card => {
          const match = category === "all" || card.dataset.category === category;
          card.style.display = match ? "block" : "none";
        });
      });
    });

    // Search filter
    searchInput.addEventListener("keyup", () => {
      const query = searchInput.value.toLowerCase();
      cards.forEach(card => {
        const name = card.querySelector(".food-name").textContent.toLowerCase();
        card.style.display = name.includes(query) ? "block" : "none";
      });
    });
  </script>
  

</body>
</html>
