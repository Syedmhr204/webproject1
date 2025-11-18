document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    const sections = document.querySelectorAll('.section');

    navToggle.addEventListener('click', function() {
        navMenu.classList.toggle('active');
    });

    
    initializeCalculators();

    
    loadSectionContent('home');
    loadSectionContent('trainers');
       loadSectionContent('food-chart');
  loadSectionContent('exercise');
    loadSectionContent('profile');
});

function initializeCalculators() {
     
    const bmiHeight = document.getElementById('bmi-height');
    const bmiWeight = document.getElementById('bmi-weight');
    
    function calculateBMI() {
        const height = parseFloat(bmiHeight.value);
        const weight = parseFloat(bmiWeight.value);
        
        if (height && weight) {
            const heightInMeters = height / 100;
            const bmi = weight / (heightInMeters * heightInMeters);
            const bmiValue = bmi.toFixed(1);
            
            let category = '';
            let categoryClass = '';
            
            if (bmi < 18.5) {
                category = 'Underweight';
                categoryClass = 'underweight';
            } else if (bmi >= 18.5 && bmi < 25) {
                category = 'Normal weight';
                categoryClass = 'normal';
            } else if (bmi >= 25 && bmi < 30) {
                category = 'Overweight';
                categoryClass = 'overweight';
            } else {
                category = 'Obese';
                categoryClass = 'obese';
            }
            
            document.getElementById('bmi-value').textContent = bmiValue;
            document.getElementById('bmi-category').textContent = category;
            document.getElementById('bmi-category').className = `result-category ${categoryClass}`;
            document.getElementById('bmi-result').style.display = 'block';
        } else {
            document.getElementById('bmi-result').style.display = 'none';
        }
    }
    
    bmiHeight.addEventListener('input', calculateBMI);
    bmiWeight.addEventListener('input', calculateBMI);
    
    // Calorie 
    const calorieInputs = ['calorie-age', 'calorie-gender', 'calorie-height', 'calorie-weight', 'calorie-activity'];
    
    function calculateCalories() {
        const age = parseFloat(document.getElementById('calorie-age').value);
        const gender = document.getElementById('calorie-gender').value;
        const height = parseFloat(document.getElementById('calorie-height').value);
        const weight = parseFloat(document.getElementById('calorie-weight').value);
        const activity = parseFloat(document.getElementById('calorie-activity').value);
        
        if (age && height && weight) {
            let bmr;
            
            if (gender === 'male') {
                bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
            } else {
                bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
            }
            
            const dailyCalories = Math.round(bmr * activity);
            
            document.getElementById('calorie-value').textContent = dailyCalories;
            document.getElementById('calorie-result').style.display = 'block';
        } else {
            document.getElementById('calorie-result').style.display = 'none';
        }
    }
    
    calorieInputs.forEach(inputId => {
        document.getElementById(inputId).addEventListener('input', calculateCalories);
        document.getElementById(inputId).addEventListener('change', calculateCalories);
    });
    
    // Protein
    const proteinWeight = document.getElementById('protein-weight');
    const proteinGoal = document.getElementById('protein-goal');
    
    function calculateProtein() {
        const weight = parseFloat(proteinWeight.value);
        const goal = proteinGoal.value;
        
        if (weight) {
            let multiplier;
            let goalText;
            
            switch (goal) {
                case 'weight-loss':
                    multiplier = 1.6;
                    goalText = 'weight loss';
                    break;
                case 'muscle-gain':
                    multiplier = 2.2;
                    goalText = 'muscle gain';
                    break;
                case 'athlete':
                    multiplier = 2.0;
                    goalText = 'athletic performance';
                    break;
                default:
                    multiplier = 1.2;
                    goalText = 'general health';
            }
            
            const protein = Math.round(weight * multiplier);
            
            document.getElementById('protein-value').textContent = protein + 'g';
            document.getElementById('protein-note').textContent = `Based on your ${goalText} goal`;
            document.getElementById('protein-result').style.display = 'block';
        } else {
            document.getElementById('protein-result').style.display = 'none';
        }
    }
    
    proteinWeight.addEventListener('input', calculateProtein);
    proteinGoal.addEventListener('change', calculateProtein);
}
// (BMR)
const bmrWeight = document.getElementById('bmr-weight');
const bmrHeight = document.getElementById('bmr-height');
const bmrAge = document.getElementById('bmr-age');
const bmrGender = document.getElementById('bmr-gender');

function calculateBMR() {
    const weight = parseFloat(bmrWeight.value);
    const height = parseFloat(bmrHeight.value);
    const age = parseInt(bmrAge.value);
    const gender = bmrGender.value;

    if (weight && height && age) {
        let bmr;
        if (gender === 'male') {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        }

        document.getElementById('bmr-value').textContent = Math.round(bmr) + ' kcal';
        document.getElementById('bmr-note').textContent = `This is your Basal Metabolic Rate (BMR)`;
        document.getElementById('bmr-result').style.display = 'block';
    } else {
        document.getElementById('bmr-result').style.display = 'none';
    }
}

bmrWeight.addEventListener('input', calculateBMR);
bmrHeight.addEventListener('input', calculateBMR);
bmrAge.addEventListener('input', calculateBMR);
bmrGender.addEventListener('change', calculateBMR);

