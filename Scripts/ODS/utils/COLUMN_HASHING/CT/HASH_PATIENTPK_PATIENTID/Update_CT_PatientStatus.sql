update PS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_PatientStatus   PS 
		JOIN ODS.dbo.CT_Patient p
	on PS .SiteCode = p.SiteCode and PS.PatientPK = p.PatientPK
	WHERE PS.PatientPKHash IS NULL OR PS.PatientIDHash IS NULL;