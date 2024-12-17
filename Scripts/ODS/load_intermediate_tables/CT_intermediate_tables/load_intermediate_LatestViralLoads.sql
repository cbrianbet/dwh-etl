IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LatestViralLoads]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LatestViralLoads];
BEGIN
	with source_LatestViralLoads as (
		select
			row_number() over(partition by SiteCode, PatientPK order by OrderedbyDate desc) as rank, 
			PatientID,
			SiteCode,
			PatientPK,
			VisitID,
			[OrderedbyDate],
			[ReportedbyDate],
			[TestName],
			TestResult,
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash,
			[Emr],
			[Project],
			Reason
		from ODS.Care.CT_PatientLabs
		where TestName = 'Viral Load'
				and TestName <>'CholesterolLDL (mmol/L)' and TestName <> 'Hepatitis C viral load' 
				and TestResult is not null and VOIDED=0
	)
	select 
 		source_LatestViralLoads.*,						
		cast(getdate() as date) as LoadDate
	into [ODS].[Intermediate].[Intermediate_LatestViralLoads]
	from source_LatestViralLoads
	where rank = 1
END
	

