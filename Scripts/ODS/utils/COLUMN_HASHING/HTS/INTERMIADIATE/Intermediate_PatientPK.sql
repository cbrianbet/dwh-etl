update [ODS].[Intermediate].[Intermediate_EncounterHTSTests]
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

		
		