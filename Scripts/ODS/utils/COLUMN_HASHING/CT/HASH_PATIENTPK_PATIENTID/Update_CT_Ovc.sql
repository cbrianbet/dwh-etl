update Ovc 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ovc     Ovc 
		JOIN ODS.dbo.CT_Patient p
	on Ovc .SiteCode = p.SiteCode and Ovc.PatientPK = p.PatientPK
	WHERE Ovc.PatientPKHash IS NULL OR Ovc.PatientIDHash IS NULL;