update ARTP
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_ARTPatients   ARTP
		JOIN ODS.Care.CT_Patient p
	on ARTP.SiteCode = p.SiteCode and ARTP.PatientPK = p.PatientPK
	WHERE ARTP.PatientPKHash IS NULL OR ARTP.PatientIDHash IS NULL;