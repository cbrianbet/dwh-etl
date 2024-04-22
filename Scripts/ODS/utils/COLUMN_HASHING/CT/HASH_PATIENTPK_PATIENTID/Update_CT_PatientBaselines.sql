update PB
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientBaselines  PB
		JOIN ODS.dbo.CT_Patient p
	on PB.SiteCode = p.SiteCode and PB.PatientPK = p.PatientPK
	WHERE PB.PatientPKHash IS NULL OR PB.PatientIDHash IS NULL;