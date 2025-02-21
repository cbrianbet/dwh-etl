	update ODS.HTS.HTS_clients 
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
			WHERE  PatientPKHash IS NULL OR HTSNumberHash IS NULL;


	update cl
			set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from ODS.HTS.HTS_ClientLinkages cl
		WHERE  CL.PatientPKHash IS NULL OR CL.HTSNumberHash IS NULL;

	update ct
			set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
	from ODS.HTS.HTS_ClientTests    ct
		WHERE  ct.PatientPKHash IS NULL;

	update ct
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from ODS.HTS.HTS_ClientTracing   ct
	WHERE  ct.PatientPKHash IS NULL OR ct.HTSNumberHash IS NULL;

	update n
			set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from ODS.HTS.HTS_PartnerNotificationServices     n
		WHERE  n.PatientPKHash IS NULL OR n.HTSNumberHash IS NULL;

	  	update [ODS].[HTS].[Hts_PartnerNotificationServices] 
		set IndexPatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(IndexPatientPk  as nvarchar(36))), 2)			
			WHERE  IndexPatientPkHash IS NULL ;

	update PT
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from ODS.HTS.HTS_PartnerTracings     PT
	WHERE  PT.PatientPKHash IS NULL OR PT.HTSNumberHash IS NULL;


	update tk
			set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from  ODS.HTS.HTS_TestKits    tk
	WHERE  tk.PatientPKHash IS NULL OR tk.HTSNumberHash IS NULL;

	update Elg
			set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
	from ODS.HTS.HTS_EligibilityExtract      Elg
		WHERE  Elg.PatientPKHash IS NULL OR Elg.HTSNumberHash IS NULL;



