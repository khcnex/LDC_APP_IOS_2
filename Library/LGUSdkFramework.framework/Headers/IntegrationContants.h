#import <UIKit/UIKit.h>

#define CALL_TYPE_WEBVIEW  "WebView"
#define CALL_TYPE_CALLBACK "Callback"
#define CALL_TYPE_FUNCTION "Function"
#define CALL_TYPE_SERVICE  "Service"

#define RESULT_SUCCESS @"SUCCESS"
#define RESULT_FAIL @"FAIL"
#define RESULT_CANCEL @"CANCEL"

#define RC_USER_SIGNUP @"USER_SIGNUP"                            // OneID 회윈가입 결과
#define RC_ACCOUNT_ADD @"ACCOUNT_ADD"                    // 계정 및 동기화 OneID 추가
#define RC_CONVERSION_RESPONSE @"CONVERSION_RESPONSE"        // 전환가입 응답
#define RC_LOGIN_RESPONSE @"LOGIN_RESPONSE"            // WebView 로그인 응답

#define RC_CALL_OLD_LOGIN @"CALL_OLD_LOGIN"            // WebView 기존ID로 로그인 요청
#define RC_SEARCH_OLD_IDPW @"RC_SEARCH_OLD_IDPW"                // WebView 기존ID/PW 찾기 요청
#define RC_SERVICE_ID_SEARCH @"SERVICE_ID_SEARCH"                            // 기존ID 찾기 요청
#define RC_SERVICE_PASSWORD_RESET @"SERVICE_PASSWORD_RESET"                // 기존PW 찾기 요청
#define RC_LOGOUT @"LOGOUT"                                    // 로그아웃
#define RC_SNS_LOGOUT @"SNS_LOGOUT"                            // SNS 로그아웃
#define RC_SNS_REVOKE @"SNS_REVOKE"                        // SNS 탈퇴
#define RC_CLOSE @"CLOSE"                                        // 웹뷰닫기
#define RC_PERMISSION_ERROR @"PERMISSION_ERROR"                // 권한오류

#define RC_EASY_LOGIN @"EASY_LOGIN"                            // 간편로그인 결과
#define RC_AUTO_LOGIN @"AUTO_LOGIN"                            // 자동로그인 결과
#define RC_DELETE_ACCOUNT @"DELETE_ACCOUNT"                    //계정및동기화 삭제 결과
#define RC_COUNT_ACCOUNT @"COUNT_ACCOUNT"                        //계정및동기화 갯수 반환
#define RC_ADD_ACCOUNT @"ADD_ACCOUNT"                            //계정및동기화 추가

#define RC_LIST_ACCOUNT @"LIST_ACCOUNT"                        //계정및동기화 리스트 반환
#define RC_GET_ACCOUNT @"GET_ACCOUNT"                            //계정및동기화 정보 반환
#define RC_SNS_LOGIN_RESPONSE @"SNS_LOGIN_RESPONSE"                // SNSWebView 로그인 응답
#define RC_SNS_CONVERSION_RESPONSE @"SNS_CONVERSION_RESPONSE"        //SNS ID 전환가입 응답
#define RC_SNS_EXISTED_ONEID_RESPONSE @"SNS_EXISTED_ONEID_RESPONSE"    //SNS 로그인시 기존 ONEID 사용 선택 응답
#define RC_EXISTED_ONEID_RESPONSE @"RC_EXISTED_ONEID_RESPONSE"            //서비스 ID/PW 로그인 화면 요청
#define RC_ATHN_USER @"RC_ATHN_USER"            //6.37    간편인증 ONE ID의 정회원 전환 응답

#define RC_EVENT_NOTI @"EVENT_NOTI"                            // 이벤트 알림 Callback
#define RC_ID_CHANGE_RESPONSE @"ID_CHANGE_RESPONSE"            // ONE ID 변경 응답
#define RC_CTN_LOGIN_RESPONSE @"CTN_LOGIN_RESPONSE"            // CTN 인증 로그인 응답
#define RC_VTID_CHANGE_RESPONSE @"VTID_CHANGE_RESPONSE"        // 임시ID ONE ID 변경 응답
#define RC_2ND_CERTIFY_RESPONSE @"2ND_CERTIFY_RESPONSE"        // FIDO 추가인증 응답

#define RT_SUCCESS @"00000"                                //성공
#define RT_NOT_ONEID @"06002"                                //등록된 계정및 동기화 없음
#define RT_NOT_TOS @"00009"                                    //약관미동의
#define RT_NOT_CONNECT @"02003"                                    //서비스 연동 시 오류가 발생하였습니다.

