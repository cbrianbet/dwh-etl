-- clean ExitDate
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET ExitDate = NULL
WHERE ExitDate < CAST('2004-01-01' AS DATE) OR ExitDate > GETDATE()

GO
--Clean Re-Enrollment Date
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET ReEnrollmentDate = NULL
WHERE ReEnrollmentDate < CAST('2004-01-01' AS DATE) OR ReEnrollmentDate > GETDATE()

GO
---Clean To Verified date
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET TOVerifiedDate = NULL
WHERE TOVerifiedDate < CAST('2004-01-01' AS DATE) 

GO 
--Clean Effective Discontinuation date 
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET EffectiveDiscontinuationDate = NULL
WHERE EffectiveDiscontinuationDate < CAST('2004-01-01' AS DATE) 

-- clean EMR 
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET Emr = CASE
                WHEN Emr = 'Ampath AMRS' THEN 'AMRS'
            END
WHERE Emr = 'Ampath AMRS'

GO


-- clean Project
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET Project = CASE
                WHEN Project IN ('Ampathplus') THEN  'Ampath Plus'
                WHEN Project IN ('UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM Kenya Trusts', 'IRDO')  THEN 'Kenya HMIS II'
            END
WHERE Project IN ('Ampathplus', 'AMPATH', 'UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM Kenya Trusts', 'IRDO')

GO

---Clean up the ExitReason where ExitReason in ('Died','Death','dead')
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET ExitReason = CASE
						WHEN ExitReason IN ('Died','Death','dead') THEN  'Death'
						
            END
where ExitReason in ('Died','Death','dead')

---Clean ExitDate, ExitReason
UPDATE [ODS].[Care].[CT_PatientStatus]
    SET ExitDate = NULL,ExitReason=NULL
WHERE ReEnrollmentDate > ExitDate
and ExitReason in ('dead','Death','Died')
GO



