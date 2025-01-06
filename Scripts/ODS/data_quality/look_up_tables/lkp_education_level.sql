IF OBJECT_ID(N'[ODS].[lkp].[lkp_education_level]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_education_level];
BEGIN
		-- create statement
		CREATE TABLE [ODS].[lkp].[lkp_education_level](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
			)

		--insert statement
		INSERT INTO [ODS].[lkp].[lkp_education_level](
			source_name, 
			target_name,
			date_created
		)
		VALUES
		(' None',' None',GETDATE()),
		('college/university/polytechnic','COLLEGE',GETDATE()),
		('LIVING WITH PARTNER','NULL',GETDATE()),
		('MARRIED','NULL',GETDATE()),
		('Married Monogamous','NULL',GETDATE()),
		('Never Schooled','NONE',GETDATE()),
		('None','NONE',GETDATE()),
		('Not Applicable','NONE',GETDATE()),
		('Other','NONE',GETDATE()),
		('Post-Secondary','COLLEGE',GETDATE()),
		('Pre-Primary','PRIMARY',GETDATE()),
		('Primary','PRIMARY',GETDATE()),
		('PRIMARY COMPLETED','PRIMARY',GETDATE()),
		('PRIMARY SCHOOL EDUCATION','PRIMARY',GETDATE()),
		('Secondary','SECONDARY ',GETDATE()),
		('SECONDARY COMPLETED','SECONDARY ',GETDATE()),
		('SECONDARY SCHOOL EDUCATION','SECONDARY ',GETDATE()),
		('Single','NULL',GETDATE()),
		('SINGLE/SEPARATED/DIVORCED','NULL',GETDATE()),
		('SOME COLLEGE/UNIVERSITY','COLLEGE',GETDATE()),
		('SOME PRIMARY','PRIMARY',GETDATE()),
		('SOME SECONDARY','SECONDARY',GETDATE()),
		('Tertiary','COLLEGE',GETDATE()),
		('Undergraduate education complete','COLLEGE',GETDATE()),
		('university','COLLEGE',GETDATE()),
		('WIDOWED','NULL',GETDATE()),
		('isnull','NOT PROVIDED',GETDATE())

END