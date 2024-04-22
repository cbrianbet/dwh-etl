/****** Script for SelectTopNRows command from SSMS  ******/


------Update Date of Birth to missing where Year <1910------------------------------

------Update Date of Birth to missing where Year <1910------------------------------
UPDATE ODS.dbo.CT_Patient   SET DOB = NULL where (DOB) < CAST ('1910-01-01' AS DATE)
Go

UPDATE [ODS].[DBO].[CT_Patient]  SET DOB = NULL where (DOB) > GETDATE()
Go


-------------------Update MaritalStatus-------------------------------------------------------------
UPDATE M SET MaritalStatus = T.Target_MaritalStatus
from [ODS].[DBO].[CT_Patient]M
inner JOIN ODS.[dbo].lkp_MaritalStatus T
on M.MaritalStatus = T.Source_MaritalStatus;

Go
-------------------Update EducationLevel-------------------------------------------------------------
UPDATE   M  SET  M.EducationLevel= T.TargetEducationLevel   
from [ODS].[DBO].[CT_Patient] M 
INNER JOIN [ODS].[dbo].[Lkp_EducationLevel] T  ON M.EducationLevel = T.SourceEducationLevel
--WHERE M.DateImported = CAST(GETDATE() AS DATE) OR M.DateImported = CAST(GETDATE()-1 AS DATE)
GO

-------------------Update RegistrationDates-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationDate = NULL where Year (RegistrationDate) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationDate = NULL where Year (RegistrationDate) > GETDATE()
Go

UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtCCC = NULL where Year (RegistrationAtCCC) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtCCC = NULL where Year (RegistrationAtCCC) > GETDATE()
Go


UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtPMTCT = NULL where Year (RegistrationAtPMTCT) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtPMTCT = NULL where Year (RegistrationAtPMTCT) > GETDATE()
Go

UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtTBClinic = NULL where Year (RegistrationAtTBClinic) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET RegistrationAtTBClinic = NULL where Year (RegistrationAtTBClinic) > GETDATE()
Go
-------------------Update PreviousARTStartDates-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient]  SET PreviousARTStartDate = NULL where Year (PreviousARTStartDate) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET PreviousARTStartDate = NULL where Year (PreviousARTStartDate) > GETDATE()
Go
-------------------Update LastVisitDates-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient]  SET LastVisit = NULL where Year (LastVisit) <1980
Go
UPDATE [ODS].[DBO].[CT_Patient]  SET LastVisit = NULL where Year (LastVisit) >GETDATE()
Go

-------------------Update EMR-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient] SET Emr = CASE
                WHEN Emr = 'Open Medical Records System - OpenMRS' THEN  'OpenMRS'
                WHEN Emr = 'Ampath AMRS' THEN 'AMRS'
            END
WHERE Emr IN ('Open Medical Records System - OpenMRS', 'Ampath AMRS')

GO
-------------------Update Project-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient] SET Project = CASE
                WHEN Project  in ('AMPATH','Ampath Plus', 'Ampathplus') THEN  'AMPATH'
				 WHEN Project  in ('CHAP Uzima','EDARP','IRDO','UCSF Clinical Kisumu','Kenya HMIS II') THEN  'Kenya HMIS II'
               ELSE Project
            END

GO
-------------------Update Orphan-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient] SET Orphan = CASE
                WHEN Orphan  in ('NOT WORKING NOW', '') THEN  'NOT PROVIDED'
				WHEN orphan is null THEN 'NOT PROVIDED'
            END
			where Orphan in ('NOT WORKING NOW','')
-------------------Update PatientType-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient] SET PatientType = CASE
                WHEN PatientType  in ('New', 'New client','Re-enroll') THEN  'New Client'
				WHEN PatientType in  ('Transfer in','Transfer-In') THEN 'Transfer in'
				WHEN PatientType='Transit' THEN 'Transit'
            END
			where PatientType in ('New', 'New client','Re-enroll','Transfer in','Transfer-In','Transit','')
			
Go

-------------------Update Regimen-------------------------------------------------------------
UPDATE   M  SET  M.PreviousARTExposure= T.Target_Regimen   from [ODS].[DBO].[CT_Patient]M 
INNER JOIN [ODS].[dbo].[lkp_RegimenMap] T  ON M.PreviousARTExposure = T.Source_Regimen

GO
-------------------Update Inschool-------------------------------------------------------------
UPDATE [ODS].[DBO].[CT_Patient] SET Inschool = CASE
                WHEN  Inschool in ('New', 'New client','Re-enroll') THEN  'New Client'
				WHEN Inschool in  ('Transfer in','Transfer-In') THEN 'Transfer in'
				WHEN Inschool='Transit' THEN 'Transit'
            END
			where Inschool in ('New', 'New client','Re-enroll','Transfer in','Transfer-In','Transit','')
Go

-------------------Update PatientResidentCounty-------------------------------------------------------------

---------------------------------UpdatePatientSource--------------------------------------------------
UPDATE M  SET  M.PatientSource= T.target_name  
from [ODS].[DBO].[CT_Patient] M 
INNER JOIN [ODS].[dbo].[lkp_patient_source] T  
ON M.PatientSource = T.source_name
GO

--Update DateConfirmedHIVPositive
UPDATE [ODS].[DBO].[CT_Patient]  SET DateConfirmedHIVPositive = NULL where Year (DateConfirmedHIVPositive) >GETDATE()
Go

UPDATE [ODS].[DBO].[CT_Patient]  SET DateConfirmedHIVPositive = NULL where Year (DateConfirmedHIVPositive) < 1980
Go

--Update TransferInDate
UPDATE [ODS].[DBO].[CT_Patient]  SET TransferInDate = NULL where Year (TransferInDate) >GETDATE()
Go

UPDATE [ODS].[DBO].[CT_Patient]  SET TransferInDate = NULL where Year (TransferInDate) < 1980
Go


-- Update Gender
UPDATE [ODS].[DBO].[CT_Patient]SET Gender =  CASE 
            WHEN Gender = 'M' THEN 'Male'
            WHEN Gender = 'F' THEN 'Female'
        END
WHERE Gender in ('F','M')

----Added by Mugo,Bett,Nobert to cation null voided column. NUll voided are active patients

UPDATE a
    SET Voided = 0             
    from [ODS].[DBO].[CT_Patient] a
WHERE Voided is null;

