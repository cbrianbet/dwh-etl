IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateFACT_HTS_DHIS2]', N'U') IS NOT NULL
	DROP TABLE [REPORTING].[dbo].[AggregateFACT_HTS_DHIS2];
BEGIN
	with dhis as (
		SELECT
			*
		FROM NDWH.Fact.FACT_HTS_DHIS2
	)

	SELECT
		MFLCode
        , FacilityName
        , County
        , SubCounty
        , agency.AgencyName
        , part.PartnerName
        , [ReportMonth_Year]
        , [Tested_Total]
        , [Positive_Total]
        , [createdAt]
        , [updatedAt]
        , [Tested_1_9]
        , [Tested_10_14_M]
        , [Tested_10_14_F]
        , [Tested_15_19_M]
        , [Tested_15_19_F]
        , [Tested_20_24_M]
        , [Tested_20_24_F]
        , [Tested_25_Plus_M]
        , [Tested_25_Plus_F]
        , [Positive_1_9]
        , [Positive_10_14_M]
        , [Positive_10_14_F]
        , [Positive_15_19_M]
        , [Positive_15_19_F]
        , [Positive_20_24_M]
        , [Positive_20_24_F]
        , [Positive_25_Plus_M]
        , [Positive_25_Plus_F]
        , cast(getdate() as date) as LoadDate
	INTO REPORTING.dbo.AggregateFACT_HTS_DHIS2
	FROM dhis
		LEFT JOIN NDWH.Dim.DimFacility fac on dhis.FacilityKey=fac.FacilityKey
		LEFT JOIN NDWH.Dim.DimAgency agency on dhis.AgencyKey=agency.AgencyKey
		LEFT JOIN NDWH.Dim.DimPartner part on dhis.PartnerKey=part.PartnerKey
	WHERE MFLCode IS NOT NULL

END