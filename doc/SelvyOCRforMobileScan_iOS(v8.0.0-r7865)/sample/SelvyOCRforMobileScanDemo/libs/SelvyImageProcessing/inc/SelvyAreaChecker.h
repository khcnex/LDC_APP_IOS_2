//
//  SelvyAreaChecker.h
//  SelvyImageProcessing
//
//  Created by selvas on 2018. 8. 10..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @struct  AreaPoint
 * @brief   영역 정보를 표현하는데 사용되는 하나의 꼭지점 좌표
 * @field   x   x 좌표
 * @field   y   y 좌표
 */
struct AreaPoint {
    int x;
    int y;
};
typedef struct AreaPoint AreaPoint;

/*!
 * @struct  AreaPoints
 * @brief   네 개의 꼭지점 영역 정보를 표현
 * @field   LT  Left-Top 좌표
 * @field   RT  Right-Top 좌표
 * @field   RB  Right-Bottom 좌표
 * @field   LB  Left-Bottom 좌표
 */
struct AreaPoints {
    AreaPoint LT;
    AreaPoint RT;
    AreaPoint RB;
    AreaPoint LB;
};
typedef struct AreaPoints AreaPoints;

CG_INLINE AreaPoint
CGAreaPointZero()
{
    AreaPoint p; p.x = 0; p.y = 0; return p;
}

CG_INLINE AreaPoint
CGAreaPointMake(int x, int y)
{
    AreaPoint p; p.x = x; p.y = y; return p;
}

CG_INLINE AreaPoints
CGAreaPointsZero() {
    AreaPoints ps; ps.LT = CGAreaPointZero(); ps.RT = CGAreaPointZero(); ps.RB = CGAreaPointZero(); ps.LB = CGAreaPointZero(); return ps;
}

CG_INLINE AreaPoints
CGAreaPointsMake(AreaPoint LT, AreaPoint RT, AreaPoint RB, AreaPoint LB)
{
    AreaPoints ps; ps.LT = LT; ps.RT = RT; ps.RB = RB; ps.LB = LB; return ps;
}

/*!
 * @class   SelvyAreaChecker
 * @abstract    SelvyAreaChecker 클래스
 * @discussion  영역 정보와 관련된 유틸리티 클래스
 */
@interface SelvyAreaChecker : NSObject

/*!
 * @discussion  주어진 두 개의 영역이 비슷한 영역인지 판단
 * @param   areaPoints1 비교할 영역
 * @param   areaPoints2 비교할 영역
 * @return  bool    두 영역이 비슷하면 YES, 아니면 NO
 */
+ (bool)isAreaSimilar:(AreaPoints)areaPoints1 cur:(AreaPoints)areaPoints2;

@end
