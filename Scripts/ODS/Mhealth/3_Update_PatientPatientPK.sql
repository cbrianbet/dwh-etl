UPDATE a
    SET a.PatientPK = null,a.PatientPKHash =null
FROM [ODS].[dbo].[Ushauri_Patient] a;

UPDATE a
    SET a.PatientPK = p.PatientPK
FROM [ODS].[dbo].[Ushauri_Patient] a
    JOIN [ODS].[dbo].[CT_Patient] p
ON  a.sitecode = p.sitecode AND a.patientID = p.patientID;


UPDATE a
    SET a.PatientPK = a.UshauriPatientPK
FROM [ODS].[dbo].[Ushauri_Patient] a
WHERE a.PatientPK IS NULL;

