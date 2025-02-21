update [ODS].[Intermediate].[Intermediate_PrepRefills]
	set PatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update [ODS].[Intermediate].[Intermediate_PrepRefills]
	set PrepNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PrepNumber  as nvarchar(36))), 2);

update [ODS].[Intermediate].[Intermediate_PrepLastVisit]
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update [ODS].[Intermediate].[Intermediate_LastestPrepAssessments]
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);

update [ODS].[Intermediate].[Intermediate_PrepLastVisit]
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2);
