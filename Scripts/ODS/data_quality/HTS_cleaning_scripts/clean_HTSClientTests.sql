---------------Update Client Tested As ------------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET ClientTestedAs =  CASE 
            WHEN ClientTestedAs  in ('C: Couple (includes polygamous)','Couple') THEN 'Couple'        
            WHEN ClientTestedAs in ('I: Individual','Individual')  THEN 'Individual'
           ELSE 'NULL'    
                END
Go 
------------------Update Entry Point----------------------------------------------

UPDATE M  SET  M.EntryPoint= T.target_name  
from [ODS].[HTS].[HTS_ClientTests] M 
INNER JOIN [ODS].[lkp].[lkp_patient_source] T  
ON M.EntryPoint = T.source_name
GO
-----------------Update Test Strategy-------------------------------------------
UPDATE M  SET  M.TestStrategy= T.Target_htsStrategy  
from [ODS].[HTS].[HTS_ClientTests] M 
INNER JOIN [ODS].[lkp].[lkp_htsStrategy] T  
ON M.TestStrategy = T.Source_htsStrategy
GO
---------------------Update TB Screening --------------------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET TbScreening =  CASE 
            WHEN TbScreening in ('No Signs','No TB','No TB signs','Yes') THEN 'No Signs'    
            WHEN TbScreening in ('On TB Treatment','INH','TB Rx','TBRx') THEN 'On TB Treatment'  
            WHEN TbScreening in ('Presumed TB','PrTB') THEN 'Presumed TB'   
            WHEN TbScreening in ('TB Confirmed') THEN 'TB Confirmed'            
           ELSE 'Not Done'    
                END

  -------------------------------------Update ClientSelfTested --------------------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET ClientSelfTested =  CASE 
            WHEN ClientSelfTested in ('1','Yes') THEN 'Yes'    
            WHEN ClientSelfTested in ('0', 'No') THEN 'No'  
            WHEN ClientSelfTested in ('NA') THEN 'NA'               
           ELSE 'NULL'    
                END
  ---------------------------------Update Couple Discordant --------------------------------------------

 UPDATE ODS.[HTS].[HTS_ClientTests] SET CoupleDiscordant =  CASE 
            WHEN CoupleDiscordant ='Yes' THEN 'Yes'    
            WHEN CoupleDiscordant ='No' THEN 'No'  
            WHEN CoupleDiscordant in ('NA','') THEN 'NULL'               
          ELSE     'NULL'
                END
---------------------Update Test Type --------------------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET TestType =  CASE 
            WHEN TestType in ('Initial','Initial Test') THEN 'Initial Test'    
            WHEN TestType in ('Repeat','Repeat Test') THEN 'Repeat Test'   
            WHEN TestType ='Retest' THEN 'Retest'                 
          ELSE     'NULL'
                END
----------------------------Update Consent------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET Consent =  CASE 
            WHEN Consent ='No' THEN 'No'    
            WHEN Consent ='Yes' THEN 'Yes'   
            WHEN Consent in ('NULL','') THEN 'NULL'                 
          ELSE     'NULL'
                END
----------------------------Update Setting------------------------------
 UPDATE ODS.[HTS].[HTS_ClientTests] SET Setting =  CASE 
            WHEN Setting in ('Facility','Tent') THEN 'Facility'    
            WHEN Setting in ('Community','Medical Camp') THEN 'Community'                  
          ELSE     'NULL'
                END
---------------------------------Update Approach-----------------------------------
                 UPDATE ODS.[HTS].[HTS_ClientTests] SET Approach =  CASE 
            WHEN Approach in ('CITC','Client Initiated Testing (CITC)') THEN 'Client Initiated Testing (CITC)'    
            WHEN Approach in ('PITC','Provider Initiated Testing(PITC)') THEN 'Provider Initiated Testing(PITC)'                  
          ELSE     'NULL'
                END
  
 ---------------------------------Update MonthssinceLastTest-----------------------------------
                 UPDATE ODS.[HTS].[HTS_ClientTests] SET MonthsSinceLastTest =  NULL 
                Where MonthsSinceLastTest > 1540 
