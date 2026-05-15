
-- SECTION 1: DATABASE CREATION

CREATE DATABASE BeautyWellnessDB;
GO
USE BeautyWellnessDB;
GO

-- SECTION 2: TABLE CREATION (DDL)

-- 1. SPA_LOCATION
CREATE TABLE SPA_LOCATION (
    spa_id            INT           PRIMARY KEY,
    name              VARCHAR(50)   NOT NULL,
    city              VARCHAR(50)   NOT NULL,
    rooms             VARCHAR(50),
    address           VARCHAR(200),
    num_private_rooms INT,
    opening_time      TIME,
    closing_time      TIME,
    spa_phone         VARCHAR(20)
);
GO

-- 2. SKILL
CREATE TABLE SKILL (
    skill_id    INT          PRIMARY KEY,
    skill_name  VARCHAR(80)  NOT NULL,
    description VARCHAR(200)
);
GO

-- 3. THERAPIST
CREATE TABLE THERAPIST (
    therapist_id    INT          PRIMARY KEY,
    spa_id          INT          NOT NULL,
    hire_date       DATE,
    therapist_fname VARCHAR(50)  NOT NULL,
    therapist_lname VARCHAR(50)  NOT NULL,
    therapist_email VARCHAR(100),
    therapist_phone VARCHAR(20),
    CONSTRAINT EMPLOYS_FK FOREIGN KEY (spa_id) REFERENCES SPA_LOCATION(spa_id)
);
GO

-- 4. THERAPIST_SKILL  (junction: therapist <-> skill, many-to-many)
CREATE TABLE THERAPIST_SKILL (
    therapist_id INT NOT NULL,
    skill_id     INT NOT NULL,
    CONSTRAINT HAS_PK  PRIMARY KEY (therapist_id, skill_id),
    CONSTRAINT HAS_FK  FOREIGN KEY (therapist_id) REFERENCES THERAPIST(therapist_id),
    CONSTRAINT HAS2_FK FOREIGN KEY (skill_id)     REFERENCES SKILL(skill_id)
);
GO

-- 5. CERTIFIED_DATE  (stores when each therapist got certified for a skill)
CREATE TABLE CERTIFIED_DATE (
    therapist_id   INT  NOT NULL,
    skill_id       INT  NOT NULL,
    certified_date DATE NOT NULL,
    CONSTRAINT CERTIFIED_DATE_PK PRIMARY KEY (therapist_id, skill_id),
    CONSTRAINT CERTIFIED_DATE_FK FOREIGN KEY (therapist_id, skill_id)
        REFERENCES THERAPIST_SKILL(therapist_id, skill_id)
);
GO

-- 6. SERVICE
CREATE TABLE SERVICE (
    service_id           INT           PRIMARY KEY,
    skill_id             INT,
    service_name         VARCHAR(100)  NOT NULL,
    service_category     VARCHAR(100),
    duration_minutes     INT,
    price                DECIMAL(10,2),
    therapeutic_benefit  VARCHAR(200),
    CONSTRAINT REQUIRED_FOR_FK FOREIGN KEY (skill_id) REFERENCES SKILL(skill_id)
);
GO

-- 7. CLIENT
CREATE TABLE CLIENT (
    client_id       INT          PRIMARY KEY,
    membership_date DATE,
    membership_type VARCHAR(50),
    client_fname    VARCHAR(50)  NOT NULL,
    client_lname    VARCHAR(50)  NOT NULL,
    client_email    VARCHAR(100),
    client_phone    VARCHAR(20)
);
GO

-- 8. PRODUCT
CREATE TABLE PRODUCT (
    product_id       INT          PRIMARY KEY,
    product_name     VARCHAR(100) NOT NULL,
    brand            VARCHAR(80),
    unit             VARCHAR(20),
    stock_quantity   INT          DEFAULT 0,
    product_category VARCHAR(50)
);
GO

-- 9. SESSION
CREATE TABLE SESSION (
    session_id   INT          PRIMARY KEY,
    service_id   INT          NOT NULL,
    client_id    INT          NOT NULL,
    therapist_id INT          NOT NULL,
    spa_id       INT          NOT NULL,
    scheduled_at DATETIME     NOT NULL,
    status       VARCHAR(20)  DEFAULT 'Scheduled',  -- Scheduled | Completed | Cancelled
    room_number  INT,
    CONSTRAINT PERFORMED_IN_FK FOREIGN KEY (spa_id)       REFERENCES SPA_LOCATION(spa_id),
    CONSTRAINT CONDUCTS_FK     FOREIGN KEY (therapist_id)  REFERENCES THERAPIST(therapist_id),
    CONSTRAINT BOOKS_FK        FOREIGN KEY (client_id)     REFERENCES CLIENT(client_id),
    CONSTRAINT HOSTS_FK        FOREIGN KEY (service_id)    REFERENCES SERVICE(service_id)
);
GO

