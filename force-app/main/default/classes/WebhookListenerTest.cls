@isTest
private class WebhookListenerTest {
    
    private static final String webhookSubscriptionName = 'Test Subscription';
    private static final String API_Key = '320bed05-a290-41c5-b3e1-6d09f2c85aa8';
    
    @TestSetup
    private static void setup() {
        Webhook_Subscription__c webhookSubscription = new Webhook_Subscription__c(
        	Name = webhookSubscriptionName,
            API_Key__c = API_Key,
			Handler_Class_Name__c = 'testWebhookHandler'
        );
        insert webhookSubscription;
    }
    
    private static String getTestApiKey() {
        Webhook_Subscription__c webhookSubscription = [
            SELECT Id, Name, API_Key__c
            FROM Webhook_Subscription__c
            WHERE Name = :webhookSubscriptionName
            LIMIT 1
        ];
        return webhookSubscription.API_Key__c;
    }
    
    @isTest
    private static void testHandlePostSuccess() {
        RestContext.response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://nosto.my.salesforce.com/services/apexrest/webhook/';
        request.httpMethod = 'POST';
        request.addHeader('API-Key', getTestApiKey());
        String body = 
            '{' + 
            	'"key": "value",' +
            	'"list": [' + 
            		'{' + 
            			'"objectName": "Name1",' + 
            			'"objectBool": true,' +
            			'"objectInt": 123' +
            		'},' +
            		'{' + 
            			'"objectName": "Name2",' + 
            			'"objectBool": false,' +
            			'"objectInt": 456' +
            		'}' +
            	']' +
            '}';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        WebhookListener.handlePost();
        
        String responseBody = RestContext.response.responseBody.toString();
        System.debug(responseBody);
        Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(true, (Boolean) jsonMap.get('success'));
    }
    
    @isTest
    private static void testHandlePostFailHeaderMissing() {
        RestContext.response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://nosto.my.salesforce.com/services/apexrest/webhook/';
        request.httpMethod = 'POST';
        String body = '';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        WebhookListener.handlePost();
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String,Object> jsonObj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        Boolean success = (Boolean) jsonObj.get('success');
        Map<String,Object> errorObj = (Map<String,Object>) jsonObj.get('error');
        String errorCause = (String) errorObj.get('cause');
        
        System.assertEquals(false, success);
        System.assertEquals('API-Key header missing', errorCause);
    }
    
    @isTest
    private static void testHandlePostFailInvalidKey() {
        RestContext.response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://nosto.my.salesforce.com/services/apexrest/webhook/';
        request.httpMethod = 'POST';
        request.addHeader('API-Key', 'invalidKey');
        String body = '';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        WebhookListener.handlePost();
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String,Object> jsonObj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        Boolean success = (Boolean) jsonObj.get('success');
        Map<String,Object> errorObj = (Map<String,Object>) jsonObj.get('error');
        String errorCause = (String) errorObj.get('cause');
        
        System.assertEquals(false, success);
        System.assertEquals('API-Key invalid', errorCause);
    }
    
    @isTest
    private static void testHandlePostFailHandlerNotFound() {
        RestContext.response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://nosto.my.salesforce.com/services/apexrest/webhook/';
        request.httpMethod = 'POST';
        request.addHeader('API-Key', getTestApiKey());
        Webhook_Subscription__c webhookSubscription = [
            SELECT Id
            FROM Webhook_Subscription__c
            WHERE Name = :webhookSubscriptionName
            LIMIT 1
        ];
        webhookSubscription.Handler_Class_Name__c = 'modifiedHandlerTest';
        update webhookSubscription;
        String body = '';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        WebhookListener.handlePost();
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String,Object> jsonObj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        Boolean success = (Boolean) jsonObj.get('success');
        Map<String,Object> errorObj = (Map<String,Object>) jsonObj.get('error');
        String errorCause = (String) errorObj.get('cause');
        
        System.assertEquals(false, success);
        System.assertEquals('Handler not found', errorCause);
    }
    
    @isTest
    private static void testHandlePostFailHandlerExecutionFailed() {
        RestContext.response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri = 'https://nosto.my.salesforce.com/services/apexrest/webhook/';
        request.httpMethod = 'POST';
        request.addHeader('API-Key', getTestApiKey());
        String body = '';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        WebhookListener.handlePost();
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String,Object> jsonObj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        Boolean success = (Boolean) jsonObj.get('success');
        Map<String,Object> errorObj = (Map<String,Object>) jsonObj.get('error');
        String errorCause = (String) errorObj.get('cause');
        
        System.assertEquals(false, success);
        System.assertEquals('Handler execution failed', errorCause);
    }
}