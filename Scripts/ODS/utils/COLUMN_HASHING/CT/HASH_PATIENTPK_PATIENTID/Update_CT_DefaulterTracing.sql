update DT 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_DefaulterTracing      DT 
		JOIN ODS.Care.CT_Patient p
	on DT .SiteCode = p.SiteCode and DT.PatientPK = p.PatientPK
	WHERE DT.PatientPKHash IS NULL OR DT.PatientIDHash IS NULL;