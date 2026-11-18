CREATE DATABASE IF NOT EXISTS hospital_management_db;
USE hospital_management_db;


-- =====================================
-- HOSPITAL MANAGEMENT SYSTEM
-- PHASE 1: MASTER TABLES
-- =====================================

USE hospital_management_db;


-- TABLE 1: DEPARTMENTS
CREATE TABLE IF NOT EXISTS Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    contact_number VARCHAR(15)
);


-- TABLE 2: PATIENTS
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    emergency_contact VARCHAR(100)
);


-- TABLE 3: DOCTORS
CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    is_surgeon BOOLEAN DEFAULT FALSE,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,

    FOREIGN KEY (department_id)
    REFERENCES Departments(department_id)
);


-- TABLE 4: HOSPITAL RESOURCES
CREATE TABLE IF NOT EXISTS Hospital_Resources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    total_quantity INT NOT NULL,
    available_quantity INT NOT NULL,

    CHECK (total_quantity >= 0),
    CHECK (available_quantity >= 0),
    CHECK (available_quantity <= total_quantity)
);


-- TABLE 5: ADMISSIONS
CREATE TABLE IF NOT EXISTS Admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    department_id INT NOT NULL,
    doctor_id INT NOT NULL,
    bed_number VARCHAR(20),
    admission_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    discharge_date DATETIME,
    admission_reason VARCHAR(255),
    admission_status VARCHAR(20) DEFAULT 'Admitted',

    FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),

    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),

    CHECK (admission_status IN ('Admitted', 'Discharged'))
);


-- TABLE 6: APPOINTMENTS
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    reason VARCHAR(255),
    appointment_status VARCHAR(20) DEFAULT 'Scheduled',

    FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),

    CHECK (appointment_status IN
        ('Scheduled', 'Completed', 'Cancelled', 'No-Show'))
);


-- TABLE 7: MEDICAL HISTORY
CREATE TABLE IF NOT EXISTS Medical_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    condition_name VARCHAR(150) NOT NULL,
    diagnosis_date DATE,
    medical_notes TEXT,

    FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id)
);


-- TABLE 8: TREATMENTS
CREATE TABLE IF NOT EXISTS Treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    doctor_id INT NOT NULL,
    treatment_name VARCHAR(150) NOT NULL,
    description TEXT,
    treatment_date DATE,
    treatment_status VARCHAR(30) DEFAULT 'Ongoing',

    FOREIGN KEY (admission_id)
        REFERENCES Admissions(admission_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),

    CHECK (treatment_status IN
        ('Ongoing', 'Completed', 'Cancelled'))
);


-- TABLE 9: DEPARTMENT TRANSFERS
CREATE TABLE IF NOT EXISTS Department_Transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    from_department_id INT NOT NULL,
    to_department_id INT NOT NULL,
    doctor_id INT NOT NULL,
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    transfer_reason VARCHAR(255),

    FOREIGN KEY (admission_id)
        REFERENCES Admissions(admission_id),

    FOREIGN KEY (from_department_id)
        REFERENCES Departments(department_id),

    FOREIGN KEY (to_department_id)
        REFERENCES Departments(department_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id),

    CHECK (from_department_id <> to_department_id)
);


-- TABLE 10: SURGERIES
CREATE TABLE IF NOT EXISTS Surgeries (
    surgery_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    surgeon_id INT NOT NULL,
    surgery_name VARCHAR(150) NOT NULL,
    operating_room VARCHAR(30),
    scheduled_start DATETIME NOT NULL,
    scheduled_end DATETIME NOT NULL,
    surgery_status VARCHAR(30) DEFAULT 'Scheduled',
    pre_op_clearance_status VARCHAR(30) DEFAULT 'Pending',
    safety_notes TEXT,

    FOREIGN KEY (admission_id)
        REFERENCES Admissions(admission_id),

    FOREIGN KEY (surgeon_id)
        REFERENCES Doctors(doctor_id),

    CHECK (scheduled_end > scheduled_start),

    CHECK (surgery_status IN
        ('Scheduled', 'Completed', 'Cancelled')),

    CHECK (pre_op_clearance_status IN
        ('Pending', 'Cleared', 'Not Cleared'))
);


