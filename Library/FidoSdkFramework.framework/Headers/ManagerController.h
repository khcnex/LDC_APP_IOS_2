//
//  ManagerController.h
//  FidoSdkFramework
//
//  Created by Admin on 2018. 4. 7..
//  Copyright © 2018년 h. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FidoManager.h"

@protocol ManagerControllerDelegate <NSObject>
@optional
-(void)fidoSdkActionSuccess:(int)requestCode resultData:(NSDictionary *)result;
-(void)fidoSdkActionFail:(int)requestCode errorData:(NSDictionary *)error;
-(void)showRegisterationGUI:(AuthenticatorType)regType;
-(void)showAuthenticationGUI:(AuthenticatorType)authType;
@end

@interface ManagerController : NSObject
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, assign) int serverTarget;
@property (nonatomic, strong) NSString *fidoSdkPartnerCode;
@property (nonatomic, strong) NSDictionary *fidoSettingData;
@property (nonatomic, assign) id<ManagerControllerDelegate> delegate;
@property (nonatomic, assign) id<clientUrlSchemeDelegate> clientUrlSchemeDelegate;

+(ManagerController *)sharedSingleton;

// SDK 주요 기능
-(NSDictionary *)getDeviceId;
-(NSDictionary *)getSurrogateKey;
-(NSDictionary *)checkSupportDevice;
-(void)checkInfo:(NSDictionary *)reqData requestCode:(int)reqCode;
-(void)resetInfo:(int)reqCode;
-(void)registration:(AuthenticatorType)type requestCode:(int)reqCode;
-(void)authentication:(AuthenticatorType)type requestCode:(int)reqCode;
-(void)deregistration:(AuthenticatorType)type requestCode:(int)reqCode;
-(void)setMainAuthenticatorType:(AuthenticatorType)type requestCode:(int)reqCode;

// PIN, TouchID 입력 관련
-(void)returnRegPinCode:(NSString *)plainPinCode failCallBack:(nullable void (^)(int errorCode))callBack;
-(void)returnAuthPinCode:(NSString *)plainPinCode failCallBack:(nullable void (^)(int errorCode))callBack;
-(void)returnRegPinCodeCancel;
-(void)returnAuthPinCodeCancel;
-(void)returnRegTouchID;
-(void)returnAuthTouchID;

@end
