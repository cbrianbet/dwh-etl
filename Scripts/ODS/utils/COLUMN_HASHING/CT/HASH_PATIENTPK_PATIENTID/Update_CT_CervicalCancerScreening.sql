update ccs 
		set PatientPKHash = p.PatientPKHash,
			ccs.PatientIDHash = p.PatientIDHash
	from [ODS].[Care].[CT_CervicalCancerScreening]   ccs 
		JOIN ODS.Care.CT_Patient p
		on ccs .SiteCode = p.SiteCode and ccs .PatientPK = p.PatientPK
		WHERE ccs.PatientPKHash IS NULL OR ccs.PatientIDHash IS NULL;