-- 10. SESSION_PRODUCT  (tracks product consumption per session)
CREATE TABLE SESSION_PRODUCT (
    sp_id         INT            PRIMARY KEY,
    product_id    INT            NOT NULL,
    session_id    INT            NOT NULL,
    quantity_used DECIMAL(10,2),
    CONSTRAINT USES_FK        FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
    CONSTRAINT CONSUMED_IN_FK FOREIGN KEY (session_id) REFERENCES SESSION(session_id)
);
GO

-- SECTION 3: INSERT SAMPLE DATA

-- SPA_LOCATION (5 spas)
INSERT INTO SPA_LOCATION VALUES (1, 'Serenity Spa', 'Cairo',      'A',  '12 Nile St, Cairo',       8, '09:00', '21:00', '0222334455');
INSERT INTO SPA_LOCATION VALUES (2, 'Lotus Retreat', 'Alexandria', 'B', '5 Corniche Ave, Alex',     6, '10:00', '22:00', '0333445566');
INSERT INTO SPA_LOCATION VALUES (3, 'Zen Haven',     'Giza',       'C', '7 Pyramid Rd, Giza',       5, '09:00', '20:00', '0244556677');
INSERT INTO SPA_LOCATION VALUES (4, 'Bloom Wellness','Cairo',      'D', '88 Garden City, Cairo',    7, '08:00', '21:00', '0211223344');
INSERT INTO SPA_LOCATION VALUES (5, 'Pearl Spa',     'Hurghada',   'E', '3 Red Sea Blvd, Hurghada', 4, '10:00', '23:00', '0655667788');
GO

-- SKILL (6 skills)
INSERT INTO SKILL VALUES (1, 'Swedish Massage',    'Full-body relaxation technique');
INSERT INTO SKILL VALUES (2, 'Deep Tissue Massage','Targets muscle knots and tension');
INSERT INTO SKILL VALUES (3, 'Facial Treatment',   'Skin cleansing and rejuvenation');
INSERT INTO SKILL VALUES (4, 'Aromatherapy',       'Essential oil-based therapy');
INSERT INTO SKILL VALUES (5, 'Hot Stone Therapy',  'Heated basalt stone massage');
INSERT INTO SKILL VALUES (6, 'Hair Treatment',     'Scalp and hair care procedures');
GO

-- THERAPIST (8 therapists)
INSERT INTO THERAPIST VALUES (1, 1, '2020-03-15', 'Layla',   'Hassan',  'layla@serenity.com',    '01011112222');
INSERT INTO THERAPIST VALUES (2, 1, '2019-07-01', 'Omar',    'Khalil',  'omar@serenity.com',     '01022223333');
INSERT INTO THERAPIST VALUES (3, 2, '2021-01-10', 'Nour',    'Salem',   'nour@lotus.com',        '01033334444');
INSERT INTO THERAPIST VALUES (4, 2, '2022-05-20', 'Ahmed',   'Farouk',  'ahmed@lotus.com',       '01044445555');
INSERT INTO THERAPIST VALUES (5, 3, '2018-09-05', 'Sara',    'Mostafa', 'sara@zen.com',          '01055556666');
INSERT INTO THERAPIST VALUES (6, 3, '2023-02-14', 'Karim',   'Nabil',   'karim@zen.com',         '01066667777');
INSERT INTO THERAPIST VALUES (7, 4, '2020-11-30', 'Rana',    'Ibrahim', 'rana@bloom.com',        '01077778888');
INSERT INTO THERAPIST VALUES (8, 5, '2021-06-01', 'Hassan',  'Ali',     'hassan@pearl.com',      '01088889999');
GO

