update ODS.dbo.MNCH_Patient 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientMnchIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientMnchID  as nvarchar(36))), 2);

	
  UPDATE AV
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM  ODS.dbo.MNCH_AncVisits  AV
  join ODS.dbo.MNCH_Patient p  on Av.SiteCode = P.SiteCode and Av.PatientPk = p.PatientPk
  where AV.PatientPKHash is null or AV.PatientMnchIDHash is null;


	  UPDATE E
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM  ODS.dbo.MNCH_Enrolments  E
  join ODS.dbo.MNCH_Patient p  on E.SiteCode = P.SiteCode and E.PatientPk = p.PatientPk
  where E.PatientPKHash is null or E.PatientMnchIDHash is null;

		  UPDATE HEIs
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM  ODS.dbo.MNCH_HEIs   HEIs
  join ODS.dbo.MNCH_Patient p  on HEIs.SiteCode = P.SiteCode and HEIs.PatientPk = p.PatientPk
  where HEIs.PatientPKHash is null or HEIs.PatientMnchIDHash is null;

  --Heis orphan records
  update ODS.dbo.MNCH_HEIs
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
	where PatientPKHash is null;



			  UPDATE MV
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM  ODS.dbo.MNCH_MatVisits    MV
  join ODS.dbo.MNCH_Patient p  on MV.SiteCode = P.SiteCode and MV.PatientPk = p.PatientPk
  where MV.PatientPKHash is null or MV.PatientMnchIDHash is null;


	 UPDATE Labs
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM ODS.dbo.MNCH_Labs    Labs
  join ODS.dbo.MNCH_Patient p  on Labs.SiteCode = P.SiteCode and Labs.PatientPk = p.PatientPk
  where Labs.PatientPKHash is null or Labs.PatientMnchIDHash is null;

UPDATE Arts
  SET PatientPKHash =p.PatientPKHash,
      PatientMnchIDHash = p.PatientMnchIDHash
  FROM ODS.dbo.MNCH_Arts    Arts
  join ODS.dbo.MNCH_Patient p  on Arts.SiteCode = P.SiteCode and Arts.PatientPk = p.PatientPk
  where Arts.PatientPKHash is null or Arts.PatientMnchIDHash is null;


	UPDATE CwcEnrolments
  SET PatientPKHash =p.PatientPKHash
  FROM ODS.dbo.MNCH_CwcEnrolments     CwcEnrolments
  join ODS.dbo.MNCH_Patient p  on CwcEnrolments.SiteCode = P.SiteCode and CwcEnrolments.PatientPk = p.PatientPk
  where CwcEnrolments.PatientPKHash is null ;

 UPDATE CwcVisits
  SET PatientPKHash =p.PatientPKHash,
	  PatientMnchIDHash = p.PatientMnchIDHash
  FROM ODS.dbo.MNCH_CwcVisits     CwcVisits
  join ODS.dbo.MNCH_Patient p  on CwcVisits.SiteCode = P.SiteCode and CwcVisits.PatientPk = p.PatientPk
  where CwcVisits.PatientPKHash is null or CwcVisits.PatientMnchIDHash is null;

	 UPDATE Enrolments
  SET PatientPKHash =p.PatientPKHash,
	  PatientMnchIDHash = p.PatientMnchIDHash
  FROM ODS.dbo.MNCH_Enrolments     Enrolments
  join ODS.dbo.MNCH_Patient p  on Enrolments.SiteCode = P.SiteCode and Enrolments.PatientPk = p.PatientPk
  where Enrolments.PatientPKHash is null or Enrolments.PatientMnchIDHash is null;

		 UPDATE PncVisits
  SET PatientPKHash =p.PatientPKHash,
	  PatientMnchIDHash = p.PatientMnchIDHash
  FROM ODS.dbo.MNCH_PncVisits     PncVisits
  join ODS.dbo.MNCH_Patient p  on PncVisits.SiteCode = P.SiteCode and PncVisits.PatientPk = p.PatientPk
  where PncVisits.PatientPKHash is null or PncVisits.PatientMnchIDHash is null;


  

