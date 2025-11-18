document.addEventListener('DOMContentLoaded', () => {

    
    const userNameInput = document.getElementById('user-name');
const userEmailInput = document.getElementById('user-email');
const userPhoneInput = document.getElementById('user-phone');
const userAddressInput = document.getElementById('user-address');
    const userAgeInput = document.getElementById('user-age');
    const userGenderInput = document.getElementById('user-gender');
    const userHeightInput = document.getElementById('user-height');
    const userWeightInput = document.getElementById('user-weight');
    const userActivityInput = document.getElementById('user-activity');
    const userGoalInput = document.getElementById('user-goal');
    const userNeckInput = document.getElementById('user-neck');
    const userWaistInput = document.getElementById('user-waist');
    const calculateBtn = document.getElementById('calculate-btn');

    const displayName = document.getElementById('display-name');
const displayEmail = document.getElementById('display-email');
const displayPhone = document.getElementById('display-phone');
const displayAddress = document.getElementById('display-address');
    const displayAge = document.getElementById('display-age');
    const displayGender = document.getElementById('display-gender');
    const displayHeight = document.getElementById('display-height');
    const displayWeight = document.getElementById('display-weight');
    const displayActivity = document.getElementById('display-activity');
    const displayGoal = document.getElementById('display-goal');
    const displayNeck = document.getElementById('display-neck');
    const displayWaist = document.getElementById('display-waist');


    const bmiValueDisplay = document.getElementById('bmi-value-display');
    const bmiCategoryDisplay = document.getElementById('bmi-category-display');
    const calorieValueDisplay = document.getElementById('calorie-value-display');
    const proteinValueDisplay = document.getElementById('protein-value-display');
    const bmrValueDisplay = document.getElementById('bmr-value-display');
    const bodyfatValueDisplay = document.getElementById('bodyfat-value-display');
    
  
    const sidebar = document.getElementById('profile-sidebar');
    const openSidebarBtn = document.getElementById('open-sidebar-btn');
    const closeSidebarBtn = document.getElementById('close-sidebar-btn');
    const sidebarOverlay = document.getElementById('sidebar-overlay');

    // Event listeners for sidebar toggling
    openSidebarBtn.addEventListener('click', () => {
        sidebar.classList.add('open');
        sidebarOverlay.classList.add('active');
    });

    closeSidebarBtn.addEventListener('click', closeSidebar);
    sidebarOverlay.addEventListener('click', closeSidebar);

    function closeSidebar() {
        sidebar.classList.remove('open');
        sidebarOverlay.classList.remove('active');
    }

    // Event listener for the calculate/update button
    calculateBtn.addEventListener('click', () => {
        calculateAllMetrics();
        saveUserData();
        displaySavedInfo();
        closeSidebar();
    });

    // Load saved data on page load
    loadUserData();
    displaySavedInfo();

    // Helper function to calculate all metrics
    function calculateAllMetrics() {
        // ... (rest of the calculation logic is the same as before) ...
        const heightCm = parseFloat(userHeightInput.value);
        const weightKg = parseFloat(userWeightInput.value);
        const age = parseFloat(userAgeInput.value);
        const gender = userGenderInput.value;
        const activityLevel = parseFloat(userActivityInput.value);
        const goalMultiplier = parseFloat(userGoalInput.value);
        const neckCm = parseFloat(userNeckInput.value);
        const waistCm = parseFloat(userWaistInput.value);

        if (heightCm > 0 && weightKg > 0 && age > 0 && gender) {
            calculateBMI(heightCm, weightKg);
            calculateBMR(gender, weightKg, heightCm, age);
            calculateCalorie(gender, weightKg, heightCm, age, activityLevel);
            calculateProtein(weightKg, goalMultiplier);
            
            if (neckCm > 0 && waistCm > 0) {
                calculateBodyFat(gender, heightCm, neckCm, waistCm);
            } else {
                bodyfatValueDisplay.textContent = '--';
            }
        } else {
            bmiValueDisplay.textContent = '--';
            bmiCategoryDisplay.textContent = '';
            calorieValueDisplay.textContent = '--';
            proteinValueDisplay.textContent = '--';
            bmrValueDisplay.textContent = '--';
            bodyfatValueDisplay.textContent = '--';
        }
    }

    function calculateBMI(heightCm, weightKg) {
        const heightM = heightCm / 100;
        const bmi = weightKg / (heightM * heightM);
        let category = '';
        if (bmi < 18.5) category = 'Underweight';
        else if (bmi >= 18.5 && bmi <= 24.9) category = 'Normal weight';
        else if (bmi >= 25 && bmi <= 29.9) category = 'Overweight';
        else category = 'Obesity';
        bmiValueDisplay.textContent = bmi.toFixed(2);
        bmiCategoryDisplay.textContent = category;
    }

    function calculateBMR(gender, weightKg, heightCm, age) {
        let bmr;
        if (gender === 'male') {
            bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
        } else {
            bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
        }
        bmrValueDisplay.textContent = Math.round(bmr);
    }
    
    function calculateCalorie(gender, weightKg, heightCm, age, activityLevel) {
        const bmr = (gender === 'male')
            ? 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age)
            : 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
        const calories = bmr * activityLevel;
        calorieValueDisplay.textContent = Math.round(calories);
    }

    function calculateProtein(weightKg, goalMultiplier) {
        const protein = weightKg * goalMultiplier;
        proteinValueDisplay.textContent = `${Math.round(protein)} g`;
    }

    function calculateBodyFat(gender, heightCm, neckCm, waistCm) {
        let bodyFat;
        if (gender === 'male') {
            bodyFat = 495 / (1.0324 - 0.19077 * Math.log10(waistCm - neckCm) + 0.15456 * Math.log10(heightCm)) - 450;
        } else {
            // Simplified formula for women
            bodyFat = 495 / (1.097 - 0.00046 * (waistCm + neckCm) + 0.00015 * heightCm) - 450;
        }
        bodyfatValueDisplay.textContent = `${bodyFat.toFixed(2)}%`;
    }

    // Function to save all user data to local storage
    function saveUserData() {
        const userData = {
            name: userNameInput.value,
        email: userEmailInput.value,
        phone: userPhoneInput.value,
        address: userAddressInput.value,
            age: userAgeInput.value,
            gender: userGenderInput.value,
            height: userHeightInput.value,
            weight: userWeightInput.value,
            activity: userActivityInput.value,
            goal: userGoalInput.value,
            neck: userNeckInput.value,
            waist: userWaistInput.value
        };
        localStorage.setItem('fitlifeUserData', JSON.stringify(userData));
    }

    // Function to load all user data from local storage and populate the form
    function loadUserData() {
        const userData = JSON.parse(localStorage.getItem('fitlifeUserData'));
        if (userData) {
             userNameInput.value = userData.name;
        userEmailInput.value = userData.email;
        userPhoneInput.value = userData.phone;
        userAddressInput.value = userData.address;
            userAgeInput.value = userData.age;
            userGenderInput.value = userData.gender;
            userHeightInput.value = userData.height;
            userWeightInput.value = userData.weight;
            userActivityInput.value = userData.activity;
            userGoalInput.value = userData.goal;
            userNeckInput.value = userData.neck;
            userWaistInput.value = userData.waist;
            
            calculateAllMetrics();
        }
    }
    
  
    function displaySavedInfo() {
        const userData = JSON.parse(localStorage.getItem('fitlifeUserData'));
        if (userData) {
          
            const activityText = userActivityInput.options[userActivityInput.selectedIndex].text;
            const goalText = userGoalInput.options[userGoalInput.selectedIndex].text.split('(')[0].trim();
            displayName.textContent = userData.name || '--';
        displayEmail.textContent = userData.email || '--';
        displayPhone.textContent = userData.phone || '--';
        displayAddress.textContent = userData.address || '--';
            displayAge.textContent = userData.age || '--';
            displayGender.textContent = userData.gender.charAt(0).toUpperCase() + userData.gender.slice(1) || '--';
            displayHeight.textContent = (userData.height ? `${userData.height} cm` : '-- cm');
            displayWeight.textContent = (userData.weight ? `${userData.weight} kg` : '-- kg');
            displayActivity.textContent = activityText || '--';
            displayGoal.textContent = goalText || '--';
            displayNeck.textContent = (userData.neck ? `${userData.neck} cm` : '-- cm');
            displayWaist.textContent = (userData.waist ? `${userData.waist} cm` : '-- cm');
        } else {
           
            const elements = [displayAge, displayGender, displayHeight, displayWeight, displayActivity, displayGoal, displayNeck, displayWaist];
            elements.forEach(el => el.textContent = el.id.includes('display-height') || el.id.includes('display-weight') || el.id.includes('display-neck') || el.id.includes('display-waist') ? '-- cm/kg' : '--');
        }
    }
});