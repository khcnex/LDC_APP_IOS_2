//
//  SelvyImageProcessing.h
//  SelvyImageProcessing
//
//  Created by selvas on 2018. 8. 10..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class   SelvyImageProcessing
 * @abstract    SelvyImageProcessing 클래스
 * @discussion  이미지 처리 클래스
 */
@interface SelvyImageProcessing : NSObject

/*!
 * @discussion  이미지의 대비(Contrast)와 밝기(Brightness)를 변경
 * @param image 대상 이미지
 * @param constrastThreshold 대비 값(-100 ~ 100)
 * @param brightnessThreshold 밝기 값(-100 ~ 100)
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageContrastBrightness:(UIImage *)image constrastThreshold:(int)constrastThreshold brightnessThreshold:(int)brightnessThreshold;
/*!
 * @discussion  이미지를 화질을 부드럽게 변경
 * @param image 대상 이미지
 * @param threshold 임계값(0 ~ 10)
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageSoften:(UIImage *)image threshold:(int)threshold;
/*!
 * @discussion  이미지를 화질을 날카롭게 변경
 * @param image 대상 이미지
 * @param threshold 임계값(0 ~ 10)
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageSharpen:(UIImage *)image threshold:(int)threshold;
/*!
 * @discussion  이미지를 화질을 자동으로 개선
 * @param image 대상 이미지
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageAuto:(UIImage *)image;
/*!
 * @discussion  이미지를 컬러를 이진으로 변경
 * @param image 대상 이미지
 * @param threshold 임계값(0 ~ 255)
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageBinarization:(UIImage *)image threshold:(int)threshold;
/*!
 * @discussion  이미지를 컬러를 적응형 이진으로 변경
 * @param image 대상 이미지
 * @param blockSize 픽셀 사이즈에 대한 임계값(3, 5, 7...)
 * @param constant 임계값
 * @return UIImage 변경된 이미지
 */
+ (UIImage *)processImageBinarizationUsingAdaptive:(UIImage *)image blockSize:(int)blockSize constant:(int)constant;

@end
