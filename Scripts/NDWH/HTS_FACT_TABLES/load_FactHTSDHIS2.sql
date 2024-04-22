IF OBJECT_ID(N'[NDWH].[dbo].[FACT_HTS_DHIS2]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FACT_HTS_DHIS2];
BEGIN
With Facilityinfo AS (
                Select
                    MFL_Code,
                    Facility_Name,
                    County,
                    SDP as PartnerName,
                    SDP_Agency as Agency,
                    EMR
                from ODS.dbo.All_EMRSites
)

		SELECT
			 FactKey = IDENTITY(INT, 1, 1)
             ,facility.FacilityKey
	         ,partner.PartnerKey
	         ,agency.AgencyKey 
			,[ReportMonth_Year]
			,[Tested_Total]
			,[Positive_Total]
			,[createdAt]
			,[updatedAt]
			,[Tested_1_9]
			,[Tested_10_14_M]
			,[Tested_10_14_F]
			,[Tested_15_19_M]
			,[Tested_15_19_F]
			,[Tested_20_24_M]
			,[Tested_20_24_F]
			,[Tested_25_Plus_M]
			,[Tested_25_Plus_F]
			,[Positive_1_9]
			,[Positive_10_14_M]
			,[Positive_10_14_F]
			,[Positive_15_19_M]
			,[Positive_15_19_F]
			,[Positive_20_24_M]
			,[Positive_20_24_F]
			,[Positive_25_Plus_M]
			,[Positive_25_Plus_F]
			,Sites.SDP PartnerName
			,Sites.SDP_Agency AgencyName
			,CAST(GETDATE() AS DATE) AS LoadDate
            Into NDWH.dbo.FACT_HTS_DHIS2 
		FROM ODS.dbo.HTS_DHIS2 summary
		LEFT JOIN ODS.dbo.ALL_EMRSites Sites on summary.SiteCode=Sites.MFL_Code
        left join NDWH.dbo.DimFacility as facility on facility.MFLCode = Summary.SiteCode COLLATE SQL_Latin1_General_CP1_CI_AS
        left join Facilityinfo on Facilityinfo.MFL_Code=Summary.SiteCode COLLATE SQL_Latin1_General_CP1_CI_AS
        left join NDWH.dbo.DimPartner as partner on partner.PartnerName = Facilityinfo.PartnerName
        left join NDWH.dbo.DimAgency as agency on agency.AgencyName = Facilityinfo.Agency
       where MFLCode is not null
         alter table NDWH.dbo.FACT_HTS_DHIS2 add primary key(FactKey)
         END



