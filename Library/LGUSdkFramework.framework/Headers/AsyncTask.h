#import <Foundation/Foundation.h>

@interface AsyncTask : NSObject
{
    NSArray *parameters;
}

- (void) executeParameters: (NSArray *) params;
- (void) preExecute;
- (NSInteger) doInBackground;
- (void) postExecute: (NSInteger) result;
@end
