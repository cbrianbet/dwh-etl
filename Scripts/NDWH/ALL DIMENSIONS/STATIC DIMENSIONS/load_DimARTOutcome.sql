IF OBJECT_ID(N'[NDWH].[dbo].[DimARTOutcome]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[DimARTOutcome];
BEGIN
	---DimARTOutcome
	with distinct_ARTOutcomes as (
		select 'S' as ARTOutcome
			union all
		select 'D' as ARTOutcome
			union all
		select 'L' as ARTOutcome
			union all
		select 'NV' as ARTOutcome
			union all
		select 'T' as ARTOutcome
			union all
		select 'V' as ARTOutcome
			union all
		select 'NP' as ARTOutcome
			union all
		select'uL' as ARTOutcome
			union all
		select'FV' as ARTOutcome
      	union all
		select'LIHMIS' as ARTOutcome
	)
	select 
		ARTOutcomeKey = IDENTITY(INT, 1, 1),
		ARTOutcome,
		case
			WHEN [ARTOutcome] ='V'	THEN 'ACTIVE'
			WHEN [ARTOutcome] ='S'	THEN 'STOPPED'
			WHEN [ARTOutcome] ='D'	THEN 'DEAD'
			WHEN [ARTOutcome] ='L'	THEN 'LOSS TO FOLLOW UP'
			WHEN [ARTOutcome] ='NV'	THEN 'NO VISIT'
			WHEN [ARTOutcome] ='T'	THEN 'TRANSFERRED OUT'
			WHEN [ARTOutcome] ='NP' THEN 'NEW PATIENT'
			WHEN [ARTOutcome] ='UL' THEN 'UNDOCUMENTED LOSS'
			WHEN [ARTOutcome] = 'FV'  THEN 'FUTURE VISIT'
         WHEN [ARTOutcome] = 'LIHMIS'  THEN 'LOST IN HMIS'


		end as ARTOutcomeDescription,
		cast(getdate() as date) as LoadDate
	INTO [NDWH].[dbo].[DimARTOutcome]
	from distinct_ARTOutcomes;
	ALTER TABLE NDWH.dbo.DimARTOutcome ADD PRIMARY KEY(ARTOutcomeKey);
END