update ccs 
		set PatientPKHash = p.PatientPKHash,
			ccs.PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_CervicalCancerScreening]   ccs 
		JOIN ODS.dbo.CT_Patient p
		on ccs .SiteCode = p.SiteCode and ccs .PatientPK = p.PatientPK
		WHERE ccs.PatientPKHash IS NULL OR ccs.PatientIDHash IS NULL;