IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastVisitDate]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastVisitDate];
BEGIN
	---Load_LatestVisit
	With LatestVisit AS (
	SELECT  row_number() OVER (PARTITION BY PatientID ,SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
		PatientID,
		SiteCode,
		PatientPK,
		VisitDate as LastVisitDate,
	CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS NextAppointment,
	cast(getdate() as date) as LoadDate,
	 convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2) PatientPKHash,
	convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)PatientIDHash
	FROM ODS.dbo.CT_PatientVisits
	 )
	 Select LatestVisit.* 
		INTO [ODS].[dbo].[Intermediate_LastVisitDate]
	 from LatestVisit
	 where NUM=1
END







