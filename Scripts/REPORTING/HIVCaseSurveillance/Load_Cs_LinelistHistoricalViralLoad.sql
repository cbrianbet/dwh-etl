IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistHistoricalViralLoad]', N'U') IS NOT NULL 
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistHistoricalViralLoad];


BEGIN 
	SELECT	Facility.FacilityName
			,Facility.MFLCode
			,Facility.County
			,Facility.SubCounty
			,Patient.PatientPKHash
			,Patient.Gender
			,Patient.DOB
			,StartARTDate
			,AsOfDate
			,AgeAsOfDate
			,[AgeGroup].DATIMAgeGroup
			,YEAR(TRY_CAST(DateConfirmedHIVPositiveKey AS DATE)) As CohortYear
			,TRY_CAST(DateConfirmedHIVPositiveKey AS DATE) As CohortYearMonth
			,cast(DateConfirmedHIVPositiveKey as date) As OutcomeYearMonth
			,IsPBFW
			,EligibleVL As VLEligibility
			,IsValidVL As VLValidity
			,VLSup As VLSuppression
			INTO [HIVCaseSurveillance].[dbo].[CsLinelistHistoricalViralLoad]
		FROM ndwh.dbo.FactViralLoad_Historical FactViralLoad_Hist
		LEFT OUTER JOIN [NDWH].[Dim].[DimFacility] Facility
		ON FactViralLoad_Hist.FacilityKey	= Facility.FacilityKey
		LEFT OUTER JOIN [NDWH].[Dim].[DimPatient] Patient
		on FactViralLoad_Hist.PatientKey = Patient.PatientKey
			LEFT OUTER JOIN [NDWH].[Dim].[DimDate] [Date]
		ON FactViralLoad_Hist.AsOfDate = [Date].[Date]
	LEFT OUTER JOIN [NDWH].[Dim].[DimAgeGroup] [AgeGroup]
		ON FactViralLoad_Hist.AgeGroupKey = [AgeGroup].AgeGroupKey
				where  YEAR(DateConfirmedHIVPositiveKey) <= YEAR(GETDATE())
		
			ORDER BY DateConfirmedHIVPositiveKey DESC;
END

