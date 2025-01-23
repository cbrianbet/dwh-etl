IF Object_id(N'[HIVCaseSurveillance].[dbo].[CsLinkage]', N'U') IS NOT NULL
  DROP TABLE [HIVCaseSurveillance].[dbo].[cslinkage];

WITH confirmed_reported_cases_and_art
     AS (SELECT ctpatients.patientkey,
                patient.gender,
                art.agelastvisit,
                ctpatients.facilitykey,
                ctpatients.partnerkey,
                ctpatients.agencykey,
                art.agegroupkey,
                CASE
                  WHEN confirmed_date.date IS NOT NULL THEN 1
                  ELSE 0
                END                                              AS
                NewCaseReported,
                CASE
                  WHEN art_date.date IS NOT NULL THEN 1
                  ELSE 0
                END                                              AS LinkedToART,
                CASE
                  WHEN art_date.date IS NULL THEN 1
                  ELSE 0
                END                                              AS
                NotLinkedOnART,
                confirmed_date.date                              AS
                   DateConfirmedPositive,
                Eomonth(confirmed_date.date)                     AS
                CohortYearMonth,
                CASE
                  WHEN art_date.date < confirmed_date.date THEN
                  confirmed_date.date
                  ELSE art_date.date
                END                                              AS StartARTDate
                ,
Datediff(year, patient.dob, confirmed_date.date) AS AgeatDiagnosis,
CASE
  WHEN Datediff(day, confirmed_date.date, art_date.date) = 0 THEN
  'Same Day'
  WHEN Datediff(day, confirmed_date.date, art_date.date) BETWEEN 1
       AND 7
   THEN
  '1 to 7 Days'
  WHEN Datediff(day, confirmed_date.date, art_date.date) BETWEEN 8
       AND
       14 THEN
  '8 to 14 Days'
  WHEN Datediff(day, confirmed_date.date, art_date.date) > 14
       AND timetoartdiagnosis IS NOT NULL THEN '> 14 Days'
  ELSE 'Missing'
END                                              AS
   TimeToARTDiagnosis_Grp,
CASE
  WHEN disclosure IS NOT NULL THEN 1
  ELSE 0
END                                              AS Disclosure
FROM   ndwh.Fact.factctpatients AS ctpatients
LEFT JOIN ndwh.Fact.factart AS art
       ON ctpatients.patientkey = art.patientkey
LEFT JOIN ndwh.Dim.dimpatient AS patient
       ON patient.patientkey = ctpatients.patientkey
LEFT JOIN ndwh.Dim.dimdate AS confirmed_date
       ON confirmed_date.datekey =
          patient.dateconfirmedhivpositivekey
LEFT JOIN ndwh.Dim.dimdate AS art_date
       ON art_date.datekey = art.startartdatekey
LEFT JOIN ndwh.Dim.dimagegroup age
       ON age.agegroupkey = art.agegroupkey),
     baselinecd4s
     AS (SELECT patientkey,
                baselinecd4,
                baselinecd4date
         FROM   ndwh.Fact.factcd4),
     baselinewho
     AS (SELECT patientkey,
                whostageatart,
                ageatartstart
         FROM   ndwh.Fact.factartbaselines)
SELECT confirmed_reported_cases_and_art.patientkey,
       gender,
       agelastvisit,
       facilitykey,
       partnerkey,
       agencykey,
       newcasereported,
       linkedtoart,
       notlinkedonart,
       dateconfirmedpositive,
       cohortyearmonth,
       startartdate,
       ageatdiagnosis,
       timetoartdiagnosis_grp,
       disclosure,
       CASE
         WHEN baselinecd4 IS NOT NULL THEN 1
         ELSE 0
       END               AS WithBaselineCD4,
       whostageatart,
       ageatartstart,
       age.datimagegroup AS AgeGroup
INTO   [HIVCaseSurveillance].[dbo].[cslinkage]
FROM   confirmed_reported_cases_and_art
       LEFT JOIN baselinecd4s
              ON baselinecd4s.patientkey =
                 confirmed_reported_cases_and_art.patientkey
       LEFT JOIN baselinewho
              ON baselinewho.patientkey =
                 confirmed_reported_cases_and_art.patientkey
       LEFT JOIN ndwh.Dim.dimagegroup age
              ON age.agegroupkey = confirmed_reported_cases_and_art.agegroupkey
