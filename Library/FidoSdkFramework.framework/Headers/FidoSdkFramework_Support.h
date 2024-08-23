//
//  FidoSdkFramework_Support.h
//  FidoSdkFramework
//
//  Created by ATS on 2016. 1. 29..
//  Copyright © 2016년 h. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@protocol RpUafDelegate <NSObject>
- (void) support_openURL_clientToRp:(NSURL *)url;
@end

@protocol RpManagerDelegate <NSObject>
- (NSArray*) support_getAuthnrSetList;
@end

@interface FidoSdkFramework_Support : NSObject


@property (nonatomic, strong) id<RpUafDelegate> m_uafDelegate;
@property (nonatomic, strong) id<RpManagerDelegate> m_managerDelegate;

+ (id)sharedInstance;
- (void)setUAFdele:(id)dele1 ManagerDele:(id)dele2;


//FIDOClient에서 RPClient의 SDK형태를 지원하기 위해 통신하는 함수 (Not use x-callback)
+ (BOOL) openURL_rpToClient:(NSURL *)url;
- (BOOL) openURL_clientToRp:(NSURL *)url;


//인증장치의 TouchID 안내 String을 호출하는 함수 (함수 호출 전, FidoManager.touchidStr가 세팅되어 있어야 한다.) / FC에서 사용
+ (NSArray*) getAuthnrSetList;

@end
