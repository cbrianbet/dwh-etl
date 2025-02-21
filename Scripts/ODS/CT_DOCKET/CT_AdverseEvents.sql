BEGIN ;

DECLARE @MaxAdverseEventStartDate DATETIME,
        @AdverseEventStartDate    DATETIME,
        @MaxCreatedDate           DATETIME

SELECT @MaxAdverseEventStartDate = Max(maxadverseeventstartdate)
FROM  [ODS_logs].[dbo].[CT_AdverseEvent_Log] (nolock);

SELECT @AdverseEventStartDate = Max(adverseeventstartdate)
FROM   [DWAPICentral].[dbo].[patientadverseeventextract] WITH (nolock);

SELECT @MaxCreatedDate = Max(createddate)
FROM   [ODS_Logs].[dbo].[ct_adverseeventcount_log] WITH (nolock);

INSERT INTO[ODS_logs].[dbo].[CT_AdverseEvent_Log]
            (maxadverseeventstartdate,
                loadstartdatetime)
VALUES     (@AdverseEventStartDate,
            Getdate());

MERGE [ODS].[Care].[ct_adverseevents] AS a
using(SELECT DISTINCT P.[patientcccnumber] AS PatientID,
                        P.[patientpid]       AS PatientPK,
                        F.NAME               AS FacilityName,
                        F.code               AS SiteCode,
                        PA.[adverseevent],
                        [adverseeventstartdate],
                        [adverseeventenddate],
                        CASE [severity]
                        WHEN '1' THEN 'Mild'
                        WHEN '2' THEN 'Moderate'
                        WHEN '3' THEN 'Severe'
                        ELSE [severity]
                        END                  AS [Severity],
                        PA.[visitdate],
                        PA.[emr],
                        PA.[project],
                        [adverseeventcause],
                        [adverseeventregimen],
                        [adverseeventactiontaken],
                        [adverseeventclinicaloutcome],
                        [adverseeventispregnant],
                        PA.id,
                        PA.[date_created],
                        PA.[date_last_modified],
                        PA.recorduuid,
                        PA.voided,
			VoidingSource = Case
						when PA.voided = 1 Then 'Source'
						Else Null
					END
        FROM   [DWAPICentral].[dbo].[patientextract](nolock) P
                INNER JOIN [DWAPICentral].[dbo].patientadverseeventextract(nolock) PA
                    ON PA.[patientid] = P.id
                INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F
                    ON P.[facilityid] = F.id AND F.voided = 0 AND F.code > 0
				INNER JOIN ( SELECT	F.code as SiteCode
										,p.[PatientPID] as PatientPK
										,VisitDate
										,InnerPA.AdverseEvent
										,InnerPA.voided
										,max(InnerPA.ID) As Max_ID
										,MAX(cast(InnerPA.created as date)) AS Maxdatecreated
								FROM   [DWAPICentral].[dbo].[patientextract](nolock) P
									INNER JOIN [DWAPICentral].[dbo].patientadverseeventextract(nolock) InnerPA
										ON InnerPA.[patientid] = P.id AND InnerPA.voided = 0
									INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F
										ON P.[facilityid] = F.id AND F.voided = 0
								GROUP BY F.code
										,p.[PatientPID]
										,InnerPA.AdverseEvent
										,VisitDate
										,InnerPA.voided
							) tm
				ON	f.code = tm.[SiteCode] and
					p.PatientPID=tm.PatientPK and
					PA.VisitDate = tm.VisitDate and
					cast(PA.created as date) = tm.Maxdatecreated and
					PA.ID = tm.Max_ID


	) AS b
ON(	 a.sitecode = b.sitecode AND
     a.patientpk = b.patientpk AND
	 a.AdverseEvent = b.AdverseEvent AND
     a.visitdate = b.visitdate AND
     a.voided = b.voided
	)
WHEN NOT matched THEN
    INSERT(patientid,
            patientpk,
            sitecode,
            adverseevent,
            adverseeventstartdate,
            adverseeventenddate,
            severity,
            visitdate,
            emr,
            project,
            adverseeventcause,
            adverseeventregimen,
            adverseeventactiontaken,
            adverseeventclinicaloutcome,
            adverseeventispregnant,
            [date_created],
            [date_last_modified],
            recorduuid,
            voided,
	    VoidingSource,
            loaddate)
    VALUES(patientid,
            patientpk,
            sitecode,
            adverseevent,
            adverseeventstartdate,
            adverseeventenddate,
            severity,
            visitdate,
            emr,
            project,
            adverseeventcause,
            adverseeventregimen,
            adverseeventactiontaken,
            adverseeventclinicaloutcome,
            adverseeventispregnant,
            [date_created],
            [date_last_modified],
            recorduuid,
            voided,
	    VoidingSource,
            Getdate())
WHEN matched THEN
    UPDATE SET a.[patientid] = b.[patientid],
                a.[adverseevent] = b.[adverseevent],
                a.[adverseeventstartdate] = b.[adverseeventstartdate],
                a.[adverseeventenddate] = b.[adverseeventenddate],
                a.[severity] = b.[severity],
                a.[visitdate] = b.[visitdate],
                a.[adverseeventcause] = b.[adverseeventcause],
                a.[adverseeventregimen] = b.[adverseeventregimen],
                a.[adverseeventactiontaken] = b.[adverseeventactiontaken],
                a.[adverseeventclinicaloutcome] =
                b.[adverseeventclinicaloutcome],
                a.[adverseeventispregnant] = b.[adverseeventispregnant],
                a.[facilityname] = b.[facilityname],
                a.[date_last_modified] = b.[date_last_modified],
                a.[date_created] = b.[date_created],
                a.[recorduuid] = b.[recorduuid],
                a.[voided] = b.[voided];

--------------------------------------------------------End
UPDATE[ODS_logs].[dbo].[CT_AdverseEvent_Log]
SET    loadenddatetime = Getdate()
WHERE  maxadverseeventstartdate = @AdverseEventStartDate;



END
