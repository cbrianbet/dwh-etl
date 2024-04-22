update EAC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_EnhancedAdherenceCounselling     EAC
		JOIN ODS.dbo.CT_Patient p
	on EAC.SiteCode = p.SiteCode and EAC.PatientPK = p.PatientPK
	WHERE EAC.PatientPKHash IS NULL OR EAC.PatientIDHash IS NULL;