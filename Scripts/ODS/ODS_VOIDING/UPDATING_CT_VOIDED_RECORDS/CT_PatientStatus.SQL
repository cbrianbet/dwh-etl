UPDATE a
	SET a.voided =1, a.VoidingSource = 1
FROM [ODS].[Care].[CT_PatientStatus] a
	JOIN [ODS].[Care].[CT_Patient] b ON	a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.voided =1 ;
