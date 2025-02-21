
BEGIN

			MERGE [ODS].[Mhealth].[Mhealth_FacilityReferral_Patient] AS a
				USING(SELECT DISTINCT [ReferralPK]
									  ,[ReferralPKHash]
									  ,[PatientID]
									  ,[PatientIDHash]
									  ,[ReferralType]
									  ,[TransferOutDate]
									  ,[TransferOutPartnerName]
									  ,[TransferOutSiteCode]
									  ,[TransferOutFacilityName]
									  ,[TransferInDate]
									  ,[TransferInPartnerName]
									  ,[TransferInSiteCode]
									  ,[TransferInFacilityName]
									  ,[TransferStatus]
								  FROM [MhealthCentral].[dbo].[CT_PatientReferral]
					) AS b
						ON(
						    a.[UshauriReferralPK]   = b.[ReferralPK] and
						    a.TransferoutDate       = b.TransferoutDate
						)

					WHEN NOT MATCHED THEN
						INSERT([UshauriReferralPK],[UshauriReferralPKHash],PatientID,PatientIDHash,ReferralType,TransferOutDate,TransferOutPartnerName,TransferOutSiteCode,TransferOutFacilityName,TransferInDate,TransferInPartnerName,TransferInSiteCode,TransferInFacilityName,TransferStatus,LoadDate)
						VALUES(ReferralPK,ReferralPKHash,PatientID,PatientIDHash,ReferralType,TransferOutDate,TransferOutPartnerName,TransferOutSiteCode,TransferOutFacilityName,TransferInDate,TransferInPartnerName,TransferInSiteCode,TransferInFacilityName,TransferStatus,getdate())

					WHEN MATCHED THEN
						UPDATE SET
							a.[ReferralType]=b.[ReferralType],
							a.[TransferOutDate]=b.[TransferOutDate],
							a.[TransferOutPartnerName]=b.[TransferOutPartnerName],
							a.[TransferOutSiteCode]=b.[TransferOutSiteCode],
							a.[TransferOutFacilityName]=b.[TransferOutFacilityName],
							a.[TransferInDate]=b.[TransferInDate],
							a.[TransferInPartnerName]=b.[TransferInPartnerName],
							a.[TransferInSiteCode]=b.[TransferInSiteCode],
							a.[TransferInFacilityName]=b.[TransferInFacilityName],
							a.[TransferStatus]=b.[TransferStatus];

	END
