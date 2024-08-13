public class WebhookHandler implements Callable {

    public Object call(String handlerName, Map<String, Object> args) {
        Blob body = (Blob) args.get('body');
        WebhookListener.WebhookResult result = (WebhookListener.WebhookResult) args.get('webhookResult');
        //Assume handler is found and then set to false in else-block of switch statement below if now handler has been defined.
        Boolean handlerFound = true;
        Exception handlerException;
        try {
            switch on handlerName {
                when 'testWebhookHandler' {
                    testWebhookHandler(body);
                }
                when 'marketoCampaignWebhook' {
                    marketoCampaignWebhookHandler(body);
                }
                when else {
                    handlerFound = false;
                }
            }
        } catch(Exception e) {
            handlerException = e;
        }
        result.handlerFound = handlerFound;
        result.handlerSuccess = (handlerException == null);
        result.handlerException = handlerException;
        
        return (result.handlerFound && result.handlerSuccess);
    }
    
    /*############################## HANDLER METHODS ##############################*/
    
    private static void testWebhookHandler(Blob body) {
        Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(body.toString());
        String value = (String) jsonMap.get('key');
        String modifiedValue = value.replace('value', 'modifiedValue');
    }
    
    public static void marketoCampaignWebhookHandler(Blob body) {
        String bodyString = body.toString();
        Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(body.toString());
        String campaignName = (String) jsonMap.get('CampaignName');
        Id recordId = (Id) jsonMap.get('SFDC_ID');
        Schema.SObjectType recordSObjectType = recordId.getSobjectType();
        String utmCampaign = (String) jsonMap.get('UtmCampaign');
        String utmContent = (String) jsonMap.get('UtmContent');
        String utmMedium = (String) jsonMap.get('UtmMedium');
        String utmSource = (String) jsonMap.get('UtmSource');
        String utmTerm = (String) jsonMap.get('UtmTerm');
        String engagementDateString = (String) jsonMap.get('EngagementDate');
        Date engagementDate = getDateFromString(engagementDateString);
        /*
        mkto_si__Integration_Log__c log = new mkto_si__Integration_Log__c();
		log.mkto_si__Direction__c = 'Inbound';
        log.mkto_si__Request_Body__c = 
            'CampaignName: ' + campaignName + '\n' +
            'SFDC_ID: ' + recordId + '\n' +
            'UTM Campgain: ' + utmCampaign + '\n' +
            'UTM Content: ' + utmContent + '\n' +
            'UTM Medium: ' + utmMedium + '\n' +
            'UTM Source: ' + utmSource + '\n' +
            'UTM Term: ' + utmTerm + '\n' +
            'Engagement Date: ' + engagementDate;
        log.mkto_si__Endpoint__c = 'Webhook Listener';
        insert log;
        */
        //Logic here
        CampaignMember member = [
            SELECT Id
            FROM CampaignMember
            WHERE Campaign.Name = :campaignName AND
            	  LeadId = :recordId
            LIMIT 1
        ];
        member.PM_UTM_Campaign__c = utmCampaign;
        member.PM_UTM_Content__c = utmContent;
        member.PM_UTM_Medium__c = utmMedium;
        member.PM_UTM_Source__c = utmSource;
        member.PM_UTM_Term__c = utmTerm;
        member.PM_Engagement_Date__c = engagementDate;
        update member;
    }
    
    private static Date getDateFromString(String dateString) {
        List<String> dateParts = dateString.split('-');
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        return Date.newInstance(year, month, day);
    }
}