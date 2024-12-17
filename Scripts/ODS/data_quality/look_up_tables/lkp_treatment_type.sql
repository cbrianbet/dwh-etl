IF OBJECT_ID(N'[ODS].[lkp].[lkp_treatment_type]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_treatment_type];
BEGIN
		-- create table statement
		CREATE TABLE [ODS].[lkp].[lkp_treatment_type](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
		)

		-- insert to table statement
		INSERT INTO [ODS].[lkp].[lkp_treatment_type](
				   source_name,
				   target_name,
				   date_created
		)
		VALUES 
		('HIV Treatment', 'ARV',GETDATE()),
		('Prophylaxis',	'Prophylaxis',GETDATE()),
		('ARV',	'ARV',GETDATE()),
		('ART',	'ARV',GETDATE()),
		('NULL', 'NOT PROVIDED',GETDATE()),
		('PMTCT', 'PMTCT',GETDATE()),
		('Other', 'OTHER',GETDATE()),
		('Non-ART', 'OTHER',GETDATE()),
		('PEP',	'PEP',GETDATE()),
		('NOT WORKING NOW',	'OTHER',GETDATE()),
		('PREP', 'PREP',GETDATE()),
		('DAPSONE',	'Prophylaxis',GETDATE()),
		('Hepatitis B',	'OTHER',GETDATE()),
		('PPCT', 'PMTCT',GETDATE())
END