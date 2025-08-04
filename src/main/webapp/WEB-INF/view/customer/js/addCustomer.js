document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('addCustomerForm');
    const phoneInput = document.getElementById('phone');
    const emailInput = document.getElementById('email');

    // Phone number validation
    if (phoneInput) {
        phoneInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '').substring(0, 10);
        });
    }

    // Form validation
    if (form) {
        form.addEventListener('submit', function(e) {
            let isValid = true;
            const errors = [];

            // Validate required fields
            const name = document.getElementById('name').value.trim();
            const phone = document.getElementById('phone').value.trim();

            if (!name) {
                errors.push('Customer name is required');
                document.getElementById('name').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('name').classList.remove('error');
            }

            if (!phone || phone.length !== 10) {
                errors.push('Valid 10-digit phone number is required');
                document.getElementById('phone').classList.add('error');
                isValid = false;
            } else {
                document.getElementById('phone').classList.remove('error');
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

            if (!isValid) {
                e.preventDefault();
                showErrors(errors);
            } else {
                // Show loading state
                const submitBtn = form.querySelector('button[type="submit"]');
                if (submitBtn) {
                    submitBtn.textContent = 'Adding Customer...';
                    submitBtn.disabled = true;
                }
            }
        });
    }

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

    // Auto-focus first input
    const nameField = document.getElementById('name');
    if (nameField) {
        nameField.focus();
    }
});/**
 * 
 */