-- THERAPIST_SKILL (many-to-many)
INSERT INTO THERAPIST_SKILL VALUES (1,1); INSERT INTO THERAPIST_SKILL VALUES (1,3);
INSERT INTO THERAPIST_SKILL VALUES (2,2); INSERT INTO THERAPIST_SKILL VALUES (2,5);
INSERT INTO THERAPIST_SKILL VALUES (3,1); INSERT INTO THERAPIST_SKILL VALUES (3,4);
INSERT INTO THERAPIST_SKILL VALUES (4,3); INSERT INTO THERAPIST_SKILL VALUES (4,6);
INSERT INTO THERAPIST_SKILL VALUES (5,2); INSERT INTO THERAPIST_SKILL VALUES (5,5);
INSERT INTO THERAPIST_SKILL VALUES (6,1); INSERT INTO THERAPIST_SKILL VALUES (6,4);
INSERT INTO THERAPIST_SKILL VALUES (7,3); INSERT INTO THERAPIST_SKILL VALUES (7,6);
INSERT INTO THERAPIST_SKILL VALUES (8,1);
GO

-- CERTIFIED_DATE
INSERT INTO CERTIFIED_DATE VALUES (1,1,'2020-04-01'),(1,3,'2020-04-15');
INSERT INTO CERTIFIED_DATE VALUES (2,2,'2019-08-01'),(2,5,'2020-01-10');
INSERT INTO CERTIFIED_DATE VALUES (3,1,'2021-02-01'),(3,4,'2021-06-01');
INSERT INTO CERTIFIED_DATE VALUES (4,3,'2022-06-01'),(4,6,'2022-09-01');
INSERT INTO CERTIFIED_DATE VALUES (5,2,'2018-10-01'),(5,5,'2019-03-01');
INSERT INTO CERTIFIED_DATE VALUES (6,1,'2023-03-01'),(6,4,'2023-07-01');
INSERT INTO CERTIFIED_DATE VALUES (7,3,'2021-01-01'),(7,6,'2021-05-01');
INSERT INTO CERTIFIED_DATE VALUES (8,1,'2021-07-01');
GO

-- SERVICE (8 services)
INSERT INTO SERVICE VALUES (1,1,'Swedish Relaxation Massage','Massage',       60, 350.00, 'Full-body stress relief');
INSERT INTO SERVICE VALUES (2,2,'Deep Tissue Therapy',       'Massage',       90, 550.00, 'Chronic pain relief');
INSERT INTO SERVICE VALUES (3,3,'Hydrating Facial',          'Facial',        45, 400.00, 'Skin hydration');
INSERT INTO SERVICE VALUES (4,3,'Anti-Aging Facial',         'Facial',        60, 600.00, 'Reduces fine lines');
INSERT INTO SERVICE VALUES (5,4,'Lavender Aromatherapy',     'Aromatherapy',  75, 450.00, 'Anxiety reduction');
INSERT INTO SERVICE VALUES (6,5,'Hot Stone Massage',         'Massage',       90, 700.00, 'Deep muscle relaxation');
INSERT INTO SERVICE VALUES (7,6,'Keratin Hair Treatment',    'Hair',          120,800.00, 'Frizz control and shine');
INSERT INTO SERVICE VALUES (8,1,'Couples Massage Package',   'Massage',       60, 900.00, 'Relaxation for two');
GO

-- CLIENT (10 clients)
INSERT INTO CLIENT VALUES (1, '2023-01-10','Premium','Salma',   'Aziz',    'salma@email.com',   '01011110001');
INSERT INTO CLIENT VALUES (2, '2023-03-22','Standard','Hana',   'Fawzy',   'hana@email.com',    '01022220002');
INSERT INTO CLIENT VALUES (3, '2022-11-05','Premium','Mohamed', 'Rashad',  'mo@email.com',      '01033330003');
INSERT INTO CLIENT VALUES (4, '2024-01-15','Standard','Dina',   'Samir',   'dina@email.com',    '01044440004');
INSERT INTO CLIENT VALUES (5, '2023-07-20','VIP',     'Tamer',  'Wahba',   'tamer@email.com',   '01055550005');
INSERT INTO CLIENT VALUES (6, '2024-02-01','Standard','Reem',   'Kamel',   'reem@email.com',    '01066660006');
INSERT INTO CLIENT VALUES (7, '2023-09-18','Premium','Youssef', 'Nasser',  'youss@email.com',   '01077770007');
INSERT INTO CLIENT VALUES (8, '2024-03-10','Standard','Amira',  'Saber',   'amira@email.com',   '01088880008');
INSERT INTO CLIENT VALUES (9, '2023-05-01','VIP',     'Khaled', 'Mansour', 'khaled@email.com',  '01099990009');
INSERT INTO CLIENT VALUES (10,'2024-04-05','Standard','Nada',   'Lotfy',   'nada@email.com',    '01010100010');
GO

