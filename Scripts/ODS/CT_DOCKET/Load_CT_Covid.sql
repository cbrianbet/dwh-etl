
BEGIN

		DECLARE	@MaxCovid19AssessmentDate_Hist			DATETIME,
				    @Covid19AssessmentDate					DATETIME

		SELECT @MaxCovid19AssessmentDate_Hist =  MAX(MaxCovid19AssessmentDate) FROM [ODS_Logs].[dbo].[CT_Covid_Log]  (NoLock)
		SELECT @Covid19AssessmentDate = MAX(Covid19AssessmentDate) FROM [DWAPICentral].[dbo].[CovidExtract](NoLock)

		INSERT INTO  [ODS_Logs].[dbo].[CT_Covid_Log](MaxCovid19AssessmentDate,LoadStartDateTime)
		VALUES(@MaxCovid19AssessmentDate_Hist,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_Covid]
			MERGE [ODS].[Care].[CT_Covid] AS a
				USING(SELECT distinct P.[PatientPID] AS PatientPK
							,P.[PatientCccNumber] AS PatientID
							,P.[Emr]
							,P.[Project]
							,F.Code AS SiteCode
							,F.Name AS FacilityName
							,C.[VisitID]
							,Cast(C.[Covid19AssessmentDate] as Date)[Covid19AssessmentDate]
							,[ReceivedCOVID19Vaccine]
							,Cast([DateGivenFirstDose] as date) [DateGivenFirstDose]
							,[FirstDoseVaccineAdministered]
							,Cast([DateGivenSecondDose] as Date)[DateGivenSecondDose]
							,[SecondDoseVaccineAdministered]
							,[VaccinationStatus]
							,[VaccineVerification]
							,[BoosterGiven]
							,[BoosterDose]
							,Cast([BoosterDoseDate] as Date)[BoosterDoseDate]
							,[EverCOVID19Positive]
							,Cast([COVID19TestDate] as Date) As [COVID19TestDate]
							,[PatientStatus]
							,[AdmissionStatus]
							,[AdmissionUnit]
							,[MissedAppointmentDueToCOVID19]
							,[COVID19PositiveSinceLasVisit]
							,Cast([COVID19TestDateSinceLastVisit] as Date)[COVID19TestDateSinceLastVisit]
							,[PatientStatusSinceLastVisit]
							,[AdmissionStatusSinceLastVisit]
							,Cast([AdmissionStartDate] as Date)[AdmissionStartDate]
							,Cast([AdmissionEndDate] as Date)[AdmissionEndDate]
							,[AdmissionUnitSinceLastVisit]
							,[SupplementalOxygenReceived]
							,[PatientVentilated]
							,[TracingFinalOutcome]
							,[CauseOfDeath]
							,BoosterDoseVerified
							,[Sequence]
							,COVID19TestResult
							,P.ID
							,C.[Date_Created]
							,C.[Date_Last_Modified]
							,C.RecordUUID
							,C.voided
							,VoidingSource = Case
													when C.voided = 1 Then 'Source'
													Else Null
											END
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
							INNER JOIN [DWAPICentral].[dbo].[CovidExtract](NoLock) C  ON C.[PatientId]= P.ID
							INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id  AND F.Voided=0
							INNER JOIN (SELECT
												a.PatientPID
												,f.code
												,InnerC.visitID
												,InnerC.Covid19AssessmentDate
												,InnerC.voided
												,Max(InnerC.ID) As MaxID
												,Max(cast(InnerC.created as date))MaxCreated
												FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) a
													INNER JOIN [DWAPICentral].[dbo].[CovidExtract](NoLock) InnerC  ON InnerC.[PatientId]= a.ID
													INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON a.[FacilityId] = F.Id  AND F.Voided=0
												GROUP BY	a.PatientPID
															,f.code
															,InnerC.visitID
															,InnerC.Covid19AssessmentDate
															,InnerC.voided
										)tn
							ON	P.PatientPID = tn.PatientPID and
								F.code = tn.code and
								 C.ID = tn.MaxID and
								cast(C.Created as date) = tn.MaxCreated
						WHERE P.gender != 'Unknown' AND F.code >0) AS b
						ON(
							 a.SiteCode = b.SiteCode
							and  a.PatientPK  = b.PatientPK
							and a.visitID = b.visitID
							AND a.Covid19AssessmentDate = b.Covid19AssessmentDate
							and a.voided   = b.voided
							--and a.ID = b.ID
						)

					WHEN NOT MATCHED THEN
						INSERT(
								ID
								,PatientPK
								,PatientID
								,Emr
								,Project
								,SiteCode
								,FacilityName
								,VisitID
								,Covid19AssessmentDate
								,ReceivedCOVID19Vaccine
								,DateGivenFirstDose
								,FirstDoseVaccineAdministered
								,DateGivenSecondDose
								,SecondDoseVaccineAdministered
								,VaccinationStatus
								,VaccineVerification
								,BoosterGiven
								,BoosterDose
								,BoosterDoseDate
								,EverCOVID19Positive
								,COVID19TestDate
								,PatientStatus
								,AdmissionStatus
								,AdmissionUnit
								,MissedAppointmentDueToCOVID19
								,COVID19PositiveSinceLasVisit
								,COVID19TestDateSinceLastVisit
								,PatientStatusSinceLastVisit
								,AdmissionStatusSinceLastVisit
								,AdmissionStartDate
								,AdmissionEndDate
								,AdmissionUnitSinceLastVisit
								,SupplementalOxygenReceived
								,PatientVentilated
								,TracingFinalOutcome
								,CauseOfDeath
								,BoosterDoseVerified
								,[Sequence]
								,COVID19TestResult
								,[Date_Created]
								,[Date_Last_Modified]
								, RecordUUID
								,voided
								,VoidingSource
								,LoadDate
							)
						VALUES(
								ID
								,PatientPK
								,PatientID
								,Emr
								,Project
								,SiteCode
								,FacilityName
								,VisitID
								,Covid19AssessmentDate
								,ReceivedCOVID19Vaccine
								,DateGivenFirstDose
								,FirstDoseVaccineAdministered
								,DateGivenSecondDose
								,SecondDoseVaccineAdministered
								,VaccinationStatus
								,VaccineVerification
								,BoosterGiven
								,BoosterDose
								,BoosterDoseDate
								,EverCOVID19Positive
								,COVID19TestDate
								,PatientStatus
								,AdmissionStatus
								,AdmissionUnit
								,MissedAppointmentDueToCOVID19
								,COVID19PositiveSinceLasVisit
								,COVID19TestDateSinceLastVisit
								,PatientStatusSinceLastVisit
								,AdmissionStatusSinceLastVisit
								,AdmissionStartDate
								,AdmissionEndDate
								,AdmissionUnitSinceLastVisit
								,SupplementalOxygenReceived
								,PatientVentilated
								,TracingFinalOutcome
								,CauseOfDeath
								,BoosterDoseVerified
								,[Sequence]
								,COVID19TestResult
								,[Date_Created]
								,[Date_Last_Modified]
								, RecordUUID
								,voided
								,VoidingSource
								,Getdate()
							)

					WHEN MATCHED THEN
						UPDATE SET
						a.PatientID						=b.PatientID,
						a.DateGivenFirstDose				=b.DateGivenFirstDose,
						a.FirstDoseVaccineAdministered		=b.FirstDoseVaccineAdministered,
						a.DateGivenSecondDose				=b.DateGivenSecondDose,
						a.SecondDoseVaccineAdministered		=b.SecondDoseVaccineAdministered,
						a.VaccinationStatus					=b.VaccinationStatus,
						a.VaccineVerification				=b.VaccineVerification,
						a.BoosterGiven						=b.BoosterGiven,
						a.BoosterDose						=b.BoosterDose,
						a.BoosterDoseDate					=b.BoosterDoseDate,
						a.EverCOVID19Positive				=b.EverCOVID19Positive,
						a.COVID19TestDate					=b.COVID19TestDate,
						a.PatientStatus						=b.PatientStatus,
						a.AdmissionStatus					=b.AdmissionStatus,
						a.AdmissionUnit						=b.AdmissionUnit,
						a.MissedAppointmentDueToCOVID19		=b.MissedAppointmentDueToCOVID19,
						a.COVID19PositiveSinceLasVisit		=b.COVID19PositiveSinceLasVisit,
						a.COVID19TestDateSinceLastVisit		=b.COVID19TestDateSinceLastVisit,
						a.PatientStatusSinceLastVisit		=b.PatientStatusSinceLastVisit,
						a.AdmissionStatusSinceLastVisit		=b.AdmissionStatusSinceLastVisit,
						a.AdmissionStartDate				=b.AdmissionStartDate,
						a.AdmissionEndDate					=b.AdmissionEndDate,
						a.AdmissionUnitSinceLastVisit		=b.AdmissionUnitSinceLastVisit,
						a.SupplementalOxygenReceived		=b.SupplementalOxygenReceived,
						a.PatientVentilated					=b.PatientVentilated,
						a.TracingFinalOutcome				=b.TracingFinalOutcome,
						a.CauseOfDeath						=b.CauseOfDeath,
						a.BoosterDoseVerified				=b.BoosterDoseVerified,
						a.[Sequence]						=b.[Sequence],
						a.COVID19TestResult					=b.COVID19TestResult,
						a.[Date_Created]					=b.[Date_Created],
						a.[Date_Last_Modified]				=b.[Date_Last_Modified],
						a.RecordUUID			=b.RecordUUID,
						a.voided		=b.voided;


				UPDATE [ODS_Logs].[dbo].[CT_Covid_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxCovid19AssessmentDate = @MaxCovid19AssessmentDate_Hist;



	END
