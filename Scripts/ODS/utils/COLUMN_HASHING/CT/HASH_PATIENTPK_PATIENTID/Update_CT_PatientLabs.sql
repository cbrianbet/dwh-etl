update Labs 
		set PatientPKHash = p.PatientPKHash,
			Labs.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientLabs   Labs 
		JOIN ODS.dbo.CT_Patient p
		on Labs .SiteCode = p.SiteCode and Labs .PatientPK = p.PatientPK
		WHERE Labs.PatientPKHash IS NULL OR Labs.PatientIDHash IS NULL;