-- PRODUCT (8 products)
INSERT INTO PRODUCT VALUES (1, 'Lavender Essential Oil', 'Aroma Pure',  'ml',  500, 'Aromatherapy');
INSERT INTO PRODUCT VALUES (2, 'Shea Butter Cream',      'Natura',      'g',   300, 'Massage');
INSERT INTO PRODUCT VALUES (3, 'Rose Hip Serum',         'SkinGlow',    'ml',  200, 'Facial');
INSERT INTO PRODUCT VALUES (4, 'Hot Basalt Stones Set',  'StoneWorks',  'set',  20, 'Hot Stone');
INSERT INTO PRODUCT VALUES (5, 'Coconut Massage Oil',    'PureTouch',   'ml',  600, 'Massage');
INSERT INTO PRODUCT VALUES (6, 'Keratin Treatment Kit',  'HairPro',     'kit',  50, 'Hair');
INSERT INTO PRODUCT VALUES (7, 'Green Tea Toner',        'SkinGlow',    'ml',  250, 'Facial');
INSERT INTO PRODUCT VALUES (8, 'Eucalyptus Body Scrub',  'Natura',      'g',   400, 'Massage');
GO

-- SESSION (20 sessions — mix of last month April 2026 and older)
-- Last month = April 2026
INSERT INTO SESSION VALUES (1, 1,1,1,1,'2026-04-02 10:00','Completed',3);
INSERT INTO SESSION VALUES (2, 3,2,1,1,'2026-04-03 11:00','Completed',1);
INSERT INTO SESSION VALUES (3, 2,3,2,1,'2026-04-05 14:00','Completed',4);
INSERT INTO SESSION VALUES (4, 6,4,2,1,'2026-04-07 16:00','Completed',2);
INSERT INTO SESSION VALUES (5, 4,5,3,2,'2026-04-08 09:00','Completed',1);
INSERT INTO SESSION VALUES (6, 5,6,3,2,'2026-04-10 13:00','Completed',2);
INSERT INTO SESSION VALUES (7, 1,7,5,3,'2026-04-12 10:00','Completed',1);
INSERT INTO SESSION VALUES (8, 3,8,4,2,'2026-04-14 15:00','Completed',3);
INSERT INTO SESSION VALUES (9, 7,9,4,2,'2026-04-15 11:00','Completed',2);
INSERT INTO SESSION VALUES (10,4,10,7,4,'2026-04-17 09:00','Completed',1);
INSERT INTO SESSION VALUES (11,1,1,1,1,'2026-04-18 10:00','Completed',3);
INSERT INTO SESSION VALUES (12,6,3,5,3,'2026-04-19 14:00','Completed',2);
INSERT INTO SESSION VALUES (13,2,5,2,1,'2026-04-21 16:00','Completed',4);
INSERT INTO SESSION VALUES (14,8,7,6,3,'2026-04-22 11:00','Completed',1);
INSERT INTO SESSION VALUES (15,5,9,6,3,'2026-04-24 13:00','Completed',3);
INSERT INTO SESSION VALUES (16,3,2,1,1,'2026-04-25 10:00','Completed',1);
INSERT INTO SESSION VALUES (17,1,4,7,4,'2026-04-26 09:00','Completed',2);
INSERT INTO SESSION VALUES (18,6,6,5,3,'2026-04-28 15:00','Completed',1);
-- Older sessions (March 2026) — for therapist with no recent bookings
INSERT INTO SESSION VALUES (19,7,8,8,5,'2026-03-05 10:00','Completed',1);
INSERT INTO SESSION VALUES (20,1,10,8,5,'2026-03-20 11:00','Completed',2);
GO

