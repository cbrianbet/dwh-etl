update C 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_Covid   C
		JOIN ODS.Care.CT_Patient p
	on C.SiteCode = p.SiteCode and C.PatientPK = p.PatientPK
	WHERE C.PatientPKHash IS NULL OR C.PatientIDHash IS NULL;