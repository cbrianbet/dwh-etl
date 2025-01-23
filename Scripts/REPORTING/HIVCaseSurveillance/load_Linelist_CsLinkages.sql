If Object_id(N'[HIVCaseSurveillance].[dbo].[CsLinkage]', N'U') Is Not Null
  Drop Table [Hivcasesurveillance].[dbo].[Cslinkage];

With Confirmed_reported_cases_and_art
     As (Select Ctpatients.Patientkey,
                Patient.Gender,
                Ctpatients.Agelastvisit,
                Ctpatients.Facilitykey,
                Ctpatients.Partnerkey,
                Ctpatients.Agencykey,
                Ctpatients.Agegroupkey,
                Case
                  When Confirmed_date.Date Is Not Null Then 1
                  Else 0
                End                                              As
                NewCaseReported,
                Case
                  When Art_date.Date Is Not Null Then 1
                  Else 0
                End                                              As LinkedToART,
                Case
                  When Art_date.Date Is Null Then 1
                  Else 0
                End                                              As
                NotLinkedOnART,
                Confirmed_date.Date                              As
                   DateConfirmedPositive,
                Eomonth(Confirmed_date.Date)                     As
                CohortYearMonth,
                Case
                  When Art_date.Date < Confirmed_date.Date Then
                  Confirmed_date.Date
                  Else Art_date.Date
                End                                              As StartARTDate
                ,
                Datediff(Year, Patient.Dob,
                Confirmed_date.Date) As AgeatDiagnosis,
                Case
                  When Datediff(Day, Confirmed_date.Date, Art_date.Date) = 0
                Then
                  'Same Day'
                  When Datediff(Day, Confirmed_date.Date, Art_date.Date) Between
                       1
                       And 7
                   Then
                  '1 to 7 Days'
                  When Datediff(Day, Confirmed_date.Date, Art_date.Date) Between
                       8
                       And
                       14 Then
                  '8 to 14 Days'
                  When Datediff(Day, Confirmed_date.Date, Art_date.Date) > 14
                       And Timetoartdiagnosis Is Not Null Then '> 14 Days'
                  Else 'Missing'
                End                                              As
                   TimeToARTDiagnosis_Grp,
                Case
                  When Disclosure Is Not Null Then 1
                  Else 0
                End                                              As Disclosure,
                Adherence,
                Baselinevloutcomes
         From   
         NDWH.Fact.FactART As Ctpatients
               
                     --  On Ctpatients.Patientkey = Art.Patientkey
                Left Join Ndwh.Dim.Dimpatient As Patient
                       On Patient.Patientkey = Ctpatients.Patientkey
                Left Join Ndwh.Dim.Dimdate As Confirmed_date
                       On Confirmed_date.Datekey =
                          Patient.Dateconfirmedhivpositivekey
                Left Join Ndwh.Dim.Dimdate As Art_date
                       On Art_date.Datekey = Ctpatients.Startartdatekey
                Left Join Ndwh.Dim.Dimagegroup Age
                       On Age.Agegroupkey = Ctpatients.Agegroupkey),
     Baselinecd4s
     As (Select Patientkey,
                Baselinecd4,
                Baselinecd4date
         From   Ndwh.Fact.Factcd4),
     Baselinewho
     As (Select Patientkey,
                Whostageatart,
                Ageatartstart
         From   Ndwh.Fact.Factartbaselines)
Select Confirmed_reported_cases_and_art.Patientkey,
       Gender,
       Agelastvisit,
       Facilitykey,
       Partnerkey,
       Agencykey,
       Newcasereported,
       Linkedtoart,
       Notlinkedonart,
       Dateconfirmedpositive,
       Cohortyearmonth,
       Startartdate,
       Ageatdiagnosis,
       Timetoartdiagnosis_grp,
       Disclosure,
       Case
         When Baselinecd4 Is Not Null Then 1
         Else 0
       End               As WithBaselineCD4,
       Whostageatart,
       Ageatartstart,
       Age.Datimagegroup As ARTStartAgeGroup,
       Adherence,
      Baselinevloutcomes
Into   [Hivcasesurveillance].[Dbo].[Cslinkage]
From   Confirmed_reported_cases_and_art
       Left Join Baselinecd4s
              On Baselinecd4s.Patientkey =
Confirmed_reported_cases_and_art.Patientkey
       Left Join Baselinewho
              On Baselinewho.Patientkey =
Confirmed_reported_cases_and_art.Patientkey
       Left Join Ndwh.Dim.Dimagegroup Age
              On Age.Agegroupkey = Confirmed_reported_cases_and_art.Agegroupkey 
=======
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
FROM   ndwh.dbo.factctpatients AS ctpatients
LEFT JOIN ndwh.dbo.factart AS art
       ON ctpatients.patientkey = art.patientkey
LEFT JOIN ndwh.dbo.dimpatient AS patient
       ON patient.patientkey = ctpatients.patientkey
LEFT JOIN ndwh.dbo.dimdate AS confirmed_date
       ON confirmed_date.datekey =
          patient.dateconfirmedhivpositivekey
LEFT JOIN ndwh.dbo.dimdate AS art_date
       ON art_date.datekey = art.startartdatekey
LEFT JOIN ndwh.dbo.dimagegroup age
       ON age.agegroupkey = art.agegroupkey),
     baselinecd4s
     AS (SELECT patientkey,
                baselinecd4,
                baselinecd4date
         FROM   ndwh.dbo.factcd4),
     baselinewho
     AS (SELECT patientkey,
                whostageatart,
                ageatartstart
         FROM   ndwh.dbo.factartbaselines)
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
       age.datimagegroup AS ARTStartAgeGroup
INTO   [HIVCaseSurveillance].[dbo].[cslinkage]
FROM   confirmed_reported_cases_and_art
       LEFT JOIN baselinecd4s
              ON baselinecd4s.patientkey =
                 confirmed_reported_cases_and_art.patientkey
       LEFT JOIN baselinewho
              ON baselinewho.patientkey =
                 confirmed_reported_cases_and_art.patientkey
       LEFT JOIN ndwh.dbo.dimagegroup age
              ON age.agegroupkey = confirmed_reported_cases_and_art.agegroupkey

