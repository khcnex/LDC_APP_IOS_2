//
//  DocumentVC.mm
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import "DocumentVC.h"

#import "DocumentOverlayView.h"

#import "SelvyDocumentData.h"

#import "SelvyAreaChecker.h"
#import "SelvyAreaFinder.h"
#import "SelvyBlurDetector.h"

// 문서 촬영 ViewController
// 문서를 촬영하고 영역 검출 결과를 전달
@interface DocumentVC () {
    BOOL isCapturing; // 현재 촬영 중(셔터 버튼 누른 직후부터 이미지가 캡쳐될 동안 유효)
    BOOL isFinding; // 현재 영역 검출 중
    
    int similarCount; // 자동 촬영 시, 비슷한 영역이 검출된 프레임 카운트
    AreaPoints beforeArea; // 자동/수동 촬영 시, 현재 프레임에서 검출된 영역을 저장
    
    UIInterfaceOrientation uiInterfaceOrientation; // UI 화면 회전 정보
    
    CGRect previewContentRect; // 카메라 프리뷰가 화면에서 차지하는 영역
    CGRect previewGuideRect; // 카메라 프리뷰에서 촬영 가이드 영역
    
    dispatch_queue_t previewQueue;
    
    AVCaptureDevice *captureDevice; // 카메라 디바이스
    
    AVCaptureSession *captureSession; // 카메라 세션
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; // 카메라 프리뷰 레이어
    
    AVCaptureVideoDataOutput *captureVideoDataOutput; // 카메라 프리뷰 아웃풋
    AVCaptureStillImageOutput *captureVideoStillImageOutput; // 카메라 스틸 이미지 아웃풋
    
    DocumentOverlayView *vOverlay; // 카메라 프리뷰 오버레이
    
    UIView *vProcessing; // 인식 진행 표시 뷰
    UILabel *lbProcessing; // 인식 진행 표시 라벨
    UIActivityIndicatorView *indiProcessing; // 인식 진행 인디케이터 뷰
    
    NSString *strGuide; // 가이드 상단 라벨 스트링
    NSString *strTip; // 가이드 하단 라벨 스트링
    NSString *strRetake; // 재촬영 경고 라벨 스트링
    NSString *strFocus; // 포커스 경고 라벨 스트링
    NSString *strSmall; // 작게 촬영됨 경고 라벨 스트링
    
    CIContext *cicontext; // 프리뷰 이미지를 UIImage로 변환할 때 사용
    
    // Adaptive frame count for auto capture
    NSDate *date;
    
    int passedFrameCount;
    int calcedFrameCount;
    
    double cumulativeTime;

    int avgFrameCount;
    // Adaptive frame count for auto capture
}

@property (weak, nonatomic) IBOutlet UIView *vCamera; // 카메라 뷰
@property (weak, nonatomic) IBOutlet UIImageView *ivTargat; // 자동 촬영 모드에서 중앙 십자선
@property (weak, nonatomic) IBOutlet UIButton *btnClose; // 닫기 버튼
@property (weak, nonatomic) IBOutlet UIButton *btnShutter; // 수동 촬영 모드에서 셔터 버튼
@property (weak, nonatomic) IBOutlet UILabel *lbGuide; // 가이드 상단 라벨
@property (weak, nonatomic) IBOutlet UILabel *lbRetake; // 재촬영 경고 라벨
@property (weak, nonatomic) IBOutlet UILabel *lbFocus; // 포커스 경고 라벨
@property (weak, nonatomic) IBOutlet UILabel *lbSmall; // 작게 촬영됨 경고 라벨

@end

@implementation DocumentVC

// Constant [[
static const char *PREVIEW_QUEUE = "PreviewQueue"; // 카메라 프리뷰 처리용 큐
static const void *CapturingStillImageContext = &CapturingStillImageContext; // Focusing and Capture on

static const float VALUE_BLUR_THRESHOLD = 0.82f; // 포커스 판단 임계값
static const float VALUE_SMALL_THRESHOLD = 0.6f; // 이미지 작게 촬영됨의 판단 임계값
static const float VALUE_GUIDE_RECT_MARGIN = 0.85f;

// Adaptive frame count for auto capture
static const int MAX_PASS_FRAME_COUNT = 4;
static const int MAX_CALC_FRAME_COUNT = 3;
static const float MAX_MS_COUNT = 600.f;
// Adaptive frame count for auto capture

static const NSString *STR_GUIDE_AUTO_PORT = @"문서를 가이드에 맞추고\r자동으로 촬영될 때까지 유지해주세요.";
static const NSString *STR_GUIDE_AUTO_LAND = @"문서를 가이드에 맞추고 자동으로 촬영될 때까지 유지해주세요.";
static const NSString *STR_GUIDE_MANUAL_PORT = @"문서를 가이드에 맞추고\r촬영 버튼을 눌러 주세요.";
static const NSString *STR_GUIDE_MANUAL_LAND = @"문서를 가이드에 맞추고 촬영 버튼을 눌러 주세요.";

