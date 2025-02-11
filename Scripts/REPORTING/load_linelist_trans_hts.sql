DECLARE @TestDate DATE = '2015-01-01'; 

IF OBJECT_ID(N'REPORTING.[dbo].[LineListTransHTS]', N'U') IS NOT NULL 
    DROP TABLE REPORTING.[dbo].[LineListTransHTS];
GO

SELECT DISTINCT
    MFLCode,
    EMR,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup as AgeGroup,
    PatientPKHash,
    IndexPatientPkHash,
    d.Date AS TestDate,
    CAST(DOB AS DATE) AS DOB,
    AgeAtTesting,
    EverTestedForHiv,
    MonthsSinceLastTest,
    ClientTestedAs,
    EntryPoint,
    TestStrategy,
    TestResult1,
    TestResult2,
    FinalTestResult,
    PatientGivenResult,
    TestType,
    tbScreening,
    ClientSelfTested,
    CoupleDiscordant,
    consent,
    e.Date AS EnrollmentDate,
    hts.ReportedCCCNumber,
    EncounterId,
    project,
    Tested,
    Positive,
    Linked,
    MonthsLastTest,
    TestedBefore,
    MaritalStatus,
    pat.NUPI,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LineListTransHTS 
FROM NDWH.dbo.FactHTSClientTests hts
LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey = hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.FactHTSClientLinkages link ON link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimDate e ON e.DateKey = DateEnrolledKey
LEFT JOIN NDWH.dbo.DimDate d ON d.DateKey = hts.DateTestedKey
LEFT JOIN NDWH.dbo.FactHTSPartnerNotificationServices pns ON pns.PatientKey = hts.PatientKey
WHERE (DATEDIFF(MONTH, DOB, d.Date) > 18 AND DATEDIFF(MONTH, DOB, d.Date) <= 1500)
AND FinalTestResult IS NOT NULL 
AND d.[Date] >= @TestDate
AND TestType = 'Initial Test';