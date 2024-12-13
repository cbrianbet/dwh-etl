---------------------------------------------------HTS_clients----------------------------------------------------

------------------Update Dob to NULL  where dates are missing, where dates are > today and where dates are <1900 year--------------------

UPDATE ODS.[HTS].[HTS_clients] SET Dob = NULL where Dob < CAST ('1910-01-01' AS DATE)
GO

UPDATE ODS.[HTS].[HTS_clients] SET Dob = NULL where Dob > GETDATE()
Go

UPDATE ODS.[HTS].[HTS_clients] SET Dob = NULL where Dob is NULL
Go
 --------------------------Update Gender----------------------------------------------------
 UPDATE ODS.[HTS].[HTS_clients] SET Gender =  CASE 
            WHEN Gender = 'M' THEN 'Male'          
            WHEN Gender = 'F' THEN 'Female'    
                END
WHERE Gender in ('F','M')

-------------------Update MaritalStatus-------------------------------------------------------------
UPDATE M SET MaritalStatus = T.Target_MaritalStatus
from ODS.[HTS].[HTS_clients] M
inner JOIN ODS.[lkp].lkp_MaritalStatus T
on M.MaritalStatus = T.Source_MaritalStatus

Go
-------------------Update Disability-------------------------------------------------------------
UPDATE M SET DisabilityType = T.Target_Disability
from ODS.[HTS].[HTS_clients] M
inner JOIN ODS.[lkp].lkp_htsDisability T
on M.DisabilityType = T.Source_Disability

Go
---------------Update PatientDisabled------------------------------------
 UPDATE ODS.[HTS].[HTS_clients] SET PatientDisabled =  CASE 
            WHEN PatientDisabled = 'No' THEN 'No'          
           ELSE 'Yes'    
                END
WHERE PatientDisabled is not NULL
Go

----Added by Mugo,Bett,Nobert to cation null voided column. NUll voided are active patients

UPDATE a
    SET Voided = 0             
    from ODS.[HTS].[HTS_clients] a
WHERE Voided is null
GO