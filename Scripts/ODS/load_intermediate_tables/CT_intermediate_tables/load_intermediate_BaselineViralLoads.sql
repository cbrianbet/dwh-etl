IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_BaseLineViralLoads]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_BaseLineViralLoads];
BEGIN
	with source_BaseLineViralLoads as (
		select
			row_number() over(partition by  SiteCode, PatientPK order by OrderedbyDate asc) as rank, 
			PatientID,
			SiteCode,
			PatientPK,
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash,
			VisitID,
			[OrderedbyDate],
			[ReportedbyDate],
			[TestName],
			TestResult,
			[Emr],
			[Project]

		from ODS.Care.CT_PatientLabs
		where TestName = 'Viral Load'
				and TestName <>'CholesterolLDL (mmol/L)' and TestName <> 'Hepatitis C viral load' 
				and TestResult is not null and VOIDED=0
	)
	select 
 		source_BaseLineViralLoads.*,
		cast(getdate() as date) as LoadDate
	INTO [ODS].[Intermediate].[Intermediate_BaseLineViralLoads]
	from source_BaseLineViralLoads
	where rank = 1
END