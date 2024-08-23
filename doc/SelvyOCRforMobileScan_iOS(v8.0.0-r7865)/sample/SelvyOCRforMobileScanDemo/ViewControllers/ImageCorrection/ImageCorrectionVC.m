//
//  ImageCorrectionVC.m
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import "ImageCorrectionVC.h"

#import "SelvyImageProcessing.h"
#import "SelvyImageSaver.h"

// ImageCorrection ViewController
// 이미지 처리(변경) 예제
@interface ImageCorrectionVC () {
    UIImage *image; // 원본 이미지
    UIImage *correctedImage; // 현재 변경 중인 이미지
    BOOL isApplied; // 변경 사항이 이미지에 적용되었는지 여부
}

@property (weak, nonatomic) IBOutlet UIView *vMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveToTiff; // TIFF 저장 버튼
@property (weak, nonatomic) IBOutlet UIImageView *ivImage; // 이미지 뷰
@property (weak, nonatomic) IBOutlet UIButton *btnApply; // 적용 버튼
@property (weak, nonatomic) IBOutlet UILabel *lbThreshold1; // 임계값 #1 라벨
@property (weak, nonatomic) IBOutlet UILabel *lbThreshold2; // 임계값 #1 라벨
@property (weak, nonatomic) IBOutlet UISlider *sThreshold1; // 임계값 #1 슬라이더
@property (weak, nonatomic) IBOutlet UISlider *sThreshold2; // 임계값 #2 슬라이더

@end

@implementation ImageCorrectionVC

// Constant [[
// 타이틀 라벨 스트링
static const NSString* STR_BINARIZATION = @"Binarization";
static const NSString* STR_BINARIZATION_ADAPTIVE = @"Bin.Adaptive";
static const NSString* STR_BRIGHTNESS = @"Brightness";
static const NSString* STR_CONTRAST = @"Contrast";
static const NSString* STR_SOFTEN = @"Soften";
static const NSString* STR_SHARPEN = @"Sharpen";

// TIFF 저장 팝업 스트링
static const NSString* STR_SAVE_SUCCESS = @"Save success";
static const NSString* STR_SAVE_FAIL = @"Failed to save";

// Image correction min/max threshold 값
static const int minThresholdValueBinarization = 0;
static const int maxThresholdValueBinarization = 255;
static const int minThresholdValueBinarizationAdaptive = 0;
static const int maxThresholdValueBinarizationAdaptive = 255;
static const int minThresholdValueBrightness = -100;
static const int maxThresholdValueBrightness = 100;
static const int minThresholdValueContrast = -100;
static const int maxThresholdValueContrast = 100;
static const int minThresholdValueSoften = 0;
static const int maxThresholdValueSoften = 10;
static const int minThresholdValueSharpen = 0;
static const int maxThresholdValueSharpen = 10;
// Constant ]]

// LifeCycle [[
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 예제 이미지 로드
    image = [UIImage imageNamed:@"sample_document.jpg"];
    isApplied = false;
}

