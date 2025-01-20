-- clean Clinical notes
UPDATE ODS.PrEP.PrEP_Visits
    SET ClinicalNotes = NULL 
WHERE ClinicalNotes = ''

GO

-- clean NextAppointment
UPDATE ODS.PrEP.PrEP_Visits
    SET NextAppointment = NULL
WHERE NextAppointment = '' OR NextAppointment < '1980-01-01'

GO
-- clean TreatedForHepC
UPDATE ODS.PrEP.PrEP_Visits
    SET TreatedForHepC = NULL
WHERE TreatedForHepC = ''

GO

-- clean VaccinationForHepCStarted
UPDATE ODS.PrEP.PrEP_Visits
    SET VaccinationForHepCStarted = NULL
WHERE VaccinationForHepCStarted = ''

GO

-- clean TreatedForHepB
UPDATE ODS.PrEP.PrEP_Visits
    SET TreatedForHepB = NULL
WHERE TreatedForHepB = ''

GO

-- clean VaccinationForHepBStarted
UPDATE ODS.PrEP.PrEP_Visits
    SET VaccinationForHepBStarted = NULL
WHERE VaccinationForHepBStarted = ''

GO

-- clean HepatitisCPositiveResult
UPDATE ODS.PrEP.PrEP_Visits
    SET HepatitisCPositiveResult = NULL
WHERE HepatitisCPositiveResult = ''

GO

-- clean HepatitisBPositiveResult
UPDATE ODS.PrEP.PrEP_Visits
    SET HepatitisBPositiveResult = NULL
WHERE HepatitisBPositiveResult = ''

GO

-- clean Reasonfornotgivingnextappointment
UPDATE ODS.PrEP.PrEP_Visits
    SET Reasonfornotgivingnextappointment = NULL
WHERE Reasonfornotgivingnextappointment = ''

GO

-- clean Tobegivennextappointment
UPDATE ODS.PrEP.PrEP_Visits
    SET Tobegivennextappointment = NULL
WHERE Tobegivennextappointment = ''

GO

-- clean CondomsIssued
UPDATE ODS.PrEP.PrEP_Visits
    SET CondomsIssued = NULL
WHERE CondomsIssued = ''

GO

-- clean MonthsPrescribed
UPDATE ODS.PrEP.PrEP_Visits
    SET MonthsPrescribed = NULL
WHERE CAST(MonthsPrescribed AS INT) > 12


-- clean RegimenPrescribed
UPDATE ODS.PrEP.PrEP_Visits
    SET RegimenPrescribed = NULL
WHERE RegimenPrescribed = ''

GO

-- clean PrepPrescribed
UPDATE ODS.PrEP.PrEP_Visits
    SET PrepPrescribed = NULL
WHERE PrepPrescribed = ''

GO

-- clean PrepTreatmentPlan
UPDATE ODS.PrEP.PrEP_Visits
    SET PrepTreatmentPlan = NULL
WHERE PrepTreatmentPlan = ''

GO

-- clean ContraindicationsPrep
UPDATE ODS.PrEP.PrEP_Visits
    SET ContraindicationsPrep = NULL
WHERE ContraindicationsPrep = ''

GO

-- clean SymptomsAcuteHIV
UPDATE ODS.PrEP.PrEP_Visits
    SET SymptomsAcuteHIV = NULL
WHERE SymptomsAcuteHIV = ''

GO

-- clean AdherenceReasons
UPDATE ODS.PrEP.PrEP_Visits
    SET AdherenceReasons = NULL
WHERE AdherenceReasons = ''

GO

-- clean AdherenceOutcome
UPDATE ODS.PrEP.PrEP_Visits
    SET AdherenceOutcome = NULL
WHERE AdherenceOutcome = ''

GO

-- clean AdherenceDone
UPDATE ODS.PrEP.PrEP_Visits
    SET AdherenceDone = NULL
WHERE AdherenceDone = ''

GO

