-- Update PatientPK with the one from ODS CT_Patients
UPDATE a
SET
    a.PatientPK = NULL,
    a.PatientPKHash = NULL
FROM
    [ODS].[Mhealth].[Mhealth_mLab_PatientLab] a;

UPDATE a
SET
    a.PatientPK = p.PatientPK
FROM
    [ODS].[Mhealth].[Mhealth_mLab_PatientLab] a
	JOIN [ODS].[Care].[CT_Patient] p
		ON a.PatientID = p.PatientID;
