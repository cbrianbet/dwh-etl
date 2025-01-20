IF OBJECT_ID(N'[NDWH].[Fact].[FactCovid]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Fact].[FactCovid];
BEGIN
With Covid As  (
SELECT ROW_NUMBER()OVER(PARTITION BY Covid.PatientPKHash, Covid.SiteCode ORDER BY Covid19AssessmentDate Desc)AS RowNumber,
        Covid.PatientIDHash  ,
        Covid.PatientPKHash ,
        Covid.SiteCode ,
        Covid.FacilityName,
        VisitID, 
        Max (Covid19AssessmentDate)Covid19AssessmentDate ,
        ReceivedCOVID19Vaccine ,
        DateGivenFirstDose ,
        FirstDoseVaccineAdministered,
        DateGivenSecondDose,
        SecondDoseVaccineAdministered ,
        VaccinationStatus,
        VaccineVerification ,
        BoosterGiven ,
        BoosterDose ,
        BoosterDoseDate ,
        EverCOVID19Positive ,
        COVID19TestDate,
        PatientStatus ,
        AdmissionStatus ,
        AdmissionUnit ,
        MissedAppointmentDueToCOVID19 ,
        COVID19PositiveSinceLasVisit ,
        COVID19TestDateSinceLastVisit ,
        PatientStatusSinceLastVisit,
        AdmissionStatusSinceLastVisit,
        AdmissionStartDate,
        AdmissionEndDate,
        AdmissionUnitSinceLastVisit,
        SupplementalOxygenReceived,
        PatientVentilated,
        TracingFinalOutcome ,
        CauseOfDeath,
        datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
        
from ODS.Care.CT_Covid as Covid
left join ODS.Care.CT_Patient as patient on patient.PatientPKHash = Covid.PatientPKHash and patient.SiteCode = Covid.SiteCode
left join ODS.[Intermediate].Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPKHash = Covid.PatientPKHash and last_encounter.SiteCode = Covid.SiteCode
group by 
        Covid.PatientIDHash,
        Covid.PatientPKHash,
        PatientStatus,
        PatientStatusSinceLastVisit,
        Covid.SiteCode,
        Covid19AssessmentDate,
        Covid.FacilityName,
        VisitID,
        ReceivedCOVID19Vaccine,
        DateGivenFirstDose,
        FirstDoseVaccineAdministered,
        DateGivenSecondDose,
        SecondDoseVaccineAdministered,
        VaccinationStatus,
        VaccineVerification,
        BoosterGiven,
        BoosterDose,
        BoosterDoseDate,
        EverCOVID19Positive,
        COVID19TestDate,
        AdmissionStatus,
        AdmissionUnit,
        MissedAppointmentDueToCOVID19,
        COVID19PositiveSinceLasVisit,
        COVID19TestDateSinceLastVisit,
        AdmissionStatusSinceLastVisit,
        AdmissionStartDate,
        AdmissionEndDate,
        AdmissionUnitSinceLastVisit,
        SupplementalOxygenReceived,
        PatientVentilated,
        TracingFinalOutcome,
        CauseOfDeath,
        DOB,
        LastEncounterDate
) ,

 MFL_partner_agency_combination as (
	select 
            distinct MFL_Code,
            SDP,
            SDP_Agency  as Agency
	from ODS.Care.All_EMRSites 
 )
 Select 
        Factkey = IDENTITY(INT, 1, 1),
        Patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        age_group.AgeGroupKey,
        VisitID, 
        Covid19AssessmentDate.Datekey As Covid19AssessmentDateKey,
        ReceivedCOVID19Vaccine ,
        DateGivenFirstDose.Datekey As DateGivenFirstDoseKey,
        FirstDoseVaccineAdministered,
        DateGivenSecondDose.Datekey As DateGivenSecondDoseKey,
        SecondDoseVaccineAdministered ,
        VaccinationStatus ,
        VaccineVerification ,
        BoosterGiven ,
        BoosterDose ,
        BoosterDoseDate.Datekey As BoosterDoseDateKey,
        EverCOVID19Positive ,
        COVID19TestDate.Datekey As COVID19TestDateKey,
        PatientStatus ,
        AdmissionStatus ,
        AdmissionUnit ,
        MissedAppointmentDueToCOVID19 ,
        COVID19PositiveSinceLasVisit ,
        COVID19TestDateSinceLastVisit ,
        PatientStatusSinceLastVisit,
        AdmissionStatusSinceLastVisit,
        AdmissionStartDate.Datekey As AdmissionStartDateKey,
        AdmissionEndDate.Datekey As  AdmissionEndDateKey,
        AdmissionUnitSinceLastVisit,
        SupplementalOxygenReceived,
        PatientVentilated,
        TracingFinalOutcome ,
        CauseOfDeath,
        cast(getdate() as date) as LoadDate
INTO NDWH.[Fact].FactCovid
 from Covid
 left join NDWH.Dim.DimPatient as patient on patient.PatientPKHash =  Covid.PatientPKHash  and patient.SiteCode = Covid.SiteCode
 left join NDWH.Dim.DimFacility as facility on facility.MFLCode = Covid.SiteCode
 left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = Covid.SiteCode
 left join NDWH.Dim.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
 left join NDWH.Dim.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
 left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = Covid.AgeLastVisit
 left join NDWH.Dim.DimDate as Covid19AssessmentDate on Covid19AssessmentDate.Date = Covid.Covid19AssessmentDate
 left join NDWH.Dim.DimDate as DateGivenFirstDose  on DateGivenFirstDose.Date = Covid.DateGivenFirstDose
 left join NDWH.Dim.DimDate as BoosterDoseDate  on BoosterDoseDate.Date = Covid.BoosterDoseDate
 left join NDWH.Dim.DimDate as DateGivenSecondDose  on DateGivenSecondDose.Date = Covid.DateGivenSecondDose
 left join NDWH.Dim.DimDate as COVID19TestDate  on COVID19TestDate.Date = Covid.COVID19TestDate
 left join NDWH.Dim.DimDate as AdmissionStartDate  on AdmissionStartDate.Date = Covid.AdmissionStartDate
 left join NDWH.Dim.DimDate as AdmissionEndDate  on AdmissionEndDate.Date = Covid.AdmissionEndDate
 where RowNumber=1 and patient.voided =0;
 
alter table NDWH.[Fact].FactCOVID add primary key(FactKey);
END