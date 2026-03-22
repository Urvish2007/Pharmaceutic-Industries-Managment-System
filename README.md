# Pharmaceutic Industry Management System

This repository contains the **Database Management System (DBMS)** designed for the **IT-214** course at **Dhirubhai Ambani University**. Our system is engineered to streamline the complex operations of a pharmaceutical manufacturing and distribution hub, prioritizing data integrity and scalable architecture.

---

### ## Project Overview
The **Pharmaceutic Industry Management System** tracks the complete lifecycle of medicine production. By replacing manual record-keeping with a centralized digital infrastructure, we manage everything from raw material procurement to chemical processing and final distribution.

### ## Key Features & Modules
* **Inventory & Production Tracking:** Real-time monitoring of raw materials, chemicals, and finished medicinal products.
* **Workforce Management:** A structured system for managing employees, including roles, shifts, and contact details.
* **Transactional Logging:** Detailed tracking of sales and distributions to ensure supply chain transparency.
* **Robust Relationship Mapping:** Our ER-Diagram establishes critical links such as:
    * **Production Logs:** Connecting workers to specific medicine batches.
    * **Ingredient Management:** Linking chemicals to final medicine products.
    * **Distribution Networks:** Managing product flow to various departments or clients.

---

### ## Database Normalization: Why BCNF?
Our schema is designed to meet **Boyce-Codd Normal Form (BCNF)** standards to ensure the high level of consistency required for medical data.

* **Elimination of Partial Dependencies:** Every non-prime attribute is fully functionally dependent on the primary key, meeting 2NF standards.
* **Elimination of Transitive Dependencies:** No non-prime attribute depends on another non-prime attribute, meeting 3NF standards.
* **The BCNF Requirement:** For every non-trivial functional dependency $X \rightarrow Y$, $X$ must be a **Super Key**.
* **The Result:** This rigorous normalization prevents update anomalies. For example, updating a worker's department will not inadvertently corrupt data regarding the medicine batches they produced.

---

### ## Tech Stack
* **Database:** PostgreSQL (Relational DBMS)
* **Documentation:** LaTeX (Overleaf)

---
