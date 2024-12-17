update ODS.PrEP.PrEP_Patient 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PrepNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PrepNumber  as nvarchar(36))), 2)
		 WHERE PatientPKHash IS NULL OR PrepNumberHash IS NULL;;

  Update Lab
  set Lab.PatientPKHash= P.PatientPKHash,
      Lab.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_Lab  Lab
  inner join ODS.PrEP.PrEP_Patient  P
  on Lab.SiteCode = p.SiteCode and Lab.PatientPk = P.PatientPk
   WHERE Lab.PatientPKHash IS NULL OR Lab.PrepNumberHash IS NULL;;

  Update AE
  set AE.PatientPKHash= P.PatientPKHash,
      AE.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_AdverseEvent  AE
  inner join ODS.PrEP.PrEP_Patient  P
  on AE.SiteCode = p.SiteCode and AE.PatientPk = P.PatientPk
   WHERE AE.PatientPKHash IS NULL OR AE.PrepNumberHash IS NULL;;

	  Update CT
  set CT.PatientPKHash= P.PatientPKHash,
      CT.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_CareTermination  CT
  inner join ODS.PrEP.PrEP_Patient  P
  on CT.SiteCode = p.SiteCode and CT.PatientPk = P.PatientPk
   WHERE CT.PatientPKHash IS NULL OR CT.PrepNumberHash IS NULL;;


		  Update V
  set V.PatientPKHash= P.PatientPKHash,
      V.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_Visits  V
  inner join ODS.PrEP.PrEP_Patient  P
  on V.SiteCode = p.SiteCode and V.PatientPk = P.PatientPk
   WHERE V.PatientPKHash IS NULL OR V.PrepNumberHash IS NULL;;

	Update BR
  set BR.PatientPKHash= P.PatientPKHash,
      BR.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_BehaviourRisk   BR
  inner join ODS.PrEP.PrEP_Patient  P
  on BR.SiteCode = p.SiteCode and BR.PatientPk = P.PatientPk
   WHERE BR.PatientPKHash IS NULL OR BR.PrepNumberHash IS NULL;


	Update Phar
  set Phar.PatientPKHash= P.PatientPKHash,
      Phar.PrepNumberHash = P.PrepNumberHash
  from ODS.PrEP.PrEP_Pharmacy    Phar
  inner join ODS.PrEP.PrEP_Patient  P
  on Phar.SiteCode = p.SiteCode and Phar.PatientPk = P.PatientPk
  WHERE Phar.PatientPKHash IS NULL OR Phar.PrepNumberHash IS NULL;
