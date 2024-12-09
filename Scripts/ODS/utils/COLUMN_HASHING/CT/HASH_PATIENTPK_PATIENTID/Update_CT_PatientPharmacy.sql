update Phar 
		set PatientPKHash = p.PatientPKHash,
		    Phar.PatientIDHash = p.PatientIDHash
	from ODS.Care.CT_PatientPharmacy   Phar
	JOIN ODS.Care.CT_Patient p
	on Phar .SiteCode = p.SiteCode and Phar .PatientPK = p.PatientPK
	WHERE Phar.PatientPKHash IS NULL OR Phar.PatientIDHash IS NULL;