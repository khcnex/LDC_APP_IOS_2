//
//  FidoDefine.h
//  FidoSdkFramework
//
//  Created by mins on 2016. 1. 21..
//  Copyright © 2016년 h. All rights reserved.
//

#ifndef FidoDefine_h
#define FidoDefine_h

//#define FIDO_SDK_VER                        @"00.01.00"
//#define FIDO_SDK_INFO                       @"FidoSdkFramework-00.01.00.framework"
//#define FIDO_SDK_VER                        @"01.00.01"
//#define FIDO_SDK_INFO                       @"LGUFidoSdkFramework-01.00.01.framework"
#define FIDO_SDK_VER                          @"01.00.02"
#define FIDO_SDK_INFO                         @"LGUFidoSdkFramework-01.00.02.framework"
#define MIN_SUPPORT_IOSVERSION              9.0

typedef NS_ENUM(NSInteger, ServerTarget) {
    SERVER_DEV                          = 0, // 개발 서버
    SERVER_STAGE                        = 1, // 스테이지 서버
    SERVER_REAL                         = 2, // 운영 서버
};

typedef NS_ENUM(NSInteger, RequestCode) {
    REQ_CHECK_INFO                          = 100, // 정보 확인 요청
    REQ_RESET_INFO                          = 200, // 초기화 요청
    REQ_REG                                 = 300, // 등록 요청
    REQ_AUTH                                = 400, // 인증 요청
    REQ_DEREG                               = 500, // 삭제 요청
    REQ_SET_MAIN_AAID                       = 600, // 주 인증수단 설정 요청
};

typedef NS_ENUM(NSInteger, ResErrorCode) {
    NON_ERROR                               = 2000,
    ERROR                                   = 3000,
    CANCELED                                = 4000,
    
    // 망 에러
    NETWORK_ERROR                           = -1000,
    NETWORK_ERROR_TIME_OUT                  = -1001,
    NETWORK_ERROR_NOT_CONNECTED             = -1009,
    
    // SDK RP서버와 통신 에러
    NETWORK_API_ERROR                       = 3100,
    NETWORK_SERVER_MAINTENANCE              = 3200,
    
    // SDK 동작 에러
    ERROR_INVALID_FIDO_SETTINGS             = 3001,
    ERROR_INVALID_API_PARAMS                = 3002,
    ERROR_INVALID_SDK_USER_INFO             = 3003,
    ERROR_INVALID_SDK_VERSION               = 3004,
    ERROR_UNSUPPORTED_DEVICE                = 3005,
    ERROR_ALREADY_PROCESSING_OTHER_API      = 3006,
    
    UAF_NO_SUITABLE_AUTHENTICATOR           = 3007,
    UAF_PROTOCOL_ERROR                      = 3008,
    UAF_UNTRUSTED_FACET_ID                  = 3009,
    AUTHENTICATOR_NO_TOUCH_ID               = 3010,
    ASM_ERROR                               = 3011,
    
    PIN_EMPTY                               = 3012,
    PIN_MISMATCH                            = 3013,
    TOUCH_ID_MISMATCH                       = 3014,
};

typedef NS_ENUM(NSUInteger, AuthenticatorType) {
    PIN = 0,
    TouchID = 1
};

#define AuthenticatorMaxCount               2
#define AUTHENTICATOR_PIN                   @"PIN"
#define AUTHENTICATOR_TOUCH_ID              @"TouchID"

#define DEF_AUTHAAID_0004                   @"003A#0004"   // PIN
#define DEF_AUTHAAID_0005                   @"003A#0005"   // TouchID

#define authenticatorTypeToAAID(enum)       [@[@"003A#0004",@"003A#0005"] objectAtIndex:enum]
#define aaidToAuthenticatorType(aaid)       [@{@"003A#0004":AUTHENTICATOR_PIN, @"003A#0005":AUTHENTICATOR_TOUCH_ID} objectForKey:aaid]

// FidoSettingData
#define DEVICE_TYPE_PHONE                   @"PHONE"
#define DEVICE_TYPE_PAD                     @"PAD"
#define DEVICE_TYPE_PC                      @"PC"
#define DEVICE_TYPE_TV                      @"TV"
#define DEVICE_TYPE_SERVER                  @"SERVER"
#define DEVICE_TYPE_ETC                     @"ETC"

#define OS_TYPE_ANDROID                     @"A"
#define OS_TYPE_IOS                         @"I"
#define OS_TYPE_WINDOWS                     @"W"
#define OS_TYPE_ETC                         @"E"

#define NETWORK_TYPE_3G                     @"3G"
#define NETWORK_TYPE_4G                     @"4G"
#define NETWORK_TYPE_5G                     @"5G"
#define NETWORK_TYPE_WIFI                   @"WIFI"
#define NETWORK_TYPE_WIRE                   @"WIRE"
#define NETWORK_TYPE_ETC                    @"ETC"

#define CARRIER_NAME_LGUPLUS                @"L"
#define CARRIER_NAME_KT                     @"K"
#define CARRIER_NAME_SKT                    @"S"
#define CARRIER_NAME_ET                     @"E"


#define Bundle_ID                           [[NSBundle mainBundle] bundleIdentifier]
#define APP_BUNDDLE_ID_PREFIX               @"ios:bundle-id:"


#define kNetworkErrorCheck                  @"_networkErrorCheck"
#define kPopupMsgNotReachability            @"네트워크를 연결할 수 없습니다.\n네트워크 확인 후 다시 시도해 주세요."
#define kPopupMsgTimedOut                   @"네트워크가 원활하지 않습니다.\n네트워크 확인 후 다시 시도해 주세요."

#endif /* FidoDefine_h */
