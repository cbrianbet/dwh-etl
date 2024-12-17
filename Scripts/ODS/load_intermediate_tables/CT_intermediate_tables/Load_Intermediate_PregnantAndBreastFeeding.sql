/*
Created By: Dennis Mugo
Revised By: Ann Kiwara and Nobert Mumo
*/
TRUNCATE TABLE [ODS].[Intermediate].[Intermediate_PregnantAndBreastFeeding];

DECLARE @start_date DATE;

SELECT @start_date = dateadd(month, -60, eomonth(dateadd(month, -1, getdate())));

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
/*  
step 1 pregnant:
       - Pick all the patients who have ever been reported as pregnant
	   - Ignore records where LMP is either 1900-01-01,null or LMP is in the future of the reporting month

*/
WITH ReportedAsPregnant As (
    select		distinct		SiteCode
						,CT_PatientVisits.PatientPK
						,CT_PatientVisits.PatientPKHash
						,Pregnant
						,Breastfeeding
						,cast(LMP as date)LMP
						,@as_of_date As AsOfDate
						,VisitDate					
						,0 IsPBFW
						from [ODS].[Care].[CT_PatientVisits] 
						where  Pregnant='Yes' and cast(LMP as date) <>'1900-01-01' and LMP is not null and voided=0 and LMP <=@as_of_date 
						and VisitDate <= @as_of_date and SiteCode is not null
						
),
---End of step 1
/*
   Step 2 Pregnant :
      - Get the latest LMP By VisitDate and by as of
	  - Determine if the patient is pregnant if the difference in dates  of LMP and AsOfDate are within the 280 days. 
*/
OrderedPregnant As (
                     select 
						row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by visitDate desc) as rank, 
						SiteCode,
						PatientPK,
						PatientPkHash,
						Pregnant,
						IspregnantAsOfDate = case when datediff(day,LMP,AsOfDate) <=280 then 1 
											else 0 end,
						LMP As LatestLMPByVisitDate,						
						AsOfDate,
						VisitDate As PregnancyRelatedVisitDate
						
					from ReportedAsPregnant

			),

   -- Get the unique pregnancy based on AsOfDate

MaxOrderedPregnantByAsOfDate As (  -- Reported as pregnant AsOfDate
select SiteCode
		,PatientPK
		,PatientPkHash
		,Pregnant
		,IspregnantAsOfDate
		,LatestLMPByVisitDate
		,AsOfDate
		,PregnancyRelatedVisitDate
from OrderedPregnant
where rank =1 
),
---End of step 2
/*
 step 3 pregnant: 
   - check if the woman was really pregnant or she has delivered and now breastfeeding
   - Calculate the Expected Date of Delivery(EDD) which shows whether the patient has delivered or not based on AsOfDate
   - If EDD is Less than AsOfDate,then delivery has happened else has not happened.280 days are equivalent to 9months and 10 days

*/
PregnantAndBreastFeedingCheckByAsOfDateByEDD As ( 
														select
																SiteCode
																,PatientPK
																,PatientPKHash
																,Pregnant
																,0 Breastfeeding
																,LatestLMPByVisitDate
																,EDD =  Cast(dateadd(day,280,LatestLMPByVisitDate) as date)
																,AsOfDate
																,PregnancyRelatedVisitDate
																,0 IsPBFW
														from MaxOrderedPregnantByAsOfDate						
),
---End
/*
  Step 4 Pregant:
         - Picking those pregnant from step 3.
		 - You are pregnant if AsOfDate is less than EDD

*/
PregnantAsOfDate As (  --Those who are really pregnant based on EDD
								select
										SiteCode
										,PatientPK
										,PatientPKHash
										,Pregnant
										,LatestLMPByVisitDate
										,EDD 
										,AsOfDate
										,PregnancyRelatedVisitDate
										,0 IsPBFW
								from PregnantAndBreastFeedingCheckByAsOfDateByEDD 
								where  AsOfDate < EDD 

),
--End

