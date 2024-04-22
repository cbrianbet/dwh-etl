IF OBJECT_ID(N'REPORTING.[dbo].[LineListTransHTS]', N'U') IS NOT NULL 			
	drop  TABLE REPORTING.[dbo].[LineListTransHTS]
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
    d.Date TestDate,
    CAST(DOB as DATE) DOB,
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
    e.date EnrollmentDate,
    hts.ReportedCCCNumber,
    EncounterId,
    project,
    Tested,
    Positive,
    Linked,
    MonthsLastTest,
    TestedBefore,
    MaritalStatus,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LineListTransHTS 
FROM NDWH.dbo.FactHTSClientTests hts
LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimDate e on e.DateKey = DateEnrolledKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
left join NDWH.dbo.FactHTSPartnerNotificationServices pns on pns.PatientKey=hts.PatientKey
WHERE  ( DATEDIFF ( MONTH, DOB, d.Date ) > 18 AND DATEDIFF ( MONTH, DOB, d.Date ) <= 1500 )
AND FinalTestResult IS NOT NULL 
AND d.[Date] >= CAST ( '2015-01-01' AS DATE )
