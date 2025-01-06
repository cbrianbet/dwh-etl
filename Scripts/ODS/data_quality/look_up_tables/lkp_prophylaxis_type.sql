IF OBJECT_ID(N'[ODS].[lkp].[lkp_prophylaxis_type]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_prophylaxis_type];
BEGIN
		-- create table statement
		CREATE TABLE [ODS].[lkp].[lkp_prophylaxis_type](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
		)
		-- insert to table statement
		INSERT INTO [ODS].[lkp].[lkp_prophylaxis_type](
				   source_name,
				   target_name,
				   date_created
		)
		VALUES 
		('CTX', 'COTRIMOXAZOLE',GETDATE()),
		('TB Prophylaxis', 'ISONIAZID',GETDATE()),
		('DAPSON', 'DAPSONE',GETDATE()),
		('HIV Treatment', 'OTHER',GETDATE()),
		('Fluconazole', 'Fluconazole',GETDATE()),
		('COTRIMOXAZOLE', 'COTRIMOXAZOLE',GETDATE()),
		('DAPSONE', 'DAPSONE',GETDATE()),
		('INH', 'ISONIAZID',GETDATE()),
		('ISONIAZID', 'ISONIAZID',GETDATE())

END