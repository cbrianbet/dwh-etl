update v
		set PatientPKHash = p.PatientPKHash,
			V.PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_PatientVisits  v
	JOIN ODS.Care.CT_Patient p
		on v.SiteCode = p.SiteCode and v.PatientPK = p.PatientPK
		WHERE V.PatientPKHash IS NULL OR V.PatientIDHash IS NULL;