static const NSString *STR_RETAKE = @"정확한 정보 파악을 위해 다시 촬영합니다.\r\r\r촬영이 끝날 때까지 문서를 가이드에 맞춰 주세요.";
static const NSString *STR_FOCUS = @"초점이 맞지 않습니다.\r\r\r촬영이 끝날 때까지 문서를 가이드에 맞춰 주세요.";
static const NSString *STR_SMALL = @"문서가 너무 작습니다.\r\r\r가이드 라인에 맞게 신분증을 맞춰 주세요";

static const NSString *STR_PROCESSING = @"정보 파악 중...";
// Constant ]]

// LifeCycle [[
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    // 촬영 중 화면이 꺼지지 않도록 설정
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 변수 초기화
    isCapturing = NO;
    isFinding = NO;
    // Adaptive frame count for auto capture
    date = nil;
    
    passedFrameCount = 0;
    calcedFrameCount = 0;
    
    cumulativeTime = 0;
    
    avgFrameCount = 0;
    // Adaptive frame count for auto capture
    
    cicontext = [CIContext contextWithOptions:nil];
    
    similarCount = 0;
    beforeArea = CGAreaPointsZero();
    
    previewContentRect = CGRectZero;
    previewGuideRect = CGRectZero;
    
    // 첫 시작 시, 뷰들을 모두 숨김
    [_vCamera setHidden:YES];
    [_ivTargat setHidden:YES];
    [_btnClose setHidden:YES];
    [_btnShutter setHidden:YES];
    [_lbGuide setHidden:YES];
    [_lbRetake setHidden:YES];
    [_lbFocus setHidden:YES];
    [_lbSmall setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self initViews];
    
    if (![self initAVCamera]) {
        if (_recognitionDelegate != nil) {
            [_recognitionDelegate onDocumentsError:DocumentErrorCamera msg:@"Camera error"];
        }
        
        // 메인 화면으로 이동
        [self dismissViewControllerAnimated:NO completion:nil];
        
        return;
    }
    
    // 위치가 변경되는 뷰 초기화
    [self coordinateViews];
    
    // 카메라 프리뷰 시작
    [self startAVCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 촬영이 끝나면 화면이 아이들 상태에서 꺼질 수 있도록 설정
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // 카메라 프리뷰 정지
    [self stopAVCamera];
    // 카메라 릴리즈
    [self releaseAVCamera];
}
// LifeCycle [[

// OverrideMethod [[
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 상태바 숨김
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// 화면 전환(가로/세로) 시, 에니메이션 삭제 및 뷰 재배치
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [UIView setAnimationsEnabled:NO];
    
    [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [UIView setAnimationsEnabled:YES];
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // 위치가 변경되는 뷰 초기화
        [self coordinateViews];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

// 카메라 포커스 옵저버
// Focusing and Capture on
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage) {
        } else {
            [[captureVideoPreviewLayer connection] setEnabled:NO];
        }
    }
}
// OverrideMethod ]]

// ClassMethod [[
// ClassMethod ]]

// InstanceMethod [[
- (void)initViews {
    // 숨겼던 뷰들을 각 모드에 따라 보여줌
    [_vCamera setHidden:NO];
    [_btnClose setHidden:NO];
    [_lbGuide setHidden:NO];
    
    if (_captureMode == DOCUMENT_CAPTURE_AUTO) { // 자동 촬영 모드에서는 십자선을 보여줌
        [_ivTargat setHidden:NO];
    } else { // 수동 촬영 모드에서는 셔터 버튼을 보여줌
        [_btnShutter setHidden:NO];
    }
}

