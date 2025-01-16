update AE 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_AdverseEvents   AE 
		JOIN ODS.Care.CT_Patient p
	on AE .SiteCode = p.SiteCode and AE.PatientPK = p.PatientPK
	WHERE AE.PatientPKHash IS NULL OR AE.PatientIDHash IS NULL;