
--truncate table first
truncate table Hivcasesurveillance.Dbo.CslinelistNCDScreening;

--declare start and end dates i.e. within the last 12 months form reporting period
declare @start_date date;
select @start_date = dateadd(month, -11, eomonth(dateadd(month, -1, getdate())));

declare @end_date date;
select @end_date = eomonth(dateadd(month, -1, getdate()));


--- create a temp table to store end of month for each month
with dates as (
     
 select datefromparts(year(@start_date), month(@start_date), 1) as dte
      union all
      select dateadd(month, 1, dte) --incrementing month by month until the date is less than or equal to @end_date
      from dates
      where dateadd(month, 1, dte) <= @end_date
      )
select 
	eomonth(dte) as end_date
into #months
from dates
option (maxrecursion 0);   

--declare as of date
declare @as_of_date as date;

--declare cursor
declare cursor_AsOfDates cursor for
select * from #months

open cursor_AsOfDates

fetch next from cursor_AsOfDates into @as_of_date
while @@FETCH_STATUS = 0

Begin
With Visitdata As (
    Select 
        Facilityname,
        Partnername,
        Agencyname,
        County,
        Subcounty,
        Visits.Patientkey,
        Visits.PatientPKHash,
        Visits.SiteCode,
        Visits.Whostage,        
        Visits.ScreenedForChronicIllness,
        Visits.ScreenedForHypertension,
        Gender,
        Try_convert(Date, Visitdatekey) As VisitDate,
        Eomonth(Try_convert(Date, Visitdatekey)) As AsofDate,
        Datediff(Year, Try_convert(Date, Pat.Dob), Try_convert(Date, Eomonth(Visitdatekey))) As Age
    From 
        NDWH.fact.Facthistoricalvisits As Visits
        Left Join NDWH.Dim.Dimpatient As Pat On Pat.Patientkey = Visits.Patientkey
        Left Join NDWH.Dim.Dimfacility As Facility On Facility.Facilitykey = Visits.Facilitykey
        Left Join NDWH.Dim.Dimpartner As Partner On Partner.Partnerkey = Visits.Partnerkey
        Left Join NDWH.Dim.Dimagency As Agency On Agency.Agencykey = Visits.Agencykey       
    Where  
        Visits.Patientkey Is Not Null and  Visitdatekey <= @as_of_date
)

insert into [HIVCaseSurveillance].[dbo].[CslinelistNCDScreening]
 
Select 
    Visits.Patientkey,
    Visits.PatientPKHash,
    Visits.SiteCode,
    VisitDate,
     @as_of_date as AsOfDate,
    Facilityname,
    Partnername,
    Agencyname,
    County,
    Subcounty,
    Whostage,
    ScreenedForChronicIllness,
    ScreenedForHypertension,
    Visits.Gender,
    Eomonth(Dateconfirmed.Date) As CohortYearMonth,
    Visits.Age,
    Age.Datimagegroup  as Agegroup

From   
    Visitdata As Visits
    Left Join NDWH.Dim.Dimpatient As Pat On Pat.Patientkey = Visits.Patientkey
    Left Join NDWH.Dim.Dimdate As Dateconfirmed On Dateconfirmed.Datekey = Pat.Dateconfirmedhivpositivekey
    Left Join NDWH.Dim.Dimagegroup Age On Age.Age = Visits.Age
    where Visits.Age >= 15
   
   fetch next from cursor_AsOfDates into @as_of_date

end

--free up objects
drop table #months;
close cursor_AsOfDates;
deallocate cursor_AsOfDates