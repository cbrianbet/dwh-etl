/*
Created by : Dennis Mugo
Revised by : Nobert Mumo and  Mary Wambui
*/
TRUNCATE TABLE ndwh.Fact.FactViralLoad_Hist;

DECLARE @start_date DATE;

SELECT @start_date = dateadd(month, -12, eomonth(dateadd(month, -1, getdate())));

DECLARE @end_date DATE;

SELECT @end_date = eomonth(dateadd(month, -1, getdate()));

--- create a temp table to store end of month for each month
with dates as (     
				SELECT datefromparts(year(@start_date), month(@start_date), 1) as dte
				UNION ALL
				SELECT dateadd(month, 1, dte) --incrementing month by month until the date is less than or equal to @end_date
				FROM dates
				WHERE dateadd(month, 1, dte) <= @end_date
			)
SELECT 
	eomonth(dte) as end_date
INTO #months
FROM dates

OPTION (maxrecursion 0);   

--declare as of date
DECLARE @as_of_date As DATE;

--declare cursor
DECLARE cursor_AsOfDates CURSOR FOR
SELECT * FROM #months

OPEN cursor_AsOfDates

FETCH NEXT FROM cursor_AsOfDates INTO @as_of_date
WHILE @@FETCH_STATUS = 0

BEGIN
WITH viralLoad As (
					SELECT	DISTINCT	
					patient.PatientPk,
					patient.PatientPkHash,
					patient.SiteCode,
					VisitID,
					art.StartARTDate,
					[OrderedbyDate],
					[ReportedbyDate],
					Patient.DOB,
					AgeAsOfDate = Datediff(year,Patient.DOB,@as_of_date),
					[TestName],
					TestResult,
					Labs.[Emr],
					Labs.[Project],
					CASE 
						WHEN datediff(month,art.StartARTDate, @as_of_date) >=3 THEN 1  
						WHEN DATEDIFF(MONTH, art.StartARTDate, @as_of_date) <3 THEN 0
					END As EligibleVL,
					CASE 
						WHEN datediff(month,[OrderedbyDate],@as_of_date) <= 6 and  Datediff(year,Patient.DOB,@as_of_date) <= 24 THEN 1
						WHEN datediff(month,[OrderedbyDate],@as_of_date) <= 12 and  Datediff(year,Patient.DOB,@as_of_date) > 24 THEN 1 
						ELSE 0
					END As IsValidVL,					
					0 as VLSup,
					@as_of_date As AsOfDate,
					getdate() As LoadDate
			FROM  ODS.Care.CT_patient  patient
			INNER join ODS.Care.CT_ARTPatients art 
			on art.PatientPK = patient.Patientpk and
				art.SiteCode = patient.SiteCode			
			left join ODS.Care.CT_PatientLabs Labs   
			ON	art.PatientPK = labs.Patientpk and
				art.SiteCode = labs.SiteCode
			where NullIf('2000-01-01',[OrderedbyDate]) <= @as_of_date
				),
				
Visits As(

select	Visits.SiteCode,
		Visits.PatientPK,
		VisitDate,Pregnant,
		Breastfeeding,
		LMP,
		NextAppointmentDate ,
		@as_of_date As AsOfDate
		from ODS.Care.CT_PatientVisits Visits
		join viralLoad 
		on  Visits.SiteCode = viralLoad.Sitecode and Visits.PatientPK = viralLoad.PatientPK
where Visits.VisitDate <= @as_of_date 
),

MaxVisitsByAsOf As (
   select 
   row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by VisitDate desc) as rank, 
   SiteCode,
   PatientPK,
   VisitDate,
   AsOfDate,
   NextAppointmentDate,
   Pregnant,
   Breastfeeding,
   LMP
   from Visits
),
RankMaxVisitDateAsOf As(
select SiteCode,PatientPK, VisitDate,Pregnant,Breastfeeding,LMP,NextAppointmentDate,AsOfDate
from MaxVisitsByAsOf
where rank =1


),
VlSupBasedOfValidity As(
    Select SiteCode,
			PatientPK,
			PatientPkHash,
			StartARTDate,
			DOB,
			AgeAsOfDate,
			[OrderedbyDate],
			[ReportedbyDate],
			EligibleVL,
			IsValidVL,
			CASE 
						WHEN IsNumeric([TestResult]) = 1 and IsValidVL=1 THEN 
																CASE 
																	WHEN try_cast(replace([TestResult], ',', '') as  float) < 200.00 THEN 1 
																	ELSE 0 
																END 
						ELSE 
							CASE 
								WHEN [TestResult]  in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') and IsValidVL=1 THEN 1 
								ELSE 0 
							END  
					END as VLSup,
			AsOfDate,
			[TestName],
			TestResult,
			[Emr],
			[Project]
	
	from viralLoad
	where NullIf('2000-01-01',[OrderedbyDate]) <= AsOfDate
),

