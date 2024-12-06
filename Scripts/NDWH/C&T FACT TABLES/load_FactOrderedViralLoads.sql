If Object_id(N'[NDWH].[dbo].[FactOrderedViralLoads]', N'U') Is Not Null
  Drop Table [Ndwh].[Dbo].[Factorderedviralloads];

With Mfl_partner_agency_combination
     As (Select Distinct Mfl_code,
                         Sdp,
                         Sdp_agency As Agency
         From   Ods.Dbo.All_emrsites)
Select Factkey = Identity(Int, 1, 1),
       Rank,
       Patientkey,
       Facilitykey,
       Partnerkey,
       Agencykey,
       Ordered_date.Datekey    As OrderedbyDateKey,
       Reportedbydate.Datekey  As ReportedbyDateKey,
       Testname,
       Testresult,
       Viralloads.Emr,
       Viralloads.Project,
       Reason,
       Cast(Getdate() As Date) As LoadDate
Into   Ndwh.Dbo.Factorderedviralloads
From   Ods.Dbo.Intermediate_orderedviralloads As Viralloads
       Left Join Ndwh.Dbo.Dimpatient As Patient
              On Patient.Patientpkhash = Viralloads.Patientpkhash
                 And Patient.Sitecode = Viralloads.Sitecode
       Left Join Ndwh.Dbo.Dimfacility As Facility
              On Facility.Mflcode = Viralloads.Sitecode
       Left Join Ndwh.Dbo.Dimdate As Ordered_date
              On Ordered_date.Date = Viralloads.Orderedbydate
       Left Join Ndwh.Dbo.Dimdate As Reportedbydate
              On Reportedbydate.Date = Viralloads.Reportedbydate
       Left Join Mfl_partner_agency_combination
              On Mfl_partner_agency_combination.Mfl_code = Viralloads.Sitecode
       Left Join Ndwh.Dbo.Dimpartner As Partner
              On Partner.Partnername = Mfl_partner_agency_combination.Sdp
       Left Join Ndwh.Dbo.Dimagency As Agency
              On Agency.Agencyname = Mfl_partner_agency_combination.Agency

Alter Table Ndwh.Dbo.Factorderedviralloads
  Add Primary Key(Factkey); 

