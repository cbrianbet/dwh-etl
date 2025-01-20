IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LastPharmacyDispenseDate]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LastPharmacyDispenseDate];
BEGIN
	--Load_LastPharmacyDispenseDate
	With LastPharmacyDispenseDate AS (
	SELECT  row_number() OVER (PARTITION BY SiteCode,PatientPK ORDER BY DispenseDate DESC) AS NUM,
		PatientID ,
		SiteCode,
		PatientPK,
		cast( '' as nvarchar(100)) PatientPKHash,
		cast( '' as nvarchar(100)) PatientIDHash,
		DispenseDate as LastDispenseDate,
	CASE WHEN ExpectedReturn IS NULL THEN DATEADD(dd,30,DispenseDate) ELSE ExpectedReturn End AS ExpectedReturn,
	cast(getdate() as date) as LoadDate
	FROM ODS.Care.CT_PatientPharmacy
	WHERE  VOIDED=0
	 )
	 Select LastPharmacyDispenseDate.* 
	 INTO [ODS].[Intermediate].[Intermediate_LastPharmacyDispenseDate]
	 from LastPharmacyDispenseDate
	 where NUM=1
END
