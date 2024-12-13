;
WITH Src_PatientConcat AS
(
	SELECT  DISTINCT p.Sitecode
		,P.PatientPK
		,CONCAT(p.Sitecode,P.PatientPK) AS PatientConcatColumn
	FROM [MNCHCentral].[dbo].[MnchPatients] P (nolock)
	INNER JOIN
	(
		SELECT  tn.PatientPK
			,tn.SiteCode
			,MAX(tn.DateExtracted)MaxDateExtracted
		FROM [MNCHCentral].[dbo].[MnchPatients]
		(NoLock
		)tn
		GROUP BY  tn.PatientPK, tn.SiteCode
	)tm
	ON P.PatientPk = tm.PatientPk AND p.SiteCode = tm.SiteCode AND p.DateExtracted = tm.MaxDateExtracted
	INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id
), ODS_PatientConcat AS
(
	SELECT  SiteCode
		,PatientPK
		,CONCAT(SiteCode,PatientPK) AS ODSPatient
	FROM [ODS].[MNCH].[Mnch_Patient]
) UPDATE [ODS].[MNCH].[mnch_Patient]

SET VOIDED = 1
FROM [ODS].[MNCH].[mnch_Patient] a
INNER JOIN ODS_PatientConcat b
ON a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.ODSPatient NOT IN ( SELECT PatientConcatColumn FROM Src_PatientConcat); 