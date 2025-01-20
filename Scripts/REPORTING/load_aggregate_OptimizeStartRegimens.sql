IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOptimizeStartRegimens]', N'U') IS NOT NULL	
	DROP TABLE [REPORTING].[dbo].[AggregateOptimizeStartRegimens];

SELECT
	SiteCode,
	FacilityName,
	County,
	Subcounty,
	PartnerName,
	AgencyName,
	Agegroup,
	[DATIMAgeGroup],
	Gender,
	StartRegimen,
	StartARTMonth,
	StartARTYr,
    AsOfDate,
	CurrentVL,
	SUM ( ISTxCurr ) TXCurr,
	Firstregimen,
	ValidVLResultCategory,
	CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[AggregateOptimizeStartRegimens]
FROM
	(
	SELECT
		SiteCode,
		FacilityName,
		County,
		Subcounty,
		PartnerName,
		AgencyName,
		DateName( m, StartARTDateKey ) AS StartARTMonth,
		YEAR ( StartARTDateKey ) AS StartARTYr,
        EOMONTH(date.Date ) AS AsOfDate,
		CASE
			WHEN StartRegimen LIKE '3TC+DTG+TDF' THEN
			'TLD' 
			WHEN StartRegimen LIKE '3TC+EFV+TDF' THEN
			'TLE' 
			WHEN StartRegimen LIKE '%NVP%' THEN
			'NVP' ELSE 'Other Regimen' 
		END AS StartRegimen,
		StartRegimen AS Firstregimen,
		Gender,
		Agegrouping as Agegroup,
		DATIMAgeGroup,

		CASE
			WHEN ISNUMERIC( vl.ValidVLResult ) = 1 THEN
				CASE
					WHEN CAST ( Replace( vl.ValidVLResult, ',', '' ) AS FLOAT ) < 400.00 THEN
						'VL' 
					WHEN CAST ( Replace( vl.ValidVLResult, ',', '' ) AS FLOAT ) BETWEEN 400.00 AND 1000.00 THEN
						'LVL' 
					WHEN CAST ( Replace( vl.ValidVLResult, ',', '' ) AS FLOAT ) > 1000.00 THEN
						'HVL' ELSE NULL 
				END 
			ELSE CASE	
				WHEN vl.ValidVLResult IN ( 'Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level' ) THEN
					'VL' ELSE NULL 
				END 
		END AS Last12MVLResult,
		vl.LastVL AS CurrentVL,

		ValidVLResultCategory2 as ValidVLResultCategory,

		ISTxCurr 
	FROM NDWH.Fact.FACTART art
	INNER JOIN NDWH.Dim.DimAgeGroup age ON art.AgeGroupKey = age.AgeGroupKey
	INNER JOIN NDWH.Dim.DimPartner part ON art.PartnerKey = part.PartnerKey
	INNER JOIN NDWH.Dim.DimAgency a ON art.AgencyKey = a.AgencyKey
	INNER JOIN NDWH.Dim.DimFacility fac ON art.FacilityKey = fac.FacilityKey
	INNER JOIN NDWH.Dim.DimPatient pat ON art.PatientKey = pat.PatientKey
	LEFT JOIN NDWH.Fact.FACTViralLoads vl ON art.PatientKey = vl.PatientKey 
    LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = art.StartARTDateKey 
	WHERE ISTxCurr = 1 
	) H 

	GROUP BY 
		SiteCode, 
		FacilityName, 
		County, 
		Subcounty,
		PartnerName, 
		AgencyName, 
		StartRegimen, 
		Agegroup, 
		[DATIMAgeGroup], 
		Gender, 
		StartARTMonth, 
		StartARTYr, 
        AsOfDate,
		Firstregimen,
        CurrentVL,
		ValidVLResultCategory;