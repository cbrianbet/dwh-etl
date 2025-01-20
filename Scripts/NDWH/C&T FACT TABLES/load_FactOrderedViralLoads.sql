If Object_id(N'[NDWH].[Fact].[FactOrderedViralLoads]', N'U') Is Not Null
  Drop Table [Ndwh].[Fact].[Factorderedviralloads];

With Mfl_partner_agency_combination
     As (Select Distinct Mfl_code,
                         Sdp,
                         Sdp_agency As Agency
         From   Ods.Care.All_emrsites)
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
Into   Ndwh.Fact.Factorderedviralloads
From   Ods.[Intermediate].Intermediate_orderedviralloads As Viralloads
       Left Join Ndwh.Dim.Dimpatient As Patient
              On Patient.Patientpkhash = Viralloads.Patientpkhash
                 And Patient.Sitecode = Viralloads.Sitecode
       Left Join Ndwh.Dim.Dimfacility As Facility
              On Facility.Mflcode = Viralloads.Sitecode
       Left Join Ndwh.Dim.Dimdate As Ordered_date
              On Ordered_date.Date = Viralloads.Orderedbydate
       Left Join Ndwh.Dim.Dimdate As Reportedbydate
              On Reportedbydate.Date = Viralloads.Reportedbydate
       Left Join Mfl_partner_agency_combination
              On Mfl_partner_agency_combination.Mfl_code = Viralloads.Sitecode
       Left Join Ndwh.Dim.Dimpartner As Partner
              On Partner.Partnername = Mfl_partner_agency_combination.Sdp
       Left Join Ndwh.Dim.Dimagency As Agency
              On Agency.Agencyname = Mfl_partner_agency_combination.Agency

Alter Table Ndwh.Fact.Factorderedviralloads
  Add Primary Key(Factkey); 

