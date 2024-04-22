update Otz 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Otz     Otz 
		JOIN ODS.dbo.CT_Patient p
	on Otz .SiteCode = p.SiteCode and Otz.PatientPK = p.PatientPK
	WHERE Otz.PatientPKHash IS NULL OR Otz.PatientIDHash IS NULL;