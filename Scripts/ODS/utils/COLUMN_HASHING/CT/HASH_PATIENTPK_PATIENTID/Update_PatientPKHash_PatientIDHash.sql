	update ODS.dbo.CT_Patient 
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)
	FROM ODS.dbo.CT_Patient
	WHERE PatientPKHash IS NULL OR PatientIDHash IS NULL;


	update PB
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientBaselines  PB
		JOIN ODS.dbo.CT_Patient p
	on PB.SiteCode = p.SiteCode and PB.PatientPK = p.PatientPK
	WHERE PB.PatientPKHash IS NULL OR PB.PatientIDHash IS NULL;

	update AC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_AllergiesChronicIllness  AC
		JOIN ODS.dbo.CT_Patient p
	on AC.SiteCode = p.SiteCode and AC.PatientPK = p.PatientPK
	WHERE AC.PatientPKHash IS NULL OR AC.PatientIDHash IS NULL;


	update ARTP
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_ARTPatients   ARTP
		JOIN ODS.dbo.CT_Patient p
	on ARTP.SiteCode = p.SiteCode and ARTP.PatientPK = p.PatientPK
	WHERE ARTP.PatientPKHash IS NULL OR ARTP.PatientIDHash IS NULL;


	update CL
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_ContactListing    CL
		JOIN ODS.dbo.CT_Patient p
	on CL.SiteCode = p.SiteCode and CL.PatientPK = p.PatientPK
	WHERE CL.PatientPKHash IS NULL OR CL.PatientIDHash IS NULL;

	update EAC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_EnhancedAdherenceCounselling     EAC
		JOIN ODS.dbo.CT_Patient p
	on EAC.SiteCode = p.SiteCode and EAC.PatientPK = p.PatientPK
	WHERE EAC.PatientPKHash IS NULL OR EAC.PatientIDHash IS NULL;


		update Otz 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Otz     Otz 
		JOIN ODS.dbo.CT_Patient p
	on Otz .SiteCode = p.SiteCode and Otz.PatientPK = p.PatientPK
	WHERE Otz.PatientPKHash IS NULL OR Otz.PatientIDHash IS NULL;

	update Ovc 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ovc     Ovc 
		JOIN ODS.dbo.CT_Patient p
	on Ovc .SiteCode = p.SiteCode and Ovc.PatientPK = p.PatientPK
	WHERE Ovc.PatientPKHash IS NULL OR Ovc.PatientIDHash IS NULL;

	update DT 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DefaulterTracing      DT 
		JOIN ODS.dbo.CT_Patient p
	on DT .SiteCode = p.SiteCode and DT.PatientPK = p.PatientPK
	WHERE DT.PatientPKHash IS NULL OR DT.PatientIDHash IS NULL;

	update PS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_PatientStatus   PS 
		JOIN ODS.dbo.CT_Patient p
	on PS .SiteCode = p.SiteCode and PS.PatientPK = p.PatientPK
	WHERE PS.PatientPKHash IS NULL OR PS.PatientIDHash IS NULL;

	update AE 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_AdverseEvents   AE 
		JOIN ODS.dbo.CT_Patient p
	on AE .SiteCode = p.SiteCode and AE.PatientPK = p.PatientPK
	WHERE AE.PatientPKHash IS NULL OR AE.PatientIDHash IS NULL;

	update DS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DepressionScreening    DS 
		JOIN ODS.dbo.CT_Patient p
	on DS .SiteCode = p.SiteCode and DS.PatientPK = p.PatientPK
	WHERE DS.PatientPKHash IS NULL OR DS.PatientIDHash IS NULL;


	update DAS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DrugAlcoholScreening   DAS 
		JOIN ODS.dbo.CT_Patient p
	on DAS.SiteCode = p.SiteCode and DAS.PatientPK = p.PatientPK
	WHERE DAS.PatientPKHash IS NULL OR DAS.PatientIDHash IS NULL;

	update GbvS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_GbvScreening  GbvS
		JOIN ODS.dbo.CT_Patient p
	on GbvS.SiteCode = p.SiteCode and GbvS.PatientPK = p.PatientPK
	WHERE GbvS.PatientPKHash IS NULL OR GbvS.PatientIDHash IS NULL;

	update C 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_Covid   C
		JOIN ODS.dbo.CT_Patient p
	on C.SiteCode = p.SiteCode and C.PatientPK = p.PatientPK
	WHERE C.PatientPKHash IS NULL OR C.PatientIDHash IS NULL;

	update v
		set PatientPKHash = p.PatientPKHash,
			V.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientVisits  v
	JOIN ODS.dbo.CT_Patient p
		on v.SiteCode = p.SiteCode and v.PatientPK = p.PatientPK
		WHERE V.PatientPKHash IS NULL OR V.PatientIDHash IS NULL;

	update Ipt
		set PatientPKHash = p.PatientPKHash,
			Ipt.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ipt  Ipt
	JOIN ODS.dbo.CT_Patient p
		on Ipt.SiteCode = p.SiteCode and Ipt.PatientPK = p.PatientPK
	WHERE Ipt.PatientPKHash IS NULL OR Ipt.PatientIDHash IS NULL;

		update Phar 
		set PatientPKHash = p.PatientPKHash,
		    Phar.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientPharmacy   Phar
	JOIN ODS.dbo.CT_Patient p
	on Phar .SiteCode = p.SiteCode and Phar .PatientPK = p.PatientPK
	WHERE Phar.PatientPKHash IS NULL OR Phar.PatientIDHash IS NULL;

	update Labs 
		set PatientPKHash = p.PatientPKHash,
			Labs.PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientLabs   Labs 
		JOIN ODS.dbo.CT_Patient p
		on Labs .SiteCode = p.SiteCode and Labs .PatientPK = p.PatientPK
		WHERE Labs.PatientPKHash IS NULL OR Labs.PatientIDHash IS NULL;

	update ccs 
		set PatientPKHash = p.PatientPKHash,
			ccs.PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_CervicalCancerScreening]   ccs 
		JOIN ODS.dbo.CT_Patient p
		on ccs .SiteCode = p.SiteCode and ccs .PatientPK = p.PatientPK
		WHERE ccs.PatientPKHash IS NULL OR ccs.PatientIDHash IS NULL;

	update Ovc
		set CPIMSUniqueIdentifierHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Ovc.CPIMSUniqueIdentifier  as nvarchar(36))), 2)
	from [ODS].[dbo].[CT_Ovc]  Ovc		
	WHERE Ovc.CPIMSUniqueIdentifierHash IS NULL;


	update IIT 
	set PatientPKHash = p.PatientPKHash,
		IIT.PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_IITRiskScores]   IIT 
	JOIN ODS.dbo.CT_Patient p
	on IIT .SiteCode = p.SiteCode and IIT .PatientPK = p.PatientPK
	WHERE IIT.PatientPKHash IS NULL OR IIT.PatientIDHash IS NULL;


		update CS
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_CancerScreening]  CS
		JOIN ODS.dbo.CT_Patient p
	on CS.SiteCode = p.SiteCode and CS.PatientPK = p.PatientPK
	WHERE CS.PatientPKHash IS NULL OR CS.PatientIDHash IS NULL;

	
  	update ArtFastTrack
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_ArtFastTrack]  ArtFastTrack
		JOIN ODS.dbo.CT_Patient p
	on ArtFastTrack.SiteCode = p.SiteCode and ArtFastTrack.PatientPK = p.PatientPK
	WHERE ArtFastTrack.PatientPKHash IS NULL OR ArtFastTrack.PatientIDHash IS NULL;

	










