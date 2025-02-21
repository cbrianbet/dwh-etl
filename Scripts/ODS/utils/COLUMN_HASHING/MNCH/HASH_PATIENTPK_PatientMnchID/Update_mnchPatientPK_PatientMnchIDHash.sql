update ODS.MNCH.MNCH_Patient 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
        WHERE PatientPKHash IS NULL OR PatientMnchIDHash IS NULL;

	
  UPDATE AV
 	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM  ODS.MNCH.MNCH_AncVisits  AV
  where AV.PatientPKHash is null or AV.PatientMnchIDHash is null;


	  UPDATE E
 set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM  ODS.MNCH.MNCH_Enrolments  E
  where E.PatientPKHash is null or E.PatientMnchIDHash is null;

UPDATE HEIs
 set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM  ODS.MNCH.MNCH_HEIs   HEIs
  where HEIs.PatientPKHash is null or HEIs.PatientMnchIDHash is null;

  --Heis orphan records
  update ODS.MNCH.MNCH_HEIs
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
	where PatientPKHash is null;



			  UPDATE MV
  set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM  ODS.MNCH.MNCH_MatVisits    MV
  where MV.PatientPKHash is null or MV.PatientMnchIDHash is null;


	 UPDATE Labs
  set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnch_ID  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_Labs    Labs
  where Labs.PatientPKHash is null or Labs.PatientMnchIDHash is null;

UPDATE Arts
  set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_Arts    Arts
  where Arts.PatientPKHash is null or Arts.PatientMnchIDHash is null;


	UPDATE CwcEnrolments
 set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_CwcEnrolments     CwcEnrolments
  where CwcEnrolments.PatientPKHash is null ;

 UPDATE CwcVisits
 set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_CwcVisits     CwcVisits
  where CwcVisits.PatientPKHash is null or CwcVisits.PatientMnchIDHash is null;

	 UPDATE Enrolments
  set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_Enrolments     Enrolments
  where Enrolments.PatientPKHash is null or Enrolments.PatientMnchIDHash is null;

		 UPDATE PncVisits
  set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2)
  FROM ODS.MNCH.MNCH_PncVisits     PncVisits
  where PncVisits.PatientPKHash is null or PncVisits.PatientMnchIDHash is null;


  

