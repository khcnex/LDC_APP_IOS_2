#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>
//#import <LGUFidoSdkFramework/LGUFidoSdkFramework.h>
#import <LGUSdkFramework/LGUSdkFramework.h>

@interface TelUtil : NSObject
{
    
}

-(void)openTelScreen:(NSString *)telnumber;
+(NSString *)AES256Encode:(NSString *)target key:(NSString *)key;
+(NSString *)AES256Decode:(NSString *)target key:(NSString *)key;
@end
