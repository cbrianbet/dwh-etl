IF OBJECT_ID(N'[ODS].[lkp].[lkp_test_name]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_test_name];
BEGIN
		-- create table statement
		CREATE TABLE [ODS].[lkp].[lkp_test_name](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
		)

		-- insert to table statement
		INSERT INTO [ODS].[lkp].[lkp_test_name](
				   source_name,
				   target_name,
				   date_created
		)
		VALUES 
		('CD4', 'CD4 Count', GETDATE()),
		('CD4 %', 'CD4 Percentage',  GETDATE()),
		('CD4 COUNT', 'CD4 Count', GETDATE()),
		('CD4 Percent', 'CD4 Percentage', GETDATE()),
		('CD4 Percentage', 'CD4 Percentage', GETDATE()),
		('CD4 Test', 'CD4 Count', GETDATE()),
		('CD4%', 'CD4 Percentage', GETDATE()),
		('CViral', 'Viral Load', GETDATE()),
		('HIV VIRAL LOAD', 'Viral Load', GETDATE()),
		('Hiv Viral Load Count', 'Viral Load', GETDATE()),
		('HIV VIRAL LOAD, QUALITATIVE', 'Viral Load', GETDATE()),
		('LDL', 'Viral Load', GETDATE()),
		('LDL (Mg/dL)', 'Viral Load', GETDATE()),
		('Viral Load', 'Viral Load', GETDATE()),
		('Viral Load Test', 'Viral Load', GETDATE()),
		('ViralLoad Undetectable', 'Viral Load', GETDATE()),
		('VL', 'Viral Load', GETDATE())

END