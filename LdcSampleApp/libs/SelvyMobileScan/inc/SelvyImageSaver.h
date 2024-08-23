//
//  SelvyImageSaver.h
//  SelvyOCRforMobileScan
//
//  Created by selvas on 2018. 8. 17..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @typedef TiffType
 * @brief   TIFF 포맷 저장 시, 이미지 압축 방법
 * @constant    TiffTypeJpeg Jpeg 방식 저장
 * @constant    TiffTypeJpeg2000JP2  Jpeg2000(JP2) 방식 저장
 */
typedef NS_ENUM(NSInteger, TiffType) {
    TiffTypeJpeg,
    TiffTypeJpeg2000JP2,
};

/*!
 * @class   SelvyImageSaver
 * @abstract    SelvyImageSaver 클래스
 * @discussion  이미지 저장 클래스
 */
@interface SelvyImageSaver : NSObject

/*!
 * @discussion  이미지를 주어진 저장 경로에 TIFF 포맷으로 저장
 * @param   path    저장 경로
 * @param   image   이미지
 * @param   tiffType    포맷
 * @param   xResolution 수평 해상도(DPI)
 * @param   yResolution 수직 해상도(DPI)
 * @return  BOOL    성공 여부
 */
+ (BOOL)saveImageToTIFF:(NSString *)path image:(UIImage *)image tiffType:(TiffType)tiffType xResolution:(float)xResolution yResolution:(float)yResolution overwrite:(bool)overwrite;

@end
