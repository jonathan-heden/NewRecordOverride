@isTest
private class WebhookHandlerTest {

    @isTest
    private static void testTestWebhookHandler() {
        String bodyString = 
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
        Blob body = Blob.valueOf(bodyString);
        WebhookListener.WebhookResult result = new WebhookListener.WebhookResult();
        String handlerName = 'testWebhookHandler';
        Test.startTest();
        Callable handler = new WebhookHandler();
        Boolean success = (Boolean) handler.call(handlerName, new Map<String,Object>{
            'body' => body,
            'webhookResult' => result
        });
        Test.stopTest();
        
        System.assert(success);
    }
}