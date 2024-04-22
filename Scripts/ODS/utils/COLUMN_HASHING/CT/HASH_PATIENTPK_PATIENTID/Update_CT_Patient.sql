	update ODS.dbo.CT_Patient 
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)
	FROM ODS.dbo.CT_Patient
	WHERE PatientPKHash IS NULL OR PatientIDHash IS NULL;