-- clean FPMethods
UPDATE ODS.PrEP.PrEP_Visits
    SET FPMethods = NULL
WHERE FPMethods = ''

GO


-- clean FamilyPlanningStatus
UPDATE ODS.PrEP.PrEP_Visits
    SET FamilyPlanningStatus = NULL
WHERE FamilyPlanningStatus = ''

GO

-- clean Breastfeeding
UPDATE ODS.PrEP.PrEP_Visits
    SET Breastfeeding = NULL
WHERE Breastfeeding = ''

GO

-- clean BirthDefects
UPDATE ODS.PrEP.PrEP_Visits
    SET BirthDefects = NULL
WHERE BirthDefects = ''

GO

-- clean PregnancyOutcome
UPDATE ODS.PrEP.PrEP_Visits
    SET PregnancyOutcome = NULL
WHERE PregnancyOutcome = ''

GO


-- clean PregnancyEndDate
UPDATE ODS.PrEP.PrEP_Visits
    SET PregnancyEndDate = NULL
WHERE PregnancyEndDate = ''

GO

--PregnancyEnded
UPDATE ODS.PrEP.PrEP_Visits
    SET PregnancyEnded = NULL
WHERE PregnancyEnded = ''

GO

-- clean PregnancyPlanned
UPDATE ODS.PrEP.PrEP_Visits
    SET PregnancyPlanned = NULL
WHERE PregnancyPlanned = ''

GO

-- clean PlanningToGetPregnant
UPDATE ODS.PrEP.PrEP_Visits
    SET PlanningToGetPregnant = NULL
WHERE PlanningToGetPregnant = ''

GO

-- clean EDD
UPDATE ODS.PrEP.PrEP_Visits
    SET EDD = NULL
WHERE EDD = ''

GO

-- PregnantAtThisVisit
UPDATE ODS.PrEP.PrEP_Visits
    SET PregnantAtThisVisit = NULL
WHERE PregnantAtThisVisit = ''

GO


-- clean MenopausalStatus
UPDATE ODS.PrEP.PrEP_Visits
    SET MenopausalStatus = NULL
WHERE MenopausalStatus = ''

GO

-- clean LMP
UPDATE ODS.PrEP.PrEP_Visits
    SET LMP = NULL
WHERE LMP = ''

GO

-- clean VMMCReferral
UPDATE ODS.PrEP.PrEP_Visits
    SET VMMCReferral = NULL
WHERE VMMCReferral = ''

GO

-- clean Circumcised
UPDATE ODS.PrEP.PrEP_Visits
    SET Circumcised = NULL
WHERE Circumcised = ''

GO

-- clean STITreated
UPDATE ODS.PrEP.PrEP_Visits
    SET STITreated = NULL
WHERE STITreated = ''

GO


-- clean STISymptoms
UPDATE ODS.PrEP.PrEP_Visits
    SET STISymptoms = NULL
WHERE STISymptoms = ''

GO

-- clean STIScreening
UPDATE ODS.PrEP.PrEP_Visits
    SET STIScreening = NULL
WHERE STIScreening = ''

GO

-- clean BMI
UPDATE ODS.PrEP.PrEP_Visits
    SET BMI = NULL
WHERE CAST(BMI AS varchar) = ''

GO


-- clean Height
UPDATE ODS.PrEP.PrEP_Visits
    SET Height = NULL
WHERE CAST(Height AS varchar) = ''

GO


-- clean Weight 
UPDATE ODS.PrEP.PrEP_Visits
    SET Weight = NULL
WHERE CAST(Weight AS varchar) = ''

GO


-- clean BloodPressure
UPDATE ODS.PrEP.PrEP_Visits
    SET BloodPressure = NULL
WHERE CAST(BloodPressure AS varchar) = ''

GO


-- clean VisitDate
UPDATE ODS.PrEP.PrEP_Visits
    SET VisitDate = NULL
WHERE VisitDate = '' OR VisitDate < '1980-01-01'



















