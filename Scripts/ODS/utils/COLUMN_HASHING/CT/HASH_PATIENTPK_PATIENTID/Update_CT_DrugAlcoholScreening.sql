update DAS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DrugAlcoholScreening   DAS 
		JOIN ODS.dbo.CT_Patient p
	on DAS.SiteCode = p.SiteCode and DAS.PatientPK = p.PatientPK
	WHERE DAS.PatientPKHash IS NULL OR DAS.PatientIDHash IS NULL;