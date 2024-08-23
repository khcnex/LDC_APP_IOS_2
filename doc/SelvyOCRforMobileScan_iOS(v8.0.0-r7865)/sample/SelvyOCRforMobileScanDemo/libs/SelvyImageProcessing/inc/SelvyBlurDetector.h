//
//  SelvyBlurDetector.h
//  SelvyImageProcessing
//
//  Created by selvas on 2018. 8. 10..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class   SelvyBlurDetector
 * @abstract    SelvyBlurDetector 클래스
 * @discussion  이미지의 흐릿함을 판단하는 클래스
 */
@interface SelvyBlurDetector : NSObject

/*!
 * @discussion  주어진 이미지의 흐릿함(blur) 값(double)을 판단함
 * @param   image   흐릿함을 판단할 이미지
 * @return  double  흐릿함(blur) 값(0.0 ~ 1.0)
 */
+ (double)blurValueOnImage:(UIImage *)image;

@end
