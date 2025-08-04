




document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('editUserForm');
    const phoneInput = document.getElementById('phone');
    const emailInput = document.getElementById('email');

    if (form) {
        // Phone number validation
        if (phoneInput) {
            phoneInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '').substring(0, 10);
            });
        }

        // Form validation
        form.addEventListener('submit', function(e) {
            let isValid = true;
            const errors = [];

            // Validate required fields
            const fullName = document.getElementById('fullName').value.trim();
            const role = document.querySelector('input[name="role"]:checked');

            if (!fullName) {
                errors.push('Full name is required');
                document.getElementById('fullName').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('fullName').classList.remove('error');
            }

            if (!role) {
                errors.push('Please select a user role');
                isValid = false;
            }

            // Validate email if provided
            const email = emailInput.value.trim();
            if (email && !isValidEmail(email)) {
                errors.push('Valid email address is required');
                emailInput.classList.add('error');
                isValid = false;
            } else {
                emailInput.classList.remove('error');
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
                submitBtn.textContent = 'Updating User...';
                submitBtn.disabled = true;
            }
        });

        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        function showErrors(errors) {
            // Remove existing error alert
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

        // Auto-focus first editable input
        document.getElementById('fullName').focus();
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