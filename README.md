# Electronics Warehouse Management System (WMS)

A simple, robust, and professional **Electronics Warehouse Management System** built for the Software Engineering Practical Examination. Designed specifically for clear faculty viva defense, zero framework bloat, and enterprise-grade reliability.

---

## 1. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript (ES6) | Zero dependencies or frontend frameworks. Responsive, accessible (WCAG AA), clean UI. |
| **Backend** | Java Servlets (Java 17, `javax.servlet` API) | Direct Java EE / Jakarta baseline, easy to explain in viva without framework magic. |
| **Data Access** | JDBC with `PreparedStatement` | Direct SQL control, parameterized queries prevent SQL injection. |
| **Database** | MySQL 8.4 Community Server | ACID-compliant relational storage with InnoDB row locking. |
| **Server** | Apache Tomcat 9.0.97 | High-performance, lightweight Java servlet container. |

---

## 2. Implemented Modules & Jira Mapping

| Jira Issue | Module | Features & Verification |
|---|---|---|
| **SCRUM-8** | Product Creation & Listing | &bull; Add new warehouse SKUs (Product ID, Name, Category, Price, Description)<br>&bull; Strict server-side validation for missing required fields<br>&bull; Rejection of non-numeric, zero, and negative prices<br>&bull; Duplicate Product ID detection (`409 Conflict`)<br>&bull; Responsive catalog data table with live search/filter |
| **SCRUM-9** | Product Update | &bull; Edit modal dialog with pre-filled attributes<br>&bull; Immutable primary key enforcement (Product ID is read-only)<br>&bull; Server-side validation on updated name, category, and price<br>&bull; `404 Not Found` handling for non-existent IDs |
| **SCRUM-10** | Inventory Management | &bull; Inward receiving (add stock) and outward dispatch (reduce stock)<br>&bull; Rejection of zero, negative, and non-numeric quantities<br>&bull; Prevention of stock reductions greater than available stock<br>&bull; ACID transaction with `SELECT ... FOR UPDATE` row locking to guarantee stock never drops below 0<br>&bull; Dynamic stock status badges (In Stock, Low Stock &le; 10, Out of Stock = 0) |
| **SCRUM-11** | Testing & Verification | &bull; Automated test suite (`test/run_tests.ps1`) executing 22 distinct edge cases<br>&bull; 100% test pass rate recorded with status codes and response bodies in `test/test_results.csv`<br>&bull; Comprehensive manual test plan in `test/manual_test_plan.md` |

---

## 3. Project Directory Structure

```
c:\Users\vidhi\OneDrive\Desktop\Jira project\
├── .gitignore                      # Prevents secrets, compiled classes, and binaries from Git
├── build.bat                       # One-click Windows CMD build script
├── build.ps1                       # PowerShell build & deployment script
├── README.md                       # Complete documentation & Viva defense guide
├── config/
│   ├── db.properties.example       # Example config template committed to Git
│   └── db.properties               # Real DB credentials (gitignored, kept private)
├── lib/
│   └── mysql-connector-j-8.4.0.jar # Official MySQL JDBC driver
├── sql/
│   └── schema.sql                  # Database schema & least-privilege user creation script
├── src/com/wms/
│   ├── model/
│   │   └── Product.java            # Product POJO with native JSON serialization
│   ├── dao/
│   │   └── ProductDAO.java         # JDBC Data Access Object (Parameterized SQL & Transactions)
│   ├── servlet/
│   │   ├── ProductServlet.java     # RESTful controller for SCRUM-8 and SCRUM-9
│   │   └── InventoryServlet.java   # RESTful controller for SCRUM-10
│   └── util/
│       ├── DBConnection.java       # Thread-safe JDBC connection manager
│       └── HttpUtil.java           # Parameter parsing, security headers, XSS prevention
├── web/
│   ├── index.html                  # Operations Dashboard & live KPI summary
│   ├── products.html               # Product Catalog, Add Form, and Edit Modal
│   ├── inventory.html              # Stock Levels Table, Adjustment Form, and Quick Adjust Modal
│   ├── 404.html                    # Custom 404 error page
│   ├── 500.html                    # Custom 500 error page
│   ├── favicon.svg                 # Warehouse SVG icon
│   ├── css/
│   │   └── styles.css              # Accessible, clean, restrained slate/navy styling
│   ├── js/
│   │   ├── products.js             # Vanilla JS product controller with XSS escaping
│   │   └── inventory.js            # Vanilla JS inventory controller with validation
│   └── WEB-INF/
│       ├── web.xml                 # Servlet mappings & error page routing
│       ├── classes/                # Compiled .class files and classpath db.properties
│       └── lib/                    # Bundled mysql-connector-j driver
├── dist/
│   └── wms.war                     # Ready-to-deploy standalone web application archive
└── test/
    ├── manual_test_plan.md         # Detailed test execution report and evidence
    ├── run_tests.ps1               # Automated test runner verifying all 22 test scenarios
    └── test_results.csv            # Actual exported test execution data
```

