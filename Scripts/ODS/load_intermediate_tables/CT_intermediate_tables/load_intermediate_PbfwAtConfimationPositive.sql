IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_PbfwAtConfimationPositive]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_PbfwAtConfimationPositive];
BEGIN
	with pregnant_or_breastfeeding_visit_dates_ordering as (
		select 
           PatientPK,
           SiteCode,
           VisitDate,
           row_number() over(partition by PatientPK, SiteCode order by VisitDate asc) as rnk
        from ODS.Care.CT_PatientVisits
        where (Pregnant in ('YES',  'Y') or Breastfeeding = 'Yes')  	  
		and  VOIDED = 0
	),
	pregnant_or_breastfeeding_visit_dates_check as (
		select 
			Patients.PatientPK,
		    Patients.PatientID,
            Patients.SiteCode,
			CASE WHEN datediff(month, 
				coalesce(replace(Patients.DateConfirmedHIVPositive,'-',''), replace(ART.StartARTDate,'-',''),replace(Patients.RegistrationAtCCC,'-','')), -- coalescing to get as much data as possible
				VisitDate) BETWEEN 0 and 2 THEN 1 ELSE 0 END as PbfwAtConfirmedPositive
		from pregnant_or_breastfeeding_visit_dates_ordering as visits
	    INNER JOIN ODS.Care.CT_Patient Patients ON  visits.PatientPK=Patients.PatientPK AND Patients.SiteCode=visits.SiteCode
	 	INNER JOIN ODS.Care.CT_ARTPatients ART ON ART.PatientPK=Patients.PatientPK AND Patients.SiteCode=ART.SiteCode
        WHERE Patients.Gender = 'Female' and
        	visits.rnk = 1 and
	  		Patients.VOIDED = 0 and
        	ART.VOIDED = 0
	)
	select 
			pregnant_or_breastfeeding_visit_dates_check.PatientPK ,
			pregnant_or_breastfeeding_visit_dates_check.PatientID,
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash,
			pregnant_or_breastfeeding_visit_dates_check.SiteCode,
            pregnant_or_breastfeeding_visit_dates_check.PbfwAtConfirmedPositive,
			cast(getdate() as date) as LoadDate
	into [ODS].[Intermediate].[Intermediate_PbfwAtConfimationPositive]
	from  pregnant_or_breastfeeding_visit_dates_check
    where  pregnant_or_breastfeeding_visit_dates_check.PbfwAtConfirmedPositive = 1
END