// 가로/세로에 따른 화면 재배치
- (void)coordinateViews {
    uiInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // 자동/수동 - 카메라 뷰 위치 및 크기 설정
    // 자동 - 삽자선 뷰 위치 및 크기 설정
    CGRect vCameraRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect ivTargetRect = CGRectMake(vCameraRect.origin.x + ((vCameraRect.size.width / 2) - 10), vCameraRect.origin.y + ((vCameraRect.size.height / 2) - 10), 20, 20);
    [_vCamera setFrame:vCameraRect];
    [_ivTargat setFrame:ivTargetRect];
    
    // 카메라 프리뷰 오리엔테이션 조정
    switch (uiInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIInterfaceOrientationLandscapeRight: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        } break;
        default: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } break;
    }
    
    // 카메라 프리뷰 오리엔테이션 조정
    switch (uiInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIInterfaceOrientationLandscapeRight: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        } break;
        default: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } break;
    }
    
    CALayer *cameraLayer = [_vCamera layer];
    [cameraLayer setMasksToBounds:YES];
    [captureVideoPreviewLayer setFrame:[cameraLayer bounds]];
    
    // 카메라 프리뷰가 화면에서 차지하는 영역을 계산
    CMFormatDescriptionRef fdesc = captureDevice.activeFormat.formatDescription;
    CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
    CGRect previewRect = [self getPreviewContentRect:_vCamera.frame.size apertureSize:cleanAperture.size interfaceOrientation:uiInterfaceOrientation];
    if (UIInterfaceOrientationIsPortrait(uiInterfaceOrientation)) {
        CGAffineTransform t = CGAffineTransformMakeTranslation(-_vCamera.frame.size.height / 2, -_vCamera.frame.size.width / 2);
        t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(M_PI_2));
        t = CGAffineTransformConcat(t, CGAffineTransformMakeTranslation(_vCamera.frame.size.width / 2, _vCamera.frame.size.height / 2));
        
        previewContentRect = CGRectApplyAffineTransform(previewRect, t);
    } else {
        previewContentRect = previewRect;
    }
    
    // 수동/자동 - 닫기 버튼 위치 및 크기 설정
    // 수동 - 셔터 버튼 위치 및 크기 설정
    CGRect btnShutterRect;
    CGRect btnCloseRect;
    if (!UIInterfaceOrientationIsLandscape(uiInterfaceOrientation)) { // Portrait
        btnShutterRect.origin.x = (self.view.frame.size.width / 2) - 20;
        btnShutterRect.size.height = 40;
        btnShutterRect.origin.y =  (previewContentRect.origin.y + previewContentRect.size.height) + 16;
        btnShutterRect.size.width = 40;
        
        btnCloseRect.origin.x = self.view.frame.size.width - 16 - 30;
        btnCloseRect.size.height = 15;
        btnCloseRect.origin.y = previewContentRect.origin.y - 15 - 30;
        btnCloseRect.size.width = 30;
    } else { // Landscape
        btnShutterRect.size.width = 40;
        btnShutterRect.origin.x = (previewContentRect.origin.x + previewContentRect.size.width) + 16;
        btnShutterRect.origin.y = (self.view.frame.size.height / 2) - 20;
        btnShutterRect.size.height = 40;
        
        btnCloseRect.origin.x = previewContentRect.origin.x - 30 - 30;
        btnCloseRect.origin.y = 16;
        btnCloseRect.size.height = 15;
        btnCloseRect.size.width = 30;
    }
    [_btnShutter setFrame:btnShutterRect];
    [_btnClose setFrame:btnCloseRect];
    
    // 주어진 프리뷰 영역 내에서 신분증 가로/세로 비율에 따른 최대 크기를 구함
    float width = 0;
    float height = 0;
    while (width <= previewContentRect.size.width * VALUE_GUIDE_RECT_MARGIN && height <= previewContentRect.size.height * VALUE_GUIDE_RECT_MARGIN) {
        width += 2.10f;
        height += 2.97f;
    }
    
    // 촬영 가이드 영역 설정
    previewGuideRect = CGRectMake((previewContentRect.size.width / 2.0f) - (width / 2.0f), (previewContentRect.size.height / 2.0f) - (height / 2.0f), width, height);
    
    [vOverlay setFrame:CGRectMake(0, 0, _vCamera.frame.size.width, _vCamera.frame.size.height)];
    vOverlay.outerRect = CGRectMake(previewContentRect.origin.x + previewGuideRect.origin.x,
                                    previewContentRect.origin.y + previewGuideRect.origin.y,
                                    previewGuideRect.size.width,
                                    previewGuideRect.size.height);
    float innerWidthGap = (previewGuideRect.size.width) * 0.08;
    float innerHeightGap = (previewGuideRect.size.height) * 0.08;
    vOverlay.innerRect = CGRectMake(vOverlay.outerRect.origin.x + innerWidthGap, vOverlay.outerRect.origin.y + innerHeightGap, (vOverlay.outerRect.size.width - innerWidthGap) - innerWidthGap, (vOverlay.outerRect.size.height - innerHeightGap) - innerHeightGap);
    
    // 라벨 스트링 및 위치 정리
    CGRect lbGuideRect = _lbGuide.frame;
    CGRect lbRetakeRect = _lbRetake.frame;
    CGRect lbFocusRect = _lbFocus.frame;
    CGRect lbSmallRect = _lbSmall.frame;
    
    if (!UIInterfaceOrientationIsLandscape(uiInterfaceOrientation)) { // Portrait
        // 세로 스트링 정리
        if (_captureMode == DOCUMENT_CAPTURE_AUTO) {
            strGuide = (NSString *) STR_GUIDE_AUTO_PORT;
        } else {
            strGuide = (NSString *) STR_GUIDE_MANUAL_PORT;
        }
        
        lbGuideRect.origin.x = vCameraRect.origin.x + previewContentRect.origin.x;
        lbGuideRect.origin.y = vCameraRect.origin.y + previewContentRect.origin.y + previewGuideRect.origin.y - 5 - 40;
        lbGuideRect.size.width = previewContentRect.size.width;
        lbGuideRect.size.height = 40;
    } else {
        // 가로 스트링 정리
        if (_captureMode == DOCUMENT_CAPTURE_AUTO) {
            strGuide = (NSString *) STR_GUIDE_AUTO_LAND;
        } else {
            strGuide = (NSString *) STR_GUIDE_MANUAL_LAND;
        }
        
        lbGuideRect.origin.x = vCameraRect.origin.x + previewContentRect.origin.x;
        lbGuideRect.origin.y = vCameraRect.origin.y + previewContentRect.origin.y + previewGuideRect.origin.y - 5 - 20;
        lbGuideRect.size.width = previewContentRect.size.width;
        lbGuideRect.size.height = 20;
    }
    
    // 공통 스트링 정리
    strRetake = (NSString *) STR_RETAKE;
    strFocus = (NSString *) STR_FOCUS;
    strSmall = (NSString *) STR_SMALL;
    
    lbRetakeRect.origin.x = vCameraRect.origin.x + previewContentRect.origin.x + previewGuideRect.origin.x;
    lbRetakeRect.origin.y = vCameraRect.origin.y + previewContentRect.origin.y + previewGuideRect.origin.y + (previewGuideRect.size.height / 2) - 33;
    lbRetakeRect.size.width = previewGuideRect.size.width;
    lbRetakeRect.size.height = 66;
    
    lbFocusRect.origin.x = vCameraRect.origin.x + previewContentRect.origin.x + previewGuideRect.origin.x;
    lbFocusRect.origin.y = vCameraRect.origin.y + previewContentRect.origin.y + previewGuideRect.origin.y + (previewGuideRect.size.height / 2) - 33;
    lbFocusRect.size.width = previewGuideRect.size.width;
    lbFocusRect.size.height = 66;
    
    lbSmallRect.origin.x = vCameraRect.origin.x + previewContentRect.origin.x + previewGuideRect.origin.x;
    lbSmallRect.origin.y = vCameraRect.origin.y + previewContentRect.origin.y + previewGuideRect.origin.y + (previewGuideRect.size.height / 2) - 33;
    lbSmallRect.size.width = previewGuideRect.size.width;
    lbSmallRect.size.height = 66;
    
    [_lbGuide setText:strGuide];
    [_lbRetake setText:strRetake];
    [_lbFocus setText:strFocus];
    [_lbSmall setText:strSmall];
    
    [_lbGuide setFrame:lbGuideRect];
    [_lbRetake setFrame:lbRetakeRect];
    [_lbFocus setFrame:lbFocusRect];
    [_lbSmall setFrame:lbSmallRect];
    
    [_lbRetake setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:200/255.f]];
    [_lbFocus setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:200/255.f]];
    [_lbSmall setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:200/255.f]];
    
    // 업데이트
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->vOverlay setNeedsDisplay];

        [self->_lbGuide setNeedsDisplay];
        [self->_lbRetake setNeedsDisplay];
        [self->_lbFocus setNeedsDisplay];
        [self->_lbSmall setNeedsDisplay];
    });
}

