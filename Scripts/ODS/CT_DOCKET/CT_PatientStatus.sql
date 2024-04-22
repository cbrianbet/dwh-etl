BEGIN;
WITH cte AS (
  SELECT 
    DISTINCT P.patientpid, 
    PS.patientid, 
    F.code, 
    PS.exitdate, 
    PS.exitreason, 
    p.lastvisit, 
    Row_number() OVER (
      partition BY P.patientpid, 
      PS.patientid, 
      F.code, 
      PS.exitdate, 
      PS.exitreason, 
      p.lastvisit 
      ORDER BY 
        PS.exitdate DESC
    ) Row_Num 
  FROM 
    [DWAPICentral].[dbo].[patientextract] P WITH (nolock) 
    INNER JOIN [DWAPICentral].[dbo].[patientstatusextract]PS WITH (nolock) ON PS.[patientid] = P.id 
    AND PS.voided = 0 
    INNER JOIN [DWAPICentral].[dbo].[facility] F (nolock) ON P.[facilityid] = F.id 
    AND F.voided = 0 
    INNER JOIN (
      SELECT 
        P.patientpid, 
        F.code, 
        exitdate, 
        Max(Ps.created) MaxCreated 
      FROM 
        [DWAPICentral].[dbo].[patientextract] P WITH (nolock) 
        INNER JOIN [DWAPICentral].[dbo].[patientstatusextract]PS WITH (nolock) ON PS.[patientid] = P.id 
        AND PS.voided = 0 
        INNER JOIN [DWAPICentral].[dbo].[facility] F (nolock) ON P.[facilityid] = F.id 
        AND F.voided = 0 
      GROUP BY 
        P.patientpid, 
        F.code, 
        exitdate
    ) tn ON P.patientpid = tn.patientpid 
    AND f.code = tn.code 
    AND PS.exitdate = tn.exitdate 
    AND PS.created = tn.maxcreated 
  WHERE 
    p.gender != 'Unknown'
) DELETE pv 
FROM 
  [DWAPICentral].[dbo].[patientstatusextract] (nolock) PV 
  INNER JOIN [DWAPICentral].[dbo].[patientextract](nolock) P ON PV.[patientid] = P.id 
  AND PV.voided = 0 
  INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F ON P.[facilityid] = F.id 
  AND F.voided = 0 
  INNER JOIN cte ON PV.patientid = cte.patientid 
  AND cte.exitdate = PV.exitdate 
  AND cte.code = f.code 
  AND cte.exitreason = PV.exitreason 
WHERE 
  Row_Num > 1;
DECLARE @MaxExitDate_Hist DATETIME, 
@ExitDate DATETIME 
SELECT 
  @MaxExitDate_Hist = Max(maxexitdate) 
FROM 
  [ODS_logs].[dbo].[CT_patientStatus_Log] (nolock);
SELECT 
  @ExitDate = Max(exitdate) 
FROM 
  [DWAPICentral].[dbo].[patientstatusextract] WITH (nolock);
INSERT INTO [ODS_logs].[dbo].[CT_patientStatus_Log] (maxexitdate, loadstartdatetime) 
VALUES 
  (
    @ExitDate, 
    Getdate()
  );
