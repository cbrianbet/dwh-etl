IF Object_id(N'REPORTING.dbo.AggregateLDLDurable', N'U') IS NOT NULL
  DROP TABLE Reporting.Dbo.Aggregateldldurable;

WITH Pbfw_patient
     AS (SELECT DISTINCT Patientkey
         FROM   Ndwh.Fact.Factpbfw),
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
         FROM   Ndwh.Fact.Factart Art
                LEFT JOIN Ndwh.Fact.Factviralloads Vl
                       ON Vl.Patientkey = Art.Patientkey
                LEFT JOIN Ndwh.Dim.Dimpatient Pat
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
                  WHEN KnownPositive = 1 THEN  'Known Positives'
                  ELSE 'Unknown'
                END                           AS PBFWCategory,
                Vl.Pbfw_validvlresultcategory AS ValidVLResultCategory,
                Patient.Istxcurr              AS IsTXCurr,
                Eligiblevl,
                Pbfw_validvl                  AS HasValidVL
         FROM   Ndwh.Fact.Factpbfw AS Pbfw
                LEFT JOIN Ndwh.Fact.Factviralloads AS Vl
                       ON Vl.Patientkey = Pbfw.Patientkey
                LEFT JOIN Ndwh.Dim.Dimpatient AS Patient
                       ON Patient.Patientkey = Pbfw.Patientkey
         WHERE  Istxcurr = 1),
     Eligible_for_two_vl_tests
     AS (
        /*less than 25 years and not part of pbfw */
        SELECT Art.Patientkey
        FROM   Ndwh.Fact.Factart AS Art
               LEFT JOIN Ndwh.Dim.Dimagegroup AS Agegroup
                      ON Agegroup.Agegroupkey = Art.Agegroupkey
               LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                      ON Start_date.Datekey = Art.Startartdatekey
        WHERE  Agegroup.Age < 25
               AND Datediff(Month, Start_date.Date, Eomonth(
                   Dateadd(Mm, -1, Getdate())))
                   >= 9
               AND Art.Patientkey NOT IN (SELECT Patientkey
                                          FROM   Pbfw_patient)
        /*ommit pbfw patients */
        UNION
        /* 25 and above years and not part of pbfw */
        SELECT Art.Patientkey
        FROM   Ndwh.Fact.Factart AS Art
               LEFT JOIN Ndwh.Dim.Dimagegroup AS Agegroup
                      ON Agegroup.Agegroupkey = Art.Agegroupkey
               LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                      ON Start_date.Datekey = Art.Startartdatekey
        WHERE  Agegroup.Age >= 25
               AND Datediff(Month, Start_date.Date, Eomonth(
                   Dateadd(Mm, -1, Getdate())))
                   >= 12
               AND Art.Patientkey NOT IN (SELECT Patientkey
                                          FROM   Pbfw_patient)
         /*ommit pbfw patients */
         UNION
         /*pbfw */
         SELECT Art.Patientkey
         FROM   Ndwh.Fact.Factart AS Art
                INNER JOIN Pbfw_patient AS Pbfw
                        ON Pbfw.Patientkey = Art.Patientkey
                LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                       ON Start_date.Datekey = Art.Startartdatekey
                          AND Datediff(Month, Start_date.Date, Eomonth(
                              Dateadd(Mm, -1, Getdate()))) >= 9),
     Two_consecutive_vl_tests_results
     AS (
        /*less than 25 years and not part of pbfw */
        SELECT Art.Patientkey,
               Vl.Latestvl1,
               Vl1date.Date AS LatestVLDate1,
               Vl.Latestvl2,
               Vl2date.Date AS LatestVLDate2
        FROM   Ndwh.Fact.Factart AS Art
               LEFT JOIN Ndwh.Dim.Dimagegroup AS Agegroup
                      ON Agegroup.Agegroupkey = Art.Agegroupkey
               LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                      ON Start_date.Datekey = Art.Startartdatekey
               INNER JOIN Ndwh.Fact.Factviralloads AS Vl
                       ON Vl.Patientkey = Art.Patientkey
               INNER JOIN Ndwh.Dim.Dimdate AS Vl2date
                       ON Vl2date.Datekey = Vl.Latestvldate2key
               INNER JOIN Ndwh.Dim.Dimdate AS Vl1date
                       ON Vl1date.Datekey = Vl.Latestvldate1key
        WHERE  Agegroup.Age < 25
               AND datediff(month, vl1Date.Date, eomonth(dateadd(mm,-1,getdate()))) <= 6
               AND Datediff(Month, Vl2date.Date, Vl1date.Date) <= 6
               /*Ensure that the second last vl and the last one is within 6 months */
               AND Art.Patientkey NOT IN (SELECT Patientkey
                                          FROM   Pbfw_patient)
        /*ommit pbfw patients */
        UNION
        /* 25 and above years and not part of pbfw */
        SELECT Art.Patientkey,
               Vl.Latestvl1,
               Vl1date.Date AS LatestVLDate1,
               Vl.Latestvl2,
               Vl2date.Date AS LatestVLDate2
        FROM   Ndwh.Fact.Factart AS Art
               LEFT JOIN Ndwh.Dim.Dimagegroup AS Agegroup
                      ON Agegroup.Agegroupkey = Art.Agegroupkey
               LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                      ON Start_date.Datekey = Art.Startartdatekey
               INNER JOIN Ndwh.Fact.Factviralloads AS Vl
                       ON Vl.Patientkey = Art.Patientkey
               INNER JOIN Ndwh.Dim.Dimdate AS Vl2date
                       ON Vl2date.Datekey = Vl.Latestvldate2key
               INNER JOIN Ndwh.Dim.Dimdate AS Vl1date
                       ON Vl1date.Datekey = Vl.Latestvldate1key
        WHERE  Agegroup.Age >= 25
                AND datediff(month, vl1Date.Date, eomonth(dateadd(mm,-1,getdate()))) <= 12
               AND Datediff(Month, Vl2date.Date, Vl1date.Date) <= 12
               AND Art.Patientkey NOT IN (SELECT Patientkey
                                          FROM   Pbfw_patient)
         /*ommit pbfw patients */
         UNION
         /*pbfw */
         SELECT Art.Patientkey,
                Vl.Latestvl1,
                Vl1date.Date AS LatestVLDate1,
                Vl.Latestvl2,
                Vl2date.Date AS LatestVLDate2
         FROM   Ndwh.Fact.Factart AS Art
                INNER JOIN Pbfw_patient AS Pbfw
                        ON Pbfw.Patientkey = Art.Patientkey
                LEFT JOIN Ndwh.Dim.Dimdate AS Start_date
                       ON Start_date.Datekey = Art.Startartdatekey
                INNER JOIN Ndwh.Fact.Factviralloads AS Vl
                        ON Vl.Patientkey = Art.Patientkey
                INNER JOIN Ndwh.Dim.Dimdate AS Vl2date
                        ON Vl2date.Datekey = Vl.Latestvldate2key
                INNER JOIN Ndwh.Dim.Dimdate AS Vl1date
                        ON Vl1date.Datekey = Vl.Latestvldate1key
               AND datediff(month, vl1Date.Date, eomonth(dateadd(mm,-1,getdate()))) <= 6
               AND Datediff(Month, Vl2date.Date, Vl1date.Date) <= 6
        ),
     Durable_ldl
     AS (SELECT Patientkey,
                Latestvl1,
                Latestvl2
         FROM   Two_consecutive_vl_tests_results
         WHERE  ( Isnumeric(Latestvl2) = 1
                  AND Cast(Replace(Latestvl2, ',', '') AS Float) < 50.00
                   OR Latestvl2 IN ( 'undetectable', 'NOT DETECTED',
                                     '0 copies/ml',
                                     'LDL',
                                     'Less than Low Detectable Level' )
                )
                AND ( Isnumeric(Latestvl1) = 1
                      AND Cast(Replace(Latestvl1, ',', '') AS Float) < 50.00
                       OR Latestvl1 IN ( 'undetectable', 'NOT DETECTED',
                                         '0 copies/ml',
                                         'LDL',
                                         'Less than Low Detectable Level' ) )),
		 OTZ_Patients AS (
			SELECT DISTINCT
				pat.PatientKey,
				otz.FacilityKey
			FROM NDWH.Fact.FactOTZ otz
			left join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
			left JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = otz.PatientKey
			WHERE age.Age BETWEEN 10 AND 19 AND IsTXCurr = 1
		 )