// 카메라 초기화
- (BOOL)initAVCamera {
    // Setup Camera Session
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Add Inputs
    // Add Video Input - Back
    NSArray *videoCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    captureDevice = nil;
    for (AVCaptureDevice *device in videoCaptureDevices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            captureDevice = device;
            break;
        }
    }
    
    if (captureDevice) {
        NSError *error;
        
        AVCaptureDeviceInput *videoCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!error) {
            if ([captureSession canAddInput:videoCaptureDeviceInput]) {
                [captureSession addInput:videoCaptureDeviceInput];
            } else {
                // NSLog(@"Couldn't add video input");
                return NO;
            }
        } else {
            // NSLog(@"Couldn't create video input");
            return NO;
        }
    } else {
        // NSLog(@"Couldn't create video capture device");
        return NO;
    }
    
    // Add outputs
    // Preview output
    previewQueue = dispatch_queue_create(PREVIEW_QUEUE, DISPATCH_QUEUE_SERIAL);
    // Add Video Data Output
    captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureVideoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [captureVideoDataOutput setSampleBufferDelegate:self queue:previewQueue];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    if ([captureSession canAddOutput:captureVideoDataOutput]) {
        [captureSession addOutput:captureVideoDataOutput];
    } else {
        // NSLog(@"Couldn't add video output");
        return NO;
    }
    
    // Add Still Image Output
    captureVideoStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [captureVideoStillImageOutput setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil]];
    [captureVideoStillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(void *)CapturingStillImageContext]; // Focusing and Capture on
    if ([captureSession canAddOutput:captureVideoStillImageOutput]) {
        [captureSession addOutput:captureVideoStillImageOutput];
    } else {
        // NSLog(@"Couldn't add still image output");
        return NO;
    }
    
    // PreviewLayer
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    captureVideoPreviewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    
    uiInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (uiInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIInterfaceOrientationLandscapeRight: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        } break;
        default: {
            captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } break;
    }
    
    CALayer *cameraLayer = [_vCamera layer];
    [cameraLayer setMasksToBounds:YES];
    [cameraLayer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    // OverlayView
    vOverlay = [[DocumentOverlayView alloc] init];
    if (_captureMode == DOCUMENT_CAPTURE_AUTO) { // 자동 촬영 시, 오버레이에서 고정 영역 모드 해제
        vOverlay.isUseFixedGuide = NO;
    } else { // 수동 촬영 시, 오버레이에서 고정 영역 모드 설정
        vOverlay.isUseFixedGuide = YES;
    }
    [_vCamera addSubview:vOverlay];
    
    return YES;
}

