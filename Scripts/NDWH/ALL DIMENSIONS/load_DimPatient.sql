BEGIN

    WITH ct_patient_source
         AS (SELECT DISTINCT patients.patientidhash,
                             patients.patientpkhash,
                             patients.patientid,
                             patients.patientpk,
                             patients.sitecode,
                             patients.gender,
                             Cast(patients.dob AS DATE)
                                AS DOB,
                             maritalstatus,
                             nupihash,
                             patienttype,
                             patients.patientsource,
                             baselines.ewho
                                AS EnrollmentWHOKey,
                             Cast(Format(COALESCE(ewhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateEnrollmentWHOKey,
                             bwho
                                AS BaseLineWHOKey,
                             Cast(Format(COALESCE(bwhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateBaselineWHOKey,
                             CASE
                               WHEN outcomes.artoutcome = 'V' THEN 1
                               ELSE 0
                             END
                                AS IsTXCurr,
                              cast(Getdate() AS DATE)
                                AS LoadDate,
                              coalesce(replace(patients.DateConfirmedHIVPositive,'-',''), replace(art.StartARTDate,'-',''),replace(patients.RegistrationAtCCC,'-','')) as DateConfirmedHIVPositiveKey,
								     patients.voided,
                             case when art.StartARTDate is not null then 1 else 0 end as EveronART
             FROM   ods.Care.ct_patient AS patients
                    LEFT JOIN ods.Care.ct_patientbaselines AS baselines
                           ON patients.patientpkhash = baselines.patientpkhash
                              AND patients.sitecode = baselines.sitecode and baselines.voided=0
                    LEFT JOIN ods.[intermediate].intermediate_artoutcomes AS outcomes
                           ON outcomes.patientpkhash = patients.patientpkhash
                              AND outcomes.sitecode = patients.sitecode
                    LEFT JOIN ODS.Care.CT_ARTPatients as art on art.PatientPKHash = patients.PatientPKHash
                        AND art.SiteCode = patients.SiteCode
            ),
         hts_patient_source
         AS (SELECT DISTINCT htsnumberhash,
                             patientpkhash,
                             patientpk,
                             sitecode,
                             Cast(dob AS DATE) AS DOB,
                             gender,
                             maritalstatus,
                             nupihash,
							 clients.voided
             FROM   ods.HTS.hts_clients AS clients

            ),
         prep_patient_source
         AS (SELECT DISTINCT patientpkhash,
                             patientpk,
                             prepnumber,
                             sitecode,
                             prepenrollmentdate,
                             sex,
                             dateofbirth,
                             clienttype,
                             maritalstatus
							 ,voided
             FROM   ods.PrEP.prep_patient),

         pmtct_patient_source
         AS (SELECT DISTINCT patientpkhash,
                             patientpk,
                             sitecode,
                             dob,
                             gender,
                             nupihash,
                             patientmnchidhash,
                             maritalstatus,
                             Cast(Format(firstenrollmentatmnch, 'yyyyMMdd') AS
                                  INT)
                             AS
                             FirstEnrollmentAtMnchDateKey
							 ,voided
             FROM   ods.MNCH.mnch_patient),
         combined_data_ct_hts
         AS (SELECT COALESCE(ct_patient_source.patientpkhash,
                    hts_patient_source.patientpkhash) AS
                    PatientPKHash,
                    COALESCE(ct_patient_source.sitecode,
                    hts_patient_source.sitecode)
                       AS SiteCode,
                    COALESCE(ct_patient_source.nupihash,
                    hts_patient_source.nupihash)
                       AS NUPI,
                    COALESCE(ct_patient_source.dob, hts_patient_source.dob)
                       AS DOB,
                    COALESCE(ct_patient_source.maritalstatus,
                    hts_patient_source.maritalstatus) AS
                    MaritalStatus,
                    COALESCE(ct_patient_source.gender,
                    hts_patient_source.gender)
                       AS Gender,
                    ct_patient_source.patientidhash,
                    ct_patient_source.patienttype
                       AS ClientType,
                    ct_patient_source.patientsource,
                    ct_patient_source.enrollmentwhokey,
                    ct_patient_source.dateenrollmentwhokey,
                    ct_patient_source.baselinewhokey,
                    ct_patient_source.datebaselinewhokey,
                    ct_patient_source.istxcurr,
                    ct_patient_source.DateConfirmedHIVPositiveKey,
                    ct_patient_source.EveronART,
                    hts_patient_source.htsnumberhash,
                    Cast(Getdate() AS DATE)
                       AS LoadDate
					   ,COALESCE(ct_patient_source.voided,hts_patient_source.voided) As voided
             FROM   ct_patient_source
                    FULL JOIN hts_patient_source
                           ON hts_patient_source.patientpkhash =
                              ct_patient_source.patientpkhash
                              AND ct_patient_source.sitecode =
                                  hts_patient_source.sitecode),


         combined_data_ct_hts_prep
         AS (SELECT COALESCE(combined_data_ct_hts.patientpkhash,
                    prep_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts.sitecode,
                    prep_patient_source.sitecode)
                       AS
                    SiteCode,
                    combined_data_ct_hts.nupi
                       AS NUPI,
                    COALESCE(combined_data_ct_hts.dob,
                    prep_patient_source.dateofbirth)
                       AS DOB,
                    COALESCE(combined_data_ct_hts.maritalstatus,
                    prep_patient_source.maritalstatus)
                                                 AS MaritalStatus,
                    COALESCE(combined_data_ct_hts.gender,
                    prep_patient_source.sex)
                       AS Gender,
                    combined_data_ct_hts.patientidhash,
                    COALESCE(combined_data_ct_hts.clienttype,
                       prep_patient_source.clienttype) AS
                    ClientType,
                    combined_data_ct_hts.patientsource,
                    combined_data_ct_hts.enrollmentwhokey,
                    combined_data_ct_hts.dateenrollmentwhokey,
                    combined_data_ct_hts.baselinewhokey,
                    combined_data_ct_hts.datebaselinewhokey,
                    combined_data_ct_hts.istxcurr,
                    combined_data_ct_hts.DateConfirmedHIVPositiveKey,
                    combined_data_ct_hts.EverOnART,
                    combined_data_ct_hts.htsnumberhash,
                    prep_patient_source.prepnumber,
                    Cast(Format(prep_patient_source.prepenrollmentdate,
                         'yyyyMMdd')
                         AS
                         INT)
                       AS
                    PrepEnrollmentDateKey,
					COALESCE(combined_data_ct_hts.voided,prep_patient_source.voided) As Voided
             FROM   combined_data_ct_hts
                    FULL JOIN prep_patient_source
                           ON combined_data_ct_hts.patientpkhash =
                              prep_patient_source.patientpkhash
                              AND prep_patient_source.sitecode =
                                  combined_data_ct_hts.sitecode),


         combined_data_ct_hts_prep_pmtct
         AS (SELECT COALESCE(combined_data_ct_hts_prep.patientpkhash,
                               pmtct_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts_prep.sitecode,
                    pmtct_patient_source.sitecode) AS
                    SiteCode,
                    COALESCE(combined_data_ct_hts_prep.nupi,
                    pmtct_patient_source.nupihash)
                       AS Nupi,
                    COALESCE(combined_data_ct_hts_prep.dob,
                    pmtct_patient_source.dob)
                       AS DOB,
                    COALESCE(combined_data_ct_hts_prep.maritalstatus,
                    pmtct_patient_source.maritalstatus)
                       AS MaritalStatus,
                    COALESCE(combined_data_ct_hts_prep.gender,
                    pmtct_patient_source.gender)
                       AS
                    Gender,
                    combined_data_ct_hts_prep.patientidhash,
                    combined_data_ct_hts_prep.clienttype,
                    combined_data_ct_hts_prep.patientsource,
                    combined_data_ct_hts_prep.enrollmentwhokey,
                    combined_data_ct_hts_prep.dateenrollmentwhokey,
                    combined_data_ct_hts_prep.baselinewhokey,
                    combined_data_ct_hts_prep.datebaselinewhokey,
                    combined_data_ct_hts_prep.istxcurr,
                    combined_data_ct_hts_prep.DateConfirmedHIVPositiveKey,
                    combined_data_ct_hts_prep.EverOnART,
                    combined_data_ct_hts_prep.htsnumberhash,
                    combined_data_ct_hts_prep.prepenrollmentdatekey,
                    combined_data_ct_hts_prep.prepnumber,
                    pmtct_patient_source.patientmnchidhash,
                    pmtct_patient_source.firstenrollmentatmnchdatekey,
                    Cast(Getdate() AS DATE)
                       AS LoadDate,
					   COALESCE(combined_data_ct_hts_prep.voided,pmtct_patient_source.voided) As Voided
             FROM   combined_data_ct_hts_prep
                    FULL JOIN pmtct_patient_source
                           ON combined_data_ct_hts_prep.patientpkhash =
                              pmtct_patient_source.patientpkhash
                              AND combined_data_ct_hts_prep.sitecode =
                                  pmtct_patient_source.sitecode),
	 ushauri_patient_source_nonEMR
         AS (SELECT DISTINCT
                             ushauri.UshauriPatientPkHash,
                             ushauri.PatientIDHash,
                             ushauri.patientpk,
                             ushauri.sitecode,
                             ushauri.patienttype,
                             ushauri.patientsource,
                             Try_convert(date,ushauri.DOB) AS DOB,
                             ushauri.gender,
                             ushauri.maritalstatus,
                             ushauri.nupihash,
                             ushauri.SiteType
             FROM   [ODS].[Mhealth].[Mhealth_Ushauri_Patient] AS ushauri
                where ushauri.PatientPKHash is null and SiteCode is not null

              ) ,
            Disclosure as (
             Select 
               row_number() OVER (PARTITION BY SiteCode,PatientPKHash ORDER BY VisitDate DESC) AS NUM,
                PatientPKHash,
                Sitecode,
                PaedsDisclosure,
                PwP
              from ODS.Care.CT_PatientVisits as visits
                WHERE PwP LIKE '%|disclosure|%'
                    OR PwP LIKE 'disclosure|%'
                    OR PwP LIKE '%|disclosure'
                    OR PwP = 'disclosure'
                    or   PaedsDisclosure ='full disclosure' or PwP='Disclosure'    
                ),
                LatestDisclosure as (
                    SELECT
                    PatientPKHash,
                        SiteCode,
                    Coalesce (PaedsDisclosure, PWP) as Disclosure
                    From Disclosure
                    where NUM=1      
 ),
  combined_data_ct_hts_prep_pmtct_Ushauri
  as(
  SELECT combined_data_ct_hts_prep_pmtct.patientpkhash AS PatientPKHash,
         combined_data_ct_hts_prep_pmtct.sitecode AS SiteCode,
         combined_data_ct_hts_prep_pmtct.nupi AS NUPI,
         combined_data_ct_hts_prep_pmtct.dob AS DOB,
         combined_data_ct_hts_prep_pmtct.maritalstatus AS MaritalStatus,
         combined_data_ct_hts_prep_pmtct.gender AS Gender,
         combined_data_ct_hts_prep_pmtct.patientidhash As PatientIdhash,
		   combined_data_ct_hts_prep_pmtct.clienttype AS ClientType,
         combined_data_ct_hts_prep_pmtct.patientsource As Patientsource,
         combined_data_ct_hts_prep_pmtct.enrollmentwhokey As enrollmentwhokey,
         combined_data_ct_hts_prep_pmtct.dateenrollmentwhokey As dateenrollmentwhokey,
         combined_data_ct_hts_prep_pmtct.baselinewhokey As baselinewhokey,
         combined_data_ct_hts_prep_pmtct.datebaselinewhokey As datebaselinewhokey,
         combined_data_ct_hts_prep_pmtct.istxcurr As istxcurr,
         combined_data_ct_hts_prep_pmtct.DateConfirmedHIVPositiveKey,
         combined_data_ct_hts_prep_pmtct.EverOnART,
         combined_data_ct_hts_prep_pmtct.htsnumberhash,
         NUll As sitetype,
         LatestDisclosure.Disclosure,
         Cast(Getdate() AS DATE) AS LoadDate,
		 combined_data_ct_hts_prep_pmtct.Voided,
		 combined_data_ct_hts_prep_pmtct.PrepNumber,
		 combined_data_ct_hts_prep_pmtct.PrepEnrollmentDateKey,
		 combined_data_ct_hts_prep_pmtct.PatientMnchIDHash,
		 combined_data_ct_hts_prep_pmtct.FirstEnrollmentAtMnchDateKey
    FROM   combined_data_ct_hts_prep_pmtct
    left join LatestDisclosure on LatestDisclosure.patientpkhash=combined_data_ct_hts_prep_pmtct.patientpkhash and LatestDisclosure.sitecode=combined_data_ct_hts_prep_pmtct.sitecode

    UNION
	SELECT	concat(ushauri.UshauriPatientPKHash,'_Ushauri') AS PatientPKHash,
			Ushauri.sitecode AS SiteCode,
			UShauri.nupihash AS NUPI,
			Ushauri.dob AS DOB,
			Ushauri.maritalstatus AS MaritalStatus,
			Ushauri.gender AS Gender,
			Ushauri.patientidhash As PatientIdhash,
			Null clienttype,
			Null patientsource,
			Null enrollmentwhokey ,
			Null dateenrollmentwhokey,
			Null baselinewhokey,
			Null datebaselinewhokey,
			Null istxcurr,
			Null DateConfirmedHIVPositiveKey,
         Null EverOnART,
			Null htsnumberhash,
			sitetype,
         LatestDisclosure.Disclosure,
			Null LoadDate,
			Null Voided,
			Null PrepNumber,
			Null PrepEnrollmentDateKey,
			Null PatientMnchIDHash,
			Null FirstEnrollmentAtMnchDateKey
	FROM ushauri_patient_source_nonEMR ushauri
     left join LatestDisclosure on LatestDisclosure.patientpkhash=ushauri.UshauriPatientPKHash and LatestDisclosure.sitecode=ushauri.sitecode

	where ushauri.SiteCode is not null                
  
  )

    MERGE NDWH.[Dim].[DimPatient] AS a
    using (SELECT combined_data_ct_hts_prep_pmtct_Ushauri.patientidhash,
                  combined_data_ct_hts_prep_pmtct_Ushauri.patientpkhash,
                  combined_data_ct_hts_prep_pmtct_Ushauri.htsnumberhash,
                  combined_data_ct_hts_prep_pmtct_Ushauri.prepnumber,
                  combined_data_ct_hts_prep_pmtct_Ushauri.sitecode,
                  combined_data_ct_hts_prep_pmtct_Ushauri.nupi,
                  combined_data_ct_hts_prep_pmtct_Ushauri.dob,
                  combined_data_ct_hts_prep_pmtct_Ushauri.maritalstatus,
                  CASE
                    WHEN combined_data_ct_hts_prep_pmtct_Ushauri.gender = 'M' THEN
                    'Male'
                    WHEN combined_data_ct_hts_prep_pmtct_Ushauri.gender = 'F' THEN
                    'Female'
                    ELSE combined_data_ct_hts_prep_pmtct_Ushauri.gender
                  END AS Gender,
                  combined_data_ct_hts_prep_pmtct_Ushauri.clienttype,
                  combined_data_ct_hts_prep_pmtct_Ushauri.patientsource,
                  combined_data_ct_hts_prep_pmtct_Ushauri.enrollmentwhokey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.datebaselinewhokey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.baselinewhokey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.prepenrollmentdatekey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.istxcurr,
                  combined_data_ct_hts_prep_pmtct_Ushauri.DateConfirmedHIVPositiveKey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.EverOnART,
				      combined_data_ct_hts_prep_pmtct_Ushauri.Disclosure,
                  combined_data_ct_hts_prep_pmtct_Ushauri.patientmnchidhash,
                  combined_data_ct_hts_prep_pmtct_Ushauri.firstenrollmentatmnchdatekey,
                  combined_data_ct_hts_prep_pmtct_Ushauri.loaddate,
				  combined_data_ct_hts_prep_pmtct_Ushauri.voided
           FROM   combined_data_ct_hts_prep_pmtct_Ushauri) AS b
    ON ( a.sitecode = b.sitecode
         AND a.patientpkhash = b.patientpkhash

        )
    WHEN NOT matched THEN
      INSERT(patientidhash,
             patientpkhash,
             htsnumberhash,
             prepnumber,
             sitecode,
             nupi,
             dob,
             maritalstatus,
             gender,
             clienttype,
             patientsource,
             enrollmentwhokey,
             datebaselinewhokey,
             baselinewhokey,
			    PrepEnrollmentDateKey,
             istxcurr,
             DateConfirmedHIVPositiveKey,
             EverOnART,
			    disclosure,
             loaddate,
			 voided)
      VALUES(patientidhash,
             patientpkhash,
             htsnumberhash,
             prepnumber,
             sitecode,
             nupi,
             dob,
             maritalstatus,
             gender,
             clienttype,
             patientsource,
             enrollmentwhokey,
             datebaselinewhokey,
             baselinewhokey,
             PrepEnrollmentDateKey,
             istxcurr,
             DateConfirmedHIVPositiveKey,
             EverOnART,
			    disclosure,
             loaddate,
			 voided)
    WHEN matched THEN
      UPDATE SET a.maritalstatus = b.maritalstatus,
                 a.clienttype		= b.clienttype,
                 a.patientsource	= b.patientsource,
				 a.patientidhash   = b.patientidhash,
                 a.nupi				= b.nupi,
                 a.dob				= b.dob,
                 a.gender			= b.gender,
                 a.prepnumber		= b.prepnumber,
				 a.IsTXCurr          = b.IsTXCurr,
				 a.enrollmentwhokey  =b.enrollmentwhokey,
				 a.baselinewhokey  = b.baselinewhokey,
				 a.PrepEnrollmentDateKey = b.PrepEnrollmentDateKey,
				 a.voided				= b.voided,
				 a.DateConfirmedHIVPositiveKey = b.DateConfirmedHIVPositiveKey,
             a.EverOnART = b.EverOnART,
				 a.Disclosure = b.Disclosure;
END