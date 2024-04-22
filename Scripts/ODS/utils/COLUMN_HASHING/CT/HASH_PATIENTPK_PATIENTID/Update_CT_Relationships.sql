update Rlshp
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_Relationships]  Rlshp
		JOIN ODS.dbo.CT_Patient p
	on Rlshp.SiteCode = p.SiteCode and Rlshp.PatientPK = p.PatientPK
	WHERE Rlshp.PatientPKHash IS NULL OR Rlshp.PatientIDHash IS NULL;