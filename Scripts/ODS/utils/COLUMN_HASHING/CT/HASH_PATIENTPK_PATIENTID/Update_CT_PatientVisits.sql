update v
		set PatientPKHash = p.PatientPKHash,
			V.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientVisits  v
	JOIN ODS.dbo.CT_Patient p
		on v.SiteCode = p.SiteCode and v.PatientPK = p.PatientPK
		WHERE V.PatientPKHash IS NULL OR V.PatientIDHash IS NULL;