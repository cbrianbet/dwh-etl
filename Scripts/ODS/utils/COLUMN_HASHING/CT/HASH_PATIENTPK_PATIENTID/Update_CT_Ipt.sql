update Ipt
		set PatientPKHash = p.PatientPKHash,
			Ipt.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ipt  Ipt
	JOIN ODS.dbo.CT_Patient p
		on Ipt.SiteCode = p.SiteCode and Ipt.PatientPK = p.PatientPK
	WHERE Ipt.PatientPKHash IS NULL OR Ipt.PatientIDHash IS NULL;