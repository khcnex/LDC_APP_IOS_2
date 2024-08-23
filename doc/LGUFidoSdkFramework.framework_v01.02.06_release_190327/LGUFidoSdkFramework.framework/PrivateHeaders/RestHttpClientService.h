#import <UIKit/UIKit.h>
#import "JSON.h"
#import "OrderedDictionary.h"

@interface RestHttpClientService : NSObject

-(OrderedDictionary *) httpGetSend:(NSString *) uri header:(NSDictionary *)header;
-(OrderedDictionary *) httpPostSend:(NSString *) ip uri:(NSString *)uri header:(NSDictionary *)header body:(NSString *)body contentType:(NSString *)contentType;
-(OrderedDictionary *) httpPutSend:(NSString *) ip uri:(NSString *)uri header:(NSDictionary *)header body:(NSString *)body contentType:(NSString *)contentType;
-(OrderedDictionary *) httpDeleteSend:(NSString *) uri header:(NSDictionary *)header;

@end