/*
step 5 breastFeeding Category 1:
      - From the pregnant list in step 4(above), If AsOfDate is greater that EDD and date difference between EDD and AsOfDate is less than 
	  24 months, then you are considered breastfeeding
*/
BreastFeedingFromPregnantOrdered As ( 
					select
							SiteCode
							,PatientPK
							,PatientPKHash
							,Pregnant
							,Breastfeeding
							,ISBreastfeeding = 1
							,LatestLMPByVisitDate
							,EDD 
							,AsOfDate
							,PregnancyRelatedVisitDate As BreastFeedingRelatedVisitDate
							,IsPBFW
						from PregnantAndBreastFeedingCheckByAsOfDateByEDD
						where AsOfDate > EDD  and datediff(month,EDD,AsOfDate) <= 24
						),
--End
/*
Step 6 BreastFeeding :
               - Pick all the records where Breastfeeding status  is yes and visitDate less than or equal to asOfDate

*/
ReportedAsBreastFeeding As (
    select				SiteCode
						,CT_PatientVisits.PatientPK
						,CT_PatientVisits.PatientPKHash
						,Pregnant
						,Breastfeeding
						,cast(LMP as date)LMP
						,@as_of_date As AsOfDate
						,VisitDate	As BreastFeedingRelatedVisitDate			
						,0 IsPBFW
						from [ODS].[Care].[CT_PatientVisits] 
						where  Breastfeeding='Yes'  and voided=0 and VisitDate <= @as_of_date
						and SiteCode is not null


),
------Get the latest breastfeeding based on a visit
OrderedBreastFeeding As (
                     select 
						row_number() over(partition by  SiteCode, PatientPK,Pregnant,AsOfDate order by BreastFeedingRelatedVisitDate Desc) as rank, 
						SiteCode,
						PatientPK,
						PatientPkHash,
						Pregnant,
						0 IsBreastFeedingAsOfDate,
						LMP,						
						AsOfDate,
						BreastFeedingRelatedVisitDate						
					from ReportedAsBreastFeeding

			),
