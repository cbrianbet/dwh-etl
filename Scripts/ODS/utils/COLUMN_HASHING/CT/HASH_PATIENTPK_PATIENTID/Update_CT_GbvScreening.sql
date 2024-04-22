update GbvS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_GbvScreening  GbvS
		JOIN ODS.dbo.CT_Patient p
	on GbvS.SiteCode = p.SiteCode and GbvS.PatientPK = p.PatientPK
	WHERE GbvS.PatientPKHash IS NULL OR GbvS.PatientIDHash IS NULL;