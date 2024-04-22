  IF OBJECT_ID(N'[REPORTING].[dbo].[AggregatePBFW]', N'U') IS NOT NULL 
    DROP TABLE [REPORTING].[dbo].[AggregatePBFW];
GO

SELECT 
    Facility.FacilityName,
    Facility.MFLCode,
    Facility.County,
    Facility.SubCounty,
    Partner.PartnerName,
    Agency.AgencyName,
    Age_group.DATIMAgeGroup as AgeGroup,
    Patient.Gender,
    Sum(Knownpositive) AS KnownPositives,
    Sum(Newpositives) AS NewPositives,
    SUM (case when Recieivedart=1 Then 1 Else 0 End ) As  PBFWOnART,
    SUM (Case When  Recieivedart=1  and EligibleVL=1 Then  1 Else 0 end) AS PBFWEligiblevl,
    SUM (CASE WHEN PBFW_ValidVLResultCategory  is not null Then 1   ELSE 0 END) AS PBFWValidVl,
    SUM (Case When PBFW_ValidVLResultCategory is not null and PBFW_ValidVLSup=1 Then 1 else 0 End) AS PBFWSuppressed,
    SUM(CASE  WHEN PBFW_ValidVLResultCategory is not null  AND ISNUMERIC(PBFW_ValidVLSup) = 1  AND CAST(PBFW_ValidVLSup AS INT) = 0   THEN 1   ELSE 0 END) AS PBFWUnsuppressed,
    Sum (Case When RepeatVls=1 Then 1 Else 0 End) As PBFWRepeatVl,
    Sum (Case When RepeatVls=1 and RepeatSuppressed= 1 Then 1 Else 0 End) As PBFWRepeatVlSuppressed,
    Sum (Case When RepeatUnsuppressed=1 Then 1 Else 0 End) As PBFWRepeatVlUnSuppressed,
    Sum (Case When RepeatUnsuppressed=1 and ReceivedEAC1=1 Then 1 else 0 End) As PBFWUnsupReceivedEAC1,
    Sum (Case When RepeatUnsuppressed=1 and ReceivedEAC2=1 Then 1 Else 0 End) As PBFWUnsupReceivedEAC2,
    Sum(Case when  RepeatUnsuppressed=1 and ReceivedEAC3=1 Then 1 Else 0 End) As PBFWUnsupReceivedEAC3,
    Sum (Case when RepeatUnsuppressed=1 and PBFWRegLineSwitch=1 Then 1 Else 0 End) As PBFWRegLineSwitch
 
INTO REPORTING.dbo.AggregatePBFW
FROM NDWH.dbo.FactPBFW AS PBFW
LEFT JOIN NDWH.dbo.DimFacility AS Facility ON Facility.FacilityKey = PBFW.FacilityKey
LEFT JOIN NDWH.dbo.DimPartner AS Partner ON Partner.PartnerKey = PBFW.PartnerKey
LEFT JOIN NDWH.dbo.DimAgency AS Agency ON Agency.AgencyKey = PBFW.AgencyKey
LEFT JOIN NDWH.dbo.DimAgeGroup AS Age_group ON Age_group.AgeGroupKey = PBFW.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPatient AS Patient ON Patient.PatientKey = PBFW.PatientKey
LEFT JOIN NDWH.dbo.FactViralLoads as Vls on Vls.patientkey=PBFW.patientkey
GROUP BY 
    Facility.FacilityName,
    Facility.MFLCode,
    Facility.County,
    Facility.SubCounty,
    Partner.PartnerName,
    Agency.AgencyName,
    Age_group.DATIMAgeGroup,
    Patient.Gender;

