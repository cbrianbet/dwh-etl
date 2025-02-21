SELECT [SiteCode],Count(1)NullPatientPK_IDHash
	FROM [ODS].[dbo].[CT_PatientVisits_Opt]
	WHERE PatientPKHash IS NULL OR PatientIDHash IS NULL
	GROUP BY [SiteCode]
	HAVING Count(1) > 1