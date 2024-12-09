update IIT 
	set PatientPKHash = p.PatientPKHash,
		IIT.PatientIDHash = p.PatientIDHash
	from [ODS].[Care].[CT_IITRiskScores]   IIT 
	JOIN ODS.Care.CT_Patient p
	on IIT .SiteCode = p.SiteCode and IIT .PatientPK = p.PatientPK
	WHERE IIT.PatientPKHash IS NULL OR IIT.PatientIDHash IS NULL;