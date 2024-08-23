//
//  JBHelper.h
//  JBHelper
//
//  Created by 한언섭 on 2014. 12. 9..
//  Copyright (c) 2014년 한언섭. All rights reserved.
//

#import <Foundation/Foundation.h>

inline void dgp() __attribute__((always_inline));

@interface JBHelper : NSObject {
@private
    
}

//    [사용법]
//    if ([[JBHelper getInstance] getJBCResult]) {
//        탈옥처리....
//    }
//

+ (JBHelper*) getInstance;
-(BOOL) getJBCResult;    // 탈옥체크 , TRUE: 탈옥상태
-(void) runDGDetect;    // Debug방지
-(void) checkRun:(NSString *) path; // 함수 테스트
@end