// BFC
  const genderSelect = document.getElementById('gender');
  const hipGroup = document.getElementById('hipGroup');
  const resultDiv = document.getElementById('result');
  const bodyFatValue = document.getElementById('bodyFatValue');

  function calculateBodyFat() {
    const gender = genderSelect.value;
    const height = parseFloat(document.getElementById('height').value);
    const neck = parseFloat(document.getElementById('neck').value);
    const waist = parseFloat(document.getElementById('waist').value);
    const hip = parseFloat(document.getElementById('hip').value);

    if (!gender || !height || !neck || !waist || (gender === 'female' && !hip)) {
      resultDiv.style.display = 'none';
      return;
    }

    let bodyFat = 0;

    // Using US Navy Method formulas
    if (gender === 'male') {
      bodyFat = 495 / (1.0324 - 0.19077 * Math.log10(waist - neck) + 0.15456 * Math.log10(height)) - 450;
    } else {
      bodyFat = 495 / (1.29579 - 0.35004 * Math.log10(waist + hip - neck) + 0.22100 * Math.log10(height)) - 450;
    }

    bodyFat = bodyFat.toFixed(2);
    bodyFatValue.textContent = `${bodyFat} %`;
    resultDiv.style.display = 'block';
  }

  // Show/hide hip input depending on gender
  genderSelect.addEventListener('change', () => {
    if (genderSelect.value === 'female') {
      hipGroup.style.display = 'block';
    } else {
      hipGroup.style.display = 'none';
      document.getElementById('hip').value = '';
    }
    calculateBodyFat();
  });

  // Add input event listeners to recalc on input changes
  ['height', 'neck', 'waist', 'hip'].forEach(id => {
    document.getElementById(id).addEventListener('input', calculateBodyFat);
  });



// Section content loading
function loadSectionContent(section) {
    switch (section) {
        case 'trainers':
            loadTrainers();
            break;
        case 'food-chart':
            loadFoodChart();
            break;
        
        case 'exercise':
            loadExercises();
            break;
    }
}

// Trainers data and functionality
function loadTrainers() {
    const trainers = [
        {
            id: 1,
            name: "Sarah Johnson",
            specialty: "Weight Loss & Cardio",
            experience: "8 years",
            rating: 4.9,
            location: "Downtown Gym",
            image: "https://images.pexels.com/photos/3823488/pexels-photo-3823488.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "Certified personal trainer specializing in weight loss and cardiovascular fitness. Helped over 200 clients achieve their fitness goals.",
            certifications: ["NASM-CPT", "Nutrition Specialist", "Group Fitness"]
        },
        {
            id: 2,
            name: "Mike Rodriguez",
            specialty: "Strength Training & Bodybuilding",
            experience: "12 years",
            rating: 4.8,
            location: "Iron Works Gym",
            image: "https://images.pexels.com/photos/1431282/pexels-photo-1431282.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "Former competitive bodybuilder turned trainer. Expert in muscle building, strength training, and sports performance.",
            certifications: ["ACSM-CPT", "Powerlifting Coach", "Sports Nutrition"]
        },
        {
            id: 3,
            name: "Emma Chen",
            specialty: "Yoga & Flexibility",
            experience: "6 years",
            rating: 4.9,
            location: "Zen Fitness Studio",
            image: "https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "Yoga instructor and flexibility expert. Specializes in injury prevention, mobility, and mind-body wellness.",
            certifications: ["RYT-500", "Pilates Instructor", "Rehabilitation Specialist"]
        },
        {
            id: 4,
            name: "David Thompson",
            specialty: "HIIT & Functional Training",
            experience: "10 years",
            rating: 4.7,
            location: "CrossFit Central",
            image: "https://images.pexels.com/photos/1544804/pexels-photo-1544804.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "High-intensity interval training specialist. Expert in functional movements and metabolic conditioning.",
            certifications: ["CrossFit L2", "HIIT Specialist", "Functional Movement"]
        },
        {
            id: 5,
            name: "Lisa Park",
            specialty: "Senior Fitness & Rehabilitation",
            experience: "9 years",
            rating: 4.8,
            location: "Active Life Center",
            image: "https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "Specializes in senior fitness, post-injury rehabilitation, and adaptive exercise programs for all fitness levels.",
            certifications: ["Medical Exercise", "Senior Fitness", "Corrective Exercise"]
        },
        {
            id: 6,
            name: "Alex Kumar",
            specialty: "Athletic Performance & Sports",
            experience: "11 years",
            rating: 4.9,
            location: "Elite Sports Complex",
            image: "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=400",
            bio: "Former professional athlete turned performance coach. Specializes in sport-specific training and athletic development.",
            certifications: ["CSCS", "Speed & Agility", "Sports Psychology"]
        }
    ];

    const trainersGrid = document.getElementById('trainers-grid');
    trainersGrid.innerHTML = trainers.map(trainer => `
        <div class="trainer-card">
            <div class="trainer-image">
                <img src="${trainer.image}" alt="${trainer.name}">
                <div class="trainer-rating">
                    <i class="fas fa-star"></i>
                    <span>${trainer.rating}</span>
                </div>
            </div>
            <div class="trainer-info">
                <h3 class="trainer-name">${trainer.name}</h3>
                <p class="trainer-specialty">${trainer.specialty}</p>
                <p class="trainer-bio">${trainer.bio}</p>
                <div class="trainer-details">
                    <div class="trainer-detail">
                        <i class="fas fa-clock"></i>
                        <span>${trainer.experience} experience</span>
                    </div>
                    <div class="trainer-detail">
                        <i class="fas fa-map-marker-alt"></i>
                        <span>${trainer.location}</span>
                    </div>
                </div>
                <div class="trainer-certifications">
                    <h4><i class="fas fa-award"></i> Certifications</h4>
                    <div class="certifications-list">
                        ${trainer.certifications.map(cert => `<span class="certification">${cert}</span>`).join('')}
                    </div>
                </div>
                <button class="book-btn">Book Session</button>
            </div>
        </div>
    `).join('');
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

