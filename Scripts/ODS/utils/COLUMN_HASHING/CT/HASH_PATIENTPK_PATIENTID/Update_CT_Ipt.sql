update Ipt
		set PatientPKHash = p.PatientPKHash,
			Ipt.PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_Ipt  Ipt
	JOIN ODS.Care.CT_Patient p
		on Ipt.SiteCode = p.SiteCode and Ipt.PatientPK = p.PatientPK
	WHERE Ipt.PatientPKHash IS NULL OR Ipt.PatientIDHash IS NULL;