update DAS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.Care.CT_DrugAlcoholScreening   DAS 
		JOIN ODS.Care.CT_Patient p
	on DAS.SiteCode = p.SiteCode and DAS.PatientPK = p.PatientPK
	WHERE DAS.PatientPKHash IS NULL OR DAS.PatientIDHash IS NULL;