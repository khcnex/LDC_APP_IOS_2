#import <UIKit/UIKit.h>
#import "IntegrationContants.h"
#import "RestAPIParameterEnum.h"
#import "RestAPIEnum.h"
#import "RestHttpClientService.h"
#import "OrderedDictionary.h"


@interface IntegrationService : NSObject
{
    RestHttpClientService *restHttpClientService;
}

extern IntegrationService const *instance;
-(OrderedDictionary *) autoLogin:(NSString *) SERVICE_CD USER_ID:(NSString *)USER_ID SSO_KEY:(NSString *)SSO_KEY;
-(NSDictionary *) deleteSSO:(NSString *)SERVICE_CD USER_ID:(NSString *)USER_ID SSO_KEY:(NSString *)SSO_KEY;
+(const IntegrationService *) getInstance;
@end

@interface IntegrationService(private)

-(NSDictionary *) requestSSOConfrim:(NSDictionary *) requestMap;
-(NSDictionary *) requestSSODelete:(NSDictionary *) requestMap;

@end
