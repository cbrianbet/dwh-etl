
--truncate table first
truncate table Hivcasesurveillance.Dbo.Cslinelistadvancehivdisease;

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
        Whostage,
        Gender,
        Try_convert(Date, Visitdatekey) As VisitDate,
        Eomonth(Try_convert(Date, Visitdatekey)) As AsofDate,
        Datediff(Year, Try_convert(Date, Pat.Dob), Try_convert(Date, Eomonth(Visitdatekey))) As Age
    From 
        Ndwh.Dbo.Facthistoricalvisits As Visits
        Left Join Ndwh.Dbo.Dimpatient As Pat On Pat.Patientkey = Visits.Patientkey
        Left Join Ndwh.Dbo.Dimfacility As Facility On Facility.Facilitykey = Visits.Facilitykey
        Left Join Ndwh.Dbo.Dimpartner As Partner On Partner.Partnerkey = Visits.Partnerkey
        Left Join Ndwh.Dbo.Dimagency As Agency On Agency.Agencykey = Visits.Agencykey
    Where  
        Visits.Patientkey Is Not Null and  Visitdatekey <= @as_of_date
), Rankedvisits As (
    Select 
        Visitdata.Patientkey,
        Facilityname,
        Partnername,
        Agencyname,
        County,
        Subcounty,
        Asofdate,
        VisitDate,
        Gender,
        Visitdata.Whostage,
        Age,
        Row_number() Over (
            Partition By Patientkey
            Order By VisitDate Desc
        ) As VisitRank
    From   
        Visitdata
), Latestvisits As (
    Select 
        Patientkey,
        Facilityname,
        Partnername,
        Agencyname,
        County,
        Subcounty,
        Asofdate,
        VisitDate,
        Whostage,
        Gender,
        Age
    From   
        Rankedvisits
    Where  
        Visitrank = 1
), Cd4s As (
    Select 
        Patientkey,
        Lastcd4,
        Lastcd4date
    From   
        Ndwh.Dbo.Factcd4
)
insert into [HIVCaseSurveillance].[dbo].[Cslinelistadvancehivdisease]
 
Select 
    Visits.Patientkey,
    VisitDate,
     @as_of_date as AsOfDate,
    Facilityname,
    Partnername,
    Agencyname,
    County,
    Subcounty,
    Whostage,
    Visits.Gender,
    Eomonth(Dateconfirmed.Date) As CohortYearMonth,
    Visits.Age,
    Age.Datimagegroup  as Agegroup,
    Case
        When ( Visits.Age >= 5 And Visits.Whostage In ( 3, 4 ) )
            Or Visits.Age < 5
            Or ( Visits.Age >= 5 And Convert(Float, Cd4s.Lastcd4) < 200 ) 
        Then 1
        Else 0
    End As AHD,
    Case
        When Visits.Whostage In ( 3, 4 ) 
        Then 1
        Else 0
    End As WhoStage3and4,
    Case
        When Visits.Age >= 5 And Convert(Float, Cd4s.Lastcd4) < 200 
        Then 1
        Else 0
    End As CD4Lessthan200,
    LastCD4Date

From   
    Latestvisits As Visits
    Left Join Cd4s On Cd4s.Patientkey = Visits.Patientkey
    Left Join Ndwh.Dbo.Dimpatient As Pat On Pat.Patientkey = Visits.Patientkey
    Left Join Ndwh.Dbo.Dimdate As Dateconfirmed On Dateconfirmed.Datekey = Pat.Dateconfirmedhivpositivekey
    Left Join Ndwh.Dbo.Dimagegroup Age On Age.Age = Visits.Age
   
   fetch next from cursor_AsOfDates into @as_of_date

end

--free up objects
drop table #months;
close cursor_AsOfDates;
deallocate cursor_AsOfDates