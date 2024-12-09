update Otz 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_Otz     Otz 
		JOIN ODS.Care.CT_Patient p
	on Otz .SiteCode = p.SiteCode and Otz.PatientPK = p.PatientPK
	WHERE Otz.PatientPKHash IS NULL OR Otz.PatientIDHash IS NULL;