-- TABLE 11: SURGERY RESOURCES
CREATE TABLE IF NOT EXISTS Surgery_Resources (
    surgery_id INT NOT NULL,
    resource_id INT NOT NULL,
    quantity_required INT NOT NULL,

    PRIMARY KEY (surgery_id, resource_id),

    FOREIGN KEY (surgery_id)
        REFERENCES Surgeries(surgery_id),

    FOREIGN KEY (resource_id)
        REFERENCES Hospital_Resources(resource_id),

    CHECK (quantity_required > 0)
);


-- 1. INSERT DEPARTMENTS
INSERT INTO Departments
(department_id, department_name, location, contact_number)
VALUES
(1, 'Cardiology', 'Block A', '0124123001'),
(2, 'Neurology', 'Block B', '0124123002'),
(3, 'Orthopedics', 'Block C', '0124123003'),
(4, 'General Medicine', 'Block A', '0124123004'),
(5, 'Emergency', 'Ground Floor', '0124123005');

-- 2. INSERT PATIENTS
INSERT INTO Patients
(patient_id, first_name, last_name, date_of_birth,
 gender, blood_group, phone, email, address, emergency_contact)
VALUES
(1, 'Aarav', 'Sharma', '1990-04-12', 'Male', 'O+',
 '9876500001', 'aarav@gmail.com', 'Gurugram', 'Raj Sharma - 9876500011'),

(2, 'Diya', 'Verma', '1985-09-23', 'Female', 'B+',
 '9876500002', 'diya@gmail.com', 'Delhi', 'Ravi Verma - 9876500012'),

(3, 'Kabir', 'Singh', '2002-01-07', 'Male', 'A+',
 '9876500003', 'kabir@gmail.com', 'Noida', 'Amit Singh - 9876500013'),

(4, 'Meera', 'Joshi', '1978-06-14', 'Female', 'AB+',
 '9876500004', 'meera@gmail.com', 'Gurugram', 'Rohan Joshi - 9876500014'),

(5, 'Riya', 'Nair', '1995-11-30', 'Female', 'O-',
 '9876500005', 'riya@gmail.com', 'Faridabad', 'Anil Nair - 9876500015'),

(6, 'Arjun', 'Patel', '1969-03-18', 'Male', 'B-',
 '9876500006', 'arjun@gmail.com', 'Delhi', 'Kiran Patel - 9876500016'),

(7, 'Sana', 'Khan', '2000-07-25', 'Female', 'A-',
 '9876500007', 'sana@gmail.com', 'Noida', 'Imran Khan - 9876500017'),

(8, 'Dev', 'Malhotra', '1988-02-09', 'Male', 'O+',
 '9876500008', 'dev@gmail.com', 'Gurugram', 'Raj Malhotra - 9876500018'),

(9, 'Isha', 'Gupta', '1992-08-16', 'Female', 'AB-',
 '9876500009', 'isha@gmail.com', 'Delhi', 'Aman Gupta - 9876500019'),

(10, 'Vihaan', 'Rao', '1975-12-03', 'Male', 'B+',
 '9876500010', 'vihaan@gmail.com', 'Faridabad', 'Karan Rao - 9876500020');


-- 3. INSERT DOCTORS
INSERT INTO Doctors
(doctor_id, department_id, first_name, last_name,
 specialization, is_surgeon, phone, email)
VALUES
(1, 1, 'Arun', 'Malhotra', 'Cardiologist', FALSE,
 '9811000001', 'arun@hospital.com'),

(2, 1, 'Kavita', 'Rao', 'Cardiothoracic Surgeon', TRUE,
 '9811000002', 'kavita@hospital.com'),

(3, 2, 'Rohan', 'Sethi', 'Neurosurgeon', TRUE,
 '9811000003', 'rohan@hospital.com'),

(4, 3, 'Neha', 'Kapoor', 'Orthopedic Surgeon', TRUE,
 '9811000004', 'neha@hospital.com'),

