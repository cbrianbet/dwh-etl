update Ovc 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_Ovc     Ovc 
		JOIN ODS.Care.CT_Patient p
	on Ovc .SiteCode = p.SiteCode and Ovc.PatientPK = p.PatientPK
	WHERE Ovc.PatientPKHash IS NULL OR Ovc.PatientIDHash IS NULL;