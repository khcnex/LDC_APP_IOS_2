#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"

@interface Util : NSObject

+ (NSData *) changeData:(NSString *) target;
+ (NSData *) dataFromHexString:(NSString *) target;
+ (NSString *) createSHA512:(NSString *) input;
+ (NSString *) createBASE64:(NSData *) data;
+ (NSString *) getBase64encode:(NSString *) content;
+ (NSString *) getBase64decode:(NSString *) encoding;
+ (void) showToastMsg:(NSString *) msg view:(UIViewController *)view;

@end
