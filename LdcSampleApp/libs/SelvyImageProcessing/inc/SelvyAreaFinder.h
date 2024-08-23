//
//  SelvyAreaFinder.h
//  SelvyImageProcessing
//
//  Created by selvas on 2018. 8. 10..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SelvyAreaChecker.h"

/*!
 * @typedef FindObjectType
 * @brief   영역을 찾을 대상 정보
 * @constant    FindObjectTypeDocument  A4문서
 */
typedef NS_ENUM(NSInteger, FindObjectType) {
    FindObjectTypeDocument,
};

/*!
 * @typedef FindOrientationType
 * @brief   영역을 찾을 대상의 회전 정보
 * @constant    FindOrientationTypeVertical 수직
 * @constant    FindOrentationTypeHorizontal    수평
 */
typedef NS_ENUM(NSInteger, FindOrientationType) {
    FindOrientationTypeVertical,
    FindOrientationTypeHorizontal,
};

/*!
 * @typedef FindResult
 * @brief   영역 검출 결과 정보
 * @constant    FindResultSuccess   성공
 * @constant    FindResultWeird 검출된 영역이 기이한 상태
 * @constant    FindResultFail  실패
 */
typedef NS_ENUM(NSInteger, FindResult) {
    FindResultSuccess,
    FindResultWeird,
    FindResultFail,
};

/*!
 * @class   SelvyAreaFinder
 * @abstract    SelvyAreaFinder 클래스
 * @discussion  신분증 혹은 문서의 영역을 찾는 클래스
 */
@interface SelvyAreaFinder : NSObject

/*!
 * @discussion  주어진 이미지 내에서 주어진 대상을 찾음
 * @param   image   찾을 대상이 포함된 이미지
 * @param   objectType  찾을 대상의 정보
 * @param   orientationType 찾을 대상의 회전 정보
 * @param   outputPoints    찾아진 대상의 영역 정보
 * @warning orientationType 의 경우 각 타입 별로 인자를 주의해야 함
 * @warning 신분증이 정방향으로 위치한 경우 : FindOrentationTypeHorizontal
 * @warning 신분증이 시계/반시계 방향으로 회전되어 있는 경우 : FindOrientationTypeVertical
 * @warning outputPoints 의 경우 output 인자이므로 반드시 미리 변수를 선언하고 대입하여야 함
 * @return  int  영역 찾기 결과
 */
+ (FindResult)findObjectAreaOnImage:(UIImage *)image objectType:(FindObjectType)objectType orientationType:(FindOrientationType)orientationType outputPoints:(AreaPoints&)outputPoints;

/*!
 * @discussion  주어진 이미지 내에서 주어진 좌표 영역을 주어진 크기로 perspective 함
 * @param   image   주어진 영역을 포함하는 이미지
 * @param   areaPoints  Perspective 할 영역 정보
 * @param   outputWidth   Perspective 할 가로 크기
 * @param   outputHeight   Perspective 할 세로 크기
 * @return  UIImage  Perspective 된 이미지
 */
+ (UIImage *)perspectiveImage:(UIImage *)image areaPoints:(AreaPoints)areaPoints outputWidth:(int)outputWidth outputHeight:(int)outputHeight;

@end