(5, 3, 'Vikram', 'Shah', 'Orthopedic Surgeon', TRUE,
 '9811000005', 'vikram@hospital.com'),

(6, 4, 'Meera', 'Nair', 'General Physician', FALSE,
 '9811000006', 'meera@hospital.com'),

(7, 5, 'Sameer', 'Khan', 'Emergency Physician', FALSE,
 '9811000007', 'sameer@hospital.com'),

(8, 1, 'Ananya', 'Bose', 'Cardiac Surgeon', TRUE,
 '9811000008', 'ananya@hospital.com');


-- 4. INSERT HOSPITAL RESOURCES
INSERT INTO Hospital_Resources
(resource_id, resource_name, resource_type,
 total_quantity, available_quantity)
VALUES
(1, 'ECG Machine', 'Medical Equipment', 3, 2),
(2, 'Ventilator', 'Life Support', 5, 3),
(3, 'Anesthesia Machine', 'Surgical Equipment', 2, 1),
(4, 'Surgical Instrument Set', 'Surgical Equipment', 10, 7),
(5, 'Infusion Pump', 'Medical Equipment', 8, 6);


-- 5. INSERT ADMISSIONS
INSERT INTO Admissions
(admission_id, patient_id, department_id, doctor_id,
 bed_number, admission_date, discharge_date,
 admission_reason, admission_status)
VALUES
(1, 1, 1, 1, 'C101', '2026-10-01', '2026-10-05',
 'Chest pain', 'Discharged'),

(2, 1, 1, 2, 'C102', '2026-10-20', '2026-10-24',
 'Cardiac complications', 'Discharged'),

(3, 2, 2, 3, 'N101', '2026-10-05', '2026-10-15',
 'Severe headache', 'Discharged'),

(4, 3, 3, 4, 'O101', '2026-10-15', '2026-10-20',
 'Leg fracture', 'Discharged'),

(5, 4, 4, 6, 'G101', '2026-11-02', NULL,
 'Diabetes monitoring', 'Admitted'),

(6, 5, 4, 6, 'G102', '2026-11-05', NULL,
 'Emergency treatment', 'Admitted'),

(7, 6, 1, 1, 'C103', '2026-11-01', NULL,
 'Heart condition', 'Admitted'),

(8, 7, 2, 3, 'N102', '2026-10-25', NULL,
 'Neurological observation', 'Admitted'),

(9, 8, 3, 5, 'O102', '2026-10-28', NULL,
 'Knee injury', 'Admitted'),

(10, 9, 4, 6, 'G103', '2026-10-30', '2026-11-03',
 'Fever and infection', 'Discharged');

-- 6. INSERT APPOINTMENTS
 INSERT INTO Appointments
(patient_id, doctor_id, appointment_datetime,
 reason, appointment_status)
VALUES
(1, 1, '2026-11-12 09:00:00', 'Cardiac follow-up', 'Scheduled'),
(2, 3, '2026-11-12 10:00:00', 'Neurological checkup', 'Scheduled'),
(3, 4, '2026-11-12 11:00:00', 'Fracture follow-up', 'Scheduled'),
(4, 6, '2026-11-11 10:00:00', 'Diabetes checkup', 'Scheduled'),
(5, 6, '2026-11-11 11:00:00', 'General consultation', 'Scheduled'),
(6, 1, '2026-11-13 09:00:00', 'Heart examination', 'Scheduled'),
(7, 3, '2026-11-13 10:00:00', 'Neurological review', 'Scheduled'),
(10, 7, '2026-11-10 16:00:00', 'Emergency consultation', 'Scheduled'),
(8, 5, '2026-11-14 09:00:00', 'Orthopedic consultation', 'Scheduled');

-- 7. INSERT MEDICAL HISTORY
INSERT INTO Medical_History
(patient_id, doctor_id, condition_name,
 diagnosis_date, medical_notes)
VALUES
(1, 1, 'Hypertension', '2024-05-10',
 'Patient has a history of high blood pressure'),

(2, 3, 'Migraine', '2025-02-15',
 'Recurring migraine episodes'),