#define RT_MSG_NOT_ONEID @"등록된 계정및 동기화 없음"                                //등록된 계정및 동기화 없음
#define RT_MSG_NOT_CONNECT @"서비스 연동 시 오류가 발생하였습니다."                    //서비스 연동 시 오류가 발생하였습니다.

#define FUNCTION_TEST_USER_SIGNUP @"TEST_USER_SIGNUP"            //테스트 회원가입 요청
#define FUNCTION_USER_SIGNUP @"USER_SIGNUP"                      //회원가입 요청
#define FUNCTION_USER_SIGNUP_TEST @"USER_SIGNUP_TEST"                      //회원가입 요청
#define FUNCTION_DEFAULT_LOGIN @"DEFAULT_LOGIN"                  //Default 로그인 요청
#define FUNCTION_IDPW_LOGIN @"IDPW_LOGIN"                        //ID/PW로그인 요청
#define FUNCTION_IDPW_LOGIN_TEST @"IDPW_LOGIN_TEST"                        //ID/PW로그인 요청
#define FUNCTION_ACCOUNT_IDPW_LOGIN @"ACCOUNT_IDPW_LOGIN"        //계정및 동기화에 계정 추가를 위한 ID/PW로그인 요청
#define FUNCTION_TOS_REQUEST @"TOS_REQUEST"                    //약관동의 및 기존ID 전환 요청
#define FUNCTION_ONEID_CONFIG @"ONEID_CONFIG"                    //One ID 관리화면 요청
#define FUNCTION_ID_SEARCH @"ID_SEARCH"                        //ID 찾기 요청
#define FUNCTION_PASSWORD_RESET @"PASSWORD_RESET"                //PW 찾기 요청
#define FUNCTION_CONVERSION_REQUEST @"CONVERSION_REQUEST"        //전환 가입 요청
#define FUNCTION_AUTH_MOBILE @"AUTH_MOBILE"                    //승급 요청
#define FUNCTION_UTIL @"UTIL"                //Default 로그인 요청
#define FUNCTION_EASY_LOGIN @"EASY_LOGIN"                //간편로그인
#define FUNCTION_AUTO_LOGIN @"AUTO_LOGIN"                //자동로그인
#define FUNCTION_DELETE_ACCOUNT @"DELETE_ACCOUNT"        //계정및동기화 삭제
#define FUNCTION_COUNT_ACCOUNT @"COUNT_ACCOUNT"        //계정및동기화 갯수 요청
#define FUNCTION_ADD_ACCOUNT @"ADD_ACCOUNT"            //계정및동기화 추가
#define FUNCTION_LIST_ACCOUNT @"LIST_ACCOUNT"            //계정및동기화 리스트 요청
#define FUNCTION_GET_ACCOUNT @"GET_ACCOUNT"            //계정및동기화 정보 요청
#define FUNCTION_USER_MANUAL_SIGNUP @"USER_MANUAL_SIGNUP"            //M2M 단말 회원가입 요청
#define FUNCTION_UFLIX_INFO @"UFLIX_INFO"                //UFLIX 이용정보 조회
#define FUNCTION_UFLIX_INFO_TEST @"UFLIX_INFO_TEST"                //UFLIX 이용정보 조회테스트
#define FUNCTION_SNS_AUTO_LOGIN @"SNS_AUTO_LOGIN"            //SNS 자동로그인 요청
#define FUNCTION_SNS_LOGOUT @"SNS_LOGOUT"            //SNS 로그아웃 요청
#define FUNCTION_SNS_REVOKE @"SNS_REVOKE"            //SNS 탈퇴 요청
#define FUNCTION_SNS_CONVERSION_REQUEST @"SNS_CONVERSION_REQUEST" //SNS 전환가입요청
#define FUNCTION_ATHN_USER @"ATHN_USER_CONVERSION_REQUEST"    // 간편 ID 전환요청
#define FUNCTION_CTN_ID_LOGIN_REQUEST @"CTN_ID_LOGIN_REQUEST"    //CTN 인증 로그인 요청
#define FUNCTION_CTN_ID_LOGIN_REQUEST_TEST @"CTN_ID_LOGIN_REQUEST_TEST"    //CTN 인증 로그인 요청
#define FUNCTION_ID_CHANGE_REQUEST @"ID_CHANGE_REQUEST"    //ONEID 변경요청
#define FUNCTION_VTID_CHANGE_REQUEST @"VTID_CHANGE_REQUEST"    //임시ID OneID 변경 요청
#define FUNCTION_CTN_LOGIN_REQUEST @"CTN_LOGIN_REQUEST"    //CTN 인증 직접 로그인 요청

