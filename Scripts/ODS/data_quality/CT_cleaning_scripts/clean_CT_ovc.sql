UPDATE   [ODS].[Care].[CT_Ovc] 
SET  [ODS].[Care].[CT_Ovc].PartnerOfferingOVCServices= lkp_PartnerOfferingOVCServices.target_name  
from [ODS].[Care].[CT_Ovc] 
INNER JOIN ods.lkp.lkp_PartnerOfferingOVCServices  
ON [ODS].[Care].[CT_Ovc].PartnerOfferingOVCServices = lkp_PartnerOfferingOVCServices.source_name
GO