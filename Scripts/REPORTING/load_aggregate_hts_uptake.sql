

IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSUptake]', N'U') IS NOT NULL 

DROP TABLE REPORTING.[dbo].[AggregateHTSUptake]
GO

BEGIN
		Declare @emonth	datetime2

			set @emonth = ( select 
								case 
									when day(getdate()) >= 1 and day(getdate()) <= 15 then eomonth(getdate(), -2)
									else eomonth (getdate(), -1) 
								end as emonth_calc
							);

		WITH HTS_DATASET AS (
			SELECT 
				DISTINCT
				MFLCode,
				f.FacilityName,
				County,
				SubCounty,
				p.PartnerName,
				a.AgencyName,
				Gender,
				age.DATIMAgeGroup AS AgeGroup,
				TestedBefore,
				year,
				month,
				EOMONTH(d.Date) as AsOfDate,
				FORMAT(CAST(date AS date), 'MMMM') AS MonthName,
				SUM(Tested) AS Tested,
				SUM(Positive) AS Positive,
				SUM(Linked) AS Linked,
				CAST(GETDATE() AS DATE) AS LoadDate 
			FROM NDWH.Fact.FactHTSClientTests hts
			LEFT JOIN NDWH.Dim.DimFacility f ON f.FacilityKey = hts.FacilityKey
			LEFT JOIN NDWH.Dim.DimAgency a ON a.AgencyKey = hts.AgencyKey
			LEFT JOIN NDWH.Dim.DimPatient pat ON pat.PatientKey = hts.PatientKey
			LEFT JOIN NDWH.Dim.DimAgeGroup age ON age.AgeGroupKey = hts.AgeGroupKey
			LEFT JOIN NDWH.Dim.DimPartner p ON p.PartnerKey = hts.PartnerKey
			LEFT JOIN NDWH.Fact.FactHTSClientLinkages link ON link.PatientKey = hts.PatientKey
			LEFT JOIN NDWH.Dim.DimDate d ON d.DateKey = hts.DateTestedKey
			WHERE TestType IN ('Initial Test', 'Initial') and  d.[Date] <= @emonth
			GROUP BY 
				MFLCode, 
				f.FacilityName,
				County, 
				SubCounty, 
				p.PartnerName, 
				a.AgencyName, 
				Gender, 
				age.DATIMAgeGroup, 
				TestedBefore, 
				year, 
				month, 
				FORMAT(CAST(date AS date), 'MMMM'),
				EOMONTH(d.Date)
		)
		SELECT 
			HTS_DATASET.*
		INTO REPORTING.dbo.AggregateHTSUptake
		FROM HTS_DATASET
END
