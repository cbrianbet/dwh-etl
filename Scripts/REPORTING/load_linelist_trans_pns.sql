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
		f.Date TestDate 
	FROM NDWH.dbo.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.dbo.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.dbo.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.dbo.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate f on c.DateTestedKey = f.DateKey
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
		e.Date DateElicited,
		f.Date TestDate, 
		d.ReportedCCCNumber
	FROM NDWH.dbo.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.dbo.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.dbo.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.dbo.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	INNER JOIN NDWH.dbo.FactHTSClientLinkages d on d.PatientKey=a.PatientKey and d.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate f on c.DateTestedKey = f.DateKey
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
    FROM  NDWH.dbo.FactHTSClientTests a
    INNER JOIN NDWH.dbo.FactHTSPartnerNotificationServices b on b.PatientKey=a.PatientKey and b.FacilityKey=a.FacilityKey
    LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = b.PatientKey
    LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = a.PartnerKey
    LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = a.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency age ON a.AgencyKey = age.AgencyKey
    LEFT JOIN NDWH.dbo.DimFacility i ON i.FacilityKey = b.FacilityKey
    LEFT JOIN NDWH.dbo.DimDate e on b.DateElicitedKey = e.DateKey
    LEFT JOIN NDWH.dbo.DimDate j on a.DateTestedKey = j.DateKey
    LEFT JOIN NDWH.dbo.DimDate h on DateLinkedToCareKey = h.DateKey
    LEFT JOIN NDWH.dbo.DimAgeGroup g on b.AgeGroupKey = g.AgeGroupKey
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