SELECT Mflcode,
       F.Facilityname,
       County,
       Subcounty,
       P.Partnername,
       A.Agencyname,
       Pat.Gender,
       G.Datimagegroup         AS AgeGroup,
       Pbfwcategory,
       Pregnant,
       Breastfeeding,
       Validvlresultcategory,
       Sum(Base_data.Istxcurr) AS TXCurr,
       Sum(Eligiblevl)         AS EligibleVL,
       Sum(Hasvalidvl)         AS HasValidVL,
       Sum(CASE
             WHEN Eligible_for_two_vl_tests.Patientkey IS NOT NULL THEN 1
             ELSE 0
           END)                AS CountEligibleForTwoVLTests,
       Sum(CASE
             WHEN Two_consecutive_vl_tests_results.Patientkey IS NOT NULL THEN 1
             ELSE 0
           END)                AS CountTwoConsecutiveTests,
       Sum(CASE
             WHEN ( Isnumeric(Two_consecutive_vl_tests_results.Latestvl1) = 1
                    AND Cast(Replace(Two_consecutive_vl_tests_results.Latestvl1,
                             ',',
                             '')
                             AS Float
                        ) <
                        50.00 )
                   OR ( Two_consecutive_vl_tests_results.Latestvl1 IN (
                            'undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL'
                            ,
                        'Less than Low Detectable Level' ) ) THEN 1
             ELSE 0
           END)                AS CountLDLLastOneTest,
       Sum(CASE
             WHEN Durable_ldl.Patientkey IS NOT NULL THEN 1
             ELSE 0
           END)                AS CountDurableLDL,
			 COUNT(DISTINCT OTZ_Patients.PatientKey) AS otzEnrolled
