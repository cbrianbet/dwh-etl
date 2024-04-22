update Phar 
		set PatientPKHash = p.PatientPKHash,
		    Phar.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientPharmacy   Phar
	JOIN ODS.dbo.CT_Patient p
	on Phar .SiteCode = p.SiteCode and Phar .PatientPK = p.PatientPK
	WHERE Phar.PatientPKHash IS NULL OR Phar.PatientIDHash IS NULL;