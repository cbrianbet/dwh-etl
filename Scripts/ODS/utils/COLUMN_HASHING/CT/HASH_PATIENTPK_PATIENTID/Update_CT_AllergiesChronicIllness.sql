update AC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_AllergiesChronicIllness  AC
		JOIN ODS.Care.CT_Patient p
	on AC.SiteCode = p.SiteCode and AC.PatientPK = p.PatientPK
	WHERE AC.PatientPKHash IS NULL OR AC.PatientIDHash IS NULL;