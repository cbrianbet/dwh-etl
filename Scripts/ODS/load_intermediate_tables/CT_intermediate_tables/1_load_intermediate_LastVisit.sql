IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LastVisitDate]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LastVisitDate];
BEGIN

	---Load_LatestVisit
With source_data as (
	SELECT  row_number() OVER (PARTITION BY SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
		PatientID,
		SiteCode,
		PatientPK,
		cast( '' as nvarchar(100))PatientPKHash,
	    cast( '' as nvarchar(100))PatientIDHash,
		VisitDate as LastVisitDate,
		visitID,
    BP,
	  CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS NextAppointment
	FROM ODS.care.CT_PatientVisits
  WHERE VOIDED=0
)
select 
  source_data.*,
  cast(getdate() as date) as LoadDate
into [ODS].[Intermediate].[Intermediate_LastVisitDate]
from source_data as source_data
where NUM = 1

END
