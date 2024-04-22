update AE 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_AdverseEvents   AE 
		JOIN ODS.dbo.CT_Patient p
	on AE .SiteCode = p.SiteCode and AE.PatientPK = p.PatientPK
	WHERE AE.PatientPKHash IS NULL OR AE.PatientIDHash IS NULL;