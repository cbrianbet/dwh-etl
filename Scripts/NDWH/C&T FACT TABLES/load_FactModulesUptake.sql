If Object_id(N'[NDWH].[dbo].[FactModulesuptake]', N'U') Is Not Null
  Drop Table [Ndwh].[Dbo].[FactModulesuptake];

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
                    EMR
             From   Ods.Dbo.All_emrsites
             Where  Emr_status = 'Active'
             ),
         Otz
         As (Select 
                   Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOTZ
             From   Ods.Dbo.Ct_otz Otz
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
            ),
         Ovc
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOVC
             From   Ods.Dbo.Ct_ovc Ovc
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Hts
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTS
             From   Ods.Dbo.Hts_clienttests Tests
             Where  Datediff(Month, Testdate, Eomonth(Dateadd(Mm, -1, Getdate())
                                              )) <= 12
            ),
         Prep
         As (Select 
                  Distinct prep.Sitecode,
                  case when prep.SiteCode is not null then 1 Else 0 End as isPrep
             From   Ods.Dbo.Prep_visits Prep
                    Full Join Ods.Dbo.Prep_behaviourrisk Beha
                           On Beha.Sitecode = Prep.Sitecode
             Where  Datediff(Month, Prep.Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Combined_dataset
         As (Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_ancvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_matvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_pncvisits),
         Pmtct
         As (Select 
                 Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isPMTCT

             From   Combined_dataset
                    Left Join Ods.Dbo.All_emrsites As Sites
                           On Sites.Mfl_code = Combined_dataset.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
             ),
         Iit
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isIITML
             From   Ods.Dbo.Ct_iitriskscores Iit
             Where  Datediff(Month, Riskevaluationdate, Eomonth(Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Htsml
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTSML
             From   Ods.Dbo.Hts_eligibilityextract Htsml
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
           summary.EMR
    Into   Ndwh.Dbo.FactModulesuptake
    From   Summary
           Left join NDWH.dbo.DimFacility as fac on fac.MFLCode=Summary.MFL_Code
           Left Join NDWH.dbo.DimPartner as partner on partner.partnername=Summary.SDP
           Left join NDWH.dbo.DimAgency agency on agency.AgencyName=Summary.SDP_Agency
          
    Alter Table Ndwh.Dbo.FactModulesuptake Add Primary Key(Factkey);
End 

