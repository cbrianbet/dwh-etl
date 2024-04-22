
		update CS
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_CancerScreening]  CS
		JOIN ODS.dbo.CT_Patient p
	on CS.SiteCode = p.SiteCode and CS.PatientPK = p.PatientPK
	WHERE CS.PatientPKHash IS NULL OR CS.PatientIDHash IS NULL;