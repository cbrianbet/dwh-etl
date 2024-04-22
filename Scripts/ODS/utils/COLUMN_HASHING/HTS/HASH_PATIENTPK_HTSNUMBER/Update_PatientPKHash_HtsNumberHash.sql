	update ODS.dbo.HTS_clients 
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2)
			WHERE  PatientPKHash IS NULL OR HTSNumberHash IS NULL;


	update cl
		set cl.PatientPKHash = c.PatientPKHash,
			cl.HTSNumberHash =c.HTSNumberHash
	from ODS.dbo.HTS_ClientLinkages cl
		inner join ODS.dbo.HTS_clients c
		on cl.SiteCode = c.sitecode and cl.PatientPk =c.PatientPk
		WHERE  CL.PatientPKHash IS NULL OR CL.HTSNumberHash IS NULL;

	update ct
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_ClientTests    ct
		JOIN ODS.dbo.HTS_clients  c
		on ct.SiteCode = c.SiteCode and ct.PatientPK = c.PatientPK
		WHERE  ct.PatientPKHash IS NULL;

	update ct
	set PatientPKHash = c.PatientPKHash,
	   CT.HTSNumberHash = C.HTSNumberHash
	from ODS.dbo.HTS_ClientTracing   ct
	JOIN ODS.dbo.HTS_clients  c
	on ct.SiteCode = c.SiteCode and ct.PatientPK = c.PatientPK
	WHERE  ct.PatientPKHash IS NULL OR ct.HTSNumberHash IS NULL;

	update n
		set PatientPKHash = c.PatientPKHash,
			N.HTSNumberHash = C.HTSNumberHash
	from ODS.dbo.HTS_PartnerNotificationServices     n
		JOIN ODS.dbo.HTS_clients  c
		on n.SiteCode = c.SiteCode and n.PatientPK = c.PatientPK
		WHERE  n.PatientPKHash IS NULL OR n.HTSNumberHash IS NULL;

	  	update [ODS].[dbo].[Hts_PartnerNotificationServices] 
		set IndexPatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(IndexPatientPk  as nvarchar(36))), 2)			
			WHERE  IndexPatientPkHash IS NULL ;

	update PT
	set PatientPKHash = c.PatientPKHash,
		PT.HTSNumberHash = C.HTSNumberHash
	from ODS.dbo.HTS_PartnerTracings     PT
	JOIN ODS.dbo.HTS_clients  c
	on PT.SiteCode = c.SiteCode and PT.PatientPK = c.PatientPK
	WHERE  PT.PatientPKHash IS NULL OR PT.HTSNumberHash IS NULL;


	update tk
		set PatientPKHash = c.PatientPKHash,
			tk.HTSNumberHash = C.HTSNumberHash
	from  ODS.dbo.HTS_TestKits    tk
	JOIN ODS.dbo.HTS_clients  c
	on tk.SiteCode = c.SiteCode and tk.PatientPK = c.PatientPK
	WHERE  tk.PatientPKHash IS NULL OR tk.HTSNumberHash IS NULL;

	update Elg
		set PatientPKHash = c.PatientPKHash,
			Elg.HTSNumberHash = C.HTSNumberHash
	from ODS.dbo.HTS_EligibilityExtract      Elg
		JOIN ODS.dbo.HTS_clients  c
		on Elg.SiteCode = c.SiteCode and Elg.PatientPK = c.PatientPK
		WHERE  Elg.PatientPKHash IS NULL OR Elg.HTSNumberHash IS NULL;