-- SESSION_PRODUCT (product usage per session)
INSERT INTO SESSION_PRODUCT VALUES (1,  5,1, 30.0);  -- Coconut oil used in session 1
INSERT INTO SESSION_PRODUCT VALUES (2,  3,2, 10.0);  -- Rose Hip serum in facial
INSERT INTO SESSION_PRODUCT VALUES (3,  2,3, 50.0);  -- Shea Butter in deep tissue
INSERT INTO SESSION_PRODUCT VALUES (4,  4,4, 1.0);   -- Stones in hot stone
INSERT INTO SESSION_PRODUCT VALUES (5,  7,5, 15.0);  -- Toner in facial
INSERT INTO SESSION_PRODUCT VALUES (6,  1,6, 20.0);  -- Lavender oil in aromatherapy
INSERT INTO SESSION_PRODUCT VALUES (7,  5,7, 30.0);  -- Coconut oil
INSERT INTO SESSION_PRODUCT VALUES (8,  3,8, 10.0);  -- Rose Hip serum
INSERT INTO SESSION_PRODUCT VALUES (9,  6,9, 1.0);   -- Keratin kit in hair treatment
INSERT INTO SESSION_PRODUCT VALUES (10, 7,10,15.0);  -- Toner in facial
INSERT INTO SESSION_PRODUCT VALUES (11, 8,11,40.0);  -- Body scrub
INSERT INTO SESSION_PRODUCT VALUES (12, 4,12,1.0);   -- Stones
INSERT INTO SESSION_PRODUCT VALUES (13, 2,13,50.0);  -- Shea butter
INSERT INTO SESSION_PRODUCT VALUES (14, 5,14,30.0);  -- Coconut oil
INSERT INTO SESSION_PRODUCT VALUES (15, 1,15,25.0);  -- Lavender oil
INSERT INTO SESSION_PRODUCT VALUES (16, 3,16,10.0);  -- Rose Hip serum
INSERT INTO SESSION_PRODUCT VALUES (17, 5,17,30.0);  -- Coconut oil
INSERT INTO SESSION_PRODUCT VALUES (18, 4,18,1.0);   -- Stones
GO

-- SECTION 4: REQUIRED CRUD OPERATIONS


-- ---------- 2 INSERT STATEMENTS on 2 different tables ----------

-- INSERT 1: Add a new client
INSERT INTO CLIENT (client_id, membership_date, membership_type, client_fname, client_lname, client_email, client_phone)
VALUES (11, GETDATE(), 'Standard', 'Yasmine', 'Tarek', 'yasmine@email.com', '01011119999');

-- INSERT 2: Schedule a new session
INSERT INTO SESSION (session_id, service_id, client_id, therapist_id, spa_id, scheduled_at, status, room_number)
VALUES (21, 1, 11, 1, 1, '2026-05-10 10:00', 'Scheduled', 3);


-- ---------- 2 DELETE STATEMENTS on 2 different tables (with conditions) ----------

-- DELETE 1: Remove a cancelled session
DELETE FROM SESSION
WHERE session_id = 21 AND status = 'Scheduled';

-- DELETE 2: Remove a client who has no sessions
DELETE FROM CLIENT
WHERE client_id = 11
  AND client_id NOT IN (SELECT DISTINCT client_id FROM SESSION);


-- ---------- 2 UPDATE STATEMENTS on 2 different tables (with conditions) ----------

-- UPDATE 1: Mark a specific session as Completed
UPDATE SESSION
SET status = 'Completed'
WHERE session_id = 1 AND status = 'Scheduled';

-- UPDATE 2: Update a product's stock quantity after restocking
UPDATE PRODUCT
SET stock_quantity = stock_quantity + 100
WHERE product_id = 1 AND product_category = 'Aromatherapy';

-- SECTION 5: SELECT QUERIES (single-table)

-- View all spa locations
SELECT * FROM SPA_LOCATION;

-- View all clients
SELECT * FROM CLIENT;

-- View all services sorted by price
SELECT service_id, service_name, service_category, duration_minutes, price
FROM SERVICE
ORDER BY price DESC;

-- View all completed sessions
SELECT * FROM SESSION WHERE status = 'Completed';

-- View current product inventory
SELECT product_name, brand, stock_quantity, unit FROM PRODUCT ORDER BY stock_quantity;

-- SECTION 6: SELECT QUERIES (multi-table with JOINs)

-- JOIN 1: Session details with client, therapist, service and spa names
SELECT
    s.session_id,
    s.scheduled_at,
    s.status,
    s.room_number,
    c.client_fname + ' ' + c.client_lname  AS client_name,
    t.therapist_fname + ' ' + t.therapist_lname AS therapist_name,
    sv.service_name,
    sv.price,
    sp.name AS spa_name
