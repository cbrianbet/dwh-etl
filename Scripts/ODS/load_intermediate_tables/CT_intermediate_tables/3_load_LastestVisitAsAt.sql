IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LastVisitAsAt]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LastVisitAsAt];
BEGIN
	--Load_LastVisitAsAt
	With LastVisitAsAt AS (
	SELECT  row_number() OVER (PARTITION BY SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
		PatientID ,
		SiteCode,
		PatientPK,
		VisitDate AS VisitDateAsAt,
	 cast( '' as nvarchar(100))PatientPKHash,
	 cast( '' as nvarchar(100))PatientIDHash,
	CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS AppointmentDateAsAt ,
	cast(getdate() as date) as LoadDate
	FROM [ODS].[Care].[CT_PatientVisits]
	WHERE VOIDED=0
	 )
	 Select LastVisitAsAt.* 
	 
	 INTO [ODS].[Intermediate].[Intermediate_LastVisitAsAt]
	 from LastVisitAsAt
	 where NUM=1 and VisitDateAsAt<=EOMONTH(DATEADD(mm,-1,GETDATE()))
END
