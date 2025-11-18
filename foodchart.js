// Navigation functionality
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    const navLinks = document.querySelectorAll('.nav-link');
    const sections = document.querySelectorAll('.section');

    // Mobile menu toggle
    navToggle.addEventListener('click', function() {
        navMenu.classList.toggle('active');
    });

 
    loadSectionContent('food-chart');
});


    
//     // Load initial content........
    loadSectionContent('food-chart');


    function loadSectionContent(section) {
    switch (section) {
        case 'trainers':
            loadTrainers();
            break;
        case 'food-chart':
            loadFoodChart();
            break;
        case 'shop':
            loadShop();
            break;
        case 'exercise':
            loadExercises();
            break;
    }
}

// Food chart data and functionality
function loadFoodChart() {
    const foods = [
        // Proteins
        { name: "Chicken Breast", category: 'protein', calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0 },
        { name: "Salmon", category: 'protein', calories: 208, protein: 22, carbs: 0, fat: 12, fiber: 0 },
        { name: "Greek Yogurt", category: 'protein', calories: 100, protein: 17, carbs: 6, fat: 0.4, fiber: 0 },
        { name: "Eggs", category: 'protein', calories: 155, protein: 13, carbs: 1.1, fat: 11, fiber: 0 },
        { name: "Tuna", category: 'protein', calories: 132, protein: 28, carbs: 0, fat: 1.3, fiber: 0 },
        { name: "Lean Beef", category: 'protein', calories: 250, protein: 26, carbs: 0, fat: 15, fiber: 0 },
        
        // Carbohydrates
        { name: "Brown Rice", category: 'carbs', calories: 216, protein: 5, carbs: 45, fat: 1.8, fiber: 3.5 },
        { name: "Quinoa", category: 'carbs', calories: 222, protein: 8, carbs: 39, fat: 3.6, fiber: 5.2 },
        { name: "Sweet Potato", category: 'carbs', calories: 112, protein: 2, carbs: 26, fat: 0.1, fiber: 3.9 },
        { name: "Oatmeal", category: 'carbs', calories: 154, protein: 6, carbs: 28, fat: 3, fiber: 4 },
        { name: "Whole Wheat Bread", category: 'carbs', calories: 247, protein: 13, carbs: 41, fat: 4.2, fiber: 7 },
        { name: "Pasta", category: 'carbs', calories: 220, protein: 8, carbs: 44, fat: 1.1, fiber: 2.5 },
        
        // Fruits
        { name: "Banana", category: 'fruits', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1 },
        { name: "Apple", category: 'fruits', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4 },
        { name: "Blueberries", category: 'fruits', calories: 84, protein: 1.1, carbs: 21, fat: 0.5, fiber: 3.6 },
        { name: "Orange", category: 'fruits', calories: 62, protein: 1.2, carbs: 15, fat: 0.2, fiber: 3.1 },
        { name: "Strawberries", category: 'fruits', calories: 49, protein: 1, carbs: 12, fat: 0.5, fiber: 3 },
        
        // Vegetables
        { name: "Broccoli", category: 'vegetables', calories: 55, protein: 3.7, carbs: 11, fat: 0.6, fiber: 5.1 },
        { name: "Spinach", category: 'vegetables', calories: 41, protein: 5.4, carbs: 7, fat: 0.7, fiber: 4.3 },
        { name: "Carrots", category: 'vegetables', calories: 50, protein: 1.1, carbs: 12, fat: 0.3, fiber: 3.4 },
        { name: "Bell Peppers", category: 'vegetables', calories: 40, protein: 2, carbs: 9, fat: 0.4, fiber: 3.4 },
        { name: "Tomatoes", category: 'vegetables', calories: 32, protein: 1.6, carbs: 7, fat: 0.4, fiber: 2.2 },
        
        // Healthy Fats
        { name: "Avocado", category: 'fats', calories: 320, protein: 4, carbs: 17, fat: 29, fiber: 14 },
        { name: "Almonds", category: 'fats', calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 12 },
        { name: "Olive Oil", category: 'fats', calories: 884, protein: 0, carbs: 0, fat: 100, fiber: 0 },
        { name: "Walnuts", category: 'fats', calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7 }
    ];

    const categories = [
        { id: 'all', name: 'All Foods' },
        { id: 'protein', name: 'Protein' },
        { id: 'carbs', name: 'Carbohydrates' },
        { id: 'fruits', name: 'Fruits' },
        { id: 'vegetables', name: 'Vegetables' },
        { id: 'fats', name: 'Healthy Fats' }
    ];

    // Create category filters
    const categoriesContainer = document.getElementById('food-categories');
    categoriesContainer.innerHTML = categories.map(category => `
        <button class="category-btn ${category.id === 'all' ? 'active' : ''}" data-category="${category.id}">
            ${category.name}
        </button>
    `).join('');

    // Add event listeners to category buttons
    const categoryBtns = categoriesContainer.querySelectorAll('.category-btn');
    categoryBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            categoryBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            filterFoods();
        });
    });

    // Add search functionality
    const searchInput = document.getElementById('food-search');
    searchInput.addEventListener('input', filterFoods);

    function filterFoods() {
        const searchTerm = searchInput.value.toLowerCase();
        const selectedCategory = document.querySelector('.category-btn.active').dataset.category;
        
        const filteredFoods = foods.filter(food => {
            const matchesSearch = food.name.toLowerCase().includes(searchTerm);
            const matchesCategory = selectedCategory === 'all' || food.category === selectedCategory;
            return matchesSearch && matchesCategory;
        });

        displayFoods(filteredFoods);
    }

    function displayFoods(foodsToShow) {
        const foodGrid = document.getElementById('food-grid');
        
        if (foodsToShow.length === 0) {
            foodGrid.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
                    <i class="fas fa-search" style="font-size: 3rem; color: #9ca3af; margin-bottom: 20px;"></i>
                    <h3 style="color: #6b7280; margin-bottom: 10px;">No foods found</h3>
                    <p style="color: #9ca3af;">Try adjusting your search or filter criteria</p>
                </div>
            `;
            return;
        }

        foodGrid.innerHTML = foodsToShow.map(food => `
            <div class="food-card">
                <div class="food-header">
                    <div class="food-icon category-${food.category}">
                        <i class="fas fa-${getFoodIcon(food.category)}"></i>
                    </div>
                    <div>
                        <div class="food-name">${food.name}</div>
                        <div class="food-category category-${food.category}">${food.category}</div>
                    </div>
                </div>
                <div class="food-calories">
                    <span>Calories</span>
                    <strong>${food.calories}</strong>
                </div>
                <div class="food-macros">
                    <div class="macro protein-macro">
                        <div class="macro-value">${food.protein}g</div>
                        <div class="macro-label">Protein</div>
                    </div>
                    <div class="macro carbs-macro">
                        <div class="macro-value">${food.carbs}g</div>
                        <div class="macro-label">Carbs</div>
                    </div>
                    <div class="macro fat-macro">
                        <div class="macro-value">${food.fat}g</div>
                        <div class="macro-label">Fat</div>
                    </div>
                    <div class="macro fiber-macro">
                        <div class="macro-value">${food.fiber}g</div>
                        <div class="macro-label">Fiber</div>
                    </div>
                </div>
            </div>
        `).join('');
    }

    function getFoodIcon(category) {
        const icons = {
            protein: 'drumstick-bite',
            carbs: 'bread-slice',
            fruits: 'apple-alt',
            vegetables: 'carrot',
            fats: 'seedling'
        };
        return icons[category] || 'utensils';
    }

    // Initial display
    displayFoods(foods);
}
