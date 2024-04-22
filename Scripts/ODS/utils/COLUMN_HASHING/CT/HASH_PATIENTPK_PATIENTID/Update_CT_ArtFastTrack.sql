update ArtFastTrack
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].[dbo].[CT_ArtFastTrack]  ArtFastTrack
		JOIN ODS.dbo.CT_Patient p
	on ArtFastTrack.SiteCode = p.SiteCode and ArtFastTrack.PatientPK = p.PatientPK
	WHERE ArtFastTrack.PatientPKHash IS NULL OR ArtFastTrack.PatientIDHash IS NULL;