- (void)viewWillAppear:(BOOL)animated {
    // 모든 뷰 숨김
    [_btnSaveToTiff setHidden:YES];
    [_ivImage setHidden:YES];
    [_btnApply setHidden:YES];
    [_lbThreshold1 setHidden:YES];
    [_lbThreshold2 setHidden:YES];
    [_sThreshold1 setHidden:YES];
    [_sThreshold2 setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect vRect = CGRectMake((self.view.frame.size.width / 2) - (320 / 2), (self.view.frame.size.height / 2) - (568 / 2), 320, 568);
    [_vMenu setFrame:vRect];
    
    [_ivImage setImage:image]; // ImageView 에 테스트 이미지 셋
    
    // 슬라이더에 최대/최소 임계값 세팅
    if (_icType == IC_Binarization) { // Binarization
        [_lbThreshold1 setText:(NSString *)STR_BINARIZATION];
        [_lbThreshold1 setHidden:NO]; // Show the threshold title label
        
        [_sThreshold1 setMinimumValue:minThresholdValueBinarization];
        [_sThreshold1 setMaximumValue:maxThresholdValueBinarization];
        [_sThreshold1 setValue:(minThresholdValueBinarization + maxThresholdValueBinarization) / 2]; // Default value
        [_sThreshold1 setHidden:NO]; // Show the threshold slider
    } else if (_icType == IC_BinarizationAdaptive) {
        [_lbThreshold1 setText:(NSString *)STR_BINARIZATION_ADAPTIVE];
        [_lbThreshold1 setHidden:NO]; // Show the threshold title label
        
        [_sThreshold1 setMinimumValue:minThresholdValueBinarizationAdaptive];
        [_sThreshold1 setMaximumValue:maxThresholdValueBinarizationAdaptive];
        [_sThreshold1 setValue:(minThresholdValueBinarization + maxThresholdValueBinarization) / 2]; // Default value
        [_sThreshold1 setHidden:NO]; // Show the threshold slider
    } else if (_icType == IC_BrightnessContrast) { // Brightness/Contrast
        [_lbThreshold1 setText:(NSString *)STR_BRIGHTNESS];
        [_lbThreshold1 setHidden:NO]; // Show the threshold title label
        [_lbThreshold2 setText:(NSString *)STR_CONTRAST];
        [_lbThreshold2 setHidden:NO]; // Show the threshold title label
        
        [_sThreshold1 setMinimumValue:minThresholdValueBrightness];
        [_sThreshold1 setMaximumValue:maxThresholdValueBrightness];
        [_sThreshold1 setValue:(minThresholdValueBrightness + maxThresholdValueBrightness) / 2]; // Default value
        [_sThreshold1 setHidden:NO]; // Show the threshold slider
        [_sThreshold2 setMinimumValue:minThresholdValueContrast];
        [_sThreshold2 setMaximumValue:maxThresholdValueContrast];
        [_sThreshold2 setValue:(minThresholdValueContrast + maxThresholdValueContrast) / 2]; // Default value
        [_sThreshold2 setHidden:NO]; // Show the threshold slider
    } else if (_icType == IC_Soften) { // Soften
        [_lbThreshold1 setText:(NSString *)STR_SOFTEN];
        [_lbThreshold1 setHidden:NO]; // Show the threshold title label
        
        [_sThreshold1 setMinimumValue:minThresholdValueSoften];
        [_sThreshold1 setMaximumValue:maxThresholdValueSoften];
        [_sThreshold1 setValue:(minThresholdValueSoften + maxThresholdValueSoften) / 2]; // Default value
        [_sThreshold1 setHidden:NO]; // Show the threshold slider
    } else if (_icType == IC_Sharpen) { // Sharpen
        [_lbThreshold1 setText:(NSString *)STR_SHARPEN];
        [_lbThreshold1 setHidden:NO]; // Show the threshold title label
        
        [_sThreshold1 setMinimumValue:minThresholdValueSharpen];
        [_sThreshold1 setMaximumValue:maxThresholdValueSharpen];
        [_sThreshold1 setValue:(minThresholdValueSharpen + maxThresholdValueSharpen) / 2]; // Default value
        [_sThreshold1 setHidden:NO]; // Show the threshold slider
    }
    
    // 버튼 나타내기
    [_ivImage setHidden:NO];
    [_btnApply setHidden:NO];
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
// 선택된 이미지 처리와 그 임계값을 이미지에 적용
- (void) imageCorrection {
    if (_icType == IC_Binarization) { // Binarization
        int value1 = (int) [_sThreshold1 value]; // 슬라이더에서 임계값을 가져옴
        correctedImage = [SelvyImageProcessing processImageBinarization:image threshold:value1]; // ImageCorrection - Binarization
        [_ivImage setImage:correctedImage]; // 변경된 이미지를 이미지뷰에 세팅
    } else if (_icType == IC_BinarizationAdaptive) { // Binarization Adaptive
        int value1 = (int) [_sThreshold1 value]; // 슬라이더에서 임계값을 가져옴
        correctedImage = [SelvyImageProcessing processImageBinarizationUsingAdaptive:image blockSize:value1 constant:10]; // ImageCorrection - Binarization Adaptive
        [_ivImage setImage:correctedImage]; // 변경된 이미지를 이미지뷰에 세팅
    } else if (_icType == IC_BrightnessContrast) { // Brightness/Contrast
        int value1 = (int) [_sThreshold1 value]; // 슬라이더에서 임계값을 가져옴
        int value2 = (int) [_sThreshold2 value]; // 슬라이더에서 임계값을 가져옴
        correctedImage = [SelvyImageProcessing processImageContrastBrightness:image constrastThreshold:value2 brightnessThreshold:value1]; // ImageCorrection - Brightness/Contrast
        [_ivImage setImage:correctedImage]; // 변경된 이미지를 이미지뷰에 세팅
    } else if (_icType == IC_Soften) { // ImageCorrection - Soften
        int value1 = (int) [_sThreshold1 value]; // 슬라이더에서 임계값을 가져옴
        correctedImage = [SelvyImageProcessing processImageSoften:image threshold:value1]; // Soften
        [_ivImage setImage:correctedImage]; // 변경된 이미지를 이미지뷰에 세팅
    } else if (_icType == IC_Sharpen) { // ImageCorrection - Sharpen
        int value1 = (int) [_sThreshold1 value]; // 슬라이더에서 임계값을 가져옴
        correctedImage = [SelvyImageProcessing processImageSharpen:image threshold:value1]; // Sharpen
        [_ivImage setImage:correctedImage]; // Sharpen 이미지를 이미지 뷰에 할당
    } else if (_icType == IC_Auto) { // Auto
        correctedImage = [SelvyImageProcessing processImageAuto:image]; // ImageCorrection - Auto
        [_ivImage setImage:correctedImage]; // 자동으로 화질 개선된 이미지를 이미지 뷰에 할당
    }
}

// 현재 시각을 스트링으로 리턴
- (NSString *)currentDateAndTime {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyy_HHmmssSS"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    return dateString;
}

// Application Document 폴더에서 유니크한 파일이름을 생성하여 리턴
- (NSString *)uniqueFilePathInDocument {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = @"TIFF_";
    fileName = [fileName stringByAppendingString:[self currentDateAndTime]];
    fileName = [fileName stringByAppendingString:@".tif"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}
// InstanceMethod ]]

// Callback [[
// 적용 버튼 콜백
- (IBAction)tapApply:(id)sender {
    isApplied = !isApplied; // 변수 값 토글
    if (isApplied) { // Apply.
        [_btnApply setBackgroundColor:[UIColor redColor]]; // 버튼 상태 변경
        
        [_btnSaveToTiff setHidden:NO]; // TIFF 저장 버튼 보여줌
        
        [self imageCorrection]; // 이미지를 변경하여 이미지 뷰에 세팅
    } else { // Not apply.
        [_btnApply setBackgroundColor:[UIColor whiteColor]]; // 버튼 상태 변경
        
        [_btnSaveToTiff setHidden:YES]; // TIFF 저장 버튼 숨김
        
        [_ivImage setImage:image]; // 원본 이미지를 이미지 뷰에 세팅
    }
}

// 임계값 슬라이더#1 콜백
// 임계값 변경 - Binarization/BinarizationAdaptiveBrightness/Soften/Sharpen
- (IBAction)tapThreshold1:(id)sender {
    if (!isApplied) { // 미적용 상태라면...
        isApplied = !isApplied; // 변수 값 토글
        [_btnApply setBackgroundColor:[UIColor redColor]]; // 버튼 상태 변경
        
        [_btnSaveToTiff setHidden:NO]; // TIFF 저장 버튼 보여줌
    }
    
    [self imageCorrection]; // 이미지 변경 후 이미지 뷰에 세팅
}

// 임계값 슬라이더#2 콜백
// 임계값 변경 - Contrast
- (IBAction)tapThreshold2:(id)sender {
    if (!isApplied) { // 미적용 상태라면...
        isApplied = !isApplied; // 변수 값 토글
        [_btnApply setBackgroundColor:[UIColor redColor]]; // 버튼 상태 변경
        
        [_btnSaveToTiff setHidden:NO]; // TIFF 저장 버튼 보여줌
    }

    [self imageCorrection]; // 이미지 변경 후 이미지 뷰에 세팅
}

// TIFF 저장 버튼 콜백
- (IBAction)tapSaveToTiff:(id)sender {
    if (correctedImage != nil) {
        NSString *filepath = [self uniqueFilePathInDocument]; // 유니크한 파일 경로를 얻어옴
        BOOL ret = [SelvyImageSaver saveImageToTIFF:filepath image:correctedImage tiffType:TiffTypeJpeg xResolution:200 yResolution:200 overwrite:YES];
        
        // 성공 혹은 실패 팝업
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if (ret) {
            alertView.title = (NSString *)STR_SAVE_SUCCESS;
            alertView.message = filepath;
        } else {
            alertView.title = (NSString *)STR_SAVE_FAIL;
        }
        
        [alertView show];
    }
}

// 닫기 버튼 콜백
- (IBAction)tapClose:(id)sender {
    // 메인 화면으로 이동
    [self dismissViewControllerAnimated:NO completion:nil];
}

// Callback ]]

// InnerClass ]]
// InnerClass ]]

@end
