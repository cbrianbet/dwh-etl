IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDApptsByStability]', N'U') IS NOT NULL 
    DROP TABLE [REPORTING].[dbo].[AggregateDSDApptsByStability]

SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    AgeGroup, 
    AppointmentsCategory,
    StabilityAssessment,
    Stability,
    COUNT(isTXCurr) AS patients_number,
    CAST(GETDATE() AS DATE) AS LoadDate
INTO REPORTING.dbo.AggregateDSDApptsByStability 
FROM (
    SELECT DISTINCT
        MFLCode,
        f.FacilityName,
        County,
        SubCounty,
        p.PartnerName,
        a.AgencyName,
        pat.Gender,
        age.DATIMAgeGroup AS AgeGroup, 
        CASE 
            WHEN ABS(DATEDIFF(DAY, LastVisitDate, NextAppointmentDate)) <= 89 THEN '<3 Months'
            WHEN ABS(DATEDIFF(DAY, LastVisitDate, NextAppointmentDate)) >= 90 AND ABS(DATEDIFF(DAY, LastVisitDate, NextAppointmentDate)) <= 150 THEN '<3-5 Months'
            WHEN ABS(DATEDIFF(DAY, LastVisitDate, NextAppointmentDate)) > 151 THEN '>6+ Months'
            ELSE 'Unclassified' 
        END AS AppointmentsCategory,
        StabilityAssessment,
        CASE 
            WHEN StabilityAssessment = 'Unstable' THEN 0
            WHEN StabilityAssessment = 'Stable' THEN 1
            ELSE '999' 
        END AS Stability,
        isTXCurr
    FROM NDWH.Fact.FactLatestObs lob
    INNER JOIN NDWH.Dim.DimAgeGroup age ON age.AgeGroupKey = lob.AgeGroupKey
    INNER JOIN NDWH.Dim.DimFacility f ON f.FacilityKey = lob.FacilityKey
    INNER JOIN NDWH.Dim.DimAgency a ON a.AgencyKey = lob.AgencyKey
    INNER JOIN NDWH.Dim.DimPatient pat ON pat.PatientKey = lob.PatientKey
    INNER JOIN NDWH.Dim.DimPartner p ON p.PartnerKey = lob.PartnerKey
    INNER JOIN NDWH.Fact.FactART art ON art.PatientKey = lob.PatientKey
    WHERE pat.isTXCurr = 1
) A
GROUP BY MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup, StabilityAssessment, AppointmentsCategory, Stability;
