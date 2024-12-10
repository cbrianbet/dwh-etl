IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSTBscreening]', N'U') IS NOT NULL 
drop TABLE REPORTING.[dbo].[AggregateHTSTBscreening]
GO

WITH tested AS (
    SELECT distinct 
        MFLCode,
        FacilityName,
        hts.PatientKey,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        Gender,
        DATIMAgeGroup,
        tbScreening,
        case 
            when TBScreening is not null then 'Screened for TB'
            else 'Not Screened for TB' 
        end as TBScreening_Grp,
        d.year,
        d.month,
        FORMAT(cast(date as date), 'MMMM') MonthName,  
        EOMONTH(d.[Date]) as AsOfDate,  
        Tested,        
        Positive,         
        Linked
    FROM NDWH.Fact.FactHTSClientTests hts
    LEFT join NDWH.Dim.DimFacility f on f.FacilityKey = hts.FacilityKey
    LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = hts.AgencyKey
    LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = hts.PatientKey
    LEFT join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
    LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = hts.PartnerKey
    LEFT JOIN NDWH.Fact.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.Dim.DimDate d on d.DateKey = hts.DateTestedKey
    WHERE TestType in ('Initial Test', 'Initial')
)
SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    DATIMAgeGroup as AgeGroup,
    tbScreening,
    TBScreening_Grp,
    year,
    month,
    MonthName,
    AsOfDate,
    Sum(Tested) Tested,
    Sum(Positive) Positive,
    Sum(Linked) Linked,
    CAST(GETDATE() AS DATE) AS LoadDate 
    INTO REPORTING.dbo.AggregateHTSTBscreening
FROM tested
GROUP BY 
    MFLCode, 
    FacilityName, 
    County,
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    DATIMAgeGroup, 
    tbScreening, 
    year, 
    month, 
    MonthName, 
    AsOfDate,
    TBScreening_Grp