FROM SESSION s
JOIN CLIENT       c  ON s.client_id    = c.client_id
JOIN THERAPIST    t  ON s.therapist_id = t.therapist_id
JOIN SERVICE      sv ON s.service_id   = sv.service_id
JOIN SPA_LOCATION sp ON s.spa_id       = sp.spa_id;

-- JOIN 2: Product consumption per session (which products used in which session)
SELECT
    ses.session_id,
    ses.scheduled_at,
    p.product_name,
    p.brand,
    sp.quantity_used,
    p.unit
FROM SESSION_PRODUCT sp
JOIN SESSION s   ON sp.session_id = s.session_id
JOIN PRODUCT  p  ON sp.product_id  = p.product_id
JOIN SESSION  ses ON ses.session_id = sp.session_id;

-- JOIN 3: Therapist skills (therapist name + skill name)
SELECT
    t.therapist_fname + ' ' + t.therapist_lname AS therapist_name,
    sk.skill_name,
    cd.certified_date
FROM THERAPIST_SKILL ts
JOIN THERAPIST     t  ON ts.therapist_id = t.therapist_id
JOIN SKILL         sk ON ts.skill_id     = sk.skill_id
LEFT JOIN CERTIFIED_DATE cd ON cd.therapist_id = ts.therapist_id AND cd.skill_id = ts.skill_id;

-- SECTION 7: INQUIRY QUERIES (as specified in the project brief)

-- INQUIRY 1: Which treatment "service" was the most popular (max bookings)?
SELECT TOP 1
    sv.service_name,
    COUNT(s.session_id) AS total_bookings
FROM SESSION s
JOIN SERVICE sv ON s.service_id = sv.service_id
GROUP BY sv.service_name
ORDER BY total_bookings DESC;

-- INQUIRY 2: Which therapist had no client sessions during the last month (April 2026)?
SELECT
    t.therapist_id,
    t.therapist_fname + ' ' + t.therapist_lname AS therapist_name
FROM THERAPIST t
WHERE t.therapist_id NOT IN (
    SELECT DISTINCT therapist_id
    FROM SESSION
    WHERE MONTH(scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
      AND YEAR(scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
);

-- INQUIRY 3: Who was the client who spent the most on "premium" category services last month?
SELECT TOP 1
    c.client_fname + ' ' + c.client_lname AS client_name,
    SUM(sv.price) AS total_spent
FROM SESSION s
JOIN CLIENT  c  ON s.client_id  = c.client_id
JOIN SERVICE sv ON s.service_id = sv.service_id
WHERE sv.service_category = 'Massage'   -- 'premium' maps to high-price Massage category
  AND MONTH(s.scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
  AND YEAR(s.scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
GROUP BY c.client_id, c.client_fname, c.client_lname
ORDER BY total_spent DESC;

-- INQUIRY 4: Identify services that were NOT booked by any client last month
SELECT
    sv.service_id,
    sv.service_name,
    sv.service_category
FROM SERVICE sv
WHERE sv.service_id NOT IN (
    SELECT DISTINCT service_id
    FROM SESSION
    WHERE MONTH(scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
      AND YEAR(scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
);

-- INQUIRY 5: Available therapists at each spa location last month
SELECT
    sp.name AS spa_name,
    sp.city,
    t.therapist_fname + ' ' + t.therapist_lname AS therapist_name,
    sk.skill_name
FROM SPA_LOCATION sp
JOIN THERAPIST     t  ON t.spa_id       = sp.spa_id
JOIN THERAPIST_SKILL ts ON ts.therapist_id = t.therapist_id
JOIN SKILL         sk ON sk.skill_id    = ts.skill_id
ORDER BY sp.name, t.therapist_lname;

-- INQUIRY 6: For each therapist, retrieve their profile and total sessions completed
SELECT
    t.therapist_id,
    t.therapist_fname + ' ' + t.therapist_lname AS therapist_name,
    t.therapist_email,
    t.therapist_phone,
    sp.name AS primary_spa,
    COUNT(s.session_id) AS total_completed_sessions
FROM THERAPIST t
JOIN SPA_LOCATION sp ON t.spa_id = sp.spa_id
LEFT JOIN SESSION s  ON s.therapist_id = t.therapist_id AND s.status = 'Completed'
GROUP BY t.therapist_id, t.therapist_fname, t.therapist_lname,
         t.therapist_email, t.therapist_phone, sp.name
ORDER BY total_completed_sessions DESC;
GO