// 카메라 해제
- (void)releaseAVCamera {
    if (vOverlay != nil) {
        [vOverlay removeFromSuperview];
    }
    
    if (captureVideoPreviewLayer != nil) {
        [captureVideoPreviewLayer removeFromSuperlayer];
    }
    
    for (AVCaptureInput *input in captureSession.inputs) {
        [captureSession removeInput:input];
    }
    
    for (AVCaptureOutput *output in captureSession.outputs) {
        [captureSession removeOutput:output];
    }
    
    captureVideoPreviewLayer = nil;
    captureVideoDataOutput = nil;
    [captureVideoStillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:(void *)CapturingStillImageContext];  // Focusing and Capture on
    captureVideoStillImageOutput = nil;
    captureSession = nil;
}

// 카메라 프리뷰 시작
- (void)startAVCamera {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self->captureSession != nil && ![self->captureSession isRunning]) {
            [self->captureSession startRunning];
        }
    });
}

// 카메라 프리뷰 정지
- (void)stopAVCamera {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self->captureSession != nil && [self->captureSession isRunning]) {
            [self->captureSession stopRunning];
        }
    });
}

// 카메라 프리뷰가 화면에서 차지하는 영역을 계산
- (CGRect)getPreviewContentRect:(CGSize)frameSize apertureSize:(CGSize)apertureSize interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat viewWidth;
    CGFloat viewHeight;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        viewWidth = frameSize.width;
        viewHeight = frameSize.height;
    } else {
        viewWidth = frameSize.height;
        viewHeight = frameSize.width;
    }
    
    CGFloat viewRatio = viewWidth/ viewHeight;
    CGFloat apertureRatio = apertureSize.width / apertureSize.height;
    
    CGSize size = CGSizeZero;
    
    if (viewRatio > apertureRatio) {
        size.width = apertureSize.width * (viewHeight / apertureSize.height);
        size.height = viewHeight;
    } else {
        size.width = viewWidth;
        size.height = apertureSize.height * (viewWidth / apertureSize.width);
    }
    
    CGRect previewContent = CGRectZero;
    previewContent.size = size;
    if (size.width < viewWidth) {
        previewContent.origin.x = (viewWidth - size.width) / 2;
    }
    
    if (size.height < viewHeight ) {
        previewContent.origin.y = (viewHeight - size.height) / 2;
    }
    
    return previewContent;
}

// 영역 검출
- (void)findDocumentArea:(CMSampleBufferRef)sampleBuffer {
    // Adaptive frame count for auto capture
    isFinding = YES;
    
    // #1. Pass frame...
    if (passedFrameCount < MAX_PASS_FRAME_COUNT) {
        passedFrameCount++;
        
        isFinding = NO;
        
        return;
    }
    
    if (date == nil) {
        date = [NSDate date];
        
        isFinding = NO;
        
        return;
    }
    
    // #2. Cumulative time...
    if (calcedFrameCount < MAX_CALC_FRAME_COUNT) {
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer videoOrientation:captureVideoPreviewLayer.connection.videoOrientation];
        [SelvyBlurDetector blurValueOnImage:image];
        float scaleW = image.size.width / previewContentRect.size.width;
        float scaleH = image.size.height / previewContentRect.size.height;
        CGRect cropRect = CGRectMake(previewGuideRect.origin.x * scaleW, previewGuideRect.origin.y * scaleH, previewGuideRect.size.width * scaleW, previewGuideRect.size.height * scaleH);
        image = [self croppedImage:image rect:cropRect];
        AreaPoints areaPoints = CGAreaPointsZero();
        [SelvyAreaFinder findObjectAreaOnImage:image objectType:FindObjectTypeDocument orientationType:FindOrientationTypeVertical outputPoints:areaPoints];
        
        cumulativeTime += [date timeIntervalSinceNow] * -1000.0;
        
        date = [NSDate date];
        calcedFrameCount++;
        
        isFinding = NO;
        
        return;
    }
    
    // #3. Calculate frame count...
    if (avgFrameCount == 0) {
        double avgTime = cumulativeTime / MAX_CALC_FRAME_COUNT;
        avgFrameCount = MAX_MS_COUNT / avgTime;
        
        isFinding = NO;
        
        return;
    }
    // Adaptive frame count for auto capture
    
    isFinding = YES; // 영역 검출 중 플래그 설정
    
    // 카메라 프리뷰 프레임에서 UIImage를 생성
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer videoOrientation:captureVideoPreviewLayer.connection.videoOrientation];

    // 현재 프리뷰 이미지의 Blur 정도가 높으면 리턴
    double blurValue = [SelvyBlurDetector blurValueOnImage:image];
    if (blurValue > VALUE_BLUR_THRESHOLD || isnan(blurValue)) {
        similarCount = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearOverlayView];
        });
        
        return;
    }
    
    // 화면의 가이트 렉트 만큼 크롭
    float scaleW = image.size.width / previewContentRect.size.width;
    float scaleH = image.size.height / previewContentRect.size.height;
    CGRect cropRect = CGRectMake(previewGuideRect.origin.x * scaleW, previewGuideRect.origin.y * scaleH, previewGuideRect.size.width * scaleW, previewGuideRect.size.height * scaleH);
    
    image = [self croppedImage:image rect:cropRect];
    
    // 영역 검출
    AreaPoints currentArea = CGAreaPointsZero();
    FindResult ret = [SelvyAreaFinder findObjectAreaOnImage:image objectType:FindObjectTypeDocument orientationType:FindOrientationTypeVertical outputPoints:currentArea];
    
    // 영역 검출 성공일 경우 프리뷰 이미지(Landscape) 내의 검출된 좌표를 시계방향으로 90도 회전 시켜서 OverlayView 에 전달하고 화면 갱신하여 영역을 표시
    if (ret == FindResultSuccess) {
        vOverlay.isDetected = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self->vOverlay setNeedsDisplay];
        });
        
        // 현재 검출된 신분증 영역과 이전 검출된 신분증 영역의 비슷한 정도를 체크하여 카운트 증가
        if ([SelvyAreaChecker isAreaSimilar:beforeArea cur:currentArea]) {
            similarCount++;
        } else {
            similarCount = 0;
        }
        
        // 현재 검출된 신분증 영역 저장
        beforeArea = currentArea;
        
        isFinding = NO;
        
        if (similarCount > avgFrameCount) {
            [self takePicture];
        }
    } else { // 영역 검출 실패 시, 초기화
        similarCount = 0;
        beforeArea = CGAreaPointsZero();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearOverlayView];
        });
    }
}

