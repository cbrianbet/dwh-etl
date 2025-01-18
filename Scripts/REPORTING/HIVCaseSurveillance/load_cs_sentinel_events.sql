IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsSentinelEvents]', N'U') IS NOT NULL 
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsSentinelEvents];
begin
 with  MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
         SDP,
        SDP_Agency as Agency 
    from ODS.Care.All_EMRSites 
 ),
 confirmed_reported_cases_and_art as (
        select 
                ctpatients.PatientKey,
                ctpatients.Gender,
                art.AgeLastVisit,
                art.Agegroupkey,
                ctpatients.sitecode,
                case when  confirmed_date.Date is not null Then 1 Else 0 End as NewCaseReported,
                Case when art_date.Date is not null then 1 Else 0 End as LinkedToART,
                case when art_date.Date is null Then 1 Else 0 End as NotLinkedOnART,
                  confirmed_date.Date as DateConfirmedPositive,
                eomonth(confirmed_date.Date) as CohortYearMonth,
                case 
                    when art_date.Date < confirmed_date.Date then confirmed_date.Date
                    else art_date.Date
                end as StartARTDate,
                DATEDIFF(year,ctpatients.DOB,confirmed_date.Date) as AgeatDiagnosis             
        from NDWH.Dim.DimPatient as ctpatients
            left join  NDWH.Fact.FACTART as art on ctpatients.patientkey=art.PatientKey
            left join NDWH.Dim.DimDate as confirmed_date on confirmed_date.DateKey = ctpatients.DateConfirmedHIVPositiveKey
            left join NDWH.Dim.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
            left join NDWH.Dim.DimAgeGroup as age on age.AgeGroupKey=art.AgeGroupKey
          
            where DateConfirmedHIVPositiveKey is not null
            
 ) ,

 BaselineCD4s As (
    SELECT
    PatientKey,
    BaselineCD4,
    BaselineCD4Date
    from NDWH.Fact.FactCD4
    where BaselineCD4 is not null
 ),
 OtherCD4s As (
   Select 
   Patientkey,
   SecondCD4 as OtherCD4s,
   SecondCD4 asOtherCD4sDate,
   LastCD4Percentage as OtherCD4Percent,
   LastCD4Date as OtherCD4PercentDate
  from NDWH.Fact.FactCD4
 
 ),
 BaselineWHO As (
    Select 
     Patientkey,
    WHOStageATART,
    AgeAtARTStart
    from  NDWH.Fact.FactARTBaselines
 ),
 Viralloads As (
  SELECT 
    
    viralloads.Patientkey,
    SiteCode,
    FirstVL,
    IsSuppressedInitialViralload,
    SecondVL,
    IsSuppressedSecondFollowupViralloads,
    ThirdVL,
    IsSuppressedThirdFollowupViralloads,
    LastVL,
           Case  WHEN (Isnumeric( LastVL) = 1 AND Cast(Replace( LastVL, ',', '') AS Float) < 200.00)
         OR LastVL IN ('undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level') 
    THEN 1 Else 0
    End As IsSuppressedLatestViralload,
    fac.FacilityKey
FROM 
    NDWH.Fact.FactViralLoads as viralloads
    LEFT join NDWH.Dim.DimFacility fac on fac.FacilityKey = viralloads.FacilityKey
    LEFT JOIN NDWH.Dim.DimAgency agency on agency.AgencyKey = viralloads.AgencyKey
    LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = viralloads.PatientKey
    LEFT JOIN NDWH.Dim.DimPartner partner on partner.PartnerKey = viralloads.PartnerKey
   
 ),
 InitialViralLoads As (
    SELECT
    Viralloads.patientkey,
    Viralloads.Facilitykey,
  Viralloads.IsSuppressedInitialViralload
    from Viralloads
 
 ),
 FirstFollowupViralloads As (
    SELECT
    Patientkey,
    Facilitykey,
    Viralloads.IsSuppressedSecondFollowupViralloads as IsSuppressedFirstFollowupViralloads
    from Viralloads
    
 ),
  SecondFollowupViralloads As (
    SELECT
    Patientkey,
    Facilitykey,
    Viralloads.IsSuppressedThirdFollowupViralloads as IsSuppressedSecondFollowupViralloads 
    from Viralloads
    
 
)
 select 
    confirmed_reported_cases_and_art.PatientKey,
    Gender,
    AgeLastVisit,
    SiteCode,
    SDP as PartnerName,
    AgencyName,
    NewCaseReported,
    LinkedToART,
    NotLinkedOnART,
    DateConfirmedPositive,
    CohortYearMonth,
    StartARTDate,
    AgeatDiagnosis,
    case when BaselineCD4 is not null Then 1 Else 0 End as WithBaselineCD4,
    case when BaselineCD4 is  null Then 1 Else 0 End as WithoutBaselineCD4,
    case when  BaselineCD4 is not null and Try_CONVERT(FLOAT, BaselineCD4) < 200 Then 1 Else 0 End as CD4Lessthan200,
    case when  BaselineCD4 is not null and Try_CONVERT(FLOAT, BaselineCD4) >= 200 Then 1 Else 0 End as CD4Morethan200,
