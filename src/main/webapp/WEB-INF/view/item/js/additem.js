document.addEventListener('DOMContentLoaded', function() {
     const form = document.getElementById('addItemForm');
     const stockInput = document.getElementById('stockQuantity');
     const stockLevel = document.getElementById('stockLevel');
     const priceInput = document.getElementById('price');

     // Stock level indicator
     if (stockInput && stockLevel) {
         stockInput.addEventListener('input', function() {
             const quantity = parseInt(this.value) || 0;
             updateStockLevel(quantity);
         });
     }

     // Price formatting
     if (priceInput) {
         priceInput.addEventListener('blur', function() {
             const value = parseFloat(this.value);
             if (!isNaN(value)) {
                 this.value = value.toFixed(2);
             }
         });
     }

     // Form validation
     if (form) {
         form.addEventListener('submit', function(e) {
             let isValid = true;
             const errors = [];

             // Validate required fields
             const name = document.getElementById('name').value.trim();
             const price = parseFloat(document.getElementById('price').value);
             const stockQuantity = parseInt(document.getElementById('stockQuantity').value);
             const category = document.querySelector('input[name="category"]:checked');

             if (!name) {
                 errors.push('Item name is required');
                 document.getElementById('name').classList.add('error');
                 isValid = false;
             } else {
                 document.getElementById('name').classList.remove('error');
             }

             if (isNaN(price) || price <= 0) {
                 errors.push('Valid price is required');
                 document.getElementById('price').classList.add('error');
                 isValid = false;
             } else {
                 document.getElementById('price').classList.remove('error');
             }

             if (isNaN(stockQuantity) || stockQuantity < 0) {
                 errors.push('Valid stock quantity is required');
                 document.getElementById('stockQuantity').classList.add('error');
                 isValid = false;
             } else {
                 document.getElementById('stockQuantity').classList.remove('error');
             }

             if (!category) {
                 errors.push('Please select a category');
                 isValid = false;
             }

             if (!isValid) {
                 e.preventDefault();
                 showErrors(errors);
             } else {
                 // Show loading state
                 const submitBtn = form.querySelector('button[type="submit"]');
                 submitBtn.textContent = 'Adding Item...';
                 submitBtn.disabled = true;
             }
         });
     }

     function updateStockLevel(quantity) {
         if (quantity <= 10) {
             stockLevel.textContent = 'Low Stock';
             stockLevel.className = 'stock-level stock-low';
         } else if (quantity <= 50) {
             stockLevel.textContent = 'Medium Stock';
             stockLevel.className = 'stock-level stock-medium';
         } else {
             stockLevel.textContent = 'Good Stock';
             stockLevel.className = 'stock-level stock-good';
         }
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
     document.getElementById('name').focus();
 });

 function selectCategory(categoryValue) {
     // Remove selected class from all options
     document.querySelectorAll('.category-option').forEach(function(option) {
         option.classList.remove('selected');
     });

     // Add selected class to clicked option
     if (event && event.currentTarget) {
         event.currentTarget.classList.add('selected');
     }

     // Check the radio button
     const radioButton = document.getElementById('category' + categoryValue);
     if (radioButton) {
         radioButton.checked = true;
     }
 }