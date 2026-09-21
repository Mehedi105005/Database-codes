USE blood_bank_db;

INSERT INTO Donor (Name,Gender,DateOfBirth,Phone,Address,BloodGroup,LastDonationDate) VALUES
('Rahim Uddin','Male','1998-04-12','01710000001','Dhanmondi, Dhaka','O+','2026-01-15'),
('Nusrat Jahan','Female','2000-08-21','01710000002','Mirpur, Dhaka','A+','2026-02-10'),
('Sakib Hasan','Male','1997-11-05','01710000003','Uttara, Dhaka','B+','2026-03-05'),
('Mim Akter','Female','1999-02-18','01710000004','Mohammadpur, Dhaka','AB+','2026-02-28'),
('Tanvir Ahmed','Male','1996-06-30','01710000005','Badda, Dhaka','O-','2026-01-25');

INSERT INTO Donation (DonorID,DonationDate,QuantityCollected,DonationCenter) VALUES
(1,'2026-05-01',450.00,'Central Blood Bank'),
(2,'2026-05-03',450.00,'Central Blood Bank'),
(3,'2026-05-05',450.00,'Central Blood Bank'),
(4,'2026-05-07',450.00,'Central Blood Bank'),
(5,'2026-05-09',450.00,'Central Blood Bank');

INSERT INTO BloodUnit (DonationID,BloodGroup,CollectionDate,ExpiryDate,Status,StorageLocation) VALUES
(1,'O+','2026-09-01','2027-01-01','Tested','REF-A01'),
(2,'A+','2026-09-03','2027-01-03','Tested','REF-A02'),
(3,'B+','2026-09-05','2027-01-05','Tested','REF-B01'),
(4,'AB+','2026-09-07','2027-01-07','Tested','REF-AB01'),
(5,'O-','2026-09-09','2027-01-09','Tested','REF-O01');

INSERT INTO Technician (Name,Phone,Qualification) VALUES
('Dr. Farzana Rahman','01810000001','BSc in Medical Laboratory Science'),
('Md. Imran Hossain','01810000002','Diploma in Medical Laboratory Technology');

INSERT INTO Hospital (HospitalName,Address,Phone,Email) VALUES
('Dhaka Medical Support Hospital','Dhaka','01910000001','contact@dmsh.example'),
('City Care Hospital','Dhaka','01910000002','info@citycare.example'),
('Green Life Community Hospital','Dhaka','01910000003','contact@greenlife.example');

INSERT INTO UserAccount (Username,Password,Role,FullName) VALUES
('admin','admin123','Administrator','System Administrator'),
('labtech1','lab123','Laboratory Technician','Dr. Farzana Rahman'),
('hospital1','hospital123','Hospital Staff','Hospital Desk Officer');

INSERT INTO TestRecord
(UnitID,TechnicianID,TestDate,HIVResult,HepatitisBResult,HepatitisCResult,OverallStatus) VALUES
(1,1,'2026-09-02','Negative','Negative','Negative','Safe'),
(2,1,'2026-09-04','Negative','Negative','Negative','Safe'),
(3,2,'2026-09-06','Negative','Negative','Negative','Safe'),
(4,2,'2026-09-08','Negative','Negative','Negative','Safe'),
(5,1,'2026-09-10','Negative','Negative','Negative','Safe');

INSERT INTO BloodRequest (HospitalID,RequestDate,PatientName,Status) VALUES
(1,'2026-09-20','Patient A','Approved'),
(2,'2026-09-21','Patient B','Pending'),
(3,'2026-09-22','Patient C','Pending');

INSERT INTO RequestItem (RequestID,ItemNo,BloodGroup,Quantity,Priority) VALUES
(1,1,'O+',1,'High'),
(2,1,'A+',1,'Normal'),
(3,1,'B+',1,'Emergency');

INSERT INTO IssueRecord (RequestID,IssueDate,IssuedBy,Remarks) VALUES
(1,'2026-09-20',1,'Issued against approved hospital request.');

INSERT INTO IssueDetail (IssueID,UnitID) VALUES (1,1);