(3, 4, 'Previous Fracture', '2023-08-20',
 'History of leg fracture'),

(4, 6, 'Diabetes', '2022-11-12',
 'Patient requires regular glucose monitoring'),

(6, 1, 'Hypertension', '2024-03-05',
 'Regular cardiac monitoring advised'),

(7, 3, 'Epilepsy', '2023-06-18',
 'Patient requires neurological follow-up');

--  8. INSERT TREATMENTS
INSERT INTO Treatments
(admission_id, doctor_id, treatment_name,
 description, treatment_date, treatment_status)
VALUES
(1, 2, 'Cardiac Monitoring',
 'Regular ECG monitoring', '2026-10-02', 'Completed'),

(2, 1, 'Medication',
 'Cardiac medication and observation', '2026-10-21', 'Completed'),

(3, 3, 'Neurological Monitoring',
 'Continuous neurological observation', '2026-10-08', 'Completed'),

(4, 4, 'Fracture Treatment',
 'Treatment and recovery monitoring', '2026-10-16', 'Completed'),

(5, 6, 'Glucose Monitoring',
 'Regular blood sugar monitoring', '2026-11-03', 'Ongoing'),

(6, 6, 'IV Fluid Treatment',
 'Intravenous fluid administration', '2026-11-05', 'Ongoing'),

(7, 1, 'Cardiac Monitoring',
 'Regular heart monitoring', '2026-11-02', 'Ongoing'),

(8, 3, 'Neurological Observation',
 'Monitoring neurological condition', '2026-10-26', 'Ongoing'),

(9, 5, 'Physiotherapy',
 'Orthopedic rehabilitation', '2026-10-29', 'Ongoing');

-- 9. INSERT DEPARTMENT TRANSFERS
INSERT INTO Department_Transfers
(admission_id, from_department_id, to_department_id,
 doctor_id, transfer_date, transfer_reason)
VALUES
(6, 5, 4, 7, '2026-11-06 10:00:00',
 'Patient condition stabilized after emergency treatment');

-- 10. INSERT SURGERIES
INSERT INTO Surgeries
(admission_id, surgeon_id, surgery_name,
 operating_room, scheduled_start, scheduled_end,
 surgery_status, pre_op_clearance_status, safety_notes)
VALUES
(1, 2, 'Cardiac Procedure', 'OT-1',
 '2026-10-02 08:00:00', '2026-10-02 10:00:00',
 'Completed', 'Cleared', 'Pre-operative checks completed'),

(2, 8, 'Cardiac Surgery', 'OT-1',
 '2026-10-21 09:00:00', '2026-10-21 11:00:00',
 'Completed', 'Cleared', 'Patient monitored after surgery'),

(3, 3, 'Neurological Surgery', 'OT-2',
 '2026-10-08 08:00:00', '2026-10-08 12:00:00',
 'Completed', 'Cleared', 'Pre-operative assessment completed'),

(4, 4, 'Fracture Fixation', 'OT-3',
 '2026-10-16 09:00:00', '2026-10-16 11:00:00',
 'Completed', 'Cleared', 'Patient safety checks completed'),

(4, 5, 'Orthopedic Repair', 'OT-3',
 '2026-10-18 09:00:00', '2026-10-18 11:00:00',
 'Completed', 'Cleared', 'Post-operative observation completed'),

(7, 2, 'Cardiac Procedure', 'OT-1',
 '2026-11-12 09:00:00', '2026-11-12 11:00:00',
 'Scheduled', 'Pending', 'Pre-operative assessment pending'),

(8, 3, 'Neurological Procedure', 'OT-2',
 '2026-11-13 10:00:00', '2026-11-13 12:00:00',
 'Scheduled', 'Pending', 'Awaiting final clearance'),

(9, 4, 'Knee Repair', 'OT-3',
 '2026-11-14 09:00:00', '2026-11-14 11:00:00',
 'Scheduled', 'Pending', 'Pre-operative review pending');

