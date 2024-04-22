BEGIN

			MERGE [ODS].[dbo].[Ushauri_PatientAppointments] AS a
				USING(SELECT Distinct
						PatientPK,Null As PatientPKHash,SiteCode,SiteType,PatientID,Null As PatientIDHash, NUPI,PartnerName,FacilityID,FacilityName,
						DOB_Date As DOB,Gender,MaritalStatus,PatientResidentCounty,PatientResidentLocation,PatientResidentSubCounty,
						PatientResidentSubLocation,PatientResidentVillage,PatientResidentWard,RegistrationDate_Date As RegistrationDate,RegistrationAtCCC_Date as RegistrationAtCCC,
						RegistrationAtPMTCT_Date As RegistrationAtPMTCT,RegistrationAtTBClinic_date As RegistrationAtTBClinic,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,AgeAtAppointment,
						AppointmentID,AppointmentDate_Date As AppointmentDate,AppointmentType,AppointmentStatus,EntryPoint,VisitType,DateAttended_Date As DateAttended,ConsentForSMS,
						SMSLanguage,SMSTargetGroup,SMSPreferredSendTime,FourWeekSMSSent,FourWeekSMSSendDate_Date As FourWeekSMSSendDate,FourWeekSMSDeliveryStatus
						,FourWeekSMSDeliveryFailureReason,ThreeWeekSMSSent,ThreeWeekSMSSendDate_Date AS ThreeWeekSMSSendDate,ThreeWeekSMSDeliveryStatus,
						ThreeWeekSMSDeliveryFailureReason,TwoWeekSMSSent,TwoWeekSMSSendDate_Date As TwoWeekSMSSendDate,TwoWeekSMSDeliveryStatus,
						TwoWeekSMSDeliveryFailureReason,OneWeekSMSSent,OneWeekSMSSendDate_Date As OneWeekSMSSendDate,OneWeekSMSDeliveryStatus,
						OneWeekSMSDeliveryFailureReason,OneDaySMSSent,OneDaySMSSendDate_Date As OneDaySMSSendDate,OneDaySMSDeliveryStatus,OneDaySMSDeliveryFailureReason,
						MissedAppointmentSMSSent,MissedAppointmentSMSSendDate_Date As MissedAppointmentSMSSendDate,MissedAppointmentSMSDeliveryStatus,MissedAppointmentSMSDeliveryFailureReason,
						TracingCalls,TracingSMS,TracingHomeVisits,TracingOutcome,TracingOutcomeDate_Date As TracingOutcomeDate,DateReturnedToCare_Date As DateReturnedToCare,DaysDefaulted
					FROM [mhealthCentral].[dbo].[CT_PatientAppointments](NoLock) P
					) AS b	
						ON(
						 a.SiteCode = b.SiteCode	
						and a.[AppointmentID] = b.[AppointmentID]
						)
					
					WHEN NOT MATCHED THEN 
						INSERT([UshauriPatientPK],PatientPKHash,SiteCode,SiteType,PatientID,PatientIDHash,NUPI,PartnerName,FacilityID,FacilityName,DOB,Gender,MaritalStatus,PatientResidentCounty,PatientResidentLocation,PatientResidentSubCounty,PatientResidentSubLocation,PatientResidentVillage,PatientResidentWard,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,AgeAtAppointment,AppointmentID,AppointmentDate,AppointmentType,AppointmentStatus,EntryPoint,VisitType,DateAttended,ConsentForSMS,SMSLanguage,SMSTargetGroup,SMSPreferredSendTime,FourWeekSMSSent,FourWeekSMSSendDate,FourWeekSMSDeliveryStatus,FourWeekSMSDeliveryFailureReason,ThreeWeekSMSSent,ThreeWeekSMSSendDate,ThreeWeekSMSDeliveryStatus,ThreeWeekSMSDeliveryFailureReason,TwoWeekSMSSent,TwoWeekSMSSendDate,TwoWeekSMSDeliveryStatus,TwoWeekSMSDeliveryFailureReason,OneWeekSMSSent,OneWeekSMSSendDate,OneWeekSMSDeliveryStatus,OneWeekSMSDeliveryFailureReason,OneDaySMSSent,OneDaySMSSendDate,OneDaySMSDeliveryStatus,OneDaySMSDeliveryFailureReason,MissedAppointmentSMSSent,MissedAppointmentSMSSendDate,MissedAppointmentSMSDeliveryStatus,MissedAppointmentSMSDeliveryFailureReason,TracingCalls,TracingSMS,TracingHomeVisits,TracingOutcome,TracingOutcomeDate,DateReturnedToCare,DaysDefaulted,LoadDate) 
						VALUES(PatientPK,PatientPKHash,SiteCode,SiteType,PatientID,PatientIDHash,NUPI,PartnerName,FacilityID,FacilityName,DOB,Gender,MaritalStatus,PatientResidentCounty,PatientResidentLocation,PatientResidentSubCounty,PatientResidentSubLocation,PatientResidentVillage,PatientResidentWard,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,AgeAtAppointment,AppointmentID,AppointmentDate,AppointmentType,AppointmentStatus,EntryPoint,VisitType,DateAttended,ConsentForSMS,SMSLanguage,SMSTargetGroup,SMSPreferredSendTime,FourWeekSMSSent,FourWeekSMSSendDate,FourWeekSMSDeliveryStatus,FourWeekSMSDeliveryFailureReason,ThreeWeekSMSSent,ThreeWeekSMSSendDate,ThreeWeekSMSDeliveryStatus,ThreeWeekSMSDeliveryFailureReason,TwoWeekSMSSent,TwoWeekSMSSendDate,TwoWeekSMSDeliveryStatus,TwoWeekSMSDeliveryFailureReason,OneWeekSMSSent,OneWeekSMSSendDate,OneWeekSMSDeliveryStatus,OneWeekSMSDeliveryFailureReason,OneDaySMSSent,OneDaySMSSendDate,OneDaySMSDeliveryStatus,OneDaySMSDeliveryFailureReason,MissedAppointmentSMSSent,MissedAppointmentSMSSendDate,MissedAppointmentSMSDeliveryStatus,MissedAppointmentSMSDeliveryFailureReason,TracingCalls,TracingSMS,TracingHomeVisits,TracingOutcome,TracingOutcomeDate,DateReturnedToCare,DaysDefaulted,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 						
						a.[SiteType]									=	b.[SiteType],
						a.[PatientID]									=	b.[PatientID],					
						a.[NUPI]										=	b.[NUPI],
						a.[PartnerName]									=	b.[PartnerName],
						a.[FacilityName]								=	b.[FacilityName],
						a.[DOB]											=	b.[DOB],
						a.[Gender]										=	b.[Gender],
						a.[MaritalStatus]								=	b.[MaritalStatus],
						a.[PatientResidentCounty]						=	b.[PatientResidentCounty],
						a.[PatientResidentLocation]						=	b.[PatientResidentLocation],
						a.[PatientResidentSubCounty]					=	b.[PatientResidentSubCounty],
						a.[PatientResidentSubLocation]					=	b.[PatientResidentSubLocation],
						a.[PatientResidentVillage]						=	b.[PatientResidentVillage],
						a.[PatientResidentWard]							=	b.[PatientResidentWard],
						a.[RegistrationDate]							=	b.[RegistrationDate],
						a.[RegistrationAtCCC]							=	b.[RegistrationAtCCC],
						a.[RegistrationAtPMTCT]							=	b.[RegistrationAtPMTCT],
						a.[RegistrationAtTBClinic]						=	b.[RegistrationAtTBClinic],
						a.[StatusAtCCC]									=	b.[StatusAtCCC],
						a.[StatusAtPMTCT]								=	b.[StatusAtPMTCT],
						a.[StatusAtTBClinic]							=	b.[StatusAtTBClinic],
						a.[AgeAtAppointment]							=	b.[AgeAtAppointment],
						a.[AppointmentType]								=	b.[AppointmentType],
						a.[AppointmentStatus]							=	b.[AppointmentStatus],
						a.[EntryPoint]									=	b.[EntryPoint],
						a.[VisitType]									=	b.[VisitType],
						a.[DateAttended]								=	b.[DateAttended],
						a.[ConsentForSMS]								=	b.[ConsentForSMS],
						a.[SMSLanguage]									=	b.[SMSLanguage],
						a.[SMSTargetGroup]								=	b.[SMSTargetGroup],
						a.[SMSPreferredSendTime]						=	b.[SMSPreferredSendTime],
						a.[FourWeekSMSSent]								=	b.[FourWeekSMSSent],
						a.[FourWeekSMSSendDate]							=	b.[FourWeekSMSSendDate],
						a.[FourWeekSMSDeliveryStatus]					=	b.[FourWeekSMSDeliveryStatus],
						a.[FourWeekSMSDeliveryFailureReason]			=	b.[FourWeekSMSDeliveryFailureReason],
						a.[ThreeWeekSMSSent]							=	b.[ThreeWeekSMSSent],
						a.[ThreeWeekSMSSendDate]						=	b.[ThreeWeekSMSSendDate],
						a.[ThreeWeekSMSDeliveryStatus]					=	b.[ThreeWeekSMSDeliveryStatus],
						a.[ThreeWeekSMSDeliveryFailureReason]			=	b.[ThreeWeekSMSDeliveryFailureReason],
						a.[TwoWeekSMSSent]								=	b.[TwoWeekSMSSent],
						a.[TwoWeekSMSSendDate]							=	b.[TwoWeekSMSSendDate],
						a.[TwoWeekSMSDeliveryStatus]					=	b.[TwoWeekSMSDeliveryStatus],
						a.[TwoWeekSMSDeliveryFailureReason]				=	b.[TwoWeekSMSDeliveryFailureReason],
						a.[OneWeekSMSSent]								=	b.[OneWeekSMSSent],
						a.[OneWeekSMSSendDate]							=	b.[OneWeekSMSSendDate],
						a.[OneWeekSMSDeliveryStatus]					=	b.[OneWeekSMSDeliveryStatus],
						a.[OneWeekSMSDeliveryFailureReason]				=	b.[OneWeekSMSDeliveryFailureReason],
						a.[OneDaySMSSent]								=	b.[OneDaySMSSent],
						a.[OneDaySMSSendDate]							=	b.[OneDaySMSSendDate],
						a.[OneDaySMSDeliveryStatus]						=	b.[OneDaySMSDeliveryStatus],
						a.[OneDaySMSDeliveryFailureReason]				=	b.[OneDaySMSDeliveryFailureReason],
						a.[MissedAppointmentSMSSent]					=	b.[MissedAppointmentSMSSent],
						a.[MissedAppointmentSMSSendDate]				=	b.[MissedAppointmentSMSSendDate],
						a.[MissedAppointmentSMSDeliveryStatus]			=	b.[MissedAppointmentSMSDeliveryStatus],
						a.[MissedAppointmentSMSDeliveryFailureReason]	=	b.[MissedAppointmentSMSDeliveryFailureReason],
						a.[TracingCalls]								=	b.[TracingCalls],
						a.[TracingSMS]									=	b.[TracingSMS],
						a.[TracingHomeVisits]							=	b.[TracingHomeVisits],
						a.[TracingOutcome]								=	b.[TracingOutcome],
						a.[TracingOutcomeDate]							=	b.[TracingOutcomeDate],
						a.[DateReturnedToCare]							=	b.[DateReturnedToCare],
						a.[DaysDefaulted]								=	b.[DaysDefaulted];

		
	END