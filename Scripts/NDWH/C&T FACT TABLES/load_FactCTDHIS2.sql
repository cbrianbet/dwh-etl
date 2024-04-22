IF OBJECT_ID(N'[NDWH].[dbo].[FACT_CT_DHIS2]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FACT_CT_DHIS2];

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
     ,DHISOrgId
      ,Ward
      ,ReportMonth_Year
      ,Enrolled_Total
      ,StartedART_Total
      ,CurrentOnART_Total
      ,CTX_Total
      ,OnART_12Months
      ,NetCohort_12Months
      ,VLSuppression_12Months
      ,VLResultAvail_12Months
      ,createdAt
      ,updatedAt
      ,Start_ART_Under_1
      ,Start_ART_1_9
      ,Start_ART_10_14_M
      ,Start_ART_10_14_F
      ,Start_ART_15_19_M
      ,Start_ART_15_19_F
      ,Start_ART_20_24_M
      ,Start_ART_20_24_F
      ,Start_ART_25_Plus_M
      ,Start_ART_25_Plus_F
      ,On_ART_Under_1
      ,On_ART_1_9
      ,On_ART_10_14_M
      ,On_ART_10_14_F
      ,On_ART_15_19_M
      ,On_ART_15_19_F
      ,On_ART_20_24_M
      ,On_ART_20_24_F
      ,On_ART_25_Plus_M
      ,On_ART_25_Plus_F
      into NDWH.dbo.FACT_CT_DHIS2
  FROM ODS.dbo.CT_DHIS2 summary 

left join NDWH.dbo.DimFacility as facility on facility.MFLCode = Summary.SiteCode COLLATE SQL_Latin1_General_CP1_CI_AS
left join Facilityinfo on Facilityinfo.MFL_Code=Summary.SiteCode COLLATE SQL_Latin1_General_CP1_CI_AS
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = Facilityinfo.PartnerName
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = Facilityinfo.Agency

alter table NDWH.dbo.FACT_CT_DHIS2 add primary key(FactKey)
