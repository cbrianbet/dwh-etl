update PS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_PatientStatus   PS 
		JOIN ODS.Care.CT_Patient p
	on PS .SiteCode = p.SiteCode and PS.PatientPK = p.PatientPK
	WHERE PS.PatientPKHash IS NULL OR PS.PatientIDHash IS NULL;