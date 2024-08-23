#import <UIKit/UIKit.h>
#import <FidoSdkFramework/ManagerController.h>

@interface FidoUtil : NSObject

+(NSDictionary *) getCheckSupportDevice:(ManagerController *) fido;
+(NSDictionary *) getDeviceIdInfo:(ManagerController *) fido;
+(NSString *) getSurrogateKeyInfo:(ManagerController *) fido;

@end
