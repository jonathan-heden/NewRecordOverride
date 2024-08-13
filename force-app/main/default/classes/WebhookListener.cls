@RestResource(urlMapping='/webhook/*')
global class WebhookListener {
    
	@HttpPost
	global static void handlePost() {
        WebhookResult result = new WebhookResult();
        result.apiKeyHeaderIncluded = checkApiKeyHeaderIncluded();
        result.apiKeyValid = validateApiKey();
        if(result.apiKeyHeaderIncluded == true && result.apiKeyValid == true) {
            String handlerName = getHandlerName();
            Callable handler = new WebhookHandler();
            handler.call(handlerName, new Map<String,Object>{
                'body' => RestContext.request.requestBody,
                'webhookResult' => result
            });
        }
        if(result.resultSuccessful()) {
            createErrorLog(result);
        }
        handleResponse(result);
	}
    // REMOVE
    private static Boolean checkApiKeyHeaderIncluded() {
        return RestContext.request.headers.get('API-Key') != null;
    }
    
    private static Boolean validateApiKey() {
        String API_Key = RestContext.request.headers.get('API-Key');
        if(API_Key == null) {
            return false;
        }
        List<Webhook_Subscription__c> webhookSubscriptions = [
            SELECT Id, Name, API_Key__c
            FROM Webhook_Subscription__c
        ];
        Set<String> apiKeys = new Set<String>();
        for(Webhook_Subscription__c webhook : webhookSubscriptions) {
            apiKeys.add(webhook.API_Key__c);
        }
        return apiKeys.contains(API_Key);
    }
    
    private static String getHandlerName() {
        String API_Key = RestContext.request.headers.get('API-Key');
        Webhook_Subscription__c webhookSubscription = [
            SELECT Id, Handler_Class_Name__c
            FROM Webhook_Subscription__c
            WHERE API_Key__c = :API_Key
        ];
        return webhookSubscription.Handler_Class_Name__c;
    }
    // REMOVE END
    
    private static void createErrorLog(WebhookResult result) {
        //TODO Create error log
    }
    
    private static void handleResponse(WebhookResult result) {
        RestResponse response = RestContext.response;
        response.statusCode = result.getResultAsHttpStatusCode();
        response.addHeader('Content-Type', 'application/json');
        String body = JSON.serialize(result);//result.printResultAsJson();
        response.responseBody = Blob.valueOf(body);
    }
    
    /**************************************** WEBHOOK RESULT ****************************************/
    
    public class WebhookResult {
        //Used to check if evaluation of the next handler in the chain of responsability should execute.
        private Boolean evaluateNext = true;
        private Webhook_Subscription__c subscription;
        
        public Boolean apiKeyHeaderIncluded;
        public Boolean apiKeyValid;
        public Boolean handlerFound;
        public Boolean handlerSuccess;
        public Exception handlerException;
        
        public Boolean resultSuccessful() {
            return apiKeyHeaderIncluded && apiKeyValid && handlerFound && handlerSuccess;
        }
        
        public Integer getResultAsHttpStatusCode() {
            return (resultSuccessful()) ? 200 : 400;
        }
        
        /*------------------- Chain Handlers -------------------*/
        
        public WebhookResult checkApiKeyHeaderIncluded() {
            if(evaluateNext == false) {
                return this;
            }
            apiKeyHeaderIncluded = RestContext.request.headers.get('API-Key') != null;
            evaluateNext = apiKeyHeaderIncluded;
            return this;
        }
        
        public WebhookResult validateApiKey() {
            if(evaluateNext == false) {
                return this;
            }
            String API_Key = RestContext.request.headers.get('API-Key');
            List<Webhook_Subscription__c> webhookSubscriptions = [
                SELECT Id, Name, API_Key__c
                FROM Webhook_Subscription__c
                WHERE API_Key__c = :API_Key
                LIMIT 1
            ];
            if(webhookSubscriptions.size() == 1) {
                subscription = webhookSubscriptions[0];
                apiKeyValid = true;
            } else {
                apiKeyValid = false;
                evaluateNext = false;
            }
            return this;
        }
        
        public WebhookResult checkHandlerClassIsImplemented() {
            if(evaluateNext == false) {
                return this;
            }
            String className = 'WebhookHandlerAbc';
            try {
				Type.forName(className).newInstance();
                handlerFound = true;
            } catch(NullPointerException npe) {
                handlerFound = false;
                evaluateNext = false;
            }
            return this;
        }
        
        public WebhookResult callHandler() {
            if(evaluateNext == false) {
                return this;
            }
            String handlerName = subscription.Handler_Class_Name__c;
            Callable handler = new WebhookHandler();
            handler.call(handlerName, new Map<String,Object>{
                'body' => RestContext.request.requestBody,
                'webhookResult' => this
            });
            return this;
        }
        
        /*-------------------- JSON Methods --------------------*/
        
        public String printResultAsJson() {
            String resultAsJson = 
            	'{' + 
            		'"success": ' + resultSuccessful() + ',' +
            		'"error": ' + getErrorAsJson() +
                '}';
            return resultAsJson;
        }
        
        private String getErrorAsJson() {
            if(resultSuccessful()) {
                return 'null';
            } else {
                String errorAsJson =
                    '{' +
            			'"cause": "' + getErrorCause() + '",' +
            			'"message": "' + getErrorMessage() + '",' + 
            			'"exception": ' + getExceptionAsJson() +
            		'}';
                return errorAsJson;
            }
        }
        
        private String getErrorCause() {
            if(apiKeyHeaderIncluded == false) {
                return 'API-Key header missing';
            } else if(apiKeyValid == false) {
                return 'API-Key invalid';
            } else if(handlerFound == false) {
                return 'Handler not found';
            } else if(handlerSuccess == false) {
                return 'Handler execution failed';
            }
            //No error
            return '';
        }
        
        private String getErrorMessage() {
            if(apiKeyHeaderIncluded == false) {
                return 'The request did not include the required API-Key HTTP header.';
            } else if(apiKeyValid == false) {
                return 'The provided API-Key is not valid.';
            } else if(handlerFound == false) {
                return 'No handler method was found. Please speak to a developer to address this issue.';
            } else if(handlerSuccess == false) {
                return 'An exception was thrown when the handler method was executed.';
            }
            //No error
            return '';
        }
        
        private String getExceptionAsJson() {
            if(handlerException == null) {
                return 'null';
            } else {
                String exceptionAsJson = 
                    '{' +
                    	'"type": "' + handlerException.getTypeName() + '",' +
                    	'"message": "' + handlerException.getMessage() + '",' +
                    	'"stack-trace": "' + handlerException.getStackTraceString().replace('\n', ' | ') + '"' +
                    '}';
                return exceptionAsJson;
            }
        }
    }
}