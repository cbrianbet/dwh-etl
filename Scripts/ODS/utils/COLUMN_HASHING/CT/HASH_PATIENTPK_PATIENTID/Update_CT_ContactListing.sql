update CL
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_ContactListing    CL
		JOIN ODS.dbo.CT_Patient p
	on CL.SiteCode = p.SiteCode and CL.PatientPK = p.PatientPK
	WHERE CL.PatientPKHash IS NULL OR CL.PatientIDHash IS NULL;