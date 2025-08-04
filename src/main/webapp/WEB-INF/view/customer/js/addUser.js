document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('addUserForm');
    const phoneInput = document.getElementById('phone');
    const passwordInput = document.getElementById('password');
    const strengthFill = document.getElementById('strengthFill');
    const strengthText = document.getElementById('strengthText');

    // Phone number validation
    if (phoneInput) {
        phoneInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '').substring(0, 10);
        });
    }

    // Password strength checker
    if (passwordInput && strengthFill && strengthText) {
        passwordInput.addEventListener('input', function() {
            const password = this.value;
            const strength = calculatePasswordStrength(password);
            updatePasswordStrength(strength);
        });
    }

    // Form validation
    if (form) {
        form.addEventListener('submit', function(e) {
            let isValid = true;
            const errors = [];

            // Validate required fields
            const username = document.getElementById('username').value.trim();
            const fullName = document.getElementById('fullName').value.trim();
            const password = document.getElementById('password').value;
            const role = document.querySelector('input[name="role"]:checked');

            if (!username || username.length < 3) {
                errors.push('Username must be at least 3 characters long');
                document.getElementById('username').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('username').classList.remove('error');
            }

            if (!fullName) {
                errors.push('Full name is required');
                document.getElementById('fullName').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('fullName').classList.remove('error');
            }

            if (!password || password.length < 6) {
                errors.push('Password must be at least 6 characters long');
                document.getElementById('password').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('password').classList.remove('error');
            }

            if (!role) {
                errors.push('Please select a user role');
                isValid = false;
            }

            // Validate email if provided
            const email = document.getElementById('email').value.trim();
            if (email && !isValidEmail(email)) {
                errors.push('Valid email address is required');
                document.getElementById('email').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('email').classList.remove('error');
            }

            // Validate phone if provided
            const phone = phoneInput.value.trim();
            if (phone && phone.length !== 10) {
                errors.push('Phone number must be exactly 10 digits');
                phoneInput.classList.add('error');
                isValid = false;
            } else {
                phoneInput.classList.remove('error');
            }

            if (!isValid) {
                e.preventDefault();
                showErrors(errors);
            } else {
                // Show loading state
                const submitBtn = form.querySelector('button[type="submit"]');
                submitBtn.textContent = 'Creating User...';
                submitBtn.disabled = true;
            }
        });
    }

    function calculatePasswordStrength(password) {
        let strength = 0;
        if (password.length >= 8) strength += 25;
        if (password.match(/[a-z]/)) strength += 25;
        if (password.match(/[A-Z]/)) strength += 25;
        if (password.match(/[0-9]/)) strength += 25;
        return strength;
    }

    function updatePasswordStrength(strength) {
        if (!strengthFill || !strengthText) return;
        
        strengthFill.style.width = strength + '%';
        
        if (strength < 50) {
            strengthFill.className = 'strength-fill strength-weak';
            strengthText.textContent = 'Weak password';
            strengthText.style.color = '#e74c3c';
        } else if (strength < 75) {
            strengthFill.className = 'strength-fill strength-medium';
            strengthText.textContent = 'Medium strength password';
            strengthText.style.color = '#f39c12';
        } else {
            strengthFill.className = 'strength-fill strength-strong';
            strengthText.textContent = 'Strong password';
            strengthText.style.color = '#27ae60';
        }
    }

    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    function showErrors(errors) {
        // Remove existing error alert (avoid JSP conflict)
        const existingAlert = document.querySelector('.alert-error');
        if (existingAlert && !existingAlert.innerHTML.includes('<%')) {
            existingAlert.remove();
        }

        // Create new error alert
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-error';
        alertDiv.innerHTML = errors.join('<br>');
        
        const formContainer = document.querySelector('.form-container');
        if (formContainer && formContainer.parentNode) {
            formContainer.parentNode.insertBefore(alertDiv, formContainer);
        }
    }

    // Auto-focus first input
    const usernameField = document.getElementById('username');
    if (usernameField) {
        usernameField.focus();
    }
});

function selectRole(roleValue) {
    // Remove selected class from all options
    document.querySelectorAll('.role-option').forEach(function(option) {
        option.classList.remove('selected');
    });

    // Add selected class to clicked option
    if (event && event.currentTarget) {
        event.currentTarget.classList.add('selected');
    }

    // Check the radio button
    const radioButton = document.getElementById('role' + roleValue.charAt(0) + roleValue.slice(1).toLowerCase());
    if (radioButton) {
        radioButton.checked = true;
    }
}/**
 * 
 */