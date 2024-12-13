IF OBJECT_ID(N'[ODS].[lkp].[lkp_exit_reason]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[lkp].[lkp_exit_reason];
BEGIN
		-- create table statement
		CREATE TABLE [ODS].[lkp].[lkp_exit_reason](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
		)

		-- insert table
		INSERT INTO [ODS].[lkp].[lkp_exit_reason] (
				   source_name,
				   target_name,
				   date_created
		)
		VALUES
		('Transfer Out', 'TRANSFER OUT', GETDATE()),
		('LTFU', 'LTFU', GETDATE()),
		('Died', 'DEAD', GETDATE()),
		('dead', 'DEAD', GETDATE()),
		('transfer_out', 'TRANSFER OUT', GETDATE()),
		('COMPLETED', 'COMPLETED TREATMENT', GETDATE()),
		('Transferred out', 'TRANSFER OUT', GETDATE()),
		('Lost to followup', 'LTFU', GETDATE()),
		('Lost', 'LTFU', GETDATE()),
		('Transfer', 'TRANSFER OUT', GETDATE()),
		('Death', 'DEAD', GETDATE()),
		('TRANSFER TO ANOTHER CLINIC', 'TRANSFER OUT', GETDATE()),
		('OTHER NON-CODED', 'OTHERS', GETDATE()),
		('Unknown', 'OTHERS', GETDATE()),
		('LOST TO FOLLOW UP', 'LTFU', GETDATE()),
		('HIV-', 'OTHERS', GETDATE()),
		('Treatment complete', 'COMPLETED TREATMENT', GETDATE()),
		('Stopped Treatment', 'STOPPED TREATMENT', GETDATE()),
		('discontinue', 	'STOPPED TREATMENT', GETDATE()),
		('PATIENT REFUSED CARE', 'OTHERS', GETDATE()),
		('Stopped', 'STOPPED TREATMENT', GETDATE()),
		('Toxicity, drug', 'OTHERS', GETDATE()),
		('Stop', 'STOPPED TREATMENT', GETDATE()),
		('HIV Positive', 'OTHERS', GETDATE()),
		('INFANT HIV-NEGATIVE', 'OTHERS', GETDATE()),
		('HIV NEGATIVE, NO LONGER AT RISK', 'OTHERS', GETDATE()),
		('Active', 'OTHERS', GETDATE()),
		('Cannot afford treatment', 'OTHERS', GETDATE()),
		('MIGRATION TO OTHER REGIONS', 'OTHERS', GETDATE()),
		('HIV Negative', 'OTHERS', GETDATE()),
		('PATIENT REQUEST', 'OTHERS', GETDATE()),
		('Self Referred to other Organisations', 'OTHERS', GETDATE()),
		('TUBERCULOSIS', 'OTHERS', GETDATE()),
		('OTZ Transition to Adult care', 'OTHERS', GETDATE()),
		('Voluntary exit', 'OTHERS', GETDATE()),
		('Patient transferred out', 'TRANSFER OUT', GETDATE()),
		('REFUSAL OF TREATMENT BY PATIENT', 'OTHERS', GETDATE())

END