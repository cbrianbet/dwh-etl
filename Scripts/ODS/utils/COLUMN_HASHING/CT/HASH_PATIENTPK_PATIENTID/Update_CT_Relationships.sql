update Rlshp
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[Care].[CT_Relationships]  Rlshp
		JOIN ODS.Care.CT_Patient p
	on Rlshp.SiteCode = p.SiteCode and Rlshp.PatientPK = p.PatientPK
	WHERE Rlshp.PatientPKHash IS NULL OR Rlshp.PatientIDHash IS NULL;


update Rlshp
		set PersonAPatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PersonAPatientPk  as nvarchar(36))), 2),
			PersonBPatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PersonBPatientPk  as nvarchar(36))), 2)
	from [ODS].[Care].[CT_Relationships]  Rlshp	
	WHERE Rlshp.PatientPKHash IS NULL OR Rlshp.PatientIDHash IS NULL;

  							