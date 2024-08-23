#import <Foundation/Foundation.h>

@interface AsyncTask : NSObject
{
    NSArray *parameters;
}

- (void) executeParameters: (NSArray *) params;
- (void) onPreExecute;
- (NSInteger) doInBackground;
- (void) onPostExecute: (NSInteger) result;
@end