---

## 4. Setup & Running Instructions

### Prerequisites
1. **JDK 17+** (Installed at `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot`)
2. **MySQL 8.4** (Installed at `C:\Program Files\MySQL\MySQL Server 8.4`)
3. **Apache Tomcat 9.0.97** (Extracted at `C:\apache-tomcat-9.0.97`)

### Step 1: Start MySQL Server
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld.exe" --datadir="C:\Users\vidhi\mysql-data" --port=3306 --console
```

### Step 2: Initialize Database & Dedicated User
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root < "c:\Users\vidhi\OneDrive\Desktop\Jira project\sql\schema.sql"
```

### Step 3: Build & Deploy Application
Run either the batch file or PowerShell script:
```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
# OR
.\build.bat
```

### Step 4: Start Apache Tomcat
```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
& "C:\apache-tomcat-9.0.97\bin\catalina.bat" run
```

### Step 5: Access the Web Application
Open your web browser and navigate to:
- **Dashboard:** [http://localhost:8080/wms/index.html](http://localhost:8080/wms/index.html)
- **Product Management:** [http://localhost:8080/wms/products.html](http://localhost:8080/wms/products.html)
- **Inventory Management:** [http://localhost:8080/wms/inventory.html](http://localhost:8080/wms/inventory.html)

---

## 5. Security & Robustness Checklist

1. **SQL Injection Prevention:** Every database interaction in `ProductDAO.java` strictly utilizes `java.sql.PreparedStatement` with parameterized placeholders (`?`). String concatenation is never used to build queries.
2. **Cross-Site Scripting (XSS) Prevention:**
   - Frontend: Vanilla JavaScript uses `escapeHtml()` helper before writing any dynamic user data to the DOM.
   - Backend: Servlets set security headers:
     - `X-Content-Type-Options: nosniff`
     - `X-Frame-Options: DENY`
     - `X-XSS-Protection: 1; mode=block`
3. **Negative Stock Prevention:** In `ProductDAO.reduceStock()`, database transactions (`conn.setAutoCommit(false)`) and pessimistic row locking (`SELECT quantity FROM products WHERE product_id = ? FOR UPDATE`) are used. If `requested_reduction > available_stock`, the transaction is rolled back and an `IllegalArgumentException` is raised, preventing negative inventory even under concurrent requests.
4. **Least-Privilege Database User:** The application connects as `wms_user`, granted only `SELECT, INSERT, UPDATE, DELETE` on `wms_db`. It does not have administrative `DROP`, `GRANT`, or `ALTER` privileges.
5. **No Hard-Coded Credentials:** Credentials reside in `config/db.properties` which is ignored by `.gitignore`. `config/db.properties.example` provides a clean template.

---

## 6. Faculty Viva Defense Guide (Q&A)

### Q1: Why did you choose Java Servlets and vanilla JavaScript instead of Spring Boot or React?
**Answer:** "The objective was to master and demonstrate core software engineering fundamentals: understanding the HTTP request-response lifecycle, raw servlet dispatching (`HttpServlet`), native DOM manipulation without virtual DOM overhead, and direct relational database interaction via JDBC without hiding ORM complexity behind Hibernate or Spring Data."

### Q2: How does your system prevent SQL Injection?
**Answer:** "We use `PreparedStatement` across all DAO methods (`ProductDAO.java`). In JDBC, a `PreparedStatement` pre-compiles the SQL query structure in the database engine first. User-supplied parameters are transmitted separately and treated strictly as literal data values, never as executable SQL code."

### Q3: How do you prevent inventory from going negative during concurrent orders?
**Answer:** "In `ProductDAO.reduceStock()`, we disable auto-commit to begin a database transaction. We execute `SELECT quantity FROM products WHERE product_id = ? FOR UPDATE`. The `FOR UPDATE` clause places an exclusive row-level lock on that specific product row. Any concurrent transaction must wait until our validation check and update complete. If the requested reduction exceeds available stock, we issue `conn.rollback()` and throw an `IllegalArgumentException` which returns HTTP 400 with an informative error message."

### Q4: How is duplicate product entry prevented?
**Answer:** "At the database level, `product_id` is defined as the `PRIMARY KEY`. At the application level in `ProductServlet`, before inserting, we execute `dao.productExists(productId)`. If true, the servlet immediately returns HTTP 409 Conflict with `A product with ID 'XYZ' already exists.`, preventing database constraint violations and providing clear feedback to the warehouse operator."

### Q5: How do you protect the application from XSS attacks?
**Answer:** "We sanitize all user data before rendering it in the DOM using an `escapeHtml()` function that converts `&`, `<`, `>`, `"`, and `'` into HTML entity equivalents. Additionally, all servlet API responses specify `Content-Type: application/json; charset=UTF-8` and send security headers like `X-Content-Type-Options: nosniff` and `X-Frame-Options: DENY`."

---

## 7. Automated Test Verification Results (SCRUM-11)

All 22 test cases were executed automatically against the live Tomcat server and passed with 100% accuracy:

| Test ID | Module | Scenario | Expected HTTP | Actual HTTP | Result |
|---|---|---|---|---|---|
| **TC-01** | SCRUM-8 | Valid Product Creation | 201 Created | 201 | **PASS** |
| **TC-02** | SCRUM-8 | Missing Product ID | 400 Bad Request | 400 | **PASS** |
| **TC-03** | SCRUM-8 | Missing Product Name | 400 Bad Request | 400 | **PASS** |
| **TC-04** | SCRUM-8 | Missing Category | 400 Bad Request | 400 | **PASS** |
| **TC-05** | SCRUM-8 | Missing Unit Price | 400 Bad Request | 400 | **PASS** |
| **TC-06** | SCRUM-8 | Zero / Negative Price | 400 Bad Request | 400 | **PASS** |
| **TC-07** | SCRUM-8 | Non-Numeric Price | 400 Bad Request | 400 | **PASS** |
| **TC-08** | SCRUM-8 | Duplicate Product ID Rejection | 409 Conflict | 409 | **PASS** |
| **TC-09** | SCRUM-8 | Product Catalog Retrieval | 200 OK | 200 | **PASS** |
| **TC-10** | SCRUM-8 | Single Product Fetch by ID | 200 OK | 200 | **PASS** |
| **TC-11** | SCRUM-9 | Update Product Details | 200 OK | 200 | **PASS** |
| **TC-12** | SCRUM-9 | Reject Update with Empty Name | 400 Bad Request | 400 | **PASS** |
| **TC-13** | SCRUM-9 | Reject Update with Negative Price | 400 Bad Request | 400 | **PASS** |
| **TC-14** | SCRUM-9 | Update Non-Existent Product ID | 404 Not Found | 404 | **PASS** |
| **TC-15** | SCRUM-10 | View Inventory Stock Levels | 200 OK | 200 | **PASS** |
| **TC-16** | SCRUM-10 | Inward Stock Addition (+100) | 200 OK | 200 | **PASS** |
| **TC-17** | SCRUM-10 | Outward Stock Reduction (-30) | 200 OK | 200 | **PASS** |
| **TC-18** | SCRUM-10 | Reject Zero Quantity Adjustment | 400 Bad Request | 400 | **PASS** |
| **TC-19** | SCRUM-10 | Reject Negative Quantity Adjustment | 400 Bad Request | 400 | **PASS** |
| **TC-20** | SCRUM-10 | Reject Non-Numeric Quantity | 400 Bad Request | 400 | **PASS** |
| **TC-21** | SCRUM-10 | Prevent Reduction > Available Stock | 400 Bad Request | 400 | **PASS** |
| **TC-22** | SCRUM-10 | Adjust Stock on Missing Product | 404 Not Found | 404 | **PASS** |

---

## 8. Live Demonstration Checklist

During your project demonstration or viva:
1. **Show Dashboard (`index.html`):** Point out the live aggregate counts (Total Products, Units in Stock, Low Stock count).
2. **Add a Product (`products.html`):**
   - Attempt to click "Add Product" with empty inputs &rarr; show immediate validation banner.
   - Enter invalid price (e.g. `-10` or `abc`) &rarr; show rejection message.
   - Enter valid details (ID: `PRD-301`, Name: `Pallet Inverter`, Category: `Material Handling`, Price: `799.00`) &rarr; click Add &rarr; show success banner & row appear in table.
   - Try to re-add `PRD-301` &rarr; show `409 Conflict: A product with ID 'PRD-301' already exists.`
3. **Update a Product (`products.html`):**
   - Click "Edit" on `PRD-301` &rarr; show modal with pre-filled fields. Note that Product ID is immutable.
   - Update price to `849.50` and save &rarr; verify table updates immediately.
4. **Adjust Stock (`inventory.html`):**
   - Select `PRD-301` &rarr; note current stock is `0` (Out of Stock badge).
   - Inward movement: Add `50` units &rarr; stock becomes `50` (In Stock badge).
   - Outward movement: Reduce `20` units &rarr; stock becomes `30`.
   - Attempt to reduce `100` units &rarr; show system rejection: `Cannot reduce by 100. Current stock is only 30.`
5. **Show Code Architecture:** Open `ProductDAO.java` to showcase the `PreparedStatement` queries and transaction logic with `FOR UPDATE`.

---

## 9. Cloud Deployment (Render + Aiven MySQL)

The application can be deployed to the cloud using **Render** (Docker web service) and **Aiven** (managed MySQL).

### Step 1: Create Aiven MySQL Service

1. Sign up at [aiven.io](https://aiven.io) and create a **Free MySQL** service.
2. From the Aiven dashboard, note the connection details:
   - **Host** (e.g. `mysql-xyz.aiven.io`)
   - **Port** (e.g. `12345`)
   - **Database** (default: `defaultdb`)
   - **User** (default: `avnadmin`)
   - **Password** (shown once at creation)

### Step 2: Initialize the Database Schema

Run the cloud-compatible schema script against your Aiven database:

```bash
mysql -h <HOST> -P <PORT> -u <USER> -p<PASSWORD> \
      --ssl-mode=REQUIRED <DATABASE> < sql/schema_cloud.sql
```

This creates the `products` table and seeds sample warehouse data. No `CREATE DATABASE` or `CREATE USER` is needed — Aiven provisions those automatically.

### Step 3: Create the Render Web Service

1. Sign up at [render.com](https://render.com) and click **New → Web Service**.
2. Connect the GitHub repository: `24rathip-ctrl/WMS-JIRA-PROJECT`.
3. Choose **Docker** as the runtime. Render will auto-detect the `Dockerfile`.
4. Select the **Free** plan, and set the branch to `main`.
5. Under **Environment Variables**, add these three secrets:

   | Key          | Value                                                                                          |
   |---|---|
   | `WMS_DB_URL`  | `jdbc:mysql://<HOST>:<PORT>/<DATABASE>?sslMode=REQUIRED&serverTimezone=UTC` (or `useSSL=true&requireSSL=true`) |
   | `WMS_DB_USER` | `avnadmin` (or your Aiven user)                                                                |
   | `WMS_DB_PASS` | Your Aiven password                                                                            |

6. Click **Create Web Service**. Render will build the Docker image and deploy automatically.

### Step 4: Access the Live Application

Once the Render deploy completes, your WMS is live at:

- **Dashboard:** `https://<your-render-service>.onrender.com/wms/`
- **Products:** `https://<your-render-service>.onrender.com/wms/products.html`
- **Inventory:** `https://<your-render-service>.onrender.com/wms/inventory.html`

### Architecture (Cloud)

```
Browser → Render (Docker/Tomcat 9) → Aiven MySQL (SSL)
           ├── Dockerfile (multi-stage build)
           ├── render.yaml (service config)
           └── Environment variables (secrets)
```

> **Note:** Credentials are never committed to Git. They are injected as environment variables at runtime. `DBConnection.java` reads `WMS_DB_URL`, `WMS_DB_USER`, and `WMS_DB_PASS` from the environment automatically.