#define FUNCTION_2ND_CERTIFY_REQUEST @"2ND_CERTIFY_REQUEST"    //FIDO 추가인증 요청
#define FUNCTION_FIDO_CONFIG @"FIDO_CONFIG"    //FIDO 관리화면 요청

#define FUNCTION_LGID_IDPW_LOGIN @"LGID_IDPW_LOGIN"    // LGID IDPW 로그인
#define FUNCTION_DAS_LOGIN @"DAS_LOGIN"                // DAS 로그인
#define FUNCTION_DAS_WEB @"DAS_WEB"                      //회원가입 요청
#define FUNCTION_LGID_HOME @"LGID_HOME"              // MYLG 홈화면 요청




@interface IntegrationContants : NSObject

+(NSString *) version;
+(NSString *) DAS_TARGET_STAGE;
+(NSString *) DAS_TARGET_REAL;

+(NSString *) URL_IDPW_LOGIN;
+(NSString *) URL_USER_SIGNUP;
+(NSString *) URL_CTN_ID_LOGIN_REQUEST;
+(NSString *) URL_ID_SEARCH;
+(NSString *) URL_PASSWORD_RESET;
+(NSString *) URL_AUTH_MOBILE;
+(NSString *) URL_ATHN_USER_CONVERSION_REQUEST;
+(NSString *) URL_TOS_REQUEST;
+(NSString *) URL_CONVERSION_REQUEST;
+(NSString *) URL_ONEID_CONFIG;
+(NSString *) URL_USER_MANUAL_SIGNUP;
+(NSString *) URL_TEST_USER_SIGNUP;
+(NSString *) URL_UFLIX_INFO;
+(NSString *) URL_UFLIX_INFO_TEST;
+(NSString *) URL_SNS_CONVERSION_REQUEST;
+(NSString *) URL_SNS_IDPW_LOGIN;
+(NSString *) URL_SNS_REVOKE;
+(NSString *) URL_SNS_LOGOUT;
+(NSString *) URL_SNS_AUTO_LOGIN;
+(NSString *) URL_ID_CHANGE_REQUEST;
+(NSString *) URL_VTID_CHANGE_REQUEST;
+(NSString *) URL_CTN_LOGIN_REQUEST;
+(NSString *) URL_2ND_CERTIFY_REQUEST;
+(NSString *) URL_FIDO_CONFIG;

+(NSString *) URL_LGID_IDPW_LOGIN;
+(NSString *) URL_DAS_LOGIN;
+(NSString *) URL_MYLG_HOME;





//extern NSString *DAS_SERVER;
@property (class) NSString *DAS_SERVER;
+ (NSString *) DAS_SERVER;
+ (void) setDAS_SERVER:(NSString *)server;

@property (class) NSString *USE_PIN;
+ (NSString *) USE_PIN;
+ (void) setUSE_PIN:(NSString *)confrim;

@property (class) NSString *DAS_LINK;
+ (NSString *)DAS_LINK;
+ (void) setDAS_LINK:(NSString *)link;

+(NSString *) PARAM_IDPW_LOGIN;
+(NSString *) PARAM_USER_SIGNUP;
+(NSString *) PARAM_CTN_ID_LOGIN_REQUEST;
+(NSString *) PARAM_ID_SEARCH;
+(NSString *) PARAM_PASSWORD_RESET;
+(NSString *) PARAM_AUTH_MOBILE;
+(NSString *) PARAM_ATHN_USER_CONVERSION_REQUEST;
+(NSString *) PARAM_TOS_REQUEST;
+(NSString *) PARAM_CONVERSION_REQUEST;
+(NSString *) PARAM_ONEID_CONFIG;
+(NSString *) PARAM_USER_MANUAL_SIGNUP;
+(NSString *) PARAM_TEST_USER_SIGNUP;
+(NSString *) PARAM_UFLIX_INFO;
+(NSString *) PARAM_SNS_CONVERSION_REQUEST;
+(NSString *) PARAM_SNS_REVOKE;
+(NSString *) PARAM_SNS_LOGOUT;
+(NSString *) PARAM_SNS_AUTO_LOGIN;
+(NSString *) PARAM_ID_CHANGE_REQUEST;
+(NSString *) PARAM_VTID_CHANGE_REQUEST;
+(NSString *) PARAM_CTN_LOGIN_REQUEST;

+(NSString *) PARAM_2ND_CERTIFY_REQUEST;
+(NSString *) PARAM_FIDO_CONFIG;

+(NSString *) PARAM_LGID_IDPW_LOGIN;
+(NSString *) PARAM_DAS_LOGIN;
+(NSString *) PARAM_MYLG_HOME;

+(void ) setIsLgId;
@end
