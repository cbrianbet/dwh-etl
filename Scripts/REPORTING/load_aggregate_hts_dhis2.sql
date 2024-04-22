IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateFACT_HTS_DHIS2]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[AggregateFACT_HTS_DHIS2];
Begin
	SELECT 	
			[MFLCode]
			,[facility].FacilityName
			,facility.County
			,facility.SubCounty
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
			, partner.PartnerName
			,Agency as AgencyName
			,CAST(GETDATE() AS DATE) AS LoadDate
	INTO REPORTING.dbo.AggregateFACT_HTS_DHIS2
		FROM NDWH.dbo.FACT_HTS_DHIS2 CT  
		LEFT join NDWH.dbo.DimFacility facility on facility.FacilityKey=CT.facilitykey 
        left join NDWH.dbo.DimPartner partner on partner.PartnerKey=CT.PartnerKey
        left join NDWH.dbo.DimAgency agency on agency.AgencyKey=CT.Agencykey
        WHERE MFLCode IS NOT NULL
	
End


