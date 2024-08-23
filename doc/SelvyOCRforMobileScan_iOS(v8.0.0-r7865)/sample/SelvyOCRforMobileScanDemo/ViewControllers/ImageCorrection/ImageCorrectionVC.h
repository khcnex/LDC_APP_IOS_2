//
//  ImageCorrectionVC.h
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <UIKit/UIKit.h>

// Image correction types.
typedef NS_ENUM(NSInteger, ImageCorrection) {
    IC_Binarization, // Binarization
    IC_BinarizationAdaptive, // Binarization Adaptive
    IC_BrightnessContrast, // Brightness & Contrast
    IC_Soften, // Soften(Softness)
    IC_Sharpen, // Sharpen
    IC_Auto, // Auto
} __TVOS_PROHIBITED;

// ImageCorrection ViewController
// You can correct image on this view controller.
@interface ImageCorrectionVC : UIViewController

@property ImageCorrection icType; // Current image correction mode.

@end
