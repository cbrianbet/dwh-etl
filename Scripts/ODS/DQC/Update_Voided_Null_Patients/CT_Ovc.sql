UPDATE ap
SET ap.voided = 1, ap.VoidingSource = 1
FROM [ODS].[dbo].[CT_Ovc] ap
LEFT JOIN [ODS].[dbo].[CT_Patient] p
ON ap.PatientIDHash = p.PatientIDHash AND ap.PatientPKHash = p.PatientPKHash
WHERE (ap.PatientIDHash IS NULL OR ap.PatientPKHash IS NULL)
AND ap.voided = 0;
