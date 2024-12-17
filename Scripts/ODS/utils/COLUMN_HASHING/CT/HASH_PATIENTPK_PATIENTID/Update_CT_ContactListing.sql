update CL
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_ContactListing    CL
		JOIN ODS.Care.CT_Patient p
	on CL.SiteCode = p.SiteCode and CL.PatientPK = p.PatientPK
	WHERE CL.PatientPKHash IS NULL OR CL.PatientIDHash IS NULL;


	update ODS.Care.CT_ContactListing
		set ContactPatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(ContactPatientPK  as nvarchar(36))), 2)			
			WHERE  ContactPatientPKHash IS NULL ;