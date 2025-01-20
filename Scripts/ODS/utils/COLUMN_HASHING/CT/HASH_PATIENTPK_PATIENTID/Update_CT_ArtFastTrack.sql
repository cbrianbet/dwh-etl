update ArtFastTrack
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from [ODS].Care.[CT_ArtFastTrack]  ArtFastTrack
		JOIN ODS.Care.CT_Patient p
	on ArtFastTrack.SiteCode = p.SiteCode and ArtFastTrack.PatientPK = p.PatientPK
	WHERE ArtFastTrack.PatientPKHash IS NULL OR ArtFastTrack.PatientIDHash IS NULL;