-- 11. INSERT SURGERY RESOURCES
INSERT INTO Surgery_Resources
(surgery_id, resource_id, quantity_required)
VALUES
(1, 3, 1),
(1, 4, 1),
(3, 2, 1),
(4, 4, 1),
(6, 3, 1),
(7, 4, 1),
(8, 4, 1);

-- Q1. Retrieve patient admission details along with their department and attending doctor.
SELECT
    a.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.department_name,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    a.bed_number,
    a.admission_date,
    a.discharge_date,
    a.admission_status
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN departments d
    ON a.department_id = d.department_id
JOIN doctors doc
    ON a.doctor_id = doc.doctor_id
ORDER BY a.admission_date;
 
-- Q2. Find patients who are currently admitted and have not been discharged.
SELECT
    a.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.department_name,
    a.bed_number,
    a.admission_date,
    a.admission_status
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN departments d
    ON a.department_id = d.department_id
WHERE a.admission_status = 'Admitted'
AND a.discharge_date IS NULL;

-- Q3. Retrieve the history of patients who have been discharged.
SELECT
    a.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    a.admission_date,
    a.discharge_date,
    a.admission_reason
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
WHERE a.admission_status = 'Discharged'
ORDER BY a.discharge_date DESC;

-- Q4. Insert a new patient (CREATE)
INSERT INTO Patients
(first_name, last_name, date_of_birth, gender,
 blood_group, phone, email, address, emergency_contact)
VALUES
('Rahul', 'Mehta', '1998-05-14', 'Male',
 'B+', '9999900001', 'rahul.test@gmail.com',
 'Gurugram', 'Amit Mehta - 9999900002');

-- Q5. Retrieve patient details (READ)
SELECT *
FROM Patients
WHERE email = 'rahul.test@gmail.com';

-- Q6. Update patient information (UPDATE)
UPDATE Patients
SET phone = '9999900011'
WHERE email = 'rahul.test@gmail.com';

-- Q7. Delete patient record (DELETE)
DELETE FROM Patients
WHERE email = 'rahul.test@gmail.com';

-- Q8. Discharge a patient
UPDATE Admissions
SET
    discharge_date = NOW(),
    admission_status = 'Discharged'
WHERE admission_id = 5
AND admission_status = 'Admitted';

SELECT
    admission_id,
    patient_id,
    admission_date,
    discharge_date,
    admission_status
FROM Admissions
WHERE admission_id = 5;

-- Q9. Display department-wise patient count
SELECT
    d.department_name,
    COUNT(a.admission_id) AS total_patients
FROM Departments d
LEFT JOIN Admissions a
    ON d.department_id = a.department_id
    AND a.admission_status = 'Admitted'
GROUP BY d.department_id, d.department_name;

-- Q10. Transfer an admitted patient from one department to another and record the transfer history.
--      We'll transfer admission ID 7 from Cardiology (Department 1) to Emergency (Department 5).

-- Record the department transfer
INSERT INTO Department_Transfers
(admission_id, from_department_id, to_department_id,
 doctor_id, transfer_date, transfer_reason)
VALUES
(7, 1, 5, 1, NOW(),
 'Patient requires emergency medical attention');
-- Update the patient's current department
UPDATE Admissions
SET department_id = 5,
    doctor_id = 7,
    bed_number = 'E101'
WHERE admission_id = 7
AND admission_status = 'Admitted';

SELECT * FROM Department_Transfers;

SELECT * FROM Admissions
WHERE admission_id = 7;

-- Q11. Retrieve the scheduled surgeries with patient and surgeon details.
SELECT
    s.surgery_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS surgeon_name,
    s.surgery_name,
    s.operating_room,
    s.scheduled_start,
    s.scheduled_end,
    s.surgery_status
FROM Surgeries s
JOIN Admissions a
    ON s.admission_id = a.admission_id
JOIN Patients p
    ON a.patient_id = p.patient_id
JOIN Doctors d
    ON s.surgeon_id = d.doctor_id
ORDER BY s.scheduled_start;

-- Q12. Identify the resources allocated to each surgery.
SELECT
    s.surgery_name,
    h.resource_name,
    sr.quantity_required
