/* Update of the PatientPK from the C&T patients.This are for the patients who are in ushauri and have been
registered in the EMR. Indentified using the patientCCCNumber */

UPDATE a
    SET a.PatientPK = null,a.PatientPKHash =null
FROM [ODS].[dbo].[Ushauri_Patient] a;

UPDATE a
    SET a.PatientPK = p.PatientPK
FROM [ODS].[dbo].[Ushauri_Patient] a
    JOIN [ODS].[dbo].[CT_Patient] p
ON  a.sitecode = p.sitecode AND a.patientID = p.patientID;


