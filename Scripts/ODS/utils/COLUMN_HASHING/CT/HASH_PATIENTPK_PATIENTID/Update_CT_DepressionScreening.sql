update DS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_DepressionScreening    DS 
		JOIN ODS.Care.CT_Patient p
	on DS .SiteCode = p.SiteCode and DS.PatientPK = p.PatientPK
	WHERE DS.PatientPKHash IS NULL OR DS.PatientIDHash IS NULL;