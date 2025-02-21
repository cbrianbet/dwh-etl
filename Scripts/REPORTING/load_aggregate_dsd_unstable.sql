IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDUnstable]', N'U') IS NOT NULL 
	drop TABLE [REPORTING].[dbo].[AggregateDSDUnstable]
GO


SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    AgeGroup, 
    Sum ([OnART<12Months]) as onARTlessthan12mnths,
    Sum(Agelessthan20Yrs) as Agelessthan20Yrs ,
    Sum(Adherence) As Adherence,
    Sum(HighVL) as HighVL,
    Sum(BMI) as BMI,
    Sum(LatestPregnancy)as LatestPregnancy,
    Sum (isTXCurr) patients_number,
    cast(getdate() as date) as LoadDate
  INTO REPORTING.dbo.AggregateDSDUnstable
FROM (
    SELECT DISTINCT
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    pat.Gender,
    age.DATIMAgeGroup as AgeGroup, 
    CASE WHEN DATEDIFF(MONTH,art.StartARTDateKey,GETDATE())>=12 THEN 0
        WHEN DATEDIFF(MONTH,art.StartARTDateKey,GETDATE())<12  THEN 1
        ELSE NULL END AS [OnART<12Months],
    case when lob.AgeLastVisit < 20 then 1 else 0 end as Agelessthan20Yrs,
    case when Adherence = 'Poor' then 1 else 0 end as Adherence,
    Case when lob.Pregnant= 'Yes' THEN 1 Else 0 End as LatestPregnancy,
    Case when LatestWeight IS NOT NULL AND LatestHeight IS NOT NULL AND cast(LatestWeight as float) > 0 and cast(LatestHeight as float) > 0 AND cast(LatestWeight as float) / (cast(LatestHeight as float) * cast(LatestHeight as float)) <=18.5 THEN 1 
        ELSE 0 END AS BMI,
    Case when ISNumeric(ValidVLResult)=1 and cast(Replace(ValidVLResult,',','') as FLOAT) >= 200.00 then 1 else 0 end as HighVL,
    isTXCurr
    FROM NDWH.Fact.FactLatestObs lob
    INNER JOIN NDWH.Dim.DimAgeGroup age on age.AgeGroupKey = lob.AgeGroupKey
    INNER JOIN NDWH.Dim.DimFacility f on f.FacilityKey = lob.FacilityKey
    INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = lob.AgencyKey
    INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = lob.PatientKey
    INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = lob.PartnerKey
    INNER JOIN NDWH.Fact.FactART art on art.PatientKey = lob.PatientKey
    LEFT JOIN NDWH.Fact.FactViralLoads vl on vl.PatientKey = lob.PatientKey and vl.PatientKey IS NOT NULL
    WHERE pat.isTXCurr = 1
) A
GROUP BY MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup
GO