FROM Surgery_Resources sr
JOIN Surgeries s
    ON sr.surgery_id = s.surgery_id
JOIN Hospital_Resources h
    ON sr.resource_id = h.resource_id;

-- Q13. Identify scheduled surgeries where pre-operative clearance is still pending.
SELECT
    surgery_id,
    surgery_name,
    operating_room,
    scheduled_start,
    pre_op_clearance_status,
    safety_notes
FROM Surgeries
WHERE surgery_status = 'Scheduled'
AND pre_op_clearance_status <> 'Cleared';

-- Q14. EXPLAIN before creating composite indexes
EXPLAIN
SELECT
    admission_id,
    patient_id,
    admission_date,
    discharge_date
FROM Admissions
WHERE patient_id = 1
ORDER BY admission_date;

EXPLAIN
SELECT
    appointment_id,
    doctor_id,
    appointment_datetime,
    patient_id
FROM Appointments
WHERE doctor_id = 1
ORDER BY appointment_datetime;

-- Q15. Create the required composite indexes
-- Index 1: Patient admission history
CREATE INDEX idx_admissions_patient_date
ON Admissions(patient_id, admission_date);

-- Index 2: Doctor appointment schedule
CREATE INDEX idx_appointments_doctor_datetime
ON Appointments(doctor_id, appointment_datetime);

-- Q16. EXPLAIN after indexing
EXPLAIN
SELECT
    admission_id,
    patient_id,
    admission_date,
    discharge_date
FROM Admissions
WHERE patient_id = 1
ORDER BY admission_date;

EXPLAIN
SELECT
    appointment_id,
    doctor_id,
    appointment_datetime,
    patient_id
FROM Appointments
WHERE doctor_id = 1
ORDER BY appointment_datetime;

-- Q16. Create a covering index
CREATE INDEX idx_admissions_inpatient_report
ON Admissions(
    admission_status,
    patient_id,
    department_id,
    doctor_id,
    bed_number,
    admission_date,
    discharge_date
);

-- Q17. Create a covering index
CREATE INDEX idx_admissions_inpatient_report
ON Admissions(
    admission_status,
    patient_id,
    department_id,
    doctor_id,
    bed_number,
    admission_date,
    discharge_date
);

EXPLAIN
SELECT
    admission_status,
    patient_id,
    department_id,
    doctor_id,
    bed_number,
    admission_date,
    discharge_date
FROM Admissions
WHERE admission_status = 'Admitted';

-- Q18. Verify created indexes
SHOW INDEX FROM Admissions;

SHOW INDEX FROM Appointments;

-- Q19. View 1 : Current In-patients View
CREATE OR REPLACE VIEW current_inpatients_view AS
SELECT
    a.admission_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.department_name,
    a.bed_number,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    a.admission_date,
    DATEDIFF(CURDATE(), DATE(a.admission_date)) AS days_admitted

FROM Admissions a

JOIN Patients p
    ON a.patient_id = p.patient_id

JOIN Departments d
    ON a.department_id = d.department_id

JOIN Doctors doc
    ON a.doctor_id = doc.doctor_id

WHERE a.admission_status = 'Admitted'
AND a.discharge_date IS NULL;

SELECT * FROM current_inpatients_view;

-- Q20. View 2 — Restricted Front-Desk View
CREATE OR REPLACE VIEW front_desk_view AS
SELECT
    a.appointment_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone,
    a.appointment_datetime,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    a.appointment_status

FROM Appointments a

JOIN Patients p
    ON a.patient_id = p.patient_id

JOIN Doctors d
    ON a.doctor_id = d.doctor_id

JOIN Departments dep
    ON d.department_id = dep.department_id;
   
SELECT * FROM front_desk_view;

-- Q21. Access Control : GRANT privileges
CREATE USER IF NOT EXISTS
'frontdesk_user'@'localhost'
IDENTIFIED BY 'FRONTEND DESK';

GRANT SELECT
ON hospital_management_db.front_desk_view
TO 'frontdesk_user'@'localhost';

SHOW GRANTS FOR 'frontdesk_user'@'localhost';

