# Project-Based Learning (PBL) – Final Project Report

---

## 1. Project Title
**Electronics Warehouse Management System (WMS)**  
*Cloud-Native Inventory Operations & Automated QA Verification*

- **GitHub Repository**: [https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT](https://github.com/24rathip-ctrl/WMS-JIRA-PROJECT)
- **Live Deployed Application**: [https://wms-zej1.onrender.com/wms/index.html](https://wms-zej1.onrender.com/wms/index.html)
- **Live QA & Testing Dashboard**: [https://wms-zej1.onrender.com/wms/testing.html](https://wms-zej1.onrender.com/wms/testing.html)
- **Jira Scrum Board**: [https://rbunagpur-team-ehjipock.atlassian.net](https://rbunagpur-team-ehjipock.atlassian.net) (Project Key: `SCRUM`)

---

## 2. Problem Statement & Objectives

### Problem Statement
Modern electronics warehouses handle high-value merchandise (e.g., laptops, flagship smartphones, studio audio gear) subject to rapid turnover. Traditional or manual inventory spreadsheets suffer from:
1. **Stock Discrepancies & Overselling**: Inability to handle concurrent inward shipments and outward dispatch requests, leading to negative inventory.
2. **Lack of Transaction Isolation**: Simultaneous user actions risk data corruption and lost updates without database-level concurrency controls.
3. **Absence of Real-Time Traceability**: Warehouses lack visibility into catalog valuation, low-stock thresholds, and categorized SKU distribution.
4. **Insufficient Quality Verification**: Systems are deployed without rigorous specification-based (black-box) and structural (white-box) test coverage.

### Objectives
- Develop an enterprise-grade Electronics Warehouse Management System with full CRUD catalog capabilities and Indian Rupee (₹) commercial valuation.
- Implement ACID-compliant transactional inventory movements (inward receiving and outward dispatch) with strict non-negative stock enforcement.
- Prevent race conditions under high concurrency through database pessimistic row-locking (`SELECT ... FOR UPDATE`).
- Track and organize all development artifacts within an Agile/Scrum framework using Atlassian Jira.
- Formulate and execute a comprehensive 60-test verification suite (30 Black-Box and 30 White-Box test cases) achieving 100% pass rates.

---

## 3. Proposed Solution & Key Features

### Proposed Solution
A secure, cloud-native Java Servlet web application deployed on Apache Tomcat and backed by an Aiven MySQL managed database with mandatory TLS encryption. The system integrates automated CI/CD via GitHub Actions and features an interactive QA suite verifying compliance in real time.

### Key Features
1. **Electronics Catalog Management**:
   - Centralized catalog of flagship electronics (Apple MacBook Pro, iPhone 16 Pro Max, Sony Bravia OLED, JBL PartyBox, Shure SM7B, etc.).
   - Strict input validation: non-empty names, recognized categories, and positive pricing boundaries (minimum ₹0.01).
   - Duplicate primary key conflict detection returning HTTP `409 Conflict`.
2. **Atomic Inventory Operations**:
   - Inward receiving (+quantity) and Outward dispatch (-quantity).
   - Transactional rollback on invalid movements; inventory cannot drop below zero.
   - Dynamic stock categorization badges: *In Stock*, *Low Stock* (≤ 15 units), and *Out of Stock* (0 units).
3. **Interactive Testing & Verification Console**:
   - Visual test matrix of 30 Black-Box (Equivalence Partitioning, Boundary Value Analysis, State Transition) and 30 White-Box (Statement, Branch, Decision, Path) test cases.
   - Interactive live test execution runner sending real-time HTTP requests against the cloud backend.
   - Dynamic "+ Add Custom Test Case" capability allowing real-time test expansion.
4. **Agile Scrum Traceability**:
   - Every feature and test case mapped to specific Jira user stories (`SCRUM-8`, `SCRUM-9`, `SCRUM-10`, `SCRUM-11`).

---

## 4. Technologies Used

| Layer | Technologies & Tools |
|---|---|
| **Programming Language** | Java (JDK 17 LTS), JavaScript (ES6+), HTML5, CSS3 |
| **Server & Runtime** | Apache Tomcat 9, Java Servlets (JSR 369 / Servlet API 4.0) |
| **Database & Persistence** | Aiven Managed MySQL 8.4, JDBC (MySQL Connector/J 8.4.0), TLS 1.3 |
| **Architecture Pattern** | MVC (Model-View-Controller), DAO (Data Access Object), Singleton Connection Pool |
| **Containerization & Cloud** | Docker (Multi-stage build), Render Cloud Hosting, Linux Temurin |
| **DevOps & CI/CD** | Git, GitHub, GitHub Actions automated verification pipeline |
| **Project Management** | Atlassian Jira Software (Scrum Board, Epics, Sprints, Backlogs) |
| **Testing & QA** | Black-Box Testing (EP, BVA, Error Guessing), White-Box Testing (Control Flow & Path Coverage), PowerShell Test Automation |

---

## 5. Brief Explanation of System Working

1. **Client Interaction**: Users interact with the frontend through a responsive interface built with HTML5, CSS3, and Vanilla JavaScript, navigating between Dashboard, Product Management, Inventory Movement, and Testing.
2. **API Request Dispatching**: Frontend actions trigger asynchronous `fetch()` HTTP requests (`GET`, `POST`, `PUT`) mapped to `/api/products` and `/api/inventory` servlets.
3. **Controller & Business Validation**:
   - Servlets parse and validate incoming payloads against RFC 8259 JSON standards.
   - Boundary limits, required fields, and non-negative constraints are evaluated; invalid inputs immediately return structured JSON errors with HTTP `400 Bad Request`.
4. **Pessimistic Row-Locking & ACID Execution**:
   - When a stock adjustment occurs, `ProductDAO.reduceStock()` disables auto-commit (`conn.setAutoCommit(false)`) and executes `SELECT quantity FROM products WHERE product_id = ? FOR UPDATE`.
   - This places an exclusive database lock on the specific SKU row, preventing concurrent race conditions.
   - If requested decrement exceeds available stock, the transaction executes `conn.rollback()` and raises an exception.
   - If valid, quantity is decremented, committed atomically (`conn.commit()`), and the lock is released.
5. **Quality Assurance Verification**:
   - The embedded automated test runner executes live HTTP assertions against these endpoints, validating response codes, payload integrity, and database consistency in real time with 100% pass rates.
