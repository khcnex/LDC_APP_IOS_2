//
//  SelvyDocumentsDetectorDelegate.h
//  SelvyOCRforMobileScan
//
//  Created by diotek on 2016. 1. 28..
//  Copyright © 2016년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @typedef DocumentError
 * @brief   문서 영역 검출 에러 종류
 * @constant    DocumentErrorLicense  라이선스 만료
 * @constant    DocumentErrorCamera   카메라 초기화 실패
 * @constant    DocumentErrorDetect 영역 검출 실패
 * @constant    DocumentErrorEngine 영역 검출 엔진 초기화 실패
 */
typedef NS_ENUM(NSInteger, DocumentError) {
    DocumentErrorLicense,
    DocumentErrorCamera,
    DocumentErrorDetect,
    DocumentErrorEngine
} __TVOS_PROHIBITED;

/*!
 * @protocol    SelvyDocumentsDetectorDelegate
 * @abstract    문서 영역 검출의 결과를 전달하는 프로토콜
 * @discussion  문서 영역 검출 결과(성공/실패) 및 그에 따른 자세한 정보(영역 검출 결과 혹은 실패 메시지)를 전달하는 프로토콜
 */
@protocol SelvyDocumentsDetectorDelegate

/*!
 * @discussion  문서들에 대한 촬영 및 영역 검출 성공 시, 결과 전달
 * @param   selvyDocumentsData 문서들의 영역 검출 결과
 */
- (void)onDocumentsDetected:(NSArray *)selvyDocumentsData imgType:(int)imgType;

/*!
 * @discussion  문서 촬영화면에서 촬영이나 영역 검출 실패 시, 결과 전달
 * @param   errorCode 문서 영역 검출 실패 코드
 * @param   msg 문서 영역 검출 실패 메시지
 */
- (void)onDocumentsError:(DocumentError)errorCode msg:(NSString *)msg;

@end
