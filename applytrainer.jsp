<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitLife Trainer Application</title>
    
    <style>
        /* --- General Setup & Typography --- */
        :root {
            --primary-color: #EF4444; /* Red */
            --secondary-color: #FEE2E2; /* Light Red */
            --dark-color: #016bffff; /* Gray 800 */
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f7f7f7;
            min-height: 100vh;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        /* --- Navbar Styling --- */
        .navbar {
            background-color: var(--dark-color);
            padding: 1rem 0;
        }
        .nav-container {
            max-width: 1280px;
            margin-left: auto;
            margin-right: auto;
            padding: 0 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .nav-logo .icon {
            color: var(--primary-color);
            font-size: 1.5rem;
        }
        .nav-logo span {
            font-weight: 700;
            font-size: 1.5rem;
            color: white;
            letter-spacing: -0.025em;
        }
        .nav-link {
            color: #D1D5DB; /* Gray 300 */
            text-decoration: none;
            transition: color 150ms ease;
        }
        .nav-link:hover {
            color: white;
        }
        
        /* --- Main Layout --- */
        .main-container {
            max-width: 1024px;
            margin: 0 auto;
            padding: 3rem 1rem;
        }
        
        /* --- Form Container --- */
        .trainer-form {
            padding: 1.5rem;
            background-color: white;
            border-radius: 0.75rem;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        @media (min-width: 768px) {
            .trainer-form {
                padding: 2.5rem;
            }
        }
        .form-header h1 {
            font-size: 2rem;
            font-weight: 800;
            color: #1F2937;
            margin-bottom: 0.5rem;
            text-align: center;
        }
        .form-header p {
            text-align: center;
            color: #6B7280;
            margin-bottom: 2rem;
        }
        
        /* --- Form Fields & Fieldsets --- */
        .fieldset {
            border: 1px solid #E5E7EB;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
        }
        .fieldset-legend {
            font-size: 1.25rem;
            font-weight: 600;
            color: #374151;
            padding: 0 0.5rem;
            margin-left: -0.5rem;
        }
        .form-group-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.5rem;
            margin-top: 1rem;
        }
        @media (min-width: 768px) {
            .form-group-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }
        .form-group {
            margin-bottom: 1.5rem;
        }
        .form-group:last-child {
            margin-bottom: 0;
        }
        .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 500;
            color: #374151;
            margin-bottom: 0.25rem;
        }
        .form-input, .form-textarea, .form-select {
            width: 100%;
            padding: 0.75rem;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
            border: 2px solid #E5E7EB;
            box-sizing: border-box; /* Crucial for width calculation */
        }
        .form-input:focus, .form-textarea:focus, .form-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.4);
        }
        .form-textarea {
            resize: vertical;
        }
        .text-xs {
            font-size: 0.75rem;
            color: #6B7280;
            margin-top: 0.25rem;
        }

        /* --- Submit Button --- */
        .submit-btn {
            width: 100%;
            color: white;
            font-weight: 700;
            padding: 0.75rem 1rem;
            border-radius: 0.5rem;
            font-size: 1.125rem;
            border: none;
            cursor: pointer;
            background: linear-gradient(135deg, #F87171, var(--primary-color));
            transition: all 0.2s ease;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.4);
        }
        .submit-btn:hover {
            box-shadow: 0 6px 15px rgba(239, 68, 68, 0.6);
            transform: translateY(-1px);
        }

        /* --- Message Area --- */
        .message-area {
            margin-bottom: 1.5rem;
        }
        .message-box {
            padding: 1rem;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            border-width: 1px;
        }
        .message-box.error {
            background-color: #FEE2E2; /* Red 100 */
            color: #B91C1C; /* Red 700 */
            border-color: #FCA5A5; /* Red 400 */
        }
        .message-box.success {
            background-color: #D1FAE5; /* Green 100 */
            color: #065F46; /* Green 700 */
            border-color: #34D399; /* Green 400 */
        }
        .hidden {
            display: none;
        }
    </style>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>

    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-logo">
                <i class="fas fa-heartbeat"></i>
                <span>FitLife</span>
            </div>
            <div class="hidden sm:block">
                <a href="#" class="nav-link">Home</a>
            </div>
        </div>
    </nav>

    <!-- Main Content: Trainer Application Form -->
    <div class="main-container">
        <div class="trainer-form">
            <header class="form-header">
                <h1>Join the FitLife Team</h1>
                <p>Complete the form below to apply for a personal trainer position.</p>
            </header>

            <!-- Message Area for success/error -->
            <div id="message-area" class="message-area hidden"></div>

            <form id="trainerApplicationForm" action="saveTrainerApplication.jsp" method="post" onsubmit="return validateForm(event)" enctype="multipart/form-data" >

                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Personal Details</legend>
                    
                    <div class="form-group-grid">
                        <!-- Full Name -->
                        <div class="form-group">
                            <label for="fullName" class="form-label">Full Name</label>
                            <input type="text" id="fullName" name="fullName" required class="form-input" placeholder="Jane Doe">
                        </div>
                        
                        <!-- Email -->
                        <div class="form-group">
                            <label for="email" class="form-label">Email Address</label>
                            <input type="email" id="email" name="email" required class="form-input" placeholder="jane.doe@example.com">
                        </div>

                        <!-- Phone -->
                        <div class="form-group">
                            <label for="phone" class="form-label">Phone Number</label>
                            <input type="tel" id="phone" name="phone" required class="form-input" placeholder="+1-555-123-4567">
                        </div>

                        <!-- Location -->
                        <div class="form-group">
                            <label for="location" class="form-label">Preferred Training Location/Gym</label>
                            <input type="text" id="location" name="location" required class="form-input" placeholder="Central City Gym">
                        </div>
                    </div>
                </fieldset>

                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Professional Credentials</legend>

                    <!-- Specializations -->
                    <div class="form-group">
                        <label for="specializations" class="form-label">Specializations (e.g., Weight Loss, HIIT, Yoga)</label>
                        <input type="text" id="specializations" name="specializations" required class="form-input" placeholder="List your key areas, separated by commas">
                    </div>

                    <div class="form-group-grid">
                        <!-- Experience -->
                        <div class="form-group">
                            <label for="experience" class="form-label">Years of Experience</label>
                            <select id="experience" name="experience" required class="form-select">
                                <option value="">Select...</option>
                                <option value="1-2 years">1-2 years</option>
                                <option value="3-5 years">3-5 years</option>
                                <option value="6-10 years">6-10 years</option>
                                <option value="10+ years">10+ years</option>
                            </select>
                        </div>
                        
                        <!-- Profile Image Path (URL) -->
                        <div class="form-group">
                            <label for="profileImagePath" class="form-label">Profile Image URL (External link)</label>
                            <%-- <input type="url" id="profileImagePath" name="profileImagePath" class="form-input" placeholder="https://example.com/photo.jpg"> --%>
                            Image: <input type="file" name="image" required/><br><br>
                            <p class="text-xs">This will be used for your trainer profile card.</p>
                        </div>
                    </div>

                    <!-- Certifications -->
                    <div class="form-group">
                        <label for="certifications" class="form-label">Certifications (List)</label>
                        <input type="text" id="certifications" name="certifications" required class="form-input" placeholder="NASM-CPT, ACE, RYT-200, etc.">
                    </div>

                    <!-- Bio (CLOB) -->
                    <div class="form-group">
                        <label for="bio" class="form-label">Professional Bio</label>
                        <textarea id="bio" name="bio" rows="5" required class="form-textarea" placeholder="Tell us about your philosophy, background, and achievements (max 4000 characters)."></textarea>
                    </div>
                    

                </fieldset>

                <fieldset class="fieldset" style="margin-bottom: 2rem;">
                    <legend class="fieldset-legend">Account Security</legend>

                    <div class="form-group-grid">
                        <!-- Password -->
                        <div class="form-group">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" id="password" name="password" required class="form-input" minlength="8">
                            <p class="text-xs">Minimum 8 characters.</p>
                        </div>

                        <!-- Confirm Password -->
                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required class="form-input" minlength="8">
                        </div>
                    </div>
                </fieldset>
                
                <!-- Submit Button -->
                <button type="submit" class="submit-btn">
                    Submit Application
                </button>
            </form>
        </div>
    </div>

    <script>
        function displayMessage(type, message) {
            const area = document.getElementById('message-area');
            area.innerHTML = `
                <div class="message-box ${type}">
                    ${message}
                </div>
            `;
            area.classList.remove('hidden');
        }

        function validateForm(event) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            // Password check
            if (password !== confirmPassword) {
                event.preventDefault(); // Stop form submission
                displayMessage('error', '⚠️ Error: Password and Confirm Password fields must match.');
                return false;
            }
            
            // Allow actual submission to the JSP backend
            return true; 
        }
        
        // Remove the simulation block from the previous version, allowing the form to submit normally.
    </script>
</body>
</html>
