#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <mach/kern_return.h>

@interface AuthenticatorUtil : NSObject

+(NSString *) getCTN;
+(NSString *) getNetworkOperatorName;
+(NSArray *) getDasLibraryConfig;
+(NSString *) getUSIMSerialNo;
+ (NSString *) getCountryCode;

@end
