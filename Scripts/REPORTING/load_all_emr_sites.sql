IF OBJECT_ID(N'REPORTING.dbo.all_EMRSites', N'U') IS NOT NULL 
	DROP TABLE REPORTING.dbo.all_EMRSites;


WITH ModulesUptake AS (
    SELECT
        MFLCode,
        FacilityName,
        SubCounty,
        County,
        isEMRSite,
        PartnerName,
        AgencyName,
        isCT,
        modules.isHTS,
        isHTSML,
        isIITML,
        isOTZ,
        isOVC,
        isPMTCT,
        isPrep,
        fac.Latitude,
        fac.Longitude,
        EMR_Status,
        modules.EMR,
        modules.owner,
        modules.InfrastructureType,
        modules.KEPH_Level,
        CAST(GETDATE() AS DATE) AS LoadDate 
    FROM NDWH.Fact.FactModulesuptake AS modules
    LEFT JOIN NDWH.Dim.DimFacility fac ON fac.FacilityKey = modules.FacilityKey
    LEFT JOIN NDWH.Dim.DimPartner pat ON pat.PartnerKey = modules.Partnerkey
    LEFT JOIN NDWH.Dim.DimAgency agency ON agency.AgencyKey = modules.Agencykey
)


SELECT *
INTO REPORTING.dbo.all_EMRSites
FROM ModulesUptake;