// 카메라 프리뷰 프레임을 UIImage 형태로 리턴
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer videoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:nil];
    
    CGAffineTransform t;
    switch (videoOrientation) {
        case AVCaptureVideoOrientationPortrait: {
            t = CGAffineTransformMakeRotation(-M_PI_2);
        } break;
        default: {
            t = CGAffineTransformMakeRotation(0);
        } break;
    }
    
    ciImage = [ciImage imageByApplyingTransform:t];
    
    CGImageRef cgImage = [cicontext createCGImage:ciImage fromRect:[ciImage extent]];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return image;
}


// 사진 촬영 버튼 콜백
- (void)takePicture {
    isCapturing = YES; // 촬영 중 플래그 설정

    dispatch_async(dispatch_get_main_queue(),^ {
        [self->_lbGuide setHidden:YES];
    });
    
    AVCaptureConnection *captureConnection = nil;
    for (AVCaptureConnection *connection in captureVideoStillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                captureConnection = connection;
                break;
            }
        }
        if (captureConnection) {
            break;
        }
    }
    
    if ([captureConnection isVideoOrientationSupported]) {
        [captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    // 촬영 콜백
    [captureVideoStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData]; // 촬영된 이미지
            
            // 촬영된 이미지의 Blur 값을 구함
            double blurValue = [SelvyBlurDetector blurValueOnImage:image];
            if (blurValue > VALUE_BLUR_THRESHOLD || isnan(blurValue)) { // Blur 정도가 기준치(0.82)보다 높으면 포커스 라벨 보여줌
                image = nil;
                
                dispatch_async(self->previewQueue, ^ {
                    [self showNeedFocus];
                });
                
                return;
            }
            
            [self stopAVCamera]; // 카메라 프리뷰 정지
            
            [self showProgress:(NSString *)STR_PROCESSING]; // 인식 인디케이터 보여줌
            dispatch_async(self->previewQueue, ^ {
                // 인식 전 이미지 전처리
                [self processImage:image orientation:self->uiInterfaceOrientation];
            });
        }
    }];
}

// 이미지 전처리
- (void)processImage:(UIImage *)image orientation:(UIInterfaceOrientation)orientationInfo {
    image = [self rotateImage:image orientation:orientationInfo];
    
    // 프리뷰 크기와 실제 캡쳐된 이미지의 비율 구함
    float scaleW = image.size.width / previewContentRect.size.width;
    float scaleH = image.size.height / previewContentRect.size.height;
    
    CGRect cropRect;
    if (CGRectIsNull(previewGuideRect) || CGRectIsEmpty(previewGuideRect)) {
        cropRect = CGRectMake(0, 0, image.size.width, image.size.height);
    } else {
        // 가이드 영역만 크롭
        CGRect scaledCropRect = CGRectMake(previewGuideRect.origin.x * scaleW, previewGuideRect.origin.y * scaleH, previewGuideRect.size.width * scaleW, previewGuideRect.size.height * scaleH);
        cropRect = CGRectMake((image.size.width - scaledCropRect.size.width) / 2, (image.size.height - scaledCropRect.size.height) / 2, scaledCropRect.size.width, scaledCropRect.size.height);
    }
    
    // 이미지 크롭
    UIImage *recognizeImage = [self croppedImage:image rect:cropRect];
    
    // 문서 영역 검출
    AreaPoints currentArea = CGAreaPointsZero();
    FindResult ret = [SelvyAreaFinder findObjectAreaOnImage:recognizeImage objectType:FindObjectTypeDocument orientationType:FindOrientationTypeVertical outputPoints:currentArea];
    if (ret == FindResultSuccess) {
        // 영역 검출이 성공하였을 때, 영역 유효성 체크
        // 검출된 4개의 점으로 만들어진 임의 영역이 크롭된 이미지의 영역보다 작은지(0.6) 체크
        CGRect findRect = CGRectZero;
        findRect.origin.x = MIN(currentArea.LT.x, currentArea.LB.x);
        findRect.origin.y = MIN(currentArea.LT.y, currentArea.RT.y);
        findRect.size.width = MAX(currentArea.RT.x, currentArea.RB.x) - findRect.origin.x;
        findRect.size.height = MAX(currentArea.RB.y, currentArea.LB.y) - findRect.origin.y;
        
        if (findRect.size.width < recognizeImage.size.width * VALUE_SMALL_THRESHOLD || findRect.size.height < recognizeImage.size.height * VALUE_SMALL_THRESHOLD) {
            [self showTooSmallImage];
            
            return;
        }
        
        NSString *path = [self saveUIImageToDocument:recognizeImage];
        
        // 퍼스펙티브 된 이미지를 가지고 리턴 시도
        SelvyDocumentData *documentData = [[SelvyDocumentData alloc] init];
        documentData.path = path;
        documentData.detectedArea = currentArea;
        NSArray *documentsData = [NSArray arrayWithObjects:documentData, nil];
        [self onDocumentsDetected:documentsData];
    } else {
        [self showRetake];
    }
}

