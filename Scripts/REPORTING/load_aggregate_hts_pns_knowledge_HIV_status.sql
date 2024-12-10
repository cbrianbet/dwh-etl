IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]', N'U') IS NOT NULL 
    DROP TABLE REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]
Go 
  With pns_and_tests AS (
    SELECT DISTINCT 
        pns.PatientKey,
        facility.MFLCode,
        facility.FacilityKey,
        pns.AgencyKey,
        pns.PartnerKey,
        pns.AgeGroupKey,
        pns.ScreenedForIpv,
        pns.CccNumber,
        pns.RelationsipToIndexClient,
        pns.KnowledgeOfHivStatus,
        tests.FinalTestResult,
        pns.DateElicitedKey,
        pns.DateLinkedToCareKey,
        tests.DateTestedKey
    FROM NDWH.Fact.FactHTSPartnerNotificationServices AS pns
    LEFT JOIN NDWH.Dim.DimFacility AS facility ON facility.FacilityKey = pns.FacilityKey
    LEFT JOIN NDWH.Dim.DimPatient AS patient ON patient.PatientPKHash = pns.PartnerPatientPk
        AND patient.SiteCode = facility.MFLCode
    LEFT JOIN NDWH.Fact.FactHTSClientTests AS tests ON tests.PatientKey = patient.PatientKey
    WHERE TestType IN ('Initial Test', 'Initial')
),
pns_tests_linkages AS (
    SELECT 
        pns_and_tests.*,
        linkages.ReportedCCCNumber  
    FROM pns_and_tests
    LEFT JOIN NDWH.Fact.FactHTSClientLinkages AS linkages ON linkages.PatientKey = pns_and_tests.PatientKey
),
line_list_dataset AS (
    SELECT DISTINCT
        dataset.PatientKey,
        facility.MFLCode,
        facility.FacilityName,
        facility.County,
        facility.SubCounty,
        patner.PartnerName,
        agency.AgencyName,
        RelationsipToIndexClient, 
        FinalTestResult,
        elicited.Date AS DateElicited,
        tested.Date AS TestDate,
        tested.[year],
        tested.[month],
        FORMAT(CAST(tested.Date AS date), 'MMMM') AS MonthName, 
        EOMONTH(tested.date) as AsOfDate,
        Gender,
        DATIMAgeGroup AS Agegroup,
        CASE 
            WHEN (dataset.PatientKey IS NOT NULL) THEN 1 
            ELSE 0 
        END AS elicited,
        CASE 
            WHEN (FinalTestResult IS NOT NULL) THEN 1
            ELSE 0 
        END AS tested,
        CASE 
            WHEN (FinalTestResult = 'Positive') THEN 1
            ELSE 0 
        END AS NewPositives, 
        CASE 
            WHEN (FinalTestResult = 'Negative') THEN 1
            ELSE 0 
        END AS NewNegatives,    
        CASE 
            WHEN (FinalTestResult = 'Positive' AND ReportedCCCNumber IS NOT NULL) THEN 1 
            ELSE 0 
        END AS Linked,
        CASE 
            WHEN (KnowledgeOfHivStatus = 'Positive') THEN 1 
            ELSE 0 
        END AS KP,
        CASE 
            WHEN (KnowledgeOfHivStatus = 'Unknown') THEN 1
            ELSE 0 
        END AS UnknownStatus
    FROM pns_tests_linkages AS dataset
    LEFT JOIN NDWH.Dim.DimPatient AS patient ON patient.PatientKey = dataset.PatientKey
    LEFT JOIN NDWH.Dim.DimPartner AS patner ON patner.PartnerKey = dataset.PartnerKey
    LEFT JOIN NDWH.Dim.DimFacility AS facility ON facility.FacilityKey = dataset.FacilityKey
    LEFT JOIN NDWH.Dim.DimAgency AS agency ON agency.AgencyKey = dataset.AgencyKey   
    LEFT JOIN NDWH.Dim.DimDate AS elicited ON elicited.DateKey = dataset.DateElicitedKey
    LEFT JOIN NDWH.Dim.DimDate AS tested ON tested.DateKey = dataset.DateTestedKey
    LEFT JOIN NDWH.Dim.DimDate AS linked ON linked.DateKey = dataset.DateLinkedToCareKey
    LEFT JOIN NDWH.Dim.DimAgeGroup AS agegroup ON agegroup.AgeGroupKey = dataset.AgeGroupKey
)
SELECT 
    Mflcode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    Agegroup,
    [year], 
    [month], 
    MonthName,
    AsOfDate, 
    SUM(elicited) AS ContactElicited, 
    SUM(tested) AS ContactTested,
    SUM(Linked) AS Linked,
    SUM(KP) AS KnownPositive, 
    SUM(NewNegatives) AS NewNegatives,
    SUM(NewPositives) AS NewPositives, 
    SUM(UnknownStatus) AS UnknownStatus,
    CAST(GETDATE() AS DATE) AS LoadDate
INTO REPORTING.dbo.AggregateHTSPNSKnowledgeHIVStatus 
FROM line_list_dataset
GROUP BY 
    Mflcode,
    FacilityName,
    County,
    SubCounty,
    PartnerName, 
    [year],
    [month],
    MonthName,
    AsOfDate,
    Gender,
    Agegroup, 
    AgencyName;