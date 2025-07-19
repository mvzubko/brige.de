# Software Requirements Specification for Brige Service Management

## Table of Contents

1. [Introduction](#1-introduction)  
    1.1. [Purpose of the Document](#11-purpose-of-the-document)  
    1.2. [Scope](#12-scope)  
    1.3. [Definitions, Abbreviations and Acronyms](#13-definitions-abbreviations-and-acronyms)  

2. [General System Description](#2-general-system-description)  
    2.1. [System Overview](#21-system-overview)  
    2.2. [User Classes and Characteristics](#22-user-classes-and-characteristics)  
    2.3. [Operating Environment](#23-operating-environment)  
    2.4. [Assumptions and Dependencies](#24-assumptions-and-dependencies)  
    2.5. [Constraints](#25-constraints)  

3. [Functional Requirements](#3-functional-requirements)  
    3.1. [Request Registration](#31-request-registration)  
    3.2. [Work Completion Registration](#32-work-completion-registration)  
    3.3. [Work Completion Confirmation](#33-work-completion-confirmation)  
    3.4. [Report Sending](#34-report-sending)  
    3.5. [Report Generation and Analytics](#35-report-generation-and-analytics)  
    3.6. [Administration and User Management](#36-administration-and-user-management)  

4. [Non-Functional Requirements](#4-non-functional-requirements)  
    4.1. [Offline Mode](#41-offline-mode)  
    4.2. [Security](#42-security)  
    4.3. [Performance](#43-performance)  
    4.4. [Usability](#44-usability)  
    4.5. [Reliability](#45-reliability)  
    4.6. [Energy Efficiency](#46-energy-efficiency)  

5. [Interface Requirements](#5-interface-requirements)  
    5.1. [User Interface](#51-user-interface)  
    5.2. [Integration and API](#52-integration-and-api)  

6. [System and Hardware Requirements](#6-system-and-hardware-requirements)  
    6.1. [System Requirements](#61-system-requirements)  
    6.2. [Hardware Requirements](#62-hardware-requirements)  

7. [Technology Stack and Architecture](#7-technology-stack-and-architecture)  
    7.1. [General Architecture](#71-general-architecture)  
    7.2. [User Management and Security](#72-user-management-and-security)  
    7.3. [Integration and Communication](#73-integration-and-communication)  
    7.4. [Monitoring and Maintenance](#74-monitoring-and-maintenance)  

8. [Training and Documentation](#8-training-and-documentation)  
    8.1. [User Training](#81-user-training)  
    8.2. [Training Materials](#82-training-materials)  
    8.3. [Technical Documentation](#83-technical-documentation)  

9. [Appendices](#9-appendices)  
    - [Appendix A: Interface Mockups](ui.md)

---

## 1. Introduction

### 1.1. Purpose of the Document
This document describes the functional and non-functional requirements for developing the Brige Service Management system, which is designed to automate service work tracking at customer sites.

The system's goal is to simplify the process of registering completed work, managing requests, storing media data, and integrating with external services. This document serves as the foundation for development, testing, and implementation of the system, as well as ensuring compliance with security and performance requirements.

### 1.2. Scope
The Brige Service Management system will be hosted on a secure domain and is intended for use only by authorized company employees. The main system functions include:
- Managing and registering completed work
- Managing requests, task distribution, and storing media data (images, documents)
- Recording photos, descriptions, and other information needed for work analysis and planning
- Organizing workflow processes

### 1.3. Definitions, Abbreviations and Acronyms
- SRS – Software Requirements Specification
- GDPR – General Data Protection Regulation
- SSL – Secure Sockets Layer encryption technology
- API – Application Programming Interface
- Keycloak – authentication and authorization management platform used for single sign-on (SSO) and access control
- PostgreSQL – relational database management system chosen for storing the system's main data
- Redis – in-memory data store used for caching and speeding up access to frequently requested information
- Brige Service Management – system for automating and tracking work at customer sites
- Brige Client – cross-platform client application for accessing system functionality

## 2. General System Description

### 2.1. System Overview
Brige Service Management is a new system that replaces current manual processes for managing requests, issuing work orders, registering completed work, and other company workflow processes.

The system will include a client application (Brige Client) for mobile devices, as well as an administrative interface for managing users and system settings.

In the context of this document, the system means an interconnected structure consisting of the following components:
- **Request management service**, including:
  - Request registration
  - Issuing work orders to technicians
  - Managing priorities and completion deadlines
  - Tracking task completion status
  - Analyzing completed work
- **User management service**, including:
  - User authentication and authorization
  - User registration
  - Managing roles and access rights
- **Work management service**, including:
  - Registering completed work
  - Tracking used materials
  - Uploading photos and documents confirming completed work
  - Customer confirmation of completed work
  - Ordering materials and equipment
- **Data management service**, including:
  - Storing and analytical processing of requests, work, and media data
  - Ensuring data security (encryption, authorization)
- **Reporting service**, including:
  - Generating reports on requests, work, and users
  - Exporting data to various formats (PDF, Excel)
- **External system integration service**, including:
  - Integration with mail servers for sending reports
- **Brige Client mobile application** for iOS, Android, Windows, and Linux
- **Monitoring and logging service** (second phase), including:
  - System status and performance monitoring
  - Event and error logging for diagnostics and troubleshooting
- **Notification service** (second phase), including:
  - Sending notifications to users about request status and completed work
  - Corporate chat for messaging between users

The system will be developed using modern technologies and approaches, including microservice architecture, containerization, and cloud solutions. Main focus will be on security, performance, and usability.

### 2.2. User Classes and Characteristics
| User Class | Description |
| ---------- | ----------- |
| ***Regular Client*** | A client is an authorized user of Brige Client software who can independently register work requests in the system, track their completion progress, and confirm actual work completion and leave feedback. |
| ***Service Technician*** | A service technician is an authorized user of Brige Client software who receives service work requests and can register completed work, upload media data, change request status, and submit requests to company management for raw materials needed for work completion. |
| ***Sales Manager*** | A sales manager is an authorized user of Brige Client software who researches customer needs, offers company solutions and services, and can register work requests. |
| ***Operator*** | An operator is an authorized user of Brige Client software who has access to the administrative part of the software and can manage users, configure access rights, view reports and statistics on completed work. The operator also reviews work requests, distributes them among service technicians and controls their completion, and can interact with clients to clarify request details and receive feedback. |
| ***Administrator*** | An administrator is an authorized user who has full system access, including user management, external service integration configuration, system status monitoring, and security management. The administrator is also responsible for technical support and solving user problems. |

### 2.3. Operating Environment
The operating environment where the system is deployed must meet the following requirements:

#### OE-1. Operating System
The system will run on modern operating systems such as Linux (e.g., Ubuntu, CentOS) for the server part and Android, iOS, Windows, and Linux for the Brige Client application.

#### OE-2. Application Runtime Environment
The system will be deployed on a server with support for modern web technologies, including HTTPS and SSL support to ensure secure data transmission.

#### OE-3. Database
The system will use PostgreSQL as the main database for storing requests, work, users, and media data. Redis will be used for caching frequently requested information and speeding up data access.

#### OE-4. Web Server
The system will use its own web server or Nginx/Apache as a reverse proxy server for processing incoming requests and routing them to appropriate microservices. The web server will be configured to work with HTTPS and SSL, ensuring secure data transmission between clients and server.

#### OE-5. Brige Client Mobile Application
Brige Client will be developed using Flutter, ensuring cross-platform compatibility and the ability to work on Android, iOS, Windows, and Linux.

#### OE-6. Containerization and Orchestration
The system will be deployed in containers using Docker, ensuring service isolation and simplifying the deployment process. Kubernetes will be used for container orchestration, scaling management, and ensuring high system availability.

#### OE-7. Data Exchange Interfaces
The system will integrate with corporate mail services and others through RESTful API. For inter-service communication, gRPC or REST API will be used, ensuring system flexibility and scalability.

#### OE-8. Security
The system will be hosted on a secure domain using SSL certificates for data encryption. User authorization will be performed through Keycloak, ensuring centralized user management and SSO (single sign-on) support. All data will be stored in accordance with GDPR requirements, including encryption of personal data (if present in the system) and restricting access to it.

#### OE-9. Monitoring and Logging
The system will include a monitoring and logging service that will track system status, performance, and errors. Logs will be stored in centralized storage for subsequent analysis and problem diagnosis. Prometheus or similar tools will be used for system status monitoring, and Grafana service will be used for data visualization.

### 2.4. Assumptions and Dependencies
- The system must be accessible only to authorized users
- The Brige Client application functions normally only when the server part of the system is functioning normally and accessible via the Internet
- Users must have a stable internet connection to work with the system when uploading media data and synchronizing data
- User devices must have sufficient free space to store Brige Client application data, including media data

### 2.5. Constraints
- The system must be accessible only through a secure web interface (SSL gateway)
- User authorization is performed using login and password
- Data processing and storage must comply with European standards requirements
- The system must provide offline mode capability for the Brige Client mobile application, with subsequent data synchronization when connection is restored
- System operation should not lead to significant battery drain on mobile devices, especially in offline mode and with weak network coverage

## 3. Functional Requirements

### 3.1. Request Registration

#### 3.1.1. Functionality Scope
- The system must ensure automatic generation of a unique reference/order number when creating it
- Users with "Operator" or "Sales Manager" roles must be able to enter request data, including:
  - ***Client name** (it's unclear what is meant by client name, possibly this is the contact person's full name or company name, possibly there are individual and corporate clients)???*
  - Client company name
  - Client address
  - Client contact person
  - Client contact number
- Users with "Operator" role must be able to enter service technician data, including:
  - Technician name
  - Company name (BRIGE, BRIGE Service UG, Conveyor System UG, etc.)
  - Planned visit date
  - Planned arrival time
- The system must support the ability to select the type of planned work:
  - Installation
  - Repair
  - Maintenance
  - Inspection
  - Commercial visit
  - Consultation
  - Other (with the ability to enter text description)

#### 3.1.2. Detailed Functionality Description
---
| Function | Description |
| -------- | ----------- |
| **Request.Creation\*** |  |
| &nbsp;&nbsp;&nbsp;&nbsp;.RegistrationCheck | The system must check if the user is registered in the database. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.NoRegistration | If the user is not registered, the system offers the following options: </br>&nbsp;&nbsp; - Register now. </br>&nbsp;&nbsp; - Continue request processing with limited functionality. </br>&nbsp;&nbsp; - Cancel request processing. |
| &nbsp;&nbsp;&nbsp;&nbsp;.ClientData | Filling in client data. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.ClientName: | Entering client company name with the ability to select from a list (for existing clients) or enter a new value (for new clients). |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.ClientAddress | Entering client address with automatic format checking (e.g., presence of city, street, and house number). |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.ContactPerson | Entering contact person's full name. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.ContactNumber | Client contact phone number with correct format validation. |
| &nbsp;&nbsp;&nbsp;&nbsp;.ServiceTechnicianData* | Filling in service technician data |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.TechnicianCompany | Dropdown list with available companies (BRIGE, BRIGE Service UG, Conveyor System UG, etc.). | 
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.TechnicianSelection | Dropdown list with available service technicians from the selected company. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.VisitDate | Selecting visit date through calendar with date relevance checking. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.ArrivalTime | Entering expected arrival time in HH:MM format with data correctness validation. |
| &nbsp;&nbsp;&nbsp;&nbsp;.WorkType | User selects planned work type through checkboxes: </br>&nbsp;&nbsp; - Installation </br>&nbsp;&nbsp; - Repair </br>&nbsp;&nbsp; - Maintenance </br>&nbsp;&nbsp; - Inspection </br>&nbsp;&nbsp; - Commercial visit </br>&nbsp;&nbsp; - Consultation </br>&nbsp;&nbsp; - Other |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.OtherSelected | A text field appears for detailed work type description. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Confirmation | User confirms entered data and sends the request for processing. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Notification | System sends notification about request creation and saves the request to the database. |
---
\* Request.Creation can be implemented in two variants:
- **Variant 1**: Users with "Operator" or "Sales Manager" roles can create requests by entering necessary data about the client and service technician, work type, and planned visit date.
- **Variant 2**: Users with "Client" role can create requests by entering necessary data about themselves and the type of work they want to order.

### 3.2. Work Completion Registration

#### 3.2.1. Functionality Scope
- The system must allow users with "Service Technician" role to register completed work, including text description, used materials, and additional tasks
- The system must support the ability to specify urgency of additional work (low, medium, high, critical)
- The system must support the ability to upload media data (photos, documents) to confirm completed work
- The system must automatically record work start and completion time

#### 3.2.2. Detailed Functionality Description
| Function | Description |
| -------- | ----------- |
| **Work.Registration** | Detailed processing of completed work registration process. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Start | User with "Service Technician" role clicks "Start Work" button.<br>- System automatically saves work start time.<br>- Geolocation is recorded (if permission is granted).<br>- Timer is started to track work duration. <br>- System changes request status to "In Progress". |
| &nbsp;&nbsp;&nbsp;&nbsp;.WorkDescription | User specifies completed work stages and execution features.<br>Basic text formatting is supported. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Materials | User selects materials from dropdown list |
| &nbsp;&nbsp;&nbsp;&nbsp;.Tasks | Entering additional task description (if needed).<br>Selecting task urgency (Low, Medium, High, Critical).<br> Ability to add multiple tasks. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Media | Ability to upload multiple images and documents.<br> System checks file format and size, displays error messages if inconsistencies are found. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Pause | If needed, user can temporarily pause work execution.<br> System stops timer and saves pause time. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Continue | After resolving the pause reason, user clicks "Continue Work".<br> System resumes timer accounting for previously interrupted time. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Completion | After work completion, user records its completion.<br>- System automatically saves work end time and calculates total execution time.<br>- Request is moved to "Completed" status. |

### 3.3. Work Completion Confirmation

#### 3.3.1. Functionality Scope
- The system must provide a form for confirming successful work completion, including the ability to enter client comments
- The system must support obtaining client digital signature to confirm completed work

#### 3.3.2. Detailed Functionality Description
---
| Function | Description |
| -------- | ----------- |
| **Work.Confirmation** |  |
| &nbsp;&nbsp;&nbsp;&nbsp;.Completed | Client can select "Yes" or "No" to confirm successful work completion. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Comment | Client can leave a comment about the completed work. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Name | Client enters their name  |
| &nbsp;&nbsp;&nbsp;&nbsp;.Signature | Client can draw their signature on the device screen. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Confirmation | When clicking "Confirm" button, the system must perform the following actions: </br>&nbsp;&nbsp; - Save client comment and signature. </br>&nbsp;&nbsp; - Change request status to "Finished". |
---

### 3.4. Report Sending

#### 3.4.1. Functionality Scope
- The system must automatically send completed forms and reports to the server, to the specified corporate address (e.g., *info@brige.de*), and also to the client's address

#### 3.4.2. Detailed Functionality Description
---
| Function | Description |
| -------- | ----------- |
| **Report.Sending** |  |
| &nbsp;&nbsp;&nbsp;&nbsp;.SendingOptions | The system must provide the following report sending options as checkboxes: </br>&nbsp;&nbsp; - Send to server (always enabled). </br>&nbsp;&nbsp; - Send to corporate email. </br>&nbsp;&nbsp; - Send to client's personal email. |
| &nbsp;&nbsp;&nbsp;&nbsp;.ClientEmail | If "Send to client's personal email" is selected, the system must request the client's email address. |
| &nbsp;&nbsp;&nbsp;&nbsp;.ReportFormat | The system must provide the ability to select report format: </br>&nbsp;&nbsp; - PDF (default) </br>&nbsp;&nbsp; - Excel </br>&nbsp;&nbsp; - Both formats. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Sending | When clicking "Send" button, the system must perform the following actions: </br>&nbsp;&nbsp; - Generate reports in selected formats. </br>&nbsp;&nbsp; - Send reports to server and specified email addresses. </br>&nbsp;&nbsp; - Display success or error message. </br> Request status must be changed to "Sent". | 
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.NoNetwork | If there's no internet access, the system must save the report locally and try to send it on next network connection. </br> Request status must be changed to "Sending". |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.NetworkRestored | When connection is restored, the system must automatically try to send previously saved reports. </br> Request status must be changed to "Sent". |
---

### 3.5. Report Generation and Analytics

#### 3.5.1. Functionality Scope
- The system must provide the ability to generate reports on requests, completed work, and users for a specific time period
- The system must support data export to various formats (PDF, Excel) for further analysis and reporting

#### 3.5.2. Detailed Functionality Description
---
| Function | Description |
| -------- | ----------- |
| **Report.Generation** |  |
| &nbsp;&nbsp;&nbsp;&nbsp;.Period | User selects period for report generation (start and end date). | 
| &nbsp;&nbsp;&nbsp;&nbsp;.ReportType | User selects report type: </br>&nbsp;&nbsp; - By requests </br>&nbsp;&nbsp; - By completed work </br>&nbsp;&nbsp; - By users. |
| &nbsp;&nbsp;&nbsp;&nbsp;.ReportFormat | User selects report format: </br>&nbsp;&nbsp; - PDF </br>&nbsp;&nbsp; - Excel </br>&nbsp;&nbsp; - Both formats. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Filters | User can apply filters to refine report data: </br>&nbsp;&nbsp; - By users </br>&nbsp;&nbsp; - By request statuses </br>&nbsp;&nbsp; - By work types. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Generate | When clicking "Generate Report" button, the system must perform the following actions: </br>&nbsp;&nbsp; - Collect data for the specified period. </br>&nbsp;&nbsp; - Generate report in selected format. </br>&nbsp;&nbsp; - Display report on screen and/or save it locally. </br>&nbsp;&nbsp; - Offer user to download report or send it by email. |
---

### 3.6. Administration and User Management

#### 3.6.1. Functionality Scope
- The system must provide an administrative interface for managing users, roles, and access rights
- The system must ensure system status monitoring, performance monitoring, and event logging for diagnostics and troubleshooting
- The system must support integration with corporate mail services for sending notifications and reports

#### 3.6.2. Detailed Functionality Description
---
| Function | Description |
| -------- | ----------- |
| **Administration** | |
| &nbsp;&nbsp;&nbsp;&nbsp;.Users | Users with "Administrator" role can manage system users regarding: </br>&nbsp;&nbsp; - Adding new users. </br>&nbsp;&nbsp; - Editing user data (name, email, role). </br>&nbsp;&nbsp; - Deleting users. </br>&nbsp;&nbsp; - Assigning roles and access rights. |
| &nbsp;&nbsp;&nbsp;&nbsp;.Roles | Administrator can manage user roles: </br>&nbsp;&nbsp; - Creating new roles. </br>&nbsp;&nbsp; - Editing access rights for existing roles. </br>&nbsp;&nbsp; - Deleting roles. |
---

## 4. Non-Functional Requirements

### 4.1. Offline Mode
- The Brige Client application must be able to function in offline mode, allowing users to register work, enter data, and take photos without internet connection
- All data entered in offline mode must be automatically synchronized with the server when internet connection is restored
- The system must notify users about successful synchronization and any synchronization errors

### 4.2. Security
- All data transmission between client and server must be encrypted using SSL/TLS protocols
- User authentication must be performed through Keycloak with support for strong passwords and multi-factor authentication
- All user actions must be logged for security auditing
- Personal data (if any) must be stored in accordance with GDPR requirements

### 4.3. Performance
- The system response time for basic operations (data loading, form submission) must not exceed 3 seconds
- The mobile application must launch within 5 seconds on modern devices
- The system must support concurrent work of at least 100 users without performance degradation
- Media file upload must be optimized to minimize data usage

### 4.4. Usability
- The user interface must be intuitive and require minimal training
- The application must support multiple languages (German, English, Russian)
- The interface must be adaptive and work correctly on various screen sizes
- All key functions must be accessible within 3 clicks from the main screen

### 4.5. Reliability
- System availability must be at least 99.5% during business hours
- The system must automatically backup data daily
- In case of server failure, data entered in offline mode must be preserved and synchronized after recovery
- The system must handle errors gracefully and provide informative error messages

### 4.6. Energy Efficiency
- The mobile application must be optimized for minimal battery consumption
- Background processes must be minimized when the app is not actively used
- Network operations must be efficient to reduce power consumption

## 5. Interface Requirements

### 5.1. User Interface
- The interface must follow modern design principles and be visually appealing
- Navigation must be consistent throughout the application
- Forms must include data validation with clear error messages
- The application must support touch gestures for mobile devices
- The interface must be accessible for users with disabilities

### 5.2. Integration and API
- The system must provide RESTful API for integration with external systems
- API must be documented and versioned
- Integration with email services must support various protocols (SMTP, IMAP)
- The system must support webhook notifications for real-time updates

## 6. System and Hardware Requirements

### 6.1. System Requirements
**Server Requirements:**
- Operating System: Linux (Ubuntu 20.04+ or CentOS 8+)
- Minimum RAM: 8 GB
- Minimum Storage: 500 GB SSD
- Network: High-speed internet connection

**Mobile Application Requirements:**
- Android: Version 8.0 or higher
- iOS: Version 12.0 or higher
- Windows: Windows 10 or higher
- Linux: Ubuntu 18.04+ or equivalent

### 6.2. Hardware Requirements
**Mobile Devices:**
- Minimum RAM: 2 GB
- Storage: At least 1 GB free space
- Camera: For photo capture functionality
- GPS: For location services (optional)
- Internet connection: Wi-Fi or mobile data

## 7. Technology Stack and Architecture

### 7.1. General Architecture
- Microservices architecture using containerization (Docker)
- Container orchestration with Kubernetes
- Load balancing and auto-scaling capabilities
- Cloud-native deployment with high availability

### 7.2. User Management and Security
- Keycloak for authentication and authorization
- SSL/TLS encryption for all communications
- Role-based access control (RBAC)
- Security auditing and logging

### 7.3. Integration and Communication
- RESTful APIs for external integrations
- gRPC for internal service communication
- Message queuing for asynchronous processing
- API gateway for request routing and rate limiting

### 7.4. Monitoring and Maintenance
- Prometheus for system monitoring
- Grafana for data visualization and dashboards
- Centralized logging with log aggregation
- Automated backup and disaster recovery procedures

## 8. Training and Documentation

### 8.1. User Training
- Online training modules for each user role
- Video tutorials for common tasks
- Interactive help system within the application
- Regular training sessions for new features

### 8.2. Training Materials
- User manuals in multiple languages
- Quick reference guides
- FAQ and troubleshooting guides
- Best practices documentation

### 8.3. Technical Documentation
- System architecture documentation
- API documentation with examples
- Deployment and configuration guides
- Maintenance and troubleshooting procedures

## 9. Appendices
- [Appendix A: Interface Mockups](ui.md)