// 주어진 스트링으로 인디케이터를 화면에 보여줌
- (void)showProgress:(NSString *)msg {
    vProcessing = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 100, (self.view.frame.size.height / 2) - 25, 200, 50)];
    [vProcessing.layer setCornerRadius:15];
    [vProcessing setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    indiProcessing = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indiProcessing setFrame:CGRectMake(0, 0, 50, 50)];
    [indiProcessing startAnimating];
    
    lbProcessing = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 180, 50)];
    [lbProcessing setText:msg];
    [lbProcessing setTextColor:[UIColor whiteColor]];
    
    [vProcessing addSubview:indiProcessing];
    [vProcessing addSubview:lbProcessing];
    
    [self.view addSubview:vProcessing];
}

// 인디케이터를 숨김
- (void)hideProgress {
    [vProcessing removeFromSuperview];
}

// 오버레이 화면 클리어
- (void)clearOverlayView {
    if (vOverlay != nil) {
        vOverlay.isDetected = NO;
        [vOverlay setNeedsDisplay];
        isFinding = NO;
    }
}

// 주어진 영역을 이미지 내에서 크롭
- (UIImage *)croppedImage:(UIImage *)image rect:(CGRect)cropRect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

// 이미지를 현재 디바이스 방향에 맞게 회전 시킴
- (UIImage *)rotateImage:(UIImage *)srcImage orientation:(UIInterfaceOrientation)orientationInfo {
    switch (orientationInfo) {
        case UIDeviceOrientationLandscapeRight: {
            UIGraphicsBeginImageContext(CGSizeMake(srcImage.size.width, srcImage.size.height));
            [[UIImage imageWithCGImage:[srcImage CGImage] scale:1.0 orientation:UIImageOrientationDown] drawInRect:CGRectMake(0, 0, srcImage.size.width, srcImage.size.height)];
        } break;
        case UIDeviceOrientationLandscapeLeft: {
            UIGraphicsBeginImageContext(CGSizeMake(srcImage.size.width, srcImage.size.height));
            [[UIImage imageWithCGImage:[srcImage CGImage] scale:1.0 orientation:UIImageOrientationUp] drawInRect:CGRectMake(0, 0, srcImage.size.width, srcImage.size.height)];
        } break;
        default: {// Portrait
            UIGraphicsBeginImageContext(CGSizeMake(srcImage.size.height, srcImage.size.width));
            [[UIImage imageWithCGImage:[srcImage CGImage] scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0, 0, srcImage.size.height, srcImage.size.width)];
        } break;
    }
    srcImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return srcImage;
}

// 재촬영 라벨을 화면에 보여줌
- (void)showRetake {
    if (captureVideoPreviewLayer.connection.enabled == NO) {
        captureVideoPreviewLayer.connection.enabled = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self hideProgress];
        [self clearOverlayView];
        
        [self->_lbGuide setText:@""];
        
        [self->_vCamera setHidden:NO];
        [self->_ivTargat setHidden:YES];
        [self->_btnClose setHidden:YES];
        [self->_btnShutter setHidden:YES];
        [self->_lbGuide setHidden:YES];
        [self->_lbRetake setHidden:NO];
        [self->_lbFocus setHidden:YES];
        [self->_lbSmall setHidden:YES];
        
        [self startAVCamera];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2500 * NSEC_PER_MSEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self->isCapturing = NO;
            
            [self->_lbGuide setText:self->strGuide];
            
            [self->_lbGuide setHidden:NO];
            
            if (self->_captureMode == DOCUMENT_CAPTURE_AUTO) {
                [self->_ivTargat setHidden:NO];
            } else {
                [self->_btnShutter setHidden:NO];
            }
            
            [self->_btnClose setHidden:NO];
            
            [self->_lbRetake setHidden:YES];
            [self->_lbFocus setHidden:YES];
            [self->_lbSmall setHidden:YES];
            
            [self->_lbGuide setNeedsDisplay];
        });
    });
}

