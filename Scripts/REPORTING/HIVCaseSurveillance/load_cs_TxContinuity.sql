IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsTxContinuity]', N'U') IS NOT NULL 
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsTxContinuity];


BEGIN 
	SELECT	Facility.FacilityName
			,Facility.MFLCode
			,Facility.County
			,Facility.SubCounty
			,Patient.PatientPKHash
			,Patient.Gender
			,Patient.DOB
			,[AgeGroup].DATIMAgeGroup as Agegroup,
			,[Partner].PartnerName
			,case 
				when ARTOutcome.ARTOutcomeDescription in ('LOSS TO FOLLOW UP','UNDOCUMENTED LOSS') Then 'IIT'
				when ARTOutcome.ARTOutcomeDescription in ('DEAD') Then 'MORTALITY'
				else ARTOutcome.ARTOutcomeDescription 
			end ARTOutcome
			,asofdatekey
			,YEAR(TRY_CAST(DateConfirmedHIVPositiveKey AS DATETIME2)) As CohortYear
			,TRY_CAST(DateConfirmedHIVPositiveKey AS DATETIME2) As CohortYearMonth
			,cast(asofdatekey as datetime2) As OutcomeYearMonth
			,COUNT(1) AS NoOfClients
			INTO [HIVCaseSurveillance].[dbo].[CsTxContinuity]
		FROM [NDWH].[dbo].[FactARTHistory] FactARTHistory
		LEFT OUTER JOIN [NDWH].[dbo].[DimFacility] Facility
		ON FactARTHistory.FacilityKey	= Facility.FacilityKey
		LEFT OUTER JOIN [NDWH].[dbo].[DimPatient] Patient
		on FactARTHistory.PatientKey = Patient.PatientKey
	LEFT OUTER JOIN [NDWH].[dbo].[DimPartner] [Partner]
		on FactARTHistory.PartnerKey = [Partner].PartnerKey
	LEFT OUTER JOIN [NDWH].[dbo].[DimAgency] Agency
		on FactARTHistory.AgencyKey = Agency.AgencyKey
	LEFT OUTER JOIN [NDWH].[dbo].[DimARTOutcome] ARTOutcome
		on FactARTHistory.ARTOutcomeKey = ARTOutcome.ARTOutcomeKey
	LEFT OUTER JOIN [NDWH].[dbo].[DimDate] [Date]
		ON FactARTHistory.AsOfDateKey = [Date].[Date]
	LEFT OUTER JOIN [NDWH].[dbo].[DimAgeGroup] [AgeGroup]
		ON FactARTHistory.AgeGroup = [AgeGroup].DATIMAgeGroup
		WHERE Facility.MFLCode IS NOT NULL AND FactARTHistory.ARTOutcomeKey in (2,3,6,8) -- MORTALITY{2="DEAD"},Txcurr{6="ACTIVE},IIT{8=UNDOCUMENTED LOSS" 3="LOSS TO FOLLOW UP"}
            AND YEAR(AsOfDateKey) <= YEAR(GETDATE())
		GROUP BY Facility.FacilityName
				,Facility.MFLCode
				,Facility.County
				,Facility.SubCounty
				,Patient.PatientPKHash
				,Patient.Gender
				,Patient.DOB
				,[Partner].PartnerName
				,ARTOutcome.ARTOutcomeDescription
				,asofdatekey
				,DateConfirmedHIVPositiveKey
				,[AgeGroup].DATIMAgeGroup
			ORDER BY DateConfirmedHIVPositiveKey DESC;
END

