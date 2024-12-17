IF OBJECT_ID(N'[ODS].[lkp].[lkp_marital_status]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_marital_status];
BEGIN
		-- create table
		 CREATE TABLE [ODS].[lkp].[lkp_marital_status] (
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
			)

		-- insert table
		INSERT INTO [ODS].[lkp].[lkp_marital_status] (
				   source_name,
				   target_name,
				   date_created
		)
		VALUES
		('NULL','NOT PROVIDED',GETDATE()),
		('','NOT PROVIDED',GETDATE()),
		(' AUNT"','NOT PROVIDED',GETDATE()),
		(' FATHER"','NOT PROVIDED',GETDATE()),
		(' MOTHER"','NOT PROVIDED',GETDATE()),
		(' OTHER FAMILY MEMBER"','NOT PROVIDED',GETDATE()),
		(' SISTER"','NOT PROVIDED',GETDATE()),
		(' UNCLE"','NOT PROVIDED',GETDATE()),
		('Allergynone','NOT PROVIDED',GETDATE()),
		('Child','MINOR',GETDATE()),
		('Cohabitating','COHABITING',GETDATE()),
		('Cohabiting','COHABITING',GETDATE()),
		('Dead','WIDOWED',GETDATE()),
		('Divorced','DIVORCED',GETDATE()),
		('Dropped Out of Care','NOT PROVIDED',GETDATE()),
		('FRIEND','COHABITING',GETDATE()),
		('Legal','MARRIED MONOGAMOUS',GETDATE()),
		('Lives Alone','SEPARATED',GETDATE()),
		('LIVING WITH PARTNER','COHABITING',GETDATE()),
		('MARRIED','MARRIED MONOGAMOUS',GETDATE()),
		('Married Monogamous','MARRIED MONOGAMOUS',GETDATE()),
		('Married Polygamous','MARRIED POLYGAMOUS',GETDATE()),
		('Medical specialty','NOT PROVIDED',GETDATE()),
		('Minor','MINOR',GETDATE()),
		('Missing','NOT PROVIDED',GETDATE()),
		('N/A','NOT PROVIDED',GETDATE()),
		('NEVER MARRIED','Single',GETDATE()),
		('Not Applicable','NOT PROVIDED',GETDATE()),
		('NULL','NOT PROVIDED',GETDATE()),
		('Nutritional support','NOT PROVIDED',GETDATE()),
		('Other','OTHER',GETDATE()),
		('Other (specify)','OTHER',GETDATE()),
		('OTHER NON-CODED','OTHER',GETDATE()),
		('Polygamous','MARRIED POLYGAMOUS',GETDATE()),
		('Separated','SEPARATED',GETDATE()),
		('Separeted','SEPARATED',GETDATE()),
		('Sexual Partner','COHABITING',GETDATE()),
		('Single','SINGLE',GETDATE()),
		('SINGLE/SEPARATED/DIVORCED','DIVORCED',GETDATE()),
		('Widowed','WIDOWED',GETDATE()),
		('separated.','SEPARATED',GETDATE()),
		('Seperated','SEPARATED',GETDATE()),
		('Divorced/separated','DIVORCED',GETDATE()),
		('Divorced/Seperated','DIVORCED',GETDATE()),
		('MM','MARRIED MONOGAMOUS',GETDATE()),
		('MP','MARRIED POLYGAMOUS',GETDATE()),
		('C','COHABITING',GETDATE()),
		('D','DIVORCED',GETDATE()),
		('W','WIDOWED',GETDATE()),
		('LIVING WITH PARTNER (COHABITATING)','COHABITING',GETDATE()),
		('Unknown','UNKNOWN',GETDATE()),
		('MARRIED, POLYGAMOUS','MARRIED POLYGAMOUS',GETDATE()),
		('isnull','NOT PROVIDED',GETDATE())

END
