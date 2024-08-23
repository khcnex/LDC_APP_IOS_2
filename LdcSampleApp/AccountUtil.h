#import <UIKit/UIKit.h>
#import "TelUtil.h"
//#import <LGUFidoSdkFramework/LGUFidoSdkFramework.h>
#import <LGUSdkFramework/LGUSdkFramework.h>

@interface AccountUtil : NSObject

+(NSString *) AUTO_ACCOUNT;
+(NSString *) SNS_AUTO_ACCOUNT;
+(NSString *) EASY_ACCOUNT;
+(NSString *) NORMAL_ACCOUNT;
+(NSString *) DAS_LIBRARY;
+(NSString *) SERVICE_CD;

+(Boolean) setAutoAccount:(NSString *) USER_ID SSO_KEY:(NSString *)SSO_KEY;
+(NSDictionary *) getAutoAccount;
+(Boolean) setSNSAutoAccount:(NSString *) SNSID_KEY SNS_CD:(NSString *)SNS_CD SNS_USER_ID:(NSString *)SNS_USER_ID;
+(NSDictionary *) getSNSAutoAccount;
+(Boolean) deleteAutoAccount;
+(Boolean) deleteSNSAutoAccount;
+(Boolean) setEasyAccount:(NSString *) USER_ID;
+(NSString *) getEasyAccount;
+(Boolean) deleteEasyAccount;
+(Boolean) setNormalAccount:(NSString *) USER_ID ONEID_KEY:(NSString *)ONEID_KEY;
+(NSDictionary *) getNormalAccount;
+(Boolean) deleteNormalAccount;
+(Boolean) setDasLibraryConfig:(NSString *) key value:(NSString *)value;

@end
