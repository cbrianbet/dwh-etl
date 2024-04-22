IF Object_id(N'[REPORTING].[dbo].AggregateVLUptakeOutcome', N'U') IS NOT NULL
  DROP TABLE [Reporting].[Dbo].Aggregatevluptakeoutcome

Go

WITH Pbfw_patient
     AS (SELECT DISTINCT Patientkey
         FROM   Ndwh.Dbo.Factpbfw),
     Base_data
     AS (SELECT Art.Facilitykey,
                Art.Partnerkey,
                Art.Agencykey,
                Art.Patientkey,
                Art.Agegroupkey,
                'Non PBFW'                AS PBFWCategory,
                Vl.Validvlresultcategory1 AS ValidVLResultCategory,
                Istxcurr                  AS IsTXCurr,
                Eligiblevl,
                Hasvalidvl                AS HasValidVL
         FROM   Ndwh.Dbo.Factart Art
                LEFT JOIN Ndwh.Dbo.Factviralloads Vl
                       ON Vl.Patientkey = Art.Patientkey
                LEFT JOIN Ndwh.Dbo.Dimpatient Pat
                       ON Pat.Patientkey = Vl.Patientkey
         WHERE  Istxcurr = 1
                AND Vl.Patientkey NOT IN (SELECT Patientkey
                                          FROM   Pbfw_patient)
         /*ommit pbfw patients */
         UNION
         SELECT Pbfw.Facilitykey,
                Pbfw.Partnerkey,
                Pbfw.Agencykey,
                Pbfw.Patientkey,
                Pbfw.Agegroupkey,
                CASE
                  WHEN Newpositives = 1 THEN 'New Positives'
                  ELSE 'Known Positives'
                END                           AS PBFWCategory,
                Vl.Pbfw_validvlresultcategory AS ValidVLResultCategory,
                Patient.Istxcurr              AS IsTXCurr,
                Eligiblevl,
                Pbfw_validvl                  AS HasValidVL
         FROM   Ndwh.Dbo.Factpbfw AS Pbfw
                LEFT JOIN Ndwh.Dbo.Factviralloads AS Vl
                       ON Vl.Patientkey = Pbfw.Patientkey
                LEFT JOIN Ndwh.Dbo.Dimpatient AS Patient
                       ON Patient.Patientkey = Pbfw.Patientkey
         WHERE  Istxcurr = 1)
SELECT Mflcode,
       F.Facilityname,
       County,
       Subcounty,
       P.Partnername,
       A.Agencyname,
       Pat.Gender,
       Year (Art.Startartdatekey)        AS StartARTYear,
       Eomonth(Date.Date)                AS AsOfDate,
       G.Datimagegroup                   AS AgeGroup,
       Count (Vl.Validvlresultcategory2) AS TotalValidVLResultCategory,
       CASE
         WHEN Vl.Validvlresultcategory2 IN ( 'Low Risk LLV', 'LDL' ) THEN
         'SUPPRESSED'
         ELSE Vl.Validvlresultcategory2
       END                               AS ValidVLResultCategory,
       Sum (Pat.Istxcurr)                AS TXCurr,
       Sum (Vl.Eligiblevl)               AS EligibleVL12Mnths,
       Sum (CASE
              WHEN Base.Hasvalidvl = 1 THEN 1
              ELSE 0
            END)                         AS HasValidVL,
       Sum (Validvlsup)                  AS VirallySuppressed,
       Sum (CASE
              WHEN _12monthvl IS NOT NULL THEN 1
            END)                         AS VLAt12Months,
       Sum ([12monthvlsup])              AS VLAt12Months_Sup,
       Sum (CASE
              WHEN _18monthvl IS NOT NULL THEN 1
            END)                         AS VLAt18Months,
       Sum ([18monthvlsup])              AS VLAt18Months_Sup,
       Sum (CASE
              WHEN _24monthvl IS NOT NULL THEN 1
            END)                         AS VLAt24Months,
       Sum ([24monthvlsup])              AS VLAt24Months_Sup,
       Sum (CASE
              WHEN _6monthvl IS NOT NULL THEN 1
            END)                         AS VLAt6Months,
       Sum ([6monthvlsup])               AS VLAt6Months_Sup,
       Cast(Getdate() AS Date)           AS LoadDate
INTO   [Reporting].[Dbo].Aggregatevluptakeoutcome
FROM   Ndwh.Dbo.Factart Art
       LEFT JOIN Ndwh.Dbo.Factviralloads Vl
              ON Vl.Patientkey = Art.Patientkey
       LEFT JOIN Ndwh.Dbo.Dimagegroup G
              ON G.Agegroupkey = Vl.Agegroupkey
       LEFT JOIN Ndwh.Dbo.Dimfacility F
              ON F.Facilitykey = Vl.Facilitykey
       LEFT JOIN Ndwh.Dbo.Dimagency A
              ON A.Agencykey = Vl.Agencykey
       LEFT JOIN Ndwh.Dbo.Dimpatient Pat
              ON Pat.Patientkey = Vl.Patientkey
       LEFT JOIN Ndwh.Dbo.Dimpartner P
              ON P.Partnerkey = Vl.Partnerkey
       LEFT JOIN Ndwh.Dbo.Dimartoutcome AS Outcome
              ON Outcome.Artoutcomekey = Art.Artoutcomekey
       LEFT JOIN Ndwh.Dbo.Dimdate AS Date
              ON Date.Datekey = Art.Startartdatekey
       LEFT JOIN Base_data AS Base
              ON Base.Patientkey = Art.Patientkey
WHERE  Pat.Istxcurr = 1
       AND Outcome.Artoutcome = 'V'
GROUP  BY Mflcode,
          F.Facilityname,
          County,
          Subcounty,
          P.Partnername,
          A.Agencyname,
          Pat.Gender,
          G.Datimagegroup,
          Year(Art.Startartdatekey),
          Eomonth(Date.Date),
          CASE
            WHEN Vl.Validvlresultcategory2 IN ( 'Low Risk LLV', 'LDL' ) THEN
            'SUPPRESSED'
            ELSE Vl.Validvlresultcategory2
          END,
          Validvlresult 