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
    pat.NUPI,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LineListTransHTS 
FROM NDWH.Fact.FactHTSClientTests hts
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.Fact.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.Dim.DimDate e on e.DateKey = DateEnrolledKey
LEFT JOIN NDWH.Dim.DimDate d on d.DateKey = hts.DateTestedKey
left join NDWH.Fact.FactHTSPartnerNotificationServices pns on pns.PatientKey=hts.PatientKey
WHERE  ( DATEDIFF ( MONTH, DOB, d.Date ) > 18 AND DATEDIFF ( MONTH, DOB, d.Date ) <= 1500 )
AND FinalTestResult IS NOT NULL 
AND d.[Date] >= CAST ( '2015-01-01' AS DATE )


