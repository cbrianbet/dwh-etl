truncate table [ods].[care].[all_EMRSites];
		

	MERGE [ods].[Care].[all_EMRSites] AS a
	USING(SELECT DISTINCT	MFL_Code
							,[Facility_Name]
							,County
							,SubCounty
							,[Owner]
							,Latitude
							,Longitude
							,SDP
							,[SDP_Agency]
							,Implementation
							,EMR
							,[EMR_Status]
							,[HTS_Use]
							,[HTS_Deployment]
							,[HTS_Status]
							,null[IL Status]
							,null[Registration IE]
							,null[Phamarmacy IE]
							,mlab
							,Ushauri
							,Nishauri
							,null[Appointment Management IE]
							,OVC
							,OTZ
							,PrEP
							,null[3PM]
							,AIR
							,KP
							,MCH
							,null TB
							,[Lab_Manifest]
							,null Comments
							,null Project
							,InfrastructureType
							,KEPH_Level
							
	FROM [HIS_Implementation].[dbo].[All_EMRSites] WHERE MFL_Code !='' AND MFL_Code >0) AS b 
	ON(a.MFL_Code  =b.MFL_Code )
    WHEN MATCHED THEN
    UPDATE SET 
    a.[Facility_Name] = B.[Facility_Name]
	WHEN NOT MATCHED THEN 
	INSERT(MFL_Code,[Facility_Name],County,SubCounty,[Owner],Latitude,Longitude,SDP,[SDP_Agency],Implementation,EMR,[EMR_Status],[HTS_Use],[HTS_Deployment],[HTS_Status],[IL_Status],[Registration_IE],Phamarmacy_IE,mlab,Ushauri,Nishauri,[Appointment_Management_IE],OVC,OTZ,PrEP,[_3PM],AIR,KP,MCH,TB,Lab_Manifest,Comments,Project,InfrastructureType,KEPH_Level,LoadDate)
	VALUES(MFL_Code,[Facility_Name],County,SubCounty,[Owner],Latitude,Longitude,SDP,[SDP_Agency],Implementation,EMR,[EMR_Status],[HTS_Use],[HTS_Deployment],[HTS_Status],[IL Status],[Registration IE],[Phamarmacy IE],mlab,Ushauri,Nishauri,[Appointment Management IE],OVC,OTZ,PrEP,[3PM],AIR,KP,MCH,TB,[Lab_Manifest],Comments,Project,InfrastructureType,KEPH_Level,Getdate());


	with cte AS (
					Select
					MFL_Code,
						
						ROW_NUMBER() OVER (PARTITION BY MFL_Code ORDER BY
					MFL_Code) Row_Num
					FROM [ods].[care].[all_EMRSites]
					)
					delete from cte 
					Where Row_Num >1 ;