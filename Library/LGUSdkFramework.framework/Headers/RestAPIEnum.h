#import <UIKit/UIKit.h>

typedef const struct {
    __unsafe_unretained NSString *method;
    __unsafe_unretained NSString *uri;
} RestAPIenum;

@interface RestAPIEnum : NSObject
//extern RestAPIenum const SSOConfirm_rest;
//extern RestAPIenum const SSODelete_rest;
//extern RestAPIenum const CtnConfirm_rest;
+(RestAPIenum) SSOConfirm_rest;
+(RestAPIenum) SSODelete_rest;
+(RestAPIenum) CtnConfirm_rest;
@end