INTO   Reporting.Dbo.Aggregateldldurable
FROM   Base_data
       LEFT JOIN Eligible_for_two_vl_tests
              ON Eligible_for_two_vl_tests.Patientkey = Base_data.Patientkey
       LEFT JOIN Two_consecutive_vl_tests_results
              ON Two_consecutive_vl_tests_results.Patientkey =
                 Base_data.Patientkey
       LEFT JOIN Durable_ldl
              ON Durable_ldl.Patientkey = Base_data.Patientkey
       LEFT JOIN OTZ_Patients
              ON OTZ_Patients.Patientkey = Base_data.Patientkey
       LEFT JOIN Ndwh.Dim.Dimagegroup G
              ON G.Agegroupkey = Base_data.Agegroupkey
       LEFT JOIN Ndwh.Dim.Dimfacility F
              ON F.Facilitykey = Base_data.Facilitykey
       LEFT JOIN Ndwh.Dim.Dimagency A
              ON A.Agencykey = Base_data.Agencykey
       LEFT JOIN Ndwh.Dim.Dimpatient Pat
              ON Pat.Patientkey = Base_data.Patientkey
       LEFT JOIN Ndwh.Dim.Dimpartner P
              ON P.Partnerkey = Base_data.Partnerkey
       LEFT JOIN NDWH.Fact.Factpbfw pbfw on pbfw.Patientkey=Base_data.PatientKey
GROUP  BY Mflcode,
          F.Facilityname,
          County,
          Subcounty,
          P.Partnername,
          A.Agencyname,
          Pat.Gender,
          G.Datimagegroup,
          Pbfwcategory,
          Validvlresultcategory ,
          Pregnant,
          Breastfeeding

