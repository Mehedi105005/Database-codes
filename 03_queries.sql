USE blood_bank_db;

-- 1. All donors
SELECT * FROM Donor;

-- 2. Donors by blood group
SELECT DonorID, Name, Phone, BloodGroup FROM Donor WHERE BloodGroup='O+';

-- 3. Donation history
SELECT d.DonationID, dr.Name AS DonorName, d.DonationDate,
       d.QuantityCollected, d.DonationCenter
FROM Donation d JOIN Donor dr ON d.DonorID=dr.DonorID
ORDER BY d.DonationDate DESC;

-- 4. Inventory
SELECT * FROM BloodUnit ORDER BY BloodGroup, UnitID;

-- 5. Available stock
SELECT * FROM AvailableBloodStock ORDER BY BloodGroup;

-- 6. Safe available units
SELECT bu.UnitID, bu.BloodGroup, bu.ExpiryDate, bu.StorageLocation
FROM BloodUnit bu
JOIN TestRecord tr ON bu.UnitID=tr.UnitID
WHERE tr.OverallStatus='Safe' AND bu.Status='Available';

-- 7. Testing history
SELECT tr.TestID, bu.UnitID, t.Name AS TechnicianName, tr.TestDate,
       tr.HIVResult, tr.HepatitisBResult, tr.HepatitisCResult, tr.OverallStatus
FROM TestRecord tr
JOIN BloodUnit bu ON tr.UnitID=bu.UnitID
JOIN Technician t ON tr.TechnicianID=t.TechnicianID
ORDER BY tr.TestDate DESC;

-- 8. Hospital requests
SELECT br.RequestID, h.HospitalName, br.RequestDate, br.PatientName, br.Status
FROM BloodRequest br JOIN Hospital h ON br.HospitalID=h.HospitalID
ORDER BY br.RequestDate DESC;

-- 9. Request items
SELECT ri.RequestID, ri.ItemNo, h.HospitalName, ri.BloodGroup,
       ri.Quantity, ri.Priority
FROM RequestItem ri
JOIN BloodRequest br ON ri.RequestID=br.RequestID
JOIN Hospital h ON br.HospitalID=h.HospitalID
ORDER BY ri.RequestID;

-- 10. Complete issue records
SELECT ir.IssueID, ir.IssueDate, h.HospitalName, br.PatientName,
       bu.UnitID, bu.BloodGroup, ua.FullName AS IssuedBy
FROM IssueRecord ir
JOIN BloodRequest br ON ir.RequestID=br.RequestID
JOIN Hospital h ON br.HospitalID=h.HospitalID
JOIN IssueDetail idt ON ir.IssueID=idt.IssueID
JOIN BloodUnit bu ON idt.UnitID=bu.UnitID
JOIN UserAccount ua ON ir.IssuedBy=ua.UserID
ORDER BY ir.IssueDate DESC;

-- 11. Donor count by blood group
SELECT BloodGroup, COUNT(*) AS TotalDonors
FROM Donor GROUP BY BloodGroup ORDER BY TotalDonors DESC;

-- 12. Blood units by status
SELECT Status, COUNT(*) AS TotalUnits
FROM BloodUnit GROUP BY Status;

-- 13. Pending requests
SELECT br.RequestID, h.HospitalName, br.PatientName, br.RequestDate
FROM BloodRequest br JOIN Hospital h ON br.HospitalID=h.HospitalID
WHERE br.Status='Pending';

-- 14. Expiring units
SELECT UnitID, BloodGroup, ExpiryDate, Status
FROM BloodUnit
WHERE ExpiryDate BETWEEN CURRENT_DATE()
AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY);

-- 15. Total collected blood
SELECT SUM(QuantityCollected) AS TotalBloodCollected
FROM Donation;

-- 16. Donors with more than one donation
SELECT dr.DonorID, dr.Name, COUNT(d.DonationID) AS DonationCount
FROM Donor dr JOIN Donation d ON dr.DonorID=d.DonorID
GROUP BY dr.DonorID, dr.Name
HAVING COUNT(d.DonationID)>1;

-- 17. Request summary view
SELECT * FROM BloodRequestSummary;

-- 18. Rejected units
SELECT * FROM BloodUnit WHERE Status='Rejected';

-- 19. Example UPDATE
-- UPDATE BloodRequest SET Status='Approved' WHERE RequestID=2;

-- 20. Example DELETE
-- DELETE FROM RequestItem WHERE RequestID=3 AND ItemNo=1;