CASE 
    WHEN 
       (ISNUMERIC(OtherCD4s) = 1 AND TRY_CONVERT(float, OtherCD4s) IS NOT NULL AND TRY_CONVERT(float, OtherCD4s) < 200)
        OR 
        (AgeatDiagnosis <= 5 AND ISNUMERIC(OtherCD4Percent) = 1 AND TRY_CONVERT(float, OtherCD4Percent) IS NOT NULL AND TRY_CONVERT(float, OtherCD4Percent) < 25)
    THEN 1 
    ELSE 0 
  END AS TreatmentFailure,
    WHOStageATART,
    AgeAtARTStart,
   age.DATIMAgeGroup as ARTStartAgeGroup,
   case when InitialViralLoads.patientkey is not null then 1 Else 0 End as WithInitialViralLoad,
   coalesce(InitialViralLoads.IsSuppressedInitialViralload,0) As IsSuppressedInitialViralload,
   case when FirstFollowupViralloads.patientkey is not null then 1 Else 0 End As WithFirstFollowupViralload,
   coalesce (FirstFollowupViralloads.IsSuppressedFirstFollowupViralloads,0) as IsSuppressedFirstFollowupViralloads,
   case when SecondFollowupViralloads.patientkey is not null then 1 Else 0 End As WithSecondFollowupViralloads,
   coalesce (SecondFollowupViralloads.IsSuppressedSecondFollowupViralloads,0) As IssuppressedSecondFollowupViralloads
  
 into [HIVCaseSurveillance].[dbo].[CsSentinelEvents]
 from confirmed_reported_cases_and_art
 left join BaselineCD4s on BaselineCD4s.PatientKey=confirmed_reported_cases_and_art.PatientKey
 left join BaselineWHO on BaselineWHO.patientkey=confirmed_reported_cases_and_art.PatientKey
 left join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey = confirmed_reported_cases_and_art.AgeGroupKey
 left join NDWH.Dim.DimFacility as facility on facility.MFLCode = confirmed_reported_cases_and_art.SiteCode
 left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = confirmed_reported_cases_and_art.SiteCode
 left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
 left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
 left join OtherCD4s on OtherCD4s.Patientkey=confirmed_reported_cases_and_art.Patientkey
 left join InitialViralLoads on InitialViralLoads.patientkey=confirmed_reported_cases_and_art.PatientKey
 left join FirstFollowupViralloads on FirstFollowupViralloads.patientkey=confirmed_reported_cases_and_art.PatientKey
 left join SecondFollowupViralloads on SecondFollowupViralloads.patientkey=confirmed_reported_cases_and_art.PatientKey

 end