// 포커스 라벨을 화면에 보여줌
- (void)showNeedFocus {
    if (captureVideoPreviewLayer.connection.enabled == NO) {
        captureVideoPreviewLayer.connection.enabled = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self hideProgress];
        [self clearOverlayView];
        
        [self->_lbGuide setText:@""];
        
        [self->_vCamera setHidden:NO];
        [self->_ivTargat setHidden:YES];
        [self->_btnClose setHidden:YES];
        [self->_btnShutter setHidden:YES];
        [self->_lbGuide setHidden:YES];
        [self->_lbRetake setHidden:YES];
        [self->_lbFocus setHidden:NO];
        [self->_lbSmall setHidden:YES];
        
        [self startAVCamera];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2500 * NSEC_PER_MSEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self->isCapturing = NO;
            
            [self->_lbGuide setText:self->strGuide];
            [self->_lbGuide setHidden:NO];
            
            if (self->_captureMode == DOCUMENT_CAPTURE_AUTO) {
                [self->_ivTargat setHidden:NO];
            } else {
                [self->_btnShutter setHidden:NO];
            }
            
            [self->_btnClose setHidden:NO];
            
            [self->_lbRetake setHidden:YES];
            [self->_lbFocus setHidden:YES];
            [self->_lbSmall setHidden:YES];
            
            [self->_lbGuide setNeedsDisplay];
        });
    });
}

// 촬영된 이미지 내의 문서 영역이 너무 작음을 보여줌
- (void)showTooSmallImage {
    if (captureVideoPreviewLayer.connection.enabled == NO) {
        captureVideoPreviewLayer.connection.enabled = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self hideProgress];
        [self clearOverlayView];
        
        [self->_lbGuide setText:@""];
        
        [self->_vCamera setHidden:NO];
        [self->_ivTargat setHidden:YES];
        [self->_btnClose setHidden:YES];
        [self->_btnShutter setHidden:YES];
        [self->_lbGuide setHidden:YES];
        [self->_lbRetake setHidden:YES];
        [self->_lbFocus setHidden:YES];
        [self->_lbSmall setHidden:NO];
        
        [self startAVCamera];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2500 * NSEC_PER_MSEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self->isCapturing = NO;
            
            [self->_lbGuide setText:self->strGuide];
            
            [self->_lbGuide setHidden:NO];
            
            if (self->_captureMode == DOCUMENT_CAPTURE_AUTO) {
                [self->_ivTargat setHidden:NO];
            } else {
                [self->_btnShutter setHidden:NO];
            }
            
            [self->_btnClose setHidden:NO];
            
            [self->_lbRetake setHidden:YES];
            [self->_lbFocus setHidden:YES];
            [self->_lbSmall setHidden:YES];
            
            [self->_lbGuide setNeedsDisplay];
        });
    });
}

// Return the current time info by string.
- (NSString *)currentDateAndTime {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyy_HHmmssSS"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    return dateString;
}

// 주어진 이미지를 Document에 저장
- (NSString *)saveUIImageToDocument:(UIImage *)image {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = @"temp_";
    fileName = [fileName stringByAppendingString:[self currentDateAndTime]];
    fileName = [fileName stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];
    
    return filePath;
}
// InstanceMethod ]]

// Callback [[
// 카메라 프리뷰 콜백
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 자동 촬영 모드이고, 현재 촬영과 영역 검출이 진행 중이 아니라면 프리뷰 프레임을 가지고 영역 검출 시도
    if (_captureMode == DOCUMENT_CAPTURE_AUTO) {
        if (isCapturing == NO && isFinding == NO && sampleBuffer != nil) {
            [self findDocumentArea:sampleBuffer];
        }
    }
}

// 셔터 버튼 콜백
- (IBAction)tapShutter:(id)sender {
    [self takePicture];
}

// 닫기 버튼 콜백
- (IBAction)tapClose:(id)sender {
    if (captureSession != nil && [captureSession isRunning]) {
        [captureSession stopRunning];
    }
    
    [self dismissViewControllerAnimated:NO completion:NULL];
}

// 문서 촬영 및 영역 검출 성공 시, 결과 전달
- (void)onDocumentsDetected:(NSArray *)selvyDocumentsData {
    if (_recognitionDelegate != nil) {
        [_recognitionDelegate onDocumentsDetected:selvyDocumentsData];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self hideProgress];
        
        [self dismissViewControllerAnimated:NO completion:NULL];
    });
}

// 문서 촬영화면에서 촬영이나 영역 검출 실패 시, 결과 전달
- (void)onDocumentsError:(DocumentError)errorCode msg:(NSString *)msg {
    if (_recognitionDelegate != nil) {
        if (errorCode == DocumentErrorDetect) {
            [self showRetake];
        } else {
            [_recognitionDelegate onDocumentsError:errorCode msg:msg];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self hideProgress];
                
                [self dismissViewControllerAnimated:NO completion:NULL];
            });
        }
    }
}

// Callback ]]
@end
