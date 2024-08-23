#import <UIKit/UIKit.h>

typedef const struct {
    __unsafe_unretained NSString *name;
    __unsafe_unretained NSString *replaceStr;
} RestAPIParameterenum;

@interface RestAPIParameterEnum : NSObject
+(RestAPIParameterenum) USER_ID;
+(RestAPIParameterenum) USER_PASSWORD;
+(RestAPIParameterenum) SSO_KEY;
+(RestAPIParameterenum) CTN;
+(RestAPIParameterenum) USIM;
+(RestAPIParameterenum) DAS_SERVER;
+(RestAPIParameterenum) SERVICE_CD;
+(RestAPIParameterenum) LGT_TYPE;
+(RestAPIParameterenum) CI;
+(RestAPIParameterenum) ENTR_NO;
+(RestAPIParameterenum) ONEID_KEY;
+(RestAPIParameterenum) SERVICE_KEY;
+(RestAPIParameterenum) LOGIN_TYPE;
+(RestAPIParameterenum) AUTH_TYPE;
+(RestAPIParameterenum) TOS_SERVICE_CD;
+(RestAPIParameterenum) SERVICE_LOGIN_TYPE;
+(RestAPIParameterenum) SERVICE_USER_ID;
+(RestAPIParameterenum) SNSID_KEY;
+(RestAPIParameterenum) SNS_CD;
+(RestAPIParameterenum) SNS_USER_ID;
+(RestAPIParameterenum) EVENT_CD;
+(RestAPIParameterenum) SERVICE_ITEM_CODE;
+(RestAPIParameterenum) VTID_USE_YN;
+(RestAPIParameterenum) ID_TYPE;
+(RestAPIParameterenum) IS_SUPPORT_DV;
+(RestAPIParameterenum) IS_SUPPORT_FP;
+(RestAPIParameterenum) DEVICE_ID;
@end

//typedef enum
//{
//    USER_ID, USER_PASSWORD, SSO_KEY, CTN, USIM, SERVICE_CD,
//    LGT_TYPE, CI, ENTR_NO, ONEID_KEY,SERVICE_KEY,
//    LOGIN_TYPE, AUTH_TYPE, TOS_SERVICE_CD, SERVICE_LOGIN_TYPE, SERVICE_USER_ID,
//    SNSID_KEY, SNS_CD, SNS_USER_ID, EVENT_CD, SERVICE_ITEM_CODE, VTID_USE_YN,
//    ID_TYPE
//} ParamEnum;

//+ (NSString *) paramEnum:(ParamEnum) param;
//{
//    NSString *result = nil;
//
//    switch(param) {
//        case USER_ID:
//            result = @"{USER_ID}";
//            break;
//        case USER_PASSWORD:
//            result = @"{USER_PASSWORD}";
//            break;
//        case SSO_KEY:
//            result = @"{SSO_KEY}";
//            break;
//        case CTN:
//            result = @"{CTN}";
//            break;
//        case USIM:
//            result = @"{USIM}";
//            break;
//        case SERVICE_CD:
//            result = @"{SERVICE_CD}";
//            break;
//        case LGT_TYPE:
//            result = @"{LGT_TYPE}";
//            break;
//        case CI:
//            result = @"{result}";
//            break;
//        case ENTR_NO:
//            result = @"{ENTR_NO}";
//            break;
//        case ONEID_KEY:
//            result = @"{ONEID_KEY}";
//            break;
//        case SERVICE_KEY:
//            result = @"{SERVICE_KEY}";
//            break;
//        case LOGIN_TYPE:
//            result = @"{LOGIN_TYPE}";
//            break;
//        case AUTH_TYPE:
//            result = @"{AUTH_TYPE}";
//            break;
//        case TOS_SERVICE_CD:
//            result = @"{TOS_SERVICE_CD}";
//            break;
//        case SERVICE_LOGIN_TYPE:
//            result = @"{SERVICE_LOGIN_TYPE}";
//            break;
//        case SERVICE_USER_ID:
//            result = @"{SERVICE_USER_ID}";
//            break;
//        case SNSID_KEY:
//            result = @"{SNSID_KEY}";
//            break;
//        case SNS_CD:
//            result = @"{SNS_CD}";
//            break;
//        case SNS_USER_ID:
//            result = @"{SNS_USER_ID}";
//            break;
//        case EVENT_CD:
//            result = @"{EVENT_CD}";
//            break;
//        case SERVICE_ITEM_CODE:
//            result = @"{SERVICE_ITEM_CODE}";
//            break;
//        case VTID_USE_YN:
//            result = @"{VTID_USE_YN}";
//            break;
//        case ID_TYPE:
//            result = @"{ID_TYPE}";
//            break;
//        default:
//            result = @"{UNKNOWN}}";
//    }
//
//    return result;
//};
