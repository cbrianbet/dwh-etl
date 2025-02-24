IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateFACT_CT_DHIS2]', N'U') IS NOT NULL
	DROP TABLE [REPORTING].[dbo].[AggregateFACT_CT_DHIS2];
BEGIN
	with dhis as (
		SELECT
			*
		FROM NDWH.Fact.FACT_CT_DHIS2 CT
	)

	SELECT
		DHISOrgId
		, MFLCode
        , FacilityName
        , County
        , SubCounty
        , AgencyName
        , PartnerName
        , Ward
        , ReportMonth_Year
        , Enrolled_Total
        , StartedART_Total
        , CurrentOnART_Total
        , CTX_Total
        , OnART_12Months
        , NetCohort_12Months
        , VLSuppression_12Months
        , VLResultAvail_12Months
        , createdAt
        , updatedAt
        , Start_ART_Under_1
        , Start_ART_1_9
        , Start_ART_10_14_M
        , Start_ART_10_14_F
        , Start_ART_15_19_M
        , Start_ART_15_19_F
        , Start_ART_20_24_M
        , Start_ART_20_24_F
        , Start_ART_25_Plus_M
        , Start_ART_25_Plus_F
        , On_ART_Under_1
        , On_ART_1_9
        , On_ART_10_14_M
        , On_ART_10_14_F
        , On_ART_15_19_M
        , On_ART_15_19_F
        , On_ART_20_24_M
        , On_ART_20_24_F
        , On_ART_25_Plus_M
        , On_ART_25_Plus_F
        , cast(getdate() as date) as LoadDate
	INTO REPORTING.dbo.AggregateFACT_CT_DHIS2
	FROM dhis
		LEFT JOIN NDWH.Dim.DimFacility fac on dhis.FacilityKey=fac.FacilityKey
		LEFT JOIN NDWH.Dim.DimAgency agency on dhis.AgencyKey=agency.AgencyKey
		LEFT JOIN NDWH.Dim.DimPartner part on dhis.PartnerKey=part.PartnerKey
	WHERE MFLCode IS NOT NULL

END
