IF Object_id(N'[NDWH].[Fact].[FactPBFW]', N'U') IS NOT NULL
  DROP TABLE [Ndwh].[Fact].[Factpbfw];

BEGIN
    WITH Mfl_partner_agency_combination
         AS (SELECT DISTINCT Mfl_code,
                             Sdp,
                             Sdp_agency AS Agency
             FROM   Ods.Care.All_emrsites
       ),
       Anc_from_mnch AS (
              select Row_number()
                            OVER (
                            Partition BY Patientpk, Sitecode
                            ORDER BY Visitdate asc ) as num,
                     Patientpk,
                     Patientpkhash,
                     Sitecode,
                     Visitdate,
                     HIVStatusBeforeANC
              from   Ods.Mnch.Mnch_ancvisits
              where (Hivstatusbeforeanc = 'KP'
                            OR Hivtestfinalresult = 'Positive')	
       ),
       Pbfw_patient AS (
              select
                     * 
              from ODS.[Intermediate].Intermediate_PregnantAndBreastFeeding
              where AsOfDate = (select max(AsOfDate) from ODS.[Intermediate].Intermediate_PregnantAndBreastFeeding)
       ),
       pbfw_visit_dates as (
              select 
                     PatientPK,
                     SiteCode,
                     BreastFeedingRelatedVisitDate as VisitDate
              from Pbfw_patient
              union 
              select 
                     PatientPK,
                     SiteCode,
                     PregnancyRelatedVisitDate as VisitDate
              from Pbfw_patient            
       ),
       greatest_pbfw_visit_dates as (
              select 
                     PatientPK,
                     SiteCode,
                     max(VisitDate) as VisitDate
              from pbfw_visit_dates
              group by 
                     PatientPK, 
                     SiteCode
       ),
       Ancdate1 as (
              SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate1
             FROM   Anc_from_mnch as anc
             WHERE  Num = 1                   
       ),
         Ancdate2
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate2
             FROM   Anc_from_mnch as anc
             WHERE  Num = 2
       ),
         Ancdate3
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate3
             FROM   Anc_from_mnch as anc
             WHERE  Num = 3
       ),
         Ancdate4
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate4
             FROM   Anc_from_mnch as anc
             WHERE  Num = 4
       ),
         Testsatanc AS (
              SELECT Row_number()
                      OVER (
                        Partition BY Tests.Sitecode, Tests.Patientpk,tests.TestDate,tests.TestType 
                        ORDER BY EncounterId ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Sitecode,
                    Tests.Patientpk
              FROM   Ods.HTS.Hts_clienttests Tests
              WHERE  Entrypoint IN ( 'PMTCT ANC', 'MCH')
              and tests.TestType = 'Initial Test'
       ),
         Testedatanc
         AS ( 
              SELECT 
                    distinct Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatanc Pat
             WHERE  Num = 1
       ),
         Testsatlandd
         AS (SELECT Row_number()
                      OVER (
                         Partition BY Tests.Sitecode, Tests.Patientpk,tests.TestDate,tests.TestType 
                        ORDER BY EncounterId ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Patientpk,
                    Tests.Sitecode
             FROM   Ods.HTS.Hts_clienttests Tests
             WHERE  Entrypoint IN ( 'Maternity', 'PMTCT MAT')
             and tests.TestType = 'Initial Test'
       ),
         Testedatlandd
         AS (SELECT distinct Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatlandd AS Pat
             WHERE  Num = 1),
         Testsatpnc
         AS (SELECT Row_number()
                      OVER (
                       Partition BY Tests.Sitecode, Tests.Patientpk,tests.TestDate,tests.TestType 
                        ORDER BY EncounterId ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Patientpk,
                    Tests.Sitecode
             FROM   Ods.HTS.Hts_clienttests Tests
             WHERE  Entrypoint IN ( 'PMTCT PNC', 'PNC', 'POSTNATAL CARE CLINIC')
             and tests.TestType = 'Initial Test'                          
          ),
         Testedatpnc
         AS (SELECT distinct Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatpnc Pat
             WHERE  Num = 1),
         Eac
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Eac.Sitecode, Eac.Patientpk
                        ORDER BY Eac.Visitdate ASC ) AS NUM,
                    Patientpkhash,
                    Sitecode,
                    Patientpk,
                    Visitdate
             FROM   Ods.Care.Ct_enhancedadherencecounselling Eac),
         Receivedeac1
         AS (SELECT Eac1.Patientpkhash,
                    Eac1.Sitecode,
                    Eac1.Patientpk
             FROM   Eac AS Eac1
             where Num=1),
         Receivedeac2
         AS (SELECT Eac2.Patientpkhash,
                    Eac2.Patientpk,
                    Eac2.Sitecode
             FROM   Eac AS Eac2
             where Num=2),
         Receivedeac3
         AS (SELECT Eac3.Patientpkhash,
                    Eac3.Patientpk,
                    Eac3.Sitecode
             FROM   Eac AS Eac3
             where Num=3),
         Switches
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Pharm.Sitecode, Pharm.Patientpk
                        ORDER BY Pharm.Dispensedate DESC ) AS NUM,
                    Pharm.Patientpk,
                    Pharm.Sitecode,
                    CASE
                      WHEN Regimenchangedswitched IS NOT NULL THEN 1
                      ELSE 0
                    END                                    AS PBFWRegLineSwitch
             FROM   Ods.Care.Ct_patientpharmacy Pharm
             WHERE  Regimenchangedswitched IS NOT NULL),
         Pbfwreglineswitch
         AS (SELECT *
             FROM   Switches
             WHERE  Num = 1
       ),
       visits_ordered as (
       select 
              PatientPK,
              SiteCode,
              VisitDate,
              row_number() over (partition by PatientPK, SiteCode order by VisitDate asc) as rank
       from ODS.Care.CT_PatientVisits
              where (Pregnant='Yes' OR breastfeeding='Yes')
              and datediff(month, VisitDate, EOMONTH(DATEADD(mm,-1,GETDATE()))) <= 33 --filtering for 9 months pregnancy and at least 24 months of brestfeeding
       ),
       earliest_anc_from_greencard as (
        select 
                PatientPK,
                SiteCode,
                VisitDate as GreenCardAncDate1
        from visits_ordered
        where rank = 1
       ),
       second_anc_greencard as (
        select 
                PatientPK,
                SiteCode,
                VisitDate as GreenCardAncDate2
        from visits_ordered
        where rank = 2
       ),
       third_anc_greencard as (
        select 
                PatientPK,
                SiteCode,
                VisitDate as GreenCardAncDate3
        from visits_ordered
        where rank = 3
       ),
       fourth_anc_greencard as (
        select 
                PatientPK,
                SiteCode,
                VisitDate as GreenCardAncDate4
        from visits_ordered
        where rank = 4
       ),
       anc_source_ordered_desc as (
              select Row_number()
                            OVER (
                            Partition BY Patientpk, Sitecode
                            ORDER BY Visitdate desc ) as num,
                     Patientpk,
                     Patientpkhash,
                     Sitecode,
                     Visitdate,
                     HIVStatusBeforeANC
              from   Ods.MNCH.Mnch_ancvisits
              where (Hivstatusbeforeanc = 'KP'
                            OR Hivtestfinalresult = 'Positive')
              and datediff(month, VisitDate, EOMONTH(DATEADD(mm,-1,GETDATE()))) <= 33 --filtering for 9 months pregnancy and at least 24 months of brestfeeding
       ),
       latest_anc as (
	select 
		*
	from anc_source_ordered_desc
	where num = 1
       ),
       Summary AS (
              SELECT
                    Patient.PatientPKHash,
                    Patient.Sitecode,
                    dim_patient.Dob,
                    dim_patient.Gender,
                    coalesce(earliest_anc_from_greencard.GreenCardAncDate1, Ancdate1.ANCDate1) as ANCDate1,
                    coalesce(second_anc_greencard.GreenCardAncDate2, ANCDate2.Ancdate2) as Ancdate2,
                    coalesce(third_anc_greencard.GreenCardAncDate3, ANCDate3.Ancdate3) as Ancdate3,
                    coalesce(fourth_anc_greencard.GreenCardAncDate4, ANCDate4.Ancdate4) as Ancdate4,
                    CASE
                      WHEN Testedatlandd.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatLandD,
                    CASE
                      WHEN Testedatanc.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatANC,
                    CASE
                      WHEN Testedatpnc.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatPNC,
                    CASE
                      WHEN Datediff(Year, dim_patient.Dob,  EOMONTH(DATEADD(mm,-1,GETDATE()))) BETWEEN 10 AND 19 THEN
                      1
                      ELSE 0
                    END       AS PositiveAdolescent,
                    CASE
                      WHEN art.Startartdate IS NOT NULL THEN 1
                      ELSE 0
                    END       AS RecieivedART,
                    CASE
                      WHEN Receivedeac1.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC1,
                    CASE
                      WHEN Receivedeac2.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC2,
                    CASE
                      WHEN Receivedeac3.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC3,
                    Pbfwreglineswitch,
                    case when IsPregnant = 1 then 'Yes' else 'No' end as Pregnant,
                    case when IsBreastfeeding = 1 then 'Yes' else 'No' end as Breastfeeding,
					case 
						when cast(dim_patient.DateConfirmedHIVPositiveKey as date) < greatest_pbfw_visit_dates.VisitDate then 'Known Positive'
						when cast(dim_patient.DateConfirmedHIVPositiveKey as date) = greatest_pbfw_visit_dates.VisitDate then 'New Positive'
						when HIVStatusBeforeANC in ('Positive', 'KP') then 'Known Positive'
						when latest_anc.PatientPK is not null and HIVStatusBeforeANC not in ('KP') then 'New Positive'
						else 'Missing'
					end as PBFWCategory
              FROM   Pbfw_patient AS Patient
              LEFT JOIN Ancdate1
                     ON Patient.Patientpk = Ancdate1.Patientpk
                            AND Patient.Sitecode = Ancdate1.Sitecode
              LEFT JOIN Ancdate2
                     ON Patient.Patientpk = Ancdate2.Patientpk
                            AND Patient.Sitecode = Ancdate2.Sitecode
              LEFT JOIN Ancdate3
                     ON Patient.Patientpk = Ancdate3.Patientpk
                            AND Patient.Sitecode = Ancdate3.Sitecode
              LEFT JOIN Ancdate4
                     ON Patient.Patientpk = Ancdate4.Patientpk
                            AND Patient.Sitecode = Ancdate4.Sitecode
              LEFT JOIN Testedatanc
                     ON Patient.Patientpk = Testedatanc.Patientpk
                            AND Patient.Sitecode = Testedatanc.Sitecode
              LEFT JOIN Testedatlandd
                     ON Patient.Patientpk = Testedatlandd.Patientpk
                            AND Patient.Sitecode = Testedatlandd.Sitecode
              LEFT JOIN Testedatpnc
                     ON Patient.Patientpk = Testedatpnc.Patientpk
                            AND Patient.Sitecode = Testedatpnc.Sitecode
              LEFT JOIN Receivedeac1
                     ON Patient.Patientpk = Receivedeac1.Patientpk
                            AND Patient.Sitecode = Receivedeac1.Sitecode
              LEFT JOIN Receivedeac2
                     ON Patient.Patientpk = Receivedeac2.Patientpk
                            AND Patient.Sitecode = Receivedeac2.Sitecode
              LEFT JOIN Receivedeac3
                     ON Patient.Patientpk = Receivedeac3.Patientpk
                            AND Patient.Sitecode = Receivedeac3.Sitecode
              LEFT JOIN Pbfwreglineswitch
                     ON Patient.Patientpk = Pbfwreglineswitch.Patientpk
                            AND Patient.Sitecode = Pbfwreglineswitch.Sitecode
              left join NDWH.Dim.Dimpatient as dim_patient 
                     on dim_patient.PatientPKHash = CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(Patient.PatientPK as NVARCHAR(36))), 2) 
                            and dim_patient.SiteCode = Patient.SiteCode
              left join ODS.Care.CT_ARTPatients as art 
                                   on art.PatientPK = Patient.PatientPK
                            and art.SiteCode = Patient.SiteCode
              left join latest_anc        
                            on latest_anc.PatientPK = Patient.PatientPK 
                            and latest_anc.SiteCode = Patient.SiteCode
              left join earliest_anc_from_greencard 
                            on earliest_anc_from_greencard.PatientPK = Patient.PatientPK 
                            and earliest_anc_from_greencard.SiteCode = Patient.SiteCode
              left join second_anc_greencard 
                            on second_anc_greencard.PatientPK = Patient.PatientPK 
                            and second_anc_greencard.SiteCode = Patient.SiteCode
              left join third_anc_greencard 
                            on third_anc_greencard.PatientPK = Patient.PatientPK 
                            and third_anc_greencard.SiteCode = Patient.SiteCode
              left join fourth_anc_greencard 
                            on fourth_anc_greencard.PatientPK = Patient.PatientPK 
                            and fourth_anc_greencard.SiteCode = Patient.SiteCode      
              left join greatest_pbfw_visit_dates 
                            on greatest_pbfw_visit_dates.PatientPK = Patient.PatientPK
                            and greatest_pbfw_visit_dates.SiteCode = Patient.SiteCode               
)
    SELECT FactKey = IDENTITY(Int, 1, 1),
           Patient.Patientkey,
           Facility.Facilitykey,
           Partner.Partnerkey,
           Agency.Agencykey,
           Age_group.Agegroupkey,
           Ancdate1,
           Ancdate2,
           Ancdate3,
           Ancdate4,
           Testedatanc,
           Testedatlandd,
           Testedatpnc,
           Positiveadolescent,
           CASE
              WHEN PBFWCategory = 'New Positive'  THEN 1
              ELSE 0
           END AS NewPositives,
           CASE
              WHEN PBFWCategory = 'Known Positive'  THEN 1
              ELSE 0
           END AS KnownPositive,
           Recieivedart,
           Ancdate1.Datekey AS ANCDate1Key,
           Ancdate2.Datekey AS ANCDate2Key,
           Ancdate3.Datekey AS ANCDate3Key,
           Ancdate4.Datekey AS ANCDate4Key,
           Receivedeac1,
           Receivedeac2,
           Receivedeac3,
           Pbfwreglineswitch,
           Pregnant,
           Breastfeeding
    INTO   Ndwh.Fact.Factpbfw
    FROM   Summary
           LEFT JOIN Ndwh.Dim.Dimfacility AS Facility
                  ON Facility.Mflcode = Summary.Sitecode
           LEFT JOIN Mfl_partner_agency_combination
                  ON Mfl_partner_agency_combination.Mfl_code = Summary.Sitecode
           LEFT JOIN Ndwh.Dim.Dimpartner AS Partner
                  ON Partner.Partnername = Mfl_partner_agency_combination.Sdp
           LEFT JOIN Ndwh.Dim.Dimagency AS Agency
                  ON Agency.Agencyname = Mfl_partner_agency_combination.Agency
           LEFT JOIN Ndwh.Dim.Dimpatient AS Patient
                  ON Patient.Patientpkhash = Summary.Patientpkhash
                     AND Patient.Sitecode = Summary.Sitecode
           LEFT JOIN Ndwh.Dim.Dimdate AS Ancdate1
                  ON Ancdate1.Date = Cast(Summary.Ancdate1 AS Date)
           LEFT JOIN Ndwh.Dim.Dimdate AS Ancdate2
                  ON Ancdate2.Date = Cast(Summary.Ancdate2 AS Date)
           LEFT JOIN Ndwh.Dim.Dimdate AS Ancdate3
                  ON Ancdate3.Date = Cast(Summary.Ancdate3 AS Date)
           LEFT JOIN Ndwh.Dim.Dimdate AS Ancdate4
                  ON Ancdate4.Date = Cast(Summary.Ancdate4 AS Date)
           LEFT JOIN Ndwh.Dim.Dimagegroup AS Age_group
                  ON Age_group.Age = Datediff(Yy, Summary.Dob, Getdate())
    WHERE  Patient.Voided = 0;

    ALTER TABLE Ndwh.Fact.Factpbfw
      ADD PRIMARY KEY(Factkey);
END 