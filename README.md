# Pahana Edu Online Billing System

A comprehensive web-based billing management system designed for Pahana Edu, a leading bookshop in Colombo City. This system automates customer account management, inventory control, and billing operations to replace traditional manual processes.

## Project Overview

The Pahana Edu Online Billing System is a distributed web application built using Java technologies, implementing a three-tier architecture with proper separation of concerns. The system provides secure user authentication, comprehensive customer management, efficient book inventory control, and automated billing calculations.

### Business Context
Pahana Edu serves hundreds of customers monthly and required a computerized solution to manage billing information efficiently. The manual processes were time-consuming and prone to errors, necessitating a robust digital solution that could handle customer accounts, inventory management, and billing operations seamlessly.

## Core Features

### User Authentication System
- Secure username and password-based authentication
- Role-based access control for different user types
- Session management with automatic timeout
- Password hashing using industry-standard algorithms
- Login attempt monitoring and security measures

### Customer Account Management
- Customer registration with unique account number generation
- Complete customer profile management including personal details
- Address and contact information storage
- Customer search and filtering capabilities
- Account status management (active/inactive)
- Customer transaction history tracking

### Book and Item Management
- Comprehensive book catalog with detailed information
- ISBN, title, author, publisher, and pricing management
- Stock quantity tracking and inventory control
- Book category classification and organization
- Search functionality across multiple book attributes
- Stock level monitoring and low inventory alerts

### Billing and Payment System
- Automated bill generation with unique bill numbers
- Multi-item billing with quantity and pricing calculations
- Discount application and tax calculations
- Payment status tracking (paid, pending, overdue)
- Bill modification and cancellation capabilities
- Comprehensive billing reports and analytics

### Reporting and Analytics
- Daily, weekly, and monthly sales reports
- Customer purchase history and patterns
- Inventory status reports and stock analysis
- Payment status summaries and outstanding amounts
- Revenue tracking and financial analytics
- Customizable report generation with date ranges

### System Administration
- User account management and role assignment
- System configuration and parameter settings
- Database backup and maintenance operations
- Audit trail and activity logging
- System performance monitoring
- Security settings and access control management

## Technical Architecture

### Three-Tier Architecture Implementation

**Presentation Layer**
- Java Server Pages (JSP) for dynamic web content
- HTML5 and CSS3 for modern user interface design
- JavaScript for client-side interactions and validations
- Bootstrap framework for responsive design
- AJAX for asynchronous server communication

**Business Logic Layer**
- Java Servlets for request processing and control
- Service classes implementing business rules and validations
- Data Transfer Objects (DTOs) for clean data exchange
- Utility classes for common operations and helper functions
- Exception handling and error management systems

**Data Access Layer**
- Data Access Objects (DAO) pattern implementation
- MySQL database with optimized schema design
- Connection pooling for efficient database resource management
- Transaction management for data consistency
- Prepared statements for SQL injection prevention

### Design Pattern Implementation

**Model-View-Controller (MVC) Pattern**
- Clear separation between data, presentation, and control logic
- Servlets acting as controllers for request routing
- JSP pages serving as views for user interface
- Model classes representing business entities and data

**Data Access Object (DAO) Pattern**
- Abstraction layer for database operations
- Centralized data access logic with consistent interfaces
- Easy maintenance and database independence
- Proper exception handling and resource management

**Singleton Pattern**
- Database connection factory implementation
- Service layer instances for efficient resource utilization
- Configuration management with single point of access
- Thread-safe implementations for concurrent access

**Factory Pattern**
- Object creation abstraction for different entity types
- Flexible object instantiation based on runtime parameters
- Centralized object creation logic for maintainability
- Easy extension for new entity types

## Technology Stack and Dependencies

### Core Technologies
- Java Development Kit (JDK) 11 or higher
- Java Enterprise Edition (JEE) specifications
- Apache Tomcat 9.0 as the web application server
- MySQL 8.0 for relational database management
- Apache Maven 3.8 for project build and dependency management

### Development Frameworks and Libraries
- Java Servlet API 4.0 for web request handling
- JavaServer Pages (JSP) 2.3 for dynamic content generation
- JSTL (JSP Standard Tag Library) for enhanced JSP functionality
- MySQL Connector/J for database connectivity
- Apache Commons libraries for utility functions

### Testing Framework
- JUnit 5 for unit testing and test automation
- Mockito framework for mock object creation
- Maven Surefire Plugin for test execution and reporting
- AssertJ for fluent assertion statements
- H2 Database for in-memory testing scenarios

### Build and Development Tools
- Apache Maven for project lifecycle management
- Git for version control and source code management
- GitHub for remote repository hosting and collaboration
- GitHub Actions for continuous integration and deployment
- SonarQube for code quality analysis and metrics

## Installation and Configuration Guide

### System Requirements
- Operating System: Windows 10/11, macOS 10.15+, or Linux Ubuntu 18.04+
- Java Development Kit (JDK) 11 or later versions
- Apache Maven 3.8.0 or higher for build management
- MySQL Server 8.0 or compatible version
- Apache Tomcat 9.0 or later for web application deployment
- Minimum 4GB RAM and 2GB available disk space

### Database Setup and Configuration

**Step 1: MySQL Installation and Setup**
Create a new database instance for the application:
```sql
CREATE DATABASE r_pahanaedu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;