```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.redupahana.model.User"%>
<%@ page import="com.redupahana.model.Bill"%>
<%@ page import="com.redupahana.model.Customer"%>
<%@ page import="com.redupahana.util.Constants"%>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("auth");
        return;
    }
    
    // Check if user is admin - if not, show access denied
    boolean isAdmin = Constants.ROLE_ADMIN.equals(loggedUser.getRole());
    
    Bill bill = (Bill) request.getAttribute("bill");
    Customer customer = (Customer) request.getAttribute("customer");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    // Set page attributes for sidebar
    request.setAttribute("currentPage", "bill");
    request.setAttribute("pageTitle", "Update Payment Status");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Payment Status - Redupahana</title>
    <style>
        /* Page-specific styles */
        /* Access Denied Styles */
        .access-denied {
            background: white;
            border-radius: 8px;
            padding: 3rem;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            margin-top: 2rem;
        }

        .access-denied-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.7;
        }

        .access-denied h2 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 1rem;
        }

        .access-denied p {
            color: #6c757d;
            font-size: 1.1rem;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        /* Bill Information */
        .bill-info {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 1.2rem;
            margin-bottom: 1.5rem;
            border: 1px solid #e9ecef;
        }

        .bill-info h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1rem;
            font-weight: 600;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem;
            background: white;
            border-radius: 4px;
            font-size: 0.9rem;
        }

        .info-label {
            font-weight: 500;
            color: #6c757d;
        }

        .info-value {
            color: #2c3e50;
            font-weight: 500;
        }

        .current-status {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        /* Status Selection */
        .status-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .status-option {
            position: relative;
            cursor: pointer;
        }

        .status-option input[type="radio"] {
            display: none;
        }

        .status-option label {
            display: block;
            padding: 1rem;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            text-align: center;
            transition: all 0.2s ease;
            cursor: pointer;
            background: white;
            color: #495057;
        }

        .status-option input[type="radio"]:checked + label {
            border-color: #007bff;
            background: #f8f9fa;
        }

        .status-option:hover label {
            border-color: #007bff;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }

        /* Selected status option styling */
        .status-option.selected label {
            border-color: #007bff !important;
            background: #e3f2fd !important;
            color: #1976d2 !important;
            transform: scale(1.02);
            box-shadow: 0 2px 8px rgba(0, 123, 255, 0.2);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .status-options {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .access-denied {
                padding: 1.5rem 1rem;
            }
            
            .access-denied h2 {
                font-size: 1.4rem;
            }
            
            .access-denied p {
                font-size: 0.95rem;
            }
            
            .info-grid {
                gap: 0.5rem;
            }
            
            .info-item {
                flex-direction: column;
                text-align: left;
                padding: 0.4rem;
            }
            
            .info-label {
                margin-bottom: 0.2rem;
                font-size: 0.8rem;
            }
            
            .info-value {
                font-size: 0.85rem;
            }
        }

        /* Enhanced access denied animation */
        .access-denied {
            animation: fadeInScale 0.6s ease-out;
        }

        @keyframes fadeInScale {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <%@ include file="../../includes/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Content Area -->
        <main class="content-area">
            <!-- Page Header -->
            <div class="page-header">
                <h1>💳 Update Payment Status</h1>
                <div class="breadcrumb">
                    <a href="dashboard">Dashboard</a> &gt; 
                    <a href="bill?action=list">Bills</a> &gt; 
                    Update Payment Status
                </div>
            </div>

            <% if (!isAdmin) { %>
                <!-- Access Denied for Cashiers -->
                <div class="access-denied">
                    <div class="access-denied-icon">🚫</div>
                    <h2>Access Denied</h2>
                    <p>
                        Sorry, you don't have permission to access this page.<br>
                        Only administrators can update payment status.<br>
                        Please contact your system administrator if you need access.
                    </p>
                    <a href="bill?action=list" class="btn btn-danger">🔙 Back to Bills</a>
                </div>
            <% } else { %>
                <!-- Success Message -->
                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    ✅ <%= successMessage %>
                </div>
                <% } %>

                <!-- Error Message -->
                <% if (errorMessage != null) { %>
                <div class="alert alert-error">
                    ❌ <%= errorMessage %>
                </div>
                <% } %>

                <% if (bill == null) { %>
                    <div class="alert alert-error">
                        ❌ Bill not found. Please try again.
                    </div>
                    <div style="text-align: center; margin-top: 2rem;">
                        <a href="bill?action=list" class="btn btn-secondary">🔙 Back to Bills</a>
                    </div>
                <% } else { %>
                    <!-- Bill Information -->
                    <div class="bill-info">
                        <h3>📄 Bill Information</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Bill Number:</span>
                                <span class="info-value">#<%= bill.getBillNumber() %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Customer:</span>
                                <span class="info-value">
                                    <%= customer != null ? customer.getName() : bill.getCustomerName() != null ? bill.getCustomerName() : "N/A" %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Bill Date:</span>
                                <span class="info-value"><%= bill.getBillDate() != null ? bill.getBillDate() : "N/A" %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Total Amount:</span>
                                <span class="info-value">Rs. <%= String.format("%.2f", bill.getTotalAmount()) %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Current Status:</span>
                                <span class="info-value">
                                    <span class="current-status status-<%= bill.getPaymentStatus().toLowerCase() %>">
                                        <%= bill.getPaymentStatus() %>
                                    </span>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Cashier:</span>
                                <span class="info-value">
                                    <%= bill.getCashierName() != null ? bill.getCashierName() : "N/A" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Update Payment Status Form -->
                    <div class="form-container">
                        <form action="bill" method="post" id="updatePaymentForm">
                            <input type="hidden" name="action" value="updatePaymentStatus">
                            <input type="hidden" name="billId" value="<%= bill.getBillId() %>">
                            
                            <div class="form-group">
                                <label>💰 Select New Payment Status</label>
                                <div class="status-options">
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="PAID" id="statusPaid" 
                                               <%= "PAID".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusPaid">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">✅</div>
                                            <div>PAID</div>
                                            <small style="opacity: 0.8;">Payment completed</small>
                                        </label>
                                    </div>
                                    
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="PENDING" id="statusPending" 
                                               <%= "PENDING".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusPending">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">⏰</div>
                                            <div>PENDING</div>
                                            <small style="opacity: 0.8;">Awaiting payment</small>
                                        </label>
                                    </div>
                                    
                                    <div class="status-option">
                                        <input type="radio" name="paymentStatus" value="CANCELLED" id="statusCancelled" 
                                               <%= "CANCELLED".equals(bill.getPaymentStatus()) ? "checked" : "" %>>
                                        <label for="statusCancelled">
                                            <div style="font-size: 2rem; margin-bottom: 0.5rem;">❌</div>
                                            <div>CANCELLED</div>
                                            <small style="opacity: 0.8;">Payment cancelled</small>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary" id="submitBtn">
                                    💾 Update Payment Status
                                </button>
                                <a href="bill?action=view&id=<%= bill.getBillId() %>" class="btn btn-secondary">
                                    👁️ View Bill
                                </a>
                                <a href="bill?action=list" class="btn btn-secondary">
                                    🔙 Back to Bills
                                </a>
                            </div>
                        </form>
                    </div>
                <% } %>
            <% } %>
        </main>
    </div>

    <script>
        // Form validation and submission
        const updatePaymentForm = document.getElementById('updatePaymentForm');
        if (updatePaymentForm) {
            updatePaymentForm.addEventListener('submit', function(e) {
                const selectedStatus = document.querySelector('input[name="paymentStatus"]:checked');
                const submitBtn = document.getElementById('submitBtn');
                
                if (!selectedStatus) {
                    e.preventDefault();
                    alert('Please select a payment status before updating.');
                    return false;
                }
                
                // Show confirmation dialog
                const statusValue = selectedStatus.value;
                const statusText = selectedStatus.nextElementSibling.querySelector('div').textContent;
                
                if (!confirm(`Are you sure you want to update the payment status to "${statusText}"?`)) {
                    e.preventDefault();
                    return false;
                }
                
                // Show loading state
                submitBtn.classList.add('loading');
                submitBtn.disabled = true;
            });
        }

        // Status option click handling
        document.querySelectorAll('.status-option').forEach(option => {
            option.addEventListener('click', function() {
                const radio = this.querySelector('input[type="radio"]');
                if (radio) {
                    radio.checked = true;
                    
                    // Update visual selection
                    document.querySelectorAll('.status-option').forEach(opt => {
                        opt.classList.remove('selected');
                    });
                    this.classList.add('selected');
                }
            });
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Update Payment Status page loaded');
            
            // Set initial selected status visual indicator
            const checkedRadio = document.querySelector('input[name="paymentStatus"]:checked');
            if (checkedRadio) {
                checkedRadio.closest('.status-option').classList.add('selected');
            }
            
            // Add visual feedback for status changes
            document.querySelectorAll('input[name="paymentStatus"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    document.querySelectorAll('.status-option').forEach(opt => {
                        opt.classList.remove('selected');
                    });
                    this.closest('.status-option').classList.add('selected');
                });
            });
            
            // Auto-focus on form if admin
            <% if (isAdmin && bill != null) { %>
            const firstStatusOption = document.querySelector('.status-option');
            if (firstStatusOption) {
                firstStatusOption.focus();
            }
            <% } %>
        });
    </script>
</body>
</html>
```