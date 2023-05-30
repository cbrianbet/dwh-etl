IF OBJECT_ID(N'[REPORTING].[dbo].AggregateVLUptakeOutcome', N'U') IS NOT NULL 		
	truncate table [REPORTING].[dbo].AggregateVLUptakeOutcome
GO

INSERT INTO [REPORTING].dbo.AggregateVLUptakeOutcome (MFLCode, FacilityName,County,SubCounty, PartnerName, AgencyName,Gender, StartARTYear, AgeGroup, TotalLast12MVL, Last12MVLResult, TXCurr, EligibleVL12Mnths, VLDone, VirallySuppressed, NewLast12MVLResult,VLAt12Months,VLAt12Months_Sup,VLAt18Months,VLAt18Months_Sup,VLAt24Months,VLAt24Months_Sup,VLAt6Months,VLAt6Months_Sup)
SELECT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	YEAR ( art.StartARTDateKey ) AS StartARTYear,
	g.DATIMAgeGroup AS AgeGroup,
	COUNT ( Last12MVLResult ) AS TotalLast12MVL,
	CASE
		WHEN ISNUMERIC( it.Last12MonthVLResults ) = 1 THEN
		CASE
			WHEN CAST ( Replace( it.Last12MonthVLResults, ',', '' ) AS FLOAT ) < 400.00 THEN
			'SUPPRESSED' 
			WHEN CAST ( Replace( it.Last12MonthVLResults, ',', '' ) AS FLOAT ) BETWEEN 400.00 AND 1000.00 THEN
			'LLV' 
			WHEN CAST ( Replace( it.Last12MonthVLResults, ',', '' ) AS FLOAT ) > 1000.00 THEN
			'HVL' ELSE NULL 
			END 
		ELSE CASE
        WHEN it.Last12MonthVLResults IN ( 'Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level' ) THEN
        'SUPPRESSED' ELSE NULL 
		END 
	END AS Last12MVLResult,
	SUM ( IsTXCurr ) AS TXCurr,
	SUM ( EligibleVL ) AS EligibleVL12Mnths,
	SUM ( Last12MonthVL ) AS VLDone,
	SUM ( Last12MVLSup ) AS VirallySuppressed,
	SUM ( Last12MonthVL ) AS NewLast12MVLResult,
	SUM (CASE WHEN _12MonthVL IS NOT NULL THEN 1 END  ) AS VLAt12Months,
	SUM ( [12MonthVLSup] ) AS VLAt12Months_Sup,
	SUM (CASE WHEN _18MonthVL IS NOT NULL THEN 1 END ) AS VLAt18Months,
	SUM ( [18MonthVLSup] ) AS VLAt18Months_Sup,
	SUM (CASE WHEN _24MonthVL IS NOT NULL THEN 1 END ) AS VLAt24Months,
	SUM ( [24MonthVLSup] ) AS VLAt24Months_Sup,
	SUM (CASE WHEN _6MonthVL IS NOT NULL THEN 1 END ) AS VLAt6Months,
	SUM ( [6MonthVLSup] ) AS VLAt6Months_Sup
FROM
	NDWH.dbo.FactViralLoads it
	LEFT JOIN NDWH.dbo.DimAgeGroup g ON g.AgeGroupKey= it.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = it.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = it.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = it.PatientKey
	LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = it.PartnerKey
	LEFT JOIN NDWH.dbo.FactART art ON art.PatientKey = it.PatientKey 
  LEFT join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
WHERE IsTXCurr=1 and outcome.ARTOutcome = 'V'
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, g.DATIMAgeGroup, art.StartARTDateKey, Last12MVLResult, Last12MonthVLResults