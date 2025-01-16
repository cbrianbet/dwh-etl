If Object_id(N'[NDWH].[Fact].[FactModulesuptake]', N'U') Is Not Null
  Drop Table [Ndwh].[Fact].[FactModulesuptake];

Begin
    With Sites
         As (Select 
         distinct  Mfl_code ,
                    case when Mfl_code is not null then 1 Else 0 End as isEMRSite,
                    SDP,
                    SDP_Agency,
                    SubCounty,
                    County,
                    EMR_Status,
                    EMR,
                    [Owner],
                    [InfrastructureType],
                    [KEPH_Level]
                    
             From   [ODS].Care.[ALL_EMRSites]
             ),
         Otz
         As (Select 
                   Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOTZ
             From   Ods.Care.Ct_otz Otz
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
            ),
         Ovc
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOVC
             From   Ods.Care.Ct_ovc Ovc
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Hts
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTS
             From   Ods.HTS.Hts_clienttests Tests
             Where  Datediff(Month, Testdate, Eomonth(Dateadd(Mm, -1, Getdate())
                                              )) <= 12
            ),
         Prep
         As (Select 
                  Distinct prep.Sitecode,
                  case when prep.SiteCode is not null then 1 Else 0 End as isPrep
             From   Ods.PrEP.Prep_visits Prep
                    Full Join Ods.PrEP.Prep_behaviourrisk Beha
                           On Beha.Sitecode = Prep.Sitecode
             Where  Datediff(Month, Prep.Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Combined_dataset
         As (Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Mnch.Mnch_ancvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Mnch.Mnch_matvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Mnch.Mnch_pncvisits),
         Pmtct
         As (Select 
                 Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isPMTCT

             From   Combined_dataset
                    Left Join Ods.Care.All_emrsites As Sites
                           On Sites.Mfl_code = Combined_dataset.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
             ),
         Iit
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isIITML
             From   Ods.Care.Ct_iitriskscores Iit
             Where  Datediff(Month, Riskevaluationdate, Eomonth(Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Htsml
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTSML
             From   Ods.HTS.Hts_eligibilityextract Htsml
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate())))  <= 12 and HIVRiskCategory is not null
             ),
         Summary
         As (Select 
                    Mfl_code ,
                    SDP,
                    SDP_Agency,
                    Subcounty,
                    County,
                    EMR_Status,
                    EMR,
                    [owner],
                    [InfrastructureType],
                    [KEPH_Level],
                    coalesce (isEMRSite,0) as isEMRSite,
                    coalesce (isOTZ,0) as isOTZ,
                    coalesce (isOVC,0) as isOVC,
                    coalesce (isHTS,0) as isHTS,
                    coalesce (isPrep,0) as isPrep,
                    coalesce (isPMTCT,0) as isPMTCT,
                    coalesce (isIITML,0) as isIITML,
                    coalesce (isHTSML,0) as isHTSML
             From   Sites
                    Left Join Otz
                           On Otz.SiteCode = Sites.MFL_Code
                    Left Join Ovc
                           On Ovc.SiteCode = Sites.MFL_Code  
                    Left Join Hts
                           On Hts.SiteCode = Sites.MFL_Code    
                    Left Join Prep
                           On Prep.SiteCode = Sites.MFL_Code     
                    Left Join Pmtct
                           On Pmtct.SiteCode = Sites.MFL_Code      
                    Left Join Iit
                           On Iit.SiteCode = Sites.MFL_Code
                    Left Join Htsml
                           On Htsml.SiteCode = Sites.MFL_Code

                              )
    Select 
           Factkey = Identity(Int, 1, 1),
           Partner.Partnerkey,
           Agency.Agencykey,
           fac.FacilityKey,
           summary.isEMRSite,
           Summary.isHTS,
           isHTSML,
           isIITML,
           isOTZ,
           isOVC,
           isPMTCT,
           isPrep,
           EMR_Status,
           summary.EMR,
           [Owner],
           [InfrastructureType],
           [KEPH_Level]
    Into   Ndwh.Fact.FactModulesuptake
    From   Summary
           Left join NDWH.Dim.DimFacility as fac on fac.MFLCode=Summary.MFL_Code
           Left Join NDWH.Dim.DimPartner as partner on partner.partnername=Summary.SDP
           Left join NDWH.Dim.DimAgency agency on agency.AgencyName=Summary.SDP_Agency
          
    Alter Table Ndwh.Fact.FactModulesuptake Add Primary Key(Factkey);
End 