-- Q22. Verify both views
SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SELECT * FROM current_inpatients_view;

SELECT * FROM front_desk_view;


-- ----------------------
-- Q19. Rank surgeons using DENSE_RANK()
SELECT
    dep.department_name,
    CONCAT(doc.first_name, ' ', doc.last_name) AS surgeon_name,
    COUNT(s.surgery_id) AS total_surgeries,
    DENSE_RANK() OVER (
        PARTITION BY dep.department_id
        ORDER BY COUNT(s.surgery_id) DESC
    ) AS surgeon_rank
FROM Doctors doc
JOIN Departments dep
    ON doc.department_id = dep.department_id
LEFT JOIN Surgeries s
    ON doc.doctor_id = s.surgeon_id
WHERE doc.is_surgeon = TRUE
GROUP BY
    dep.department_id,
    dep.department_name,
    doc.doctor_id,
    doc.first_name,
    doc.last_name
ORDER BY dep.department_name, surgeon_rank;

-- Q20. Calculate average patient stay using AVG() OVER()
SELECT
    admission_id,
    patient_name,
    department_name,
    days_admitted,
    ROUND(
        AVG(days_admitted) OVER (
            PARTITION BY department_id
        ), 2
    ) AS department_avg_days,
    CASE
        WHEN days_admitted >
             AVG(days_admitted) OVER (
                 PARTITION BY department_id
             )
        THEN 'Above Department Average'
        WHEN days_admitted <
             AVG(days_admitted) OVER (
                 PARTITION BY department_id
             )
        THEN 'Below Department Average'
        ELSE 'Equal to Department Average'
    END AS stay_comparison
FROM (
    SELECT
        a.admission_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        d.department_id,
        d.department_name,
        DATEDIFF(
            COALESCE(DATE(a.discharge_date), CURDATE()),
            DATE(a.admission_date)
        ) AS days_admitted
    FROM Admissions a
    JOIN Patients p
        ON a.patient_id = p.patient_id
    JOIN Departments d
        ON a.department_id = d.department_id
) AS patient_stays
ORDER BY department_name, admission_id;

-- Q21. Detect patient readmissions using LAG()
WITH admission_history AS (
    SELECT
        patient_id,
        admission_id,
        DATE(admission_date) AS admission_date,
        DATE(discharge_date) AS discharge_date,

        LAG(DATE(discharge_date)) OVER (
            PARTITION BY patient_id
            ORDER BY admission_date
        ) AS previous_discharge_date

    FROM Admissions
)

SELECT
    patient_id,
    admission_id,
    previous_discharge_date,
    admission_date,

    DATEDIFF(
        admission_date,
        previous_discharge_date
    ) AS days_between_readmission,

    'Readmitted Within 30 Days' AS readmission_status

FROM admission_history

WHERE previous_discharge_date IS NOT NULL

AND DATEDIFF(
    admission_date,
    previous_discharge_date
) BETWEEN 0 AND 30;


-- ---------------------
-- VERIFY
SHOW TABLES;
SELECT
    (SELECT COUNT(*) FROM Departments) AS Departments,
    (SELECT COUNT(*) FROM Patients) AS Patients,
    (SELECT COUNT(*) FROM Doctors) AS Doctors,
    (SELECT COUNT(*) FROM Hospital_Resources) AS Resources,
    (SELECT COUNT(*) FROM Admissions) AS Admissions,
    (SELECT COUNT(*) FROM Appointments) AS Appointments,
    (SELECT COUNT(*) FROM Medical_History) AS Medical_History,
    (SELECT COUNT(*) FROM Treatments) AS Treatments,
    (SELECT COUNT(*) FROM Department_Transfers) AS Transfers,
    (SELECT COUNT(*) FROM Surgeries) AS Surgeries,
    (SELECT COUNT(*) FROM Surgery_Resources) AS Surgery_Resources;

SHOW INDEX FROM Admissions;

SHOW INDEX FROM Appointments;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SELECT * FROM current_inpatients_view;

SELECT * FROM front_desk_view;

SHOW GRANTS FOR 'frontdesk_user'@'localhost';