---- Refresh [ODS].[dbo].[CT_PatientStatus]
MERGE [ODS].[dbo].[ct_patientstatus] AS a using(
  SELECT 
    DISTINCT P.[patientcccnumber] AS PatientID, 
    P.[patientpid] AS PatientPK, 
    F.NAME AS FacilityName, 
    F.code AS SiteCode, 
    PS.[exitdescription] ExitDescription, 
    PS.[exitdate] ExitDate, 
    PS.[exitreason] ExitReason, 
    P.[emr] Emr, 
    CASE P.[project] WHEN 'I-TECH' THEN 'Kenya HMIS II' WHEN 'HMIS' THEN 'Kenya HMIS II' ELSE P.[project] END AS [Project], 
    PS.[voided] Voided, 
    PS.[processed] Processed, 
    PS.[created] Created, 
    [reasonfordeath], 
    [specificdeathreason], 
    Cast([deathdate] AS DATE) [DeathDate], 
    effectivediscontinuationdate, 
    PS.toverified TOVerified, 
    PS.toverifieddate TOVerifiedDate, 
    PS.reenrollmentdate ReEnrollmentDate, 
    PS.[date_created], 
    PS.[date_last_modified], 
    PS.[recorduuid] 
  FROM 
    [DWAPICentral].[dbo].[patientextract] P WITH (nolock) 
    INNER JOIN [DWAPICentral].[dbo].[patientstatusextract]PS WITH (nolock) ON PS.[patientid] = P.id 
    INNER JOIN [DWAPICentral].[dbo].[facility] F (nolock) ON P.[facilityid] = F.id 
    AND F.voided = 0 
    INNER JOIN (
      SELECT 
        P.patientpid, 
        F.code, 
        exitdate, 
        ps.voided, 
        max(PS.ID) As Max_ID, 
        Max(
          Cast(Ps.created AS DATE)
        ) MaxCreated 
      FROM 
        [DWAPICentral].[dbo].[patientextract] P WITH (nolock) 
        INNER JOIN [DWAPICentral].[dbo].[patientstatusextract]PS WITH (nolock) ON PS.[patientid] = P.id 
        INNER JOIN [DWAPICentral].[dbo].[facility] F (nolock) ON P.[facilityid] = F.id 
        AND F.voided = 0 
      GROUP BY 
        P.patientpid, 
        F.code, 
        exitdate, 
        ps.voided
    ) tn ON P.patientpid = tn.patientpid 
    AND f.code = tn.code 
    AND PS.exitdate = tn.exitdate 
    AND Cast(PS.created AS DATE) = tn.maxcreated 
    and PS.ID = tn.Max_ID 
  WHERE 
    p.gender != 'Unknown' 
    AND F.code > 0
) AS b ON(
  a.patientpk = b.patientpk 
  AND a.sitecode = b.sitecode 
  AND a.exitdate = b.exitdate 
  AND a.exitreason = b.exitreason 
  AND a.voided = b.voided
) WHEN NOT matched THEN INSERT(
  patientid, sitecode, facilityname, 
  exitdescription, exitdate, exitreason, 
  patientpk, emr, project, toverified, 
  toverifieddate, reenrollmentdate, 
  deathdate, effectivediscontinuationdate, 
  reasonfordeath, specificdeathreason, 
  [date_created], [recorduuid], [date_last_modified], 
  loaddate
) 
VALUES 
  (
    patientid, 
    sitecode, 
    facilityname, 
    exitdescription, 
    exitdate, 
    exitreason, 
    patientpk, 
    emr, 
    project, 
    toverified, 
    toverifieddate, 
    reenrollmentdate, 
    deathdate, 
    effectivediscontinuationdate, 
    reasonfordeath, 
    specificdeathreason, 
    [date_created], 
    [recorduuid], 
    [date_last_modified], 
    Getdate()
  ) WHEN matched THEN 
UPDATE 
SET 
  a.[patientid] = b.[patientid], 
  a.[facilityname] = b.[facilityname], 
  a.[exitdescription] = b.[exitdescription], 
  a.[exitdate] = b.[exitdate], 
  a.[exitreason] = b.[exitreason], 
  a.[emr] = b.[emr], 
  a.[project] = b.[project], 
  a.[toverified] = b.[toverified], 
  a.[toverifieddate] = b.[toverifieddate], 
  a.[reenrollmentdate] = b.[reenrollmentdate], 
  a.[reasonfordeath] = b.[reasonfordeath], 
  a.[specificdeathreason] = b.[specificdeathreason], 
  a.[deathdate] = b.[deathdate], 
  a.[effectivediscontinuationdate] = b.[effectivediscontinuationdate], 
  a.[date_last_modified] = b.[date_last_modified], 
  a.[date_created] = b.[date_created], 
  a.[recorduuid] = b.[recorduuid], 
  a.[voided] = b.[voided];
UPDATE 
  [ODS_logs].[dbo].[CT_patientStatus_Log] 
SET 
  loadenddatetime = Getdate() 
WHERE 
  maxexitdate = @ExitDate;
END
