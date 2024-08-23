//
//  FidoSdkFramework.h
//  FidoSdkFramework
//
//  Created by mins on 2016. 1. 14..
//  Copyright © 2016년 h. All rights reserved.
//

#ifndef FidoSdk_h
#define FidoSdk_h

#import <UIKit/UIKit.h>
#import "FidoDefine.h"
#import "FidoGlobalConfig.h"
#import "FidoSdkFramework_Support.h"
#import "FidoKdf.h"


@protocol responseDelegate <NSObject>
-(void)getResponseData:(NSString *)response type:(int)type;
@end

@protocol clientUrlSchemeDelegate <NSObject>
@optional
-(void)returnProcessReg:(NSMutableArray*)arrData error:(NSError **)error;
-(void)returnProcessAuth:(NSMutableArray*)arrData error:(NSError **)error;
-(void)returnFacetIdList:(NSString *)trustedFacets;
@end



@interface FidoManager :NSObject

@property int m_nType;
@property (nonatomic, retain) NSString *responseData;
@property (nonatomic, assign) id<responseDelegate> delegate;

+ (FidoManager*) sharedSingleton;

- (void)registerWithData:(NSString *)data channel:(NSString *)channel;
- (void)registerWithData:(NSString *)data channel:(NSString *)channel type:(int)type;
- (void)authenticateWithData:(NSString *)data channel:(NSString *)channel;
- (void)authenticateWithData:(NSString *)data channel:(NSString *)channel type:(int)type;
- (void)deRegisterWithData:(NSString *)data channel:(NSString *)channel;
- (void)discover;
- (void)initAuthenticator;
- (void)resetPasscode;
- (void)doOperation:(int)type data:(NSString *)data channel:(NSString *)channel;

- (BOOL)checkData:(NSString *)json;
- (BOOL)deviceAvailableOS;
- (BOOL)isTouchIDReg;
- (BOOL)isDeviceSupportTouchID;
- (NSDictionary*)getTelephonyInfo;
- (NSDictionary*)getOsInfo;

@end

#endif /* FidoSdk_h */
