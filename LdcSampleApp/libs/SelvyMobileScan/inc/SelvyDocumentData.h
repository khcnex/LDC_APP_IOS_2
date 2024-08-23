//
//  SelvyDocumentData.h
//  SelvyOCRforMobileScan
//
//  Created by selvasAI on 2018. 8. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SelvyAreaChecker.h"

/*!
 * @class   SelvyDocumentData
 * @abstract    SelvyDocumentData 클래스
 * @discussion  하나의 문서 영역 검출 결과 클래스
 */
@interface SelvyDocumentData : NSObject

/*!
 * @@property path
 * @brief   문서 이미지가 저장된 위치
 */
@property (strong, nonatomic, readwrite) NSString *path;

/*!
 * @@property detectedArea
 * @brief   문서 이미지 내의 실제 문서 영역 정보
 */
@property AreaPoints detectedArea;

@end
