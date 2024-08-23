//
//  ViewController.m
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import "ViewController.h"

#import "DocumentVC.h"
#import "ImageCorrectionVC.h"

#import "SelvyDocumentData.h"
#import "SelvyDocumentsDetectorDelegate.h"

#import "SelvyAreaFinder.h"
#import "SelvyImageSaver.h"

@interface ViewController () <UIScrollViewDelegate, SelvyDocumentsDetectorDelegate> {
    CGFloat originHeight;
}

@property (weak, nonatomic) IBOutlet UIView *vMenu;
@property (weak, nonatomic) IBOutlet UIView *vFirst;
@property (weak, nonatomic) IBOutlet UISwitch *swAuto;
@property (weak, nonatomic) IBOutlet UIView *vSecond;
@property (weak, nonatomic) IBOutlet UIView *vResult;
@property (weak, nonatomic) IBOutlet UIScrollView *swResult;
@property (weak, nonatomic) IBOutlet UIImageView *ivResult;
@property (weak, nonatomic) IBOutlet UILabel *lbResult;
@property (weak, nonatomic) IBOutlet UIButton *btnGoMain;

@end

@implementation ViewController
// Constant [[
static const float DOCUMENT_ASPECT_RATIO = 1.3590f; // 문서 가로/세로 비율
// Constant ]]

// LifeCycle [[
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect vRect = CGRectMake((self.view.frame.size.width / 2) - (320 / 2), (self.view.frame.size.height / 2) - (568 / 2), 320, 568);
    [_vMenu setFrame:vRect];
    [_vResult setFrame:vRect];
    
    [_vMenu setHidden:NO];
    [_vResult setHidden:YES];
    
    _vFirst.layer.borderColor = [UIColor grayColor].CGColor;
    _vFirst.layer.borderWidth = 1.f;
    _vSecond.layer.borderColor = [UIColor grayColor].CGColor;
    _vSecond.layer.borderWidth = 1.f;
    
    [_swAuto setOn:NO];
    
    originHeight = _ivResult.frame.size.height;
    
    _swResult.delegate = self;
}
// LifeCycle ]]

// OverrideMethod [[
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 화면 세로 고정을 위한 루틴
- (BOOL)shouldAutorotate {
    return YES;
}

// 화면 세로 고정을 위한 루틴
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
// OverrideMethod ]]

// ClassMethod [[
// ClassMethod ]]

// InstanceMethod [[
- (UIImage *)loadUIImageFromDocument:(NSString *)imagePath {
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (BOOL)deleteFileFromDocument:(NSString *)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
// InstanceMethod ]]

// InnerClass & Callback [[
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _ivResult;
}

- (IBAction)tapGoCapture:(id)sender {
    DocumentVC *documentVC = [[DocumentVC alloc] init];
    // 스위치에서 자동 촬영 on/off 상태를 가져와서 세팅
    documentVC.captureMode = [_swAuto isOn] == YES ? DOCUMENT_CAPTURE_AUTO : DOCUMENT_CAPTURE_MANUAL;
    documentVC.recognitionDelegate = self;
    
    // 신분증 촬영 화면으로 이동
    [self presentViewController:documentVC animated:NO completion:NULL];
}

- (IBAction)tapGoMain:(id)sender {
    [_vMenu setHidden:NO];
    [_vResult setHidden:YES];
    
    [_lbResult setText:@""];
    [_ivResult setImage:nil];
}

- (IBAction)tapAuto:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_Auto; // Auto
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

- (IBAction)tapBrightnessContrast:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_BrightnessContrast; // Brightness/Contrast
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

- (IBAction)tapSoften:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_Soften; // Soften
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

- (IBAction)tapSharpen:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_Sharpen; // Sharpen
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

- (IBAction)tapBinarization:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_Binarization; // Binarization
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

- (IBAction)tapBinarizationAdaptive:(id)sender {
    ImageCorrectionVC *imageCorrectionVC = [[ImageCorrectionVC alloc] init];
    imageCorrectionVC.icType = IC_BinarizationAdaptive; // Binarization Adaptive
    
    [self presentViewController:imageCorrectionVC animated:NO completion:NULL];
}

// 문서 촬영 및 탐지 성공 시, 결과 전달
- (void)onDocumentsDetected:(NSArray *)selvyDocumentsData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self->_vMenu setHidden:YES];
            [self->_vResult setHidden:NO];
            
            if (selvyDocumentsData != nil && [selvyDocumentsData count] > 0) {
                SelvyDocumentData *selvyDocumentData = [selvyDocumentsData objectAtIndex:0];
                UIImage* image = [self loadUIImageFromDocument:selvyDocumentData.path];
                int width = image.size.width > 3000 ? 3000 : image.size.width;
                image = [SelvyAreaFinder perspectiveImage:image areaPoints:selvyDocumentData.detectedArea outputWidth:width outputHeight:width * DOCUMENT_ASPECT_RATIO];
                [self deleteFileFromDocument:selvyDocumentData.path];
                
                self->_swResult.minimumZoomScale = 1.0f;
                self->_swResult.maximumZoomScale = image.size.height / self->_ivResult.frame.size.height;
                self->_swResult.zoomScale = 1.0f;
                
                CGRect swFrame = CGRectMake(8, 8, 304, self->_btnGoMain.frame.origin.y - 16);
                [self->_swResult setFrame:swFrame];
                self->_swResult.contentSize = CGSizeMake(304, self->_btnGoMain.frame.origin.y - 16);
                [self->_swResult setNeedsDisplay];
                
                CGRect ivFrame = CGRectMake(0, 0, 304, self->_btnGoMain.frame.origin.y - 16);
                [self->_ivResult setFrame:ivFrame];
                [self->_ivResult setNeedsDisplay];
                
                // 인식 이미지에 사진 영역을 표시하여 뷰에 세킹
                [self->_ivResult setImage:image];
            } else {
                self->_swResult.minimumZoomScale = 1.0f;
                self->_swResult.maximumZoomScale = 1.0f;
                self->_swResult.zoomScale = 1.0f;
                
                CGRect swFrame = CGRectMake(8, 8, 304, self->originHeight);
                [self->_swResult setFrame:swFrame];
                self->_swResult.contentSize = CGSizeMake(304, self->originHeight);
                
                CGRect ivFrame = CGRectMake(0, 0, 304, self->originHeight);
                [self->_ivResult setFrame:ivFrame];
                
                [self->_lbResult setText:@""];
                [self->_ivResult setImage:nil];
            }
        });
    });
}

// 문서 촬영화면에서 촬영이나 탐지 실패 시, 결과 전달
- (void)onDocumentsError:(DocumentError)errorCode msg:(NSString *)msg {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self->_vMenu setHidden:YES];
            [self->_vResult setHidden:NO];
            
            self->_swResult.minimumZoomScale = 1.0f;
            self->_swResult.maximumZoomScale = 1.0f;
            self->_swResult.zoomScale = 1.0f;
            
            CGRect swFrame = CGRectMake(8, 8, 304, self->originHeight);
            [self->_swResult setFrame:swFrame];
            self->_swResult.contentSize = CGSizeMake(304, self->originHeight);
            
            CGRect ivFrame = CGRectMake(0, 0, 304, self->originHeight);
            [self->_ivResult setFrame:ivFrame];
            
            if (msg != nil && [msg length] > 0) {
                // 인식 실패 메시지를 뷰에 세팅
                [self->_lbResult setText:msg];
                [self->_ivResult setImage:nil];
            }
        });
    });
}
// InnerClass & Callback ]]

@end
