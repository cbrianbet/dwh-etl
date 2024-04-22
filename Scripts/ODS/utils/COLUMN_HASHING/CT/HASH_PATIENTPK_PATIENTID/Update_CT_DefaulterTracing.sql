update DT 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DefaulterTracing      DT 
		JOIN ODS.dbo.CT_Patient p
	on DT .SiteCode = p.SiteCode and DT.PatientPK = p.PatientPK
	WHERE DT.PatientPKHash IS NULL OR DT.PatientIDHash IS NULL;