MaxOrderedbyDateByAsOfDate As (
                     select 
						row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by [OrderedbyDate] desc) as rank, 
						SiteCode,
						PatientPK,
						PatientPkHash,
						StartARTDate,
						DOB,
						AgeAsOfDate,
						[OrderedbyDate],
						[ReportedbyDate],
						EligibleVL,
						IsValidVL,
						VLSup,
						AsOfDate,
						[TestName],
						TestResult,
						[Emr],
						[Project]
					from VlSupBasedOfValidity
					where NullIf('2000-01-01',[OrderedbyDate]) <= AsOfDate

			),
MaxOrderedbyDateByAsOfDate_Final As (
select SiteCode,PatientPK,PatientPkHash,StartARTDate,DOB,AgeAsOfDate,OrderedbyDate,ReportedbyDate,EligibleVL,IsValidVL,VLSup,AsOfDate,TestName,TestResult,Emr,Project 
from MaxOrderedbyDateByAsOfDate
where rank =1

)

,
Combined As(
 Select OrderedFinal.SiteCode,OrderedFinal.PatientPK,OrderedFinal.PatientPkHash,StartARTDate,DOB,AgeAsOfDate,OrderedbyDate,MaxVisitAsOf.VisitDate,MaxVisitAsOf.Pregnant,MaxVisitAsOf.Breastfeeding,LMP,ReportedbyDate,EligibleVL,IsValidVL,VLSup,OrderedFinal.AsOfDate,TestName,TestResult,Emr,Project  
 from MaxOrderedbyDateByAsOfDate_Final OrderedFinal
 join RankMaxVisitDateAsOf MaxVisitAsOf
 on OrderedFinal.SiteCode =  MaxVisitAsOf.SiteCode and OrderedFinal.PatientPK =  MaxVisitAsOf.PatientPK
 and OrderedFinal.AsOfDate =  MaxVisitAsOf.AsOfDate

),
Combined_PBFW As(
Select	SiteCode,
		PatientPK,
		PatientPkHash,
		StartARTDate,
		DOB,
		AgeAsOfDate,
		OrderedbyDate,
		VisitDate,
		Pregnant,
		Breastfeeding,
		LMP,
		ReportedbyDate,
		EligibleVL,
		IsPBFW= case
						WHEN (Pregnant ='yes' or  Breastfeeding ='yes')  THEN 1
						ELSE 0
						END,
		IsValidVL,
		VLSup,
		AsOfDate,
		TestName,
		TestResult,
		Emr,
		Project   
	from Combined
)

insert into ndwh.Fact.FactViralLoad_Hist(PatientKey,
										FacilityKey,
										AgeGroupKey,
										SiteCode,
										VisitDate,
										Pregnant,
										Breastfeeding,
										LMP,
										AgeAsOfDate,											
										OrderedbyDate,											
										ReportedbyDate,
										EligibleVL,
										IsPBFW,
										IsValidVL,
										VLSup,
										AsOfDate,
										TestName,
										TestResult,
										Emr,
										Project
									)

select  Patient.PatientKey,
		Facility.FacilityKey,
		AgeGroup.AgeGroupKey,
		Combined_PBFW.SiteCode,
		VisitDate,
		Pregnant,
		Breastfeeding,
		LMP,
		AgeAsOfDate,
		OrderedbyDate,
		ReportedbyDate,
		EligibleVL,
		IsPBFW,
		IsValidVL,
		VLSup,
		AsOfDate,
		TestName,
		TestResult,
		Combined_PBFW.Emr,
		Combined_PBFW.Project  
from Combined_PBFW
left join NDWH.Dim.DimPatient Patient
   on Combined_PBFW.SiteCode = Patient.SiteCode and Combined_PBFW.PatientPkHash = Patient.PatientPKHash
Left join NDWH.Dim.DimFacility   Facility
	on Combined_PBFW.SiteCode = Facility.MFLCode
left join [NDWH].[Dim].[DimAgeGroup] AgeGroup
     on Combined_PBFW.AgeAsOfDate = AgeGroup.Age


fetch next from cursor_AsOfDates into @as_of_date
end
drop table #months
close cursor_AsOfDates
deallocate cursor_AsOfDates




