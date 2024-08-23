//
//  DocumentVC.h
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "SelvyDocumentsDetectorDelegate.h"

// 촬영 모드 : DOCUMENT_CAPTURE_AUTO(0) : 자동 촬영, DOCUMENT_CAPTURE_MANUAL(1) : 수동 촬영
enum DOCUMENT_CAPTURE_MODE {
    DOCUMENT_CAPTURE_AUTO, DOCUMENT_CAPTURE_MANUAL,
};

// 신분증 촬영 ViewController
// 신분증을 촬영하고 인식 결과를 전달
@interface DocumentVC : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, SelvyDocumentsDetectorDelegate>

@property int captureMode; // 촬영 모드 (CAPTURE_MANUL : 수동 촬영 / CAPTURE_AUTO : 자동 촬영)
@property (weak, nonatomic) NSString *encryptKey;
@property (weak, nonatomic) id<SelvyDocumentsDetectorDelegate> recognitionDelegate;

@end
