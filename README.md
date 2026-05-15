# 💆 Professional Beauty & Wellness Network — Database System

A full relational database system for a luxury spa management platform, built as a university project for **Introduction to Databases (IS211)** at Cairo University's Faculty of Computers and Artificial Intelligence.

> Professional Beauty & Wellness Network project — Physical Data Model & SQL Implementation

---

## 👥 Team
- Omar Rashad (20247008)
- Eyad WalaaEldin Ahmed (20246024)
- Osama Ehab (20247001)
- Hamsa Nagy (20246124)
- Almokhtar Medhat (20246020)
- Mariz Ashraf Fayez (20257034)

---

## 📋 System Overview

A luxury wellness brand manages several high-end spas offering relaxation and grooming treatments. The system handles:

- Spa location and private room management
- Therapist registration and skill mapping
- Client membership and session scheduling
- Product inventory tracking per session
- Therapist calendar and availability management

---

## 🗂️ Database Design

### Entities (9 Tables)

| Entity | Description |
|---|---|
| SPA_LOCATION | Spa branches with rooms, hours, and contact info |
| THERAPIST | Certified staff assigned to spa locations |
| SKILL | Treatment specializations |
| THERAPIST_SKILL | M:N resolution — therapist certifications with dates |
| CLIENT | Membership profiles with contact info |
| SERVICE | Treatments with pricing, duration, and therapeutic benefit |
| SESSION | Bookings linking client, therapist, service, and location |
| PRODUCT | Wellness products with stock quantity |
| SESSION_PRODUCT | M:N resolution — product consumption tracking per session |

### Key Relationships
- A therapist is employed by one spa location
- A client books sessions at a spa
- A session is conducted by one therapist for one service
- Sessions consume products tracked in SESSION_PRODUCT

---

## 🔍 SQL Queries Included

1. Most booked treatment service (MAX bookings)
2. Therapists with no sessions scheduled last month
3. Client who spent the most on premium services last month
4. Services with zero bookings last month
5. Available therapists per spa location last month
6. Full therapist profile with total completed sessions

---

## 🐍 Python Application

`beauty_app.py` provides a Python interface to the database for querying and interacting with the system programmatically.

---

## 🛠️ Tech Stack

- **SQL** — DDL schema creation + DML analytical queries
- **Python** — database connectivity and interface
- **PowerAMC** — CDM/PDM conceptual and physical modeling

---

## 📁 Project Files

```
├── Beauty_DDL.sql     # Full schema — CREATE TABLE statements + constraints
├── beauty_app.py      # Python database interface
├── Beauty_CDM.cdm     # Conceptual Data Model (PowerAMC)
└── The Professional Beauty & Wellness Network.pdf # Full report with CDM and PDM diagrams
```

---

## 🎓 Course

Introduction to Database Systems — IS211/SIS211  
Cairo University, Faculty of Computers and Artificial Intelligence
