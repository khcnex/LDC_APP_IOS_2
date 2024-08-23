//
//  FidoUaf.h
//  FidoSdkFramework
//
//  Created by h on 2015. 9. 18..
//  Copyright © 2015년 h. All rights reserved.
//

#ifndef FidoUaf_h
#define FidoUaf_h

#import <Foundation/Foundation.h>
#import "FidoSdkFramework_Support.h"

@protocol FidoAppDelegate <NSObject>
-(void) receiveFidoMessage:(NSDictionary *)msgDict;
@end

@interface FidoUaf : NSObject<RpUafDelegate> {
    NSError* error;
    NSMutableDictionary *header;
    NSString *saveId;
    NSString *savedMessage;
    BOOL    log;
    NSString *requestUrl;
    NSString *responseUrl;
    BOOL useCompletion;
}

+ (id)sharedInstance;
- (bool) handleUrl:(NSURL *)url;
- (bool) registrationUser:(NSString *)userId ;
- (bool) handleServerData:(NSString *)recv;
- (void) saveHeader:(NSMutableDictionary *)header;

- (bool) discovery;
- (bool) setAuthnr;
+ (NSString * ) getDiscoverSimplefromJson : (NSString * ) json;
+ (NSString*) objectToJson:(id)mutable;

- (bool)registrationUserLGU:(NSString *)data channel:(NSString *)channel;
- (bool)authenticateUserLGU:(NSString *)data channel:(NSString *)channel;
- (bool)deRegistrationUserLGU:(NSString *)data channel:(NSString *)channel;
- (bool)discoveryLGU;
- (bool)initAppletLGU;

- (NSString *)makeDataToSendFidoClient:(NSString *)data channel:(NSString *)channel state:(int)state;
- (void)sendDataToClient:(NSString *)data;

- (void) getServiceRqeust:(NSString *)jsonString serverUrl:(NSString *)serverUrl type:(NSString*) type;
- (void) getJobInfoRqeust:(NSString *)jsonString serverUrl:(NSString *)serverUrl;

- (BOOL) support_openURL_clientToRp:(NSURL *)url;

@property(strong , nonatomic) id<FidoAppDelegate> delegate;
@property(strong , nonatomic) NSError* error;
@property(strong , nonatomic) NSMutableDictionary* header;
@property(strong , nonatomic) NSString* saveId;
@property(strong , nonatomic) NSString* savedMessage;
@property   BOOL useCompletion;
@property   BOOL log;
@property(strong , nonatomic) NSString *requestUrl;
@property(strong , nonatomic) NSString *responseUrl;
@end

#endif