----Pick the unique breastfeeding record by on a visit
MaxOrderedBreastFeedingAsOfDate As (
select SiteCode,PatientPK,PatientPkHash,Pregnant,IsBreastFeedingAsOfDate,LMP,AsOfDate,BreastFeedingRelatedVisitDate
from OrderedBreastFeeding
where rank =1 
),
/*
step 7 BreastFeeding :
				- validate if the mother is actually breastfeeding in relation to her DeliveryDate
				- DeliveryDate is the DOB for the child. DOB of the child is delivered from MNCH_Patient
				- Step 6 output are screened through MNCH_MotherBabyPairs and MNCH_Patient
				- If the date difference between DOB and AsOFDate is less than or equal to 24 months( Assume that most mothers breastfeed for 2 years) then 
				 she is still breastfeeding,else not

*/
IsBreastFeedingFromHeiDOB As( ---breastfeeding confirmed from MNCH
				Select
   						MaxOrderedBreastFeedingAsOfDate.SiteCode
						,MaxOrderedBreastFeedingAsOfDate.PatientPK
						,MaxOrderedBreastFeedingAsOfDate.PatientPKHash
						,Pregnant
						,Patient.DOB
						,IsBreastFeedingAsOfDate
						,LMP
						,@as_of_date As AsOfDate
						,BreastFeedingRelatedVisitDate					
						,0 IsPBFW 
				From MaxOrderedBreastFeedingAsOfDate                           
				left join [ODS].[MNCH].[MNCH_MotherBabyPairs] pairs
				on MaxOrderedBreastFeedingAsOfDate.SiteCode = pairs.SiteCode  and MaxOrderedBreastFeedingAsOfDate.PatientPK = pairs.MotherPatientPK
				left join [ODS].[MNCH].[MNCH_Patient]  Patient
				on pairs.SiteCode = Patient.SiteCode 
							and pairs.BabyPatientPK = Patient.PatientPK
				WHERE Datediff(month,Patient.DOB,@as_of_date) <=24 ---and pairs.PatientPK = 12706 and pairs.SiteCode = 11259	
),
--End
/*
Step 8 combine the breastFeeders
*/
CombineBreastFeeding As(

						select						
								SiteCode
								,PatientPK
								,PatientPKHash
								,0 Pregnant
								,IsBreastFeedingAsOfDate =1
								,AsOfDate
								,BreastFeedingRelatedVisitDate
								,0 IsPBFW 
							from BreastFeedingFromPregnantOrdered
							union
select				SiteCode
					,PatientPK
					,PatientPKHash
					,0 Pregnant
					,IsBreastFeedingAsOfDate =1
					,AsOfDate
					,BreastFeedingRelatedVisitDate
					,0 IsPBFW 
	
	from IsBreastFeedingFromHeiDOB
),
OrderedCombineBreastFeeding As (

select 
						row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by BreastFeedingRelatedVisitDate Desc) as rank, 
						SiteCode,
						PatientPK,
						PatientPKHash,
						Pregnant,
						IsBreastFeedingAsOfDate,						
						AsOfDate,
						BreastFeedingRelatedVisitDate,	
						IsPBFW
					from CombineBreastFeeding


),
MaxOrderedCombineBreastFeeding As (
			select SiteCode,PatientPK,PatientPkHash,Pregnant,IsBreastFeedingAsOfDate,AsOfDate,BreastFeedingRelatedVisitDate
			from OrderedCombineBreastFeeding
			where rank =1 
),
--End
/*
Step 9 combine breastfeeders and and pregnancies 
  - Combines to the two datasets to form PBFW
  - A seperator of either isPregnant or Isbreastfeeding is also there
*/
PBFW As(
  
	   select 
			coalesce(MaxOrderedCombineBreastFeeding.SiteCode, PregnantAsOfDate.SiteCode) as SiteCode
			,coalesce(MaxOrderedCombineBreastFeeding.PatientPK, PregnantAsOfDate.PatientPK) as PatientPK
			,coalesce(MaxOrderedCombineBreastFeeding.PatientPKHash, PregnantAsOfDate.PatientPK) as PatientPKHash
			,IsPregnant  = case 
								when PregnantAsOfDate.Pregnant ='yes' then 1 
								else 0 
							end
			,IsBreastFeedingAsOfDate
			,coalesce(MaxOrderedCombineBreastFeeding.AsOfDate, PregnantAsOfDate.AsOfDate) as AsOfDate
			,BreastFeedingRelatedVisitDate
			,PregnantAsOfDate.PregnancyRelatedVisitDate
			,IsPBFW	 = 1  
	   from MaxOrderedCombineBreastFeeding
	   full join PregnantAsOfDate
	   on	MaxOrderedCombineBreastFeeding.SiteCode = PregnantAsOfDate.SiteCode and
			MaxOrderedCombineBreastFeeding.PatientPK = PregnantAsOfDate.PatientPK and
			MaxOrderedCombineBreastFeeding.AsOfDate = PregnantAsOfDate.AsOfDate

)
--End
--/*
--Step 10 : Insert into [ODS].[dbo].[Intermediate_PregnantAndBreastFeeding] for reuse
--*/
insert into [ODS].[Intermediate].[Intermediate_PregnantAndBreastFeeding]([SiteCode],[PatientPK],PatientPKHash,[IsPregnant],[IsBreastFeeding],[AsOfDate],BreastFeedingRelatedVisitDate,PregnancyRelatedVisitDate,[IsPBFW])
SELECT  [SiteCode]
      ,[PatientPK]
	  ,PatientPKHash
      ,[IsPregnant]
      ,[IsBreastFeedingAsOfDate]
      ,[AsOfDate]
      ,BreastFeedingRelatedVisitDate
	  ,PregnancyRelatedVisitDate
      ,[IsPBFW]
	  
  FROM PBFW 

fetch next from cursor_AsOfDates into @as_of_date
end
drop table #months
close cursor_AsOfDates
deallocate cursor_AsOfDates