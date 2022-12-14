public with sharing class LWCService {
    
    @testVisible
    private static FXService fxService;
    @testVisible
    private static Logger logger;
    @testVisible
    private static Emailer emailer;

    static {
        fxService = new FXService();
        logger = new Logger();
        emailer = new Emailer();
    }

    public class Response {
        public Boolean isSuccess {get;set;}
        public String message {get;set;}
        public Object data {get;set;}

        public Response() {
            this.isSuccess = false;
        }
    }

    @AuraEnabled
    public static Response GetFXRate(String fromCurr, String toCurr) {

        Response response = new Response();
        
        Integer maxRetries = 3;
        Integer retryCount = 0;
        while(!response.isSuccess && retryCount < maxRetries) {
            try {
                Decimal rate = fxService.getRate(fromCurr, toCurr);
                response.isSuccess = true;
                response.data = rate;
            } catch(Exception ex) {
                response.isSuccess = false;
                response.message = Label.UserReadableMessage;

                logger.log(ex.getMessage());
            } finally {
                retryCount++;
            }
        }

        if(!response.isSuccess) {
            emailer.notifyAdmins();
        }

        return response;
    }
}
