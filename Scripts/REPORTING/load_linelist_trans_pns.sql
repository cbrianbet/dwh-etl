IF OBJECT_ID(N'REPORTING.[dbo].[LineListTransPNS]', N'U') IS NOT NULL 			
	drop TABLE REPORTING.[dbo].[LineListTransPNS]
GO

With cte1 as (
    SELECT distinct 
		a.PartnerPatientPk,
        a.IndexPatientPkHash,
		fac.[MFLCODE] SiteCode,
		fac.County,
		fac.SubCounty,
		a.ScreenedForIpv,
		a.CccNumber,
		c.FinalTestResult as FinalResult, 
		e.Date DateElicited,
		f.Date TestDate, 
        b.NupiHash
	FROM NDWH.Fact.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.Dim.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.HTS.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.Fact.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.Dim.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.Dim.DimDate f on c.DateTestedKey = f.DateKey
), cte2 as (
    SELECT distinct 
		a.PartnerPatientPk,
        a.IndexPatientPkHash,
		fac.MFLCode SiteCode,
		fac.County,
		fac.SubCounty,
		a.ScreenedForIpv,
		a.CccNumber,
		c.FinalTestResult as FinalResult, 
        b.NupiHash,
		e.Date DateElicited,
		f.Date TestDate, 
		d.ReportedCCCNumber
	FROM NDWH.Fact.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.Dim.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.HTS.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.fact.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	INNER JOIN NDWH.Fact.FactHTSClientLinkages d on d.PatientKey=a.PatientKey and d.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.Dim.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.Dim.DimDate f on c.DateTestedKey = f.DateKey
), combined as (
    SELECT DISTINCT 
        f.Mflcode,
        f.FacilityName,
        f.County,
        f.SubCounty,
        PartnerName,
        AgencyName,
        pat.PatientPkHash,
        b.IndexPatientPkHash,
        j.Date HIVDiagnosisDate,
        PartnerPersonID,
        b.PartnerPatientPk,
        pat.NUPI,
        Gender, 
        Age,
        DATIMAgeGroup  Agegroup,
        RelationsipToIndexClient,
        CurrentlyLivingWithIndexClient,
        b.ScreenedForIpv,
        b.IpvScreeningOutcome,
        e.Date,
        Case 
            WHEN (b.KnowledgeOfHivStatus='Positive') then 1 
        ELSE 0 End  KnownPositive,
        PnsConsent, 
        d.TestDate PartnerTestdate,
        c.FinalResult,
        PnsApproach,
        Case 
            WHEN (d.ReportedCCCNumber  is not null ) then 1     
        ELSE 0 End  Linked,
        d.ReportedCCCNumber,
        FacilityLinkedTo,
        h.Date LinkDateLinkedToCare
    FROM  NDWH.Fact.FactHTSClientTests a
    INNER JOIN NDWH.Fact.FactHTSPartnerNotificationServices b on b.PatientKey=a.PatientKey and b.FacilityKey=a.FacilityKey
    LEFT JOIN NDWH.Dim.DimPatient pat ON pat.PatientKey = b.PatientKey
    LEFT JOIN NDWH.Dim.DimPartner p ON p.PartnerKey = a.PartnerKey
    LEFT JOIN NDWH.Dim.DimFacility f ON f.FacilityKey = a.FacilityKey
    LEFT JOIN NDWH.Dim.DimAgency age ON a.AgencyKey = age.AgencyKey
    LEFT JOIN NDWH.Dim.DimFacility i ON i.FacilityKey = b.FacilityKey
    LEFT JOIN NDWH.Dim.DimDate e on b.DateElicitedKey = e.DateKey
    LEFT JOIN NDWH.Dim.DimDate j on a.DateTestedKey = j.DateKey
    LEFT JOIN NDWH.Dim.DimDate h on DateLinkedToCareKey = h.DateKey
    LEFT JOIN NDWH.Dim.DimAgeGroup g on b.AgeGroupKey = g.AgeGroupKey
    LEFT JOIN cte1 c on c.PartnerPatientPk = b.PartnerPatientPk and c.SiteCode=i.MFLCode
    LEFT JOIN cte2 d on d.PartnerPatientPk = b.PartnerPatientPk and d.SiteCode=i.MFLCode
    where a.FinalTestResult='Positive'
)

SELECT  
    Mflcode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    PatientPkHash,
    HIVDiagnosisDate,
    PartnerPersonID,
    PartnerPatientPk,
    IndexPatientPkHash,
    Gender, 
    Age,
    Agegroup,
    RelationsipToIndexClient,
    CurrentlyLivingWithIndexClient,
    ScreenedForIpv,
    IpvScreeningOutcome,
    Date,
    KnownPositive,
    PnsConsent, 
    PartnerTestdate,
    FinalResult,
    PnsApproach,
    Linked,
    ReportedCCCNumber,
    FacilityLinkedTo,
    LinkDateLinkedToCare,
    CAST(GETDATE() AS DATE) AS LoadDate 
    INTO REPORTING.dbo.LineListTransPNS
FROM combined
