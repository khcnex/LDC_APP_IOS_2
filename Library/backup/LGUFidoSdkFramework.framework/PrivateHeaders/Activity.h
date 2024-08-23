#import <UIKit/UIKit.h>

@interface Activity : NSObject
extern int const RESULT_OK;
extern int const RESULT_CANCELED;

+(void)startActivityForResult:(UIViewController *)ctCtext class:(UIViewController *)class intent:(NSMutableDictionary *)intent requestCode:(int)requestCode;

@end
