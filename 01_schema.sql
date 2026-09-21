-- CSE 2301 DBMS Project
-- Blood Bank Management System
-- MySQL 8.0+

DROP DATABASE IF EXISTS blood_bank_db;
CREATE DATABASE blood_bank_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blood_bank_db;

CREATE TABLE Donor (
    DonorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    BloodGroup VARCHAR(3) NOT NULL,
    LastDonationDate DATE NULL,
    CONSTRAINT chk_donor_blood_group CHECK (BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);

CREATE TABLE Donation (
    DonationID INT AUTO_INCREMENT PRIMARY KEY,
    DonorID INT NOT NULL,
    DonationDate DATE NOT NULL,
    QuantityCollected DECIMAL(5,2) NOT NULL,
    DonationCenter VARCHAR(150) NOT NULL,
    CONSTRAINT chk_donation_quantity CHECK (QuantityCollected > 0),
    CONSTRAINT fk_donation_donor FOREIGN KEY (DonorID) REFERENCES Donor(DonorID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE BloodUnit (
    UnitID INT AUTO_INCREMENT PRIMARY KEY,
    DonationID INT NOT NULL,
    BloodGroup VARCHAR(3) NOT NULL,
    CollectionDate DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Tested',
    StorageLocation VARCHAR(100) NOT NULL,
    CONSTRAINT chk_unit_blood_group CHECK (BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    CONSTRAINT chk_unit_dates CHECK (ExpiryDate > CollectionDate),
    CONSTRAINT chk_unit_status CHECK (Status IN ('Available','Tested','Rejected','Issued','Expired','Disposed')),
    CONSTRAINT fk_unit_donation FOREIGN KEY (DonationID) REFERENCES Donation(DonationID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Technician (
    TechnicianID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Qualification VARCHAR(150) NOT NULL
);

CREATE TABLE TestRecord (
    TestID INT AUTO_INCREMENT PRIMARY KEY,
    UnitID INT NOT NULL,
    TechnicianID INT NOT NULL,
    TestDate DATE NOT NULL,
    HIVResult VARCHAR(20) NOT NULL,
    HepatitisBResult VARCHAR(20) NOT NULL,
    HepatitisCResult VARCHAR(20) NOT NULL,
    OverallStatus VARCHAR(20) NOT NULL,
    CONSTRAINT chk_hiv_result CHECK (HIVResult IN ('Negative','Positive','Pending')),
    CONSTRAINT chk_hbv_result CHECK (HepatitisBResult IN ('Negative','Positive','Pending')),
    CONSTRAINT chk_hcv_result CHECK (HepatitisCResult IN ('Negative','Positive','Pending')),
    CONSTRAINT chk_overall_status CHECK (OverallStatus IN ('Safe','Rejected','Pending')),
    CONSTRAINT fk_test_unit FOREIGN KEY (UnitID) REFERENCES BloodUnit(UnitID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_test_technician FOREIGN KEY (TechnicianID) REFERENCES Technician(TechnicianID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Hospital (
    HospitalID INT AUTO_INCREMENT PRIMARY KEY,
    HospitalName VARCHAR(150) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE BloodRequest (
    RequestID INT AUTO_INCREMENT PRIMARY KEY,
    HospitalID INT NOT NULL,
    RequestDate DATE NOT NULL,
    PatientName VARCHAR(100) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT chk_request_status CHECK (Status IN ('Pending','Approved','Partially Fulfilled','Fulfilled','Rejected','Cancelled')),
    CONSTRAINT fk_request_hospital FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE RequestItem (
    RequestID INT NOT NULL,
    ItemNo INT NOT NULL,
    BloodGroup VARCHAR(3) NOT NULL,
    Quantity INT NOT NULL,
    Priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    PRIMARY KEY (RequestID, ItemNo),
    CONSTRAINT chk_request_item_no CHECK (ItemNo > 0),
    CONSTRAINT chk_request_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_request_blood_group CHECK (BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    CONSTRAINT chk_request_priority CHECK (Priority IN ('Low','Normal','High','Emergency')),
    CONSTRAINT fk_request_item_request FOREIGN KEY (RequestID) REFERENCES BloodRequest(RequestID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE UserAccount (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(30) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    CONSTRAINT chk_user_role CHECK (Role IN ('Administrator','Laboratory Technician','Hospital Staff'))
);

CREATE TABLE IssueRecord (
    IssueID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    IssueDate DATE NOT NULL,
    IssuedBy INT NOT NULL,
    Remarks VARCHAR(255) NULL,
    CONSTRAINT fk_issue_request FOREIGN KEY (RequestID) REFERENCES BloodRequest(RequestID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_issue_user FOREIGN KEY (IssuedBy) REFERENCES UserAccount(UserID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IssueDetail (
    IssueID INT NOT NULL,
    UnitID INT NOT NULL,
    PRIMARY KEY (IssueID, UnitID),
    UNIQUE KEY uq_issue_unit (UnitID),
    CONSTRAINT fk_issue_detail_issue FOREIGN KEY (IssueID) REFERENCES IssueRecord(IssueID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_issue_detail_unit FOREIGN KEY (UnitID) REFERENCES BloodUnit(UnitID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_donor_blood_group ON Donor(BloodGroup);
CREATE INDEX idx_unit_group_status ON BloodUnit(BloodGroup, Status);
CREATE INDEX idx_request_hospital ON BloodRequest(HospitalID);
CREATE INDEX idx_request_status ON BloodRequest(Status);
CREATE INDEX idx_test_unit ON TestRecord(UnitID);

DELIMITER $$

CREATE TRIGGER trg_testrecord_after_insert
AFTER INSERT ON TestRecord
FOR EACH ROW
BEGIN
    IF NEW.OverallStatus = 'Safe' THEN
        UPDATE BloodUnit SET Status = 'Available' WHERE UnitID = NEW.UnitID;
    ELSEIF NEW.OverallStatus = 'Rejected' THEN
        UPDATE BloodUnit SET Status = 'Rejected' WHERE UnitID = NEW.UnitID;
    ELSE
        UPDATE BloodUnit SET Status = 'Tested' WHERE UnitID = NEW.UnitID;
    END IF;
END$$

CREATE TRIGGER trg_testrecord_after_update
AFTER UPDATE ON TestRecord
FOR EACH ROW
BEGIN
    IF NEW.OverallStatus = 'Safe' THEN
        UPDATE BloodUnit SET Status = 'Available' WHERE UnitID = NEW.UnitID;
    ELSEIF NEW.OverallStatus = 'Rejected' THEN
        UPDATE BloodUnit SET Status = 'Rejected' WHERE UnitID = NEW.UnitID;
    ELSE
        UPDATE BloodUnit SET Status = 'Tested' WHERE UnitID = NEW.UnitID;
    END IF;
END$$

CREATE TRIGGER trg_issue_detail_before_insert
BEFORE INSERT ON IssueDetail
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_expiry DATE;
    DECLARE v_safe_count INT DEFAULT 0;

    SELECT Status, ExpiryDate INTO v_status, v_expiry
    FROM BloodUnit WHERE UnitID = NEW.UnitID;

    SELECT COUNT(*) INTO v_safe_count
    FROM TestRecord
    WHERE UnitID = NEW.UnitID AND OverallStatus = 'Safe';

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Blood unit does not exist.';
    END IF;

    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only available blood units can be issued.';
    END IF;

    IF v_expiry <= CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expired blood unit cannot be issued.';
    END IF;

    IF v_safe_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Blood unit has no safe test result.';
    END IF;
END$$

CREATE TRIGGER trg_issue_detail_after_insert
AFTER INSERT ON IssueDetail
FOR EACH ROW
BEGIN
    UPDATE BloodUnit SET Status = 'Issued' WHERE UnitID = NEW.UnitID;
END$$

DELIMITER ;

CREATE VIEW AvailableBloodStock AS
SELECT BloodGroup, COUNT(*) AS AvailableUnits
FROM BloodUnit
WHERE Status = 'Available' AND ExpiryDate > CURRENT_DATE()
GROUP BY BloodGroup;

CREATE VIEW BloodRequestSummary AS
SELECT br.RequestID, h.HospitalName, br.RequestDate, br.PatientName,
       br.Status, COUNT(ri.ItemNo) AS NumberOfItems
FROM BloodRequest br
JOIN Hospital h ON br.HospitalID = h.HospitalID
LEFT JOIN RequestItem ri ON br.RequestID = ri.RequestID
GROUP BY br.RequestID, h.HospitalName, br.RequestDate, br.PatientName, br.Status;
