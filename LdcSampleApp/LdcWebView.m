#import "LdcWebView.h"

//SSL 유효성 검증
//CFAbsoluteTime SecCertificateNotValidBefore(SecCertificateRef certificate);
//CFAbsoluteTime SecCertificateNotValidAfter(SecCertificateRef certificate);

@implementation LdcWebView

@synthesize webView;
@synthesize requestCode;
@synthesize resultCode;
@synthesize intent;
@synthesize data;
@synthesize latitude;
@synthesize longitude;
@synthesize task;
@synthesize activityIndicator;
@synthesize wkProcessPool;
@synthesize splashView;
//@synthesize connection;

//2018.09.06 hmwoo 페이지 이동시에 페이지기록을 저장해놓는 변수
NSMutableArray *urlHistory;

//2018.09.07 hmwoo 현재 페이지 정보
NSString *currentUrl;
NSString *SERVICE_CD = @"A69";
NSString *rootUrl = @"";
NSString *ONEID_KEY = @"";
NSString *USER_ID = @"";

CLAuthorizationStatus currentLocationStatus = kCLAuthorizationStatusNotDetermined;

CustomAlertView *popup;

// 다운로드 시에 UI 표시용
float progress = 0.0;

float percentageWritten = 0.0;
int taskTotalBytesWritten = 0;
int taskTotalBytesExpectedToWrite = 0;

#define DEV 0
#define STG 1
#define PRD 2

#define TARGET PRD

#if TARGET == PRD
    // 상용
    //NSString *mainUrl = @"ucare.uplus.co.kr";
    NSString *mainUrl = @"https://ucare.uplus.co.kr:8443";
#elif TARGET == STG
    // 검수
    //NSString *mainUrl = @"phone.uplus.co.kr";
    NSString *mainUrl = @"https://phone.uplus.co.kr:8443";
#elif TARGET == DEV
    // 개발
    NSString *mainUrl = @"http://nexgrid2.iptime.org:8084";

#endif

//===================

Boolean debug = false;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 2019.05.09 ADD hmwoo 네비게이션 기능 초기화
	[self naviFuncInit];
	
	// 2019.05.09 ADD hmwoo JavaScript CallBack(Web -> App) 초기화
	[self jsCallBackInit];
	
	// 2019.05.09 ADD hmwoo WKWebView Basic Setting
	[self wkWebViewInit:false];

	// 2019.05.09 ADD hmwoo WKWeb 스와이프(뒤로가기, 앞으로가기) 핸들러 추가
	[self addSwipehandler];
	
	// 2019.05.09 ADD hmwoo App 화면 꺼지가나 켜질경우 Callback 함수 추가
//    [self addTurnContrlhandler];

    [self showSplash];
    
    if (debug == false) {
        [self versionCheck];
    } else {
        // 2019.05.09 ADD hmwoo WebView Page 로드(Webview 관련 설정 가장 마지막에 배치해야함)
        [self loadWebview];
    }
	// 2019.05.29 Das Server 검수 설정
    if (TARGET == PRD) {
        [SetServerTarget Server:IntegrationContants.DAS_TARGET_REAL];
    } else {
        [SetServerTarget Server:IntegrationContants.DAS_TARGET_STAGE];
    }

    [self connectedToNetwork];
    
}

- (void)viewWillLayoutSubviews
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

   
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGRect appRect = self.view.frame;
//    if (screenRect.size.height == appRect.size.height)
//    {
//        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//        float statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
//        appRect.origin.y = statusBarHeight;
//        appRect.size.height -= statusBarHeight;
//        self.view.frame = appRect;
//    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (void) sendUUID
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* iOSUUID = [userDefault stringForKey:@"UUID_KEY"];

    // new uuid
    if(iOSUUID == nil || [iOSUUID  isEqual:@""])
    {
        iOSUUID = [[NSUUID UUID] UUIDString];
    }

    // save uuid
    [userDefault setObject:iOSUUID forKey:@"UUID_KEY"];
    [userDefault synchronize];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         NSString *js = [NSString stringWithFormat: @"resUUID('%@')", iOSUUID];
         
         [self.webView evaluateJavaScript:js completionHandler:nil];
     }];
}

- (void) hashCheck
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         NSString *confirm = @"";
         
         NSString *searchPath = @"/private/var/containers/Bundle/Application/";
         
         NSError *error = nil;
         
         NSFileManager *filemanager;
         
         filemanager = [NSFileManager defaultManager];
         
         NSArray *items = [filemanager contentsOfDirectoryAtPath:searchPath error:&error];
         
         NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
         
         NSString *target = nil;
         
         bool endSearch = false;
         
         if(error == nil)
         {
             for(int i = 0; i < items.count; i++)
             {
                 NSArray *tmpitems = [filemanager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@", searchPath, [items objectAtIndex:i]] error:&error];
                 
                 for(int j = 0; j < tmpitems.count; j++)
                 {
                     if([[tmpitems objectAtIndex:j] isEqualToString:[NSString stringWithFormat:@"%@%@", appName, @".app"]])
                     {
                         target = [NSString stringWithFormat:@"%@%@/%@", searchPath, [items objectAtIndex:i], [tmpitems objectAtIndex:j]];
                         endSearch = true;
                         break;
                     }
                 }
                 if(endSearch) break;
             }
             
             if(target != nil)
             {
                 NSMutableData *hashData = [NSMutableData data];
                 
                 NSString *path;
                 
                 NSDirectoryEnumerator *dirEnum = [filemanager enumeratorAtPath:target];
                 
                 while ((path = [dirEnum nextObject]) != nil)
                 {
                     if([path isEqualToString:@".DS_Store"] || [path containsString:@"SC_Info"])
                     {
                         continue;
                     }
                     
                     NSData *data = [filemanager contentsAtPath:[NSString stringWithFormat:@"%@/%@", target, path]];
                     
                     [hashData appendData:data];
                 }
                 
                 confirm = [TelUtil AES256Encode:[Util createSHA512:[Util createBASE64:hashData]] key:@"secretKey1234567"];
             }
         }
         
         NSString *webCheck;
         
         if(error == nil)
         {
             webCheck = confirm;
         }
         else
         {
             webCheck =
             [TelUtil AES256Encode:[
                                    Util createSHA512:
                                    [NSString stringWithFormat:@"%@", error == nil?@"":error.localizedDescription]
                                    ] key:@"secretKey1234567"
             ];
         }
         
         NSString *js = [NSString stringWithFormat: @"resContinueCheck('%@')", webCheck];
         
         [self.webView evaluateJavaScript:js completionHandler:nil];
     }];
}

- (void) showSplash
{
    splashView = [[UIView alloc] init];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"back.png"]];
    
    [splashView setBackgroundColor:background];
    
    splashView.frame = self.view.frame;
    
    UIView *videoView = [[UIView alloc] init];
    
    UIImageView *splashText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_ci@3x.png"]];
    
    [videoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [splashText setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [splashView addSubview:videoView];
    [splashView addSubview:splashText];
    
    NSLayoutConstraint *videoViewLeft = [NSLayoutConstraint constraintWithItem:videoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:splashView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *videoViewRight = [NSLayoutConstraint constraintWithItem:videoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:splashView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *aspectRatio = [NSLayoutConstraint
                                       constraintWithItem:videoView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:videoView
                                       attribute:NSLayoutAttributeWidth
                                       multiplier:(18 / 9)
                                       constant:0];
    
    NSLayoutConstraint *videoViewVerticalCenter =
    [NSLayoutConstraint constraintWithItem:videoView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:splashView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    //126
    NSLayoutConstraint *splashTextWidth = [NSLayoutConstraint constraintWithItem:splashText attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:66];
    //39
    NSLayoutConstraint *splashTextHeight = [NSLayoutConstraint constraintWithItem:splashText attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:20];
    //74
    NSLayoutConstraint *splashTextBottom = [NSLayoutConstraint constraintWithItem:splashView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:splashText attribute:NSLayoutAttributeBottom multiplier:1 constant:34];
    
    NSLayoutConstraint *splashTextHorizontalCenter =
    [NSLayoutConstraint constraintWithItem:splashText
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:splashView
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0];
    
    [splashView addConstraints:@[videoViewLeft, videoViewRight]];
    [videoView addConstraint:aspectRatio];
    [splashView addConstraint:videoViewVerticalCenter];
    
    [splashView addConstraints:@[splashTextBottom, splashTextHorizontalCenter]];
    [splashText addConstraints:@[splashTextWidth, splashTextHeight]];
    
    [self.view addSubview:splashView];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
   
       NSString *path = [[NSBundle mainBundle] pathForResource:@"splash" ofType:@"mp4"];
       
       NSURL *url = [NSURL fileURLWithPath:path];
       
       AVPlayer *player = [AVPlayer playerWithURL:url];
       
       AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:player];
       
       videoLayer.frame = videoView.bounds;
       
       [videoView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
       
       videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
       
       [videoView.layer addSublayer:videoLayer];
       
       [videoLayer.player play];
       
       [splashText setAlpha:1.0f];
       /*
       [UIView animateWithDuration:1.1f animations:^{
           
           [splashText setAlpha:0.0f];
           
       }
                        completion:^(BOOL finished)
        {
            [UIView animateWithDuration:0.5f animations:^{
                
                [splashText setAlpha:1.0f];
                
            }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.8f animations:^{
                     
                     [splashText setAlpha:0.0f];
                     
                 } completion:nil];
                 
             }];
        }];
        */
   }];

}

/*
- (void) showSplash
{
    splashView = [[[NSBundle mainBundle] loadNibNamed:@"SplashView" owner:self options:nil] lastObject];
    
    UIView *videoView;
    
    UIImageView *splashText;
    
    
    for(int i = 0; i < splashView.subviews.count; i++)
    {
        if([splashView.subviews[i] isKindOfClass:[UIImageView class]])
        {
            splashText = splashView.subviews[i];
        }
        else if([splashView.subviews[i] isKindOfClass:[UIView class]])
        {
            videoView = splashView.subviews[i];
        }
    }
    
    [self.view addSubview:splashView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"splash" ofType:@"mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    
    //    AVAsset *asset = player.currentItem.asset;
    
    //    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    
    //    AVPlayer *newPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    videoLayer.frame = CGRectMake(0, 0, screenRect.size.height, screenRect.size.height);
    //    videoLayer.frame = videoView.frame;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [videoView.layer addSublayer:videoLayer];
    
    [videoLayer.player play];
    
    [splashText setAlpha:1.0f];
    
    [UIView animateWithDuration:1.1f animations:^{
        
        [splashText setAlpha:0.0f];
        
    }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f animations:^{
             
             [splashText setAlpha:1.0f];
             
         }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.8f animations:^{
                  
                  [splashText setAlpha:0.0f];
                  
              } completion:nil];
              
          }];
         
     }];
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [videoLayer.player pause];
    //    });
}
*/
/*
- (void) showSplash
{
    splashView = [[[NSBundle mainBundle] loadNibNamed:@"SplashView" owner:self options:nil] lastObject];
    
    UIView *videoView;
    
    UIImageView *splashText;
    
    
    for(int i = 0; i < splashView.subviews.count; i++)
    {
        if([splashView.subviews[i] isKindOfClass:[UIImageView class]])
        {
            splashText = splashView.subviews[i];
        }
        else if([splashView.subviews[i] isKindOfClass:[UIView class]])
        {
            videoView = splashView.subviews[i];
        }
    }
    
    [self.view addSubview:splashView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"splash" ofType:@"mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    
    //    AVAsset *asset = player.currentItem.asset;
    
    //    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    
    //    AVPlayer *newPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    videoLayer.frame = CGRectMake(0, 0, screenRect.size.height, screenRect.size.height);
//    videoLayer.frame = videoView.frame;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [videoView.layer addSublayer:videoLayer];
    
    [videoLayer.player play];
    
    [splashText setAlpha:1.0f];

    [UIView animateWithDuration:1.1f animations:^{
        
        [splashText setAlpha:0.0f];
        
    }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f animations:^{
             
             [splashText setAlpha:1.0f];
             
         }
                          completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.8f animations:^{
                  
                  [splashText setAlpha:0.0f];
                  
              } completion:nil];
              
          }];
         
     }];
 
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [videoLayer.player pause];
//    });
}
*/

- (void)permissionCheck
{
	if
	(
     // 2022-01-27 apple 심사로 주석 처리
//		(
//			[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways &&
//			[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
//		) ||
		([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) ||
		([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized)
	)
	{
		popup = [[CustomAlertView alloc] init];
        popup.backgroundColor = [UIColor colorWithRed:241.0f / 255.0f green:241.0f / 255.0f blue:241.0f / 255.0f alpha:1.0f];
        
        // 2021.03.09 iOS 11 이상 권한 팝업 아래 짤리는 문제 해결 (safe area 문제)
        if (@available(iOS 11.0, *)) {
            popup.center = CGPointMake(self.view.safeAreaLayoutGuide.layoutFrame.size.width / 2, self.view.safeAreaLayoutGuide.layoutFrame.size.height);
            popup.frame = CGRectMake(0, 0, self.view.safeAreaLayoutGuide.layoutFrame.size.width, self.view.safeAreaLayoutGuide.layoutFrame.size.height);
            
        } else {
            popup.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height);
            popup.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        
		[popup.btn_allow addTarget:self action:@selector(permissionAllowClick) forControlEvents:UIControlEventTouchUpInside];
		[popup.btn_denied addTarget:self action:@selector(permissionDeniedClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        [webView addSubview:popup];
	}
}

- (void) permissionAllowClick
{
    // 2022-01-27 위치권한 삭제
//	if([self locationPermissionCheck])
	{
        // 2024.01.05 삭제
//		if([self cameraPermissionCheck])
//		{
//			[self photoElbumPermissionCheck];
//		}
        
        [self cameraPermissionCheck];
        
        [self photoElbumPermissionCheck];
	}

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:true forKey:@"ALLOW_PERMISSION"];
    [defaults synchronize]; // 변경 사항 저장
    
    // 2024.01.05 추가
    [popup removeFromSuperview];
}

- (void) permissionDeniedClick
{
	exit(0);
}

/**
 * 네비게이션 기능(화면 이동) 초기화, 스와이프(손가락으로 미는 행위)로 앞으로가기 뒤로가기를 사용할 경우 사용할 필요 없음
 * 만약 사용 하지 않고 화면의 네비게이션 바를 표시하고 싶지 않을경우 setRootViewController 를 [UINavigationController alloc] 을 사용하지 않고 그대로 뷰를 호출해야함
 * ex) [self.window setRootViewController:[[UINavigationController alloc]initWithRootViewController:ldcWebView]] => [self.window setRootViewController:ldcWebView]
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) naviFuncInit
{
	//[self.navigationItem.leftBarButtonItem setAction:@selector(onBackPressed:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"←"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(onBackPressed:)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"→"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(onForwardPressed:)];
	
	self.navigationItem.leftBarButtonItem.title = @"";
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.title = @"";
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[webView setNavigationDelegate:self];
}

/**
 * Web -> App 자바스크립트 콜백 메소드
 * ex) web 자바스크립트에서 window.webkit.messageHandlers.ldc.postMessage() 로 호출 가능
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) jsCallBackInit
{
//    WKWebViewConfiguration *javascriptHandler = [[WKWebViewConfiguration alloc] init];
//
//    [javascriptHandler.userContentController addScriptMessageHandler:self name:@"ldc"];
	
//    CGRect frame = self.view.frame;
//    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//
//    frame.origin.y = statusBarHeight;
//    frame.size.height = frame.size.height - statusBarHeight;
//    self.view.frame = frame;
	
    wkProcessPool = [[WKProcessPool alloc] init];
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = true;
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    configuration.processPool = wkProcessPool;
    [configuration.userContentController addScriptMessageHandler:self name:@"ldc"];
    
    // 2024.01.05 추가
    configuration.allowsInlineMediaPlayback = true;
    
    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    
    // 2024.01.05 추가
    webView.UIDelegate = self;
    
//    webView.scrollView.contentInset = UIEdgeInsetsMake(0 - statusBarHeight, 0, 0, 0);
}

/**
 * WKWebView 초기 기본 설정
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) wkWebViewInit:(bool)useSwipe
{
//    if(@available(iOS 11.0, *))
//    {
//        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
//    }
    
	// navigation bar hide
	[self.navigationController setNavigationBarHidden:YES animated:YES];

	[webView setUIDelegate:self];
//    [webView setUserInteractionEnabled:NO];
    [webView allowsBackForwardNavigationGestures];
	
    //2018.09.07 hmwoo WKWebView의 웹페이지 이동을 감지하는 핸들러가 동작하기 위하여 필요
    webView.navigationDelegate = self;
	
    //2018.09.07 hmwoo WKWebView에서 뒤로 및 앞으로 스와이프 동작을 설정
    webView.allowsBackForwardNavigationGestures = useSwipe;
    
    //2019.06.26 hmwoo wkwebview 화면 bounce 현상 삭제
    webView.scrollView.bounces = false;
}

-(BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

/**
 * WKWebView 스와이프(뒤로가기, 앞으로가기)시 동작 메소드 설정
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) addSwipehandler
{
	UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(recognizerGesture:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [webView addGestureRecognizer:leftSwipeGesture];

    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(recognizerGesture:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [webView addGestureRecognizer:rightSwipeGesture];
    //2018.09.06 hmwoo IOS WebView 스와이프 핸들러 추가(왼쪽, 오른쪽) @END

    //2018.09.06 hmwoo IOS WebView 팬 핸들러 추가(팬핸들러를 추가하지 않을경우 스와이프 핸들러가 잘 동작하지 않는 증상 발견하여 추가) @START
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(recognizerGesture:)];
    [webView addGestureRecognizer:panGesture];
	
    [panGesture requireGestureRecognizerToFail:leftSwipeGesture];
    [panGesture requireGestureRecognizerToFail:rightSwipeGesture];
    //2018.09.06 hmwoo IOS WebView 팬 핸들러 추가(팬핸들러를 추가하지 않을경우 스와이프 핸들러가 잘 동작하지 않는 증상 발견하여 추가) @END
}

/**
 * 앱 화면이 꺼지거나 켜질경우 호출되는 핸들러 추가
 *
 * @author  hmwoo
 * @version 1.0
 */
//- (void) addTurnContrlhandler
//{
//    //2018.09.06 hmwoo IOS 화면이 켜지거나 꺼졌을경우 CallBack 함수 추가 @START
//    CFNotificationCenterAddObserver
//    (
//        CFNotificationCenterGetDarwinNotifyCenter(), //center
//        NULL, // observer
//        onReceive, // callback
//        CFSTR("com.apple.springboard.lockcomplete"),
//        NULL, // object
//        CFNotificationSuspensionBehaviorDeliverImmediately
//    );
//    //2018.09.06 hmwoo IOS 화면이 켜지거나 꺼졌을경우 CallBack 함수 추가 @END
//}

/**
 * 웹 뷰 로드
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) loadWebview
{
	
	//2018.09.06 hmwoo IOS 뷰에 WebView 웹뷰 추가
    [self.view addSubview:webView];
    [self.view sendSubviewToBack:webView];
    
    
    
    // 2021.03.09 status bar 투명해 지문 문제로 추가함
    webView.backgroundColor = [UIColor redColor];
    webView.translatesAutoresizingMaskIntoConstraints = NO;

    if (@available(iOS 11, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [webView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
        [webView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
        [webView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [webView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [webView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
        [webView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
        [webView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [webView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;

    }
    
    
    
    
    
    
//    self.view = webView;

    NSMutableURLRequest *request;
    NSString *url;
    NSString *param = @"";
    NSString *method;
	
    //2018.09.06 hmwoo debug?프로젝트 내 테스트를 위해 만든 html 파일 정보 취득:실질적인 웹페이지 정보 취득
//    Boolean debug = false;
	
    if(debug)
    {
        url = [[NSBundle mainBundle] pathForResource:@"FirstPage" ofType:@"html" inDirectory:@""];
		
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL fileURLWithPath:url]];

    }
    else
    {
//        url = @"https://dasteb.uplus.co.kr:80/das/login/loginView.do";
//        param = @"serviceCd=A45&oneidEmailAddr=&serviceLoginType=1000";
//        method = @"POST";
        
//    url = @"https://dasteb.uplus.co.kr/das/login/loginView.do?serviceCd=A69&oneidEmailAddr=&serviceLoginType=1010&isSupportDv=Y&isSupportFp=Y&deviceId=C069C242-B945-4044-9436-4D4344C0D97D&fidoRt=SUCCESS";
//        url = @"https://casecode.ez-i.co.kr/";
        
        // 검수
//        url = @"https://phone.uplus.co.kr:8443/mob/";
        url = [NSString stringWithFormat:@"%@%@", mainUrl, @"/mob/"];
        
        // 상용
//        url = [NSString stringWithFormat:@"%@%@%@", @"https://", mainUrl, @":8443/mob/"];
        url = [NSString stringWithFormat:@"%@%@", mainUrl, @"/mob/"];
        
        // 개발
        url = [NSString stringWithFormat:@"%@%@", mainUrl, @"/mob/"];
        
        // 고객의 소리 테스트
//        url = @"https://uvoc.uplus.co.kr/uvoc/A0012/true/false";
        
        // 권한 테스트
//        url = @"https://ss7isup2.github.io/WebTest/ldc_ios_permission.html";
        
        method = @"GET";
		
        //2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
        //NSString *body = [NSString stringWithFormat: @"arg1=%@&arg2=%@", @"val1",@"val2"];
		
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, @"?", param]]];
		
        [request setHTTPMethod:method];
        
        //SSL 유효성 검증을위해 일다 냉겨둠
//        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
        //[request setHTTPBody:[body dataUsingEncoding: NSUTF8StringEncoding];
		
		
		
    }
    //2018.09.06 hmwoo 실질적으로 운영하고 있는 웹페이지 정보 취득 @END
	
    //2018.09.07 hmwoo 페이지 이동 Url 취득을 위해 URL SET @START
    urlHistory = [[NSMutableArray alloc] init];
	
    NSMutableDictionary *tmpMap = [NSMutableDictionary dictionary];
    [tmpMap setObject:url forKey:@"url"];
    [tmpMap setObject:method==nil?[NSNull null]:method forKey:@"method"];
    [tmpMap setObject:param forKey:@"param"];
    [urlHistory addObject:tmpMap];
    //2018.09.07 hmwoo 페이지 이동 Url 취득을 위해 URL SET @End
	
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
             for (WKWebsiteDataRecord *record  in records)
             {
                 if ( [record.displayName containsString:@"facebook"])
                 {
                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                       forDataRecords:@[record]
                    completionHandler:^{
                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                    }];
                 }
             }
    }];
    
    //2018.09.06 hmwoo 지정된 웹페이지 로드 @START
    [webView loadRequest:request];
    //2018.09.06 hmwoo 지정된 웹페이지 로드 @END
	
	//2019.05.27 hmwoo 웹뷰 움직이지 않도록 변경 @START
//    [[[webView subviews] lastObject] setScrollEnabled:NO];
//
//    for(id subviews in webView.subviews)
//    {
//        if([[subviews class] isSubclassOfClass:[UIScrollView class]])
//        {
//            ((UIScrollView *)subviews).bounces = NO;
//        }
//	}
	//2019.05.27 hmwoo 웹뷰 움직이지 않도록 변경 @END
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
	NSLog(@"%@", navigationResponse.response.class);
	NSLog(@"%@", webView.URL.absoluteString);
	NSLog(@"%@",  navigationResponse.response.URL.absoluteString);
	if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse *response = ((NSHTTPURLResponse *)navigationResponse.response);
		
		NSDictionary *headers = response.allHeaderFields;
		
		if([headers[@"Content-Type"] containsString:@"application/pdf"])
		{
			MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:true];
			progress = 0.0;
			hub.mode = MBProgressHUDModeDeterminateHorizontalBar;
			[hub setUserInteractionEnabled:true];
			[hub label].text = NSLocalizedString(@"Downloading...", comment:@"HUD loading title");
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self doSomeWorkWithProgress];
				dispatch_async(dispatch_get_main_queue(), ^(void)
				{
					[hub label].text = NSLocalizedString(@"Just Wait...", comment:@"HUD loading title");
    			});
			});
			
			NSURL *url = navigationResponse.response.URL;
			
			
						//NSURL *url = [NSURL URLWithString:@"https://s3.eu-west-2.amazonaws.com/blockchainhub.media/Blockchain+Technology+Handbook.pdf"];
			//NSURL *url = [NSURL URLWithString:@"http://159.65.154.78:8002/storage/whatsapp-status/video/2018/07/26/Zd1XMyCZIpd3XHREyWFOou9ig98IzcJKxEYR8fzd.mp4"];
			
			NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

			[req setHTTPMethod:@"GET"];

//			WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
//
//			[cookieStore getAllCookies:^(NSArray* cookies)
//			{

//				for(NSHTTPCookie *cookie in cookies)
//				{
//					NSLog(@"%@ : %@", cookie.name, cookie.value);
//				}
//
//				NSDictionary *cookie = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
//
//				[req setAllHTTPHeaderFields:cookie];
			
			NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

			NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];

			NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];

			self.task = task;

			[session downloadTaskWithRequest:req];

			[task resume];
		
			decisionHandler(WKNavigationResponsePolicyCancel);
			return;
		}
	}
	else if([webView.URL.absoluteString containsString:@"blob"])
	{
	
	
//		NSURL *url = navigationResponse.response.URL;
//
//		//NSLog(@"%@", [url.absoluteString substringFromIndex:5]);
//		url = [NSURL URLWithString:[url.absoluteString substringFromIndex:5]];
//
//		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//
//		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//

		
//
//
//		NSURLSession *session = [NSURLSession sharedSession];
//
//		self.task = task;
//
//		[session downloadTaskWithRequest:req];
//
//		[task resume];
		
		decisionHandler(WKNavigationResponsePolicyCancel);
		return;
	}
	
	decisionHandler(WKNavigationResponsePolicyAllow);
}

 
- (void) doSomeWorkWithProgress
{
	while (progress < 1.0)
	{
		dispatch_async(dispatch_get_main_queue(), ^(void)
		{
			NSLog(@"%lf", progress);
			[MBProgressHUD HUDForView:self.view].progress = progress;
		});
		usleep(50000);
	}
}
int count = 0;
/**
 * WKWebView의 웹 컨텐트가 탐색되기 전에 탐색여부를 묻는 메소드. decisionHandler를 항상 추가해 주어야 함
 *
 * @author  hmwoo
 * @version 1.0
 * @param   navigationAction  탐색되는 웹 컨텐트의 HTTP메소드, URL 등의 정보
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler {
    
    //===============
    /*
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;
    NSLog(@"backgroundSupported ==>%@",(backgroundSupported?@"YES":@"NO"));
    if (!backgroundSupported){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"안 내"
                                                      message:@"멀티테스킹을 지원하는 기기 또는 어플만  공인인증서비스가 가능합니다."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    NSURLRequest *request = navigationAction.request;
    
    NSString *reqUrl = [[request URL] absoluteString];
    NSLog(@"webview에 요청된 URL => %@", reqUrl);
    
    
    //스마트 신한앱 다운로드 url
    NSString  *sh_url = @"http://itunes.apple.com/us/app/id360681882?mt=8";
    //신한Mobile앱 결제 다운로드 url
    NSString  *sh_url2= @"https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8";
    //현대 다운로드 url
    NSString  *hd_url = @"http://itunes.apple.com/kr/app/id362811160?mt=8";
    //스마트 신한 url 스키마
    NSString  *sh_appname = @"smshinhanansimclick";
    //스마트 신한앱 url 스키마
    NSString  *sh_appname2 = @"shinhan-sr-ansimclick";
    //현대카드 url
    NSString  *hd_appname = @"smhyundaiansimclick";
    //롯데카드 url
    NSString  *lottecard = @"lottesmartpay";
    
    NSLog(@"webview에 요청된 url==>%@",reqUrl);
    if ([reqUrl isEqualToString:hd_url] == YES ){
        NSLog(@"1. 현대 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ( [reqUrl hasPrefix:hd_appname]){
        NSLog(@"2. 현대 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ([reqUrl isEqualToString:sh_url] == YES ){
        NSLog(@"1. 스마트신한 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ( [reqUrl hasPrefix:sh_appname]){
        NSLog(@"2. 스마트신한 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ([reqUrl isEqualToString:sh_url2] == YES ){
        NSLog(@"1. 스마트신한앱 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ( [reqUrl hasPrefix:sh_appname2]){
        NSLog(@"2. 신한모바일앱 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ( [reqUrl hasPrefix:lottecard]){
        NSLog(@"롯데카드 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    //NH카드 공인인증서  다운로드 url
    NSString  *nh_url = @"https://itunes.apple.com/kr/app/nhansimkeullig/id609410702?mt=8";
    //nh카드 앱 url 스키마
    NSString  *nh_appname = @"nonghyupcardansimclick";
    if ([reqUrl isEqualToString:nh_url] == YES ){
        NSLog(@"NH앱 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ( [reqUrl hasPrefix:nh_appname]){
        NSLog(@"NH 앱 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    
    if (![reqUrl hasPrefix:@"http://"] && ![reqUrl hasPrefix:@"https://"]){
        NSLog(@"  앱  url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
    }else{
        NSLog(@"  앱  url 입니다. ==>%@",reqUrl);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
    //===============
    
    
    
    
    
    
    
    
    
    
    */
    
    
    
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);

//	NSLog(@"%@", navigationAction.request.URL.absoluteString);
//
//	NSArray *urlSlashSeperate = [navigationAction.request.URL.absoluteString componentsSeparatedByString: @"/"];
//
//	NSArray *urlExtention = [urlSlashSeperate[[urlSlashSeperate count] - 1] componentsSeparatedByString: @"."];
//
//	NSLog(@"%@", [urlExtention[[urlExtention count] - 1] componentsSeparatedByString:@"?"][0]);
	
// 	NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
//
// 	for(NSHTTPCookie *cookie in cookies)
// 	{
//		NSLog(@"%@ : %@", cookie, cookie.value);
//	}

//	[NSHTTPCookie requestHeaderFieldsWithCookies:NSHTTPCookieStorage.sharedHTTPCookieStorage.];

    // 2021.04.12 수정 - 마켓이동
    NSString *reqUrl = navigationAction.request.URL.absoluteString;
    
    NSLog(@"reqUrl : %@", reqUrl);
    

    // 마켓으로 이동하는 URL 수신
    NSString *appStore = @"https://itunes.apple.com";
    if ([reqUrl hasPrefix:appStore]) {
                       // 마켓 이동
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: reqUrl]];    // deprecated
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                 NSLog(@"마켓 이동 성공");
            }
        }];
    
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    
    
    
    // U+ 고객센터 앱 호출 URL 수신
    NSString *appScheme = @"upapp-mcc-prod://smsurl";

    if ([reqUrl hasPrefix:appScheme]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: reqUrl] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                 NSLog(@"고객센터 앱 실행 성공");
            } else {
                // 마켓 이동
//              [[UIApplication sharedApplication] openURL:[NSURL URLWithString: reqUrl]];    // deprecated
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                         NSLog(@"마켓 이동 성공");
                    }
                }];
            }
        }];

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
        
    
    
    
    
    
    
	NSDictionary *headers = navigationAction.request.allHTTPHeaderFields;

	for(NSString *key in headers)
	{
		NSLog(@"%@ : %@", key, headers[key]);
	}
	
    if(navigationAction.navigationType == WKNavigationTypeBackForward)
    {
		
        if(currentUrl == nil || [currentUrl isEqualToString:webView.backForwardList.forwardItem.URL.absoluteString])
        {
            NSLog(@"%@", @"뒤로가기");
			
        }
        else
        {
            NSLog(@"%@", @"앞으로가기");
        }
    }
    else
    {
        NSLog(@"%@", @"뒤로가기, 앞으로가기 아님");
    }
	
    NSLog(@"~~~");
    NSLog(@"~~~");
    
//    NSURLRequest *request = navigationAction.request;
////    if(![request.URL.absoluteString hasPrefix:@"http://"] && ![request.URL.absoluteString hasPrefix:@"https://"]) {
//    if([request.URL.absoluteString hasPrefix:@"http://"]) {
//        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {
//           //urlscheme, tel, mailto, etc.
////           [[UIApplication sharedApplication] openURL:request.URL];
//            [webView loadRequest:request];
//
////           decisionHandler(WKNavigationActionPolicyCancel);
////           return;
//       }
//   }
    
    
    
      
    decisionHandler(WKNavigationActionPolicyAllow); //Always allow
	
	
	
//
//    NSLog(@"%@", navigationAction.request.URL.absoluteString);
//    NSLog(@"%@", navigationAction.request.HTTPMethod);
    
    
    
}

/**
 * WKWebView의 웹 컨텐트가 로드될경우 호출되는 핸들러
 *
 * @author  hmwoo
 * @version 1.0
 * @param   webView  url, parameter 등의 로드된 웹페이지 정보
 * @param   navigation  ...
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    currentUrl = webView.URL.absoluteString;
	
    NSLog(@"%@", webView.URL.absoluteString);
}

- (void) startIndicator
{
    if(activityIndicator == nil)
    {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [activityIndicator setCenter:self.view.center];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview : activityIndicator];
   }

   // ProgressBar Start
   activityIndicator.hidden= FALSE;
   [activityIndicator startAnimating];
   [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void) stopIndicator
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden= TRUE;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

/**
 * 화면에 동작이 인식되었을 경우 동작을 지시하는 CallBack 함수.
 *
 * @author  hmwoo
 * @version 1.0
 * @param   gesture  화면에 동작이 인식되었을 경우 동작에 대한 정보
 */
-(void)recognizerGesture:(UIGestureRecognizer *)gesture{
	
//	NSLog(@"%@", @"recognizerGesture");
	
    if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
		
        UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gesture;
		
        if(swipeGesture.direction == UISwipeGestureRecognizerDirectionRight)
        {
            //[self onBackPressed:gesture];
        }
        else if(((UISwipeGestureRecognizer *)gesture).direction == UISwipeGestureRecognizerDirectionLeft)
        {
            //[self onForwardPressed:gesture];
        }
    }
}

/**
 * 뒤로가기에 해당하는 동작을 지원하는 메소드
 *
 * @author  hmwoo
 * @version 1.0
 * @param   sender  ...
 */
-(void)onBackPressed:(id)sender
{
    NSLog(@"뒤로가기 : onBackPressed");
    //NSLog(@"%@", webView.URL.absoluteURL);
    if(webView.canGoBack)
    {
        [webView goBack];
    }
}

/**
 * 앞으로가기 해당하는 동작을 지원하는 메소드
 *
 * @author  hmwoo
 * @version 1.0
 * @param   sender  ...
 */
-(void)onForwardPressed:(id)sender
{
    NSLog(@"앞으로가기 : onForwardPressed");
    if(webView.canGoForward)
    {
        [webView goForward];
    }
}

/**
 * 휴대폰이 화면에 관련된 동작(ex_화면꺼짐)이 인식될경우 호출되는 메소드
 *
 * @author  hmwoo
 * @version 1.0
 * @param   name  화면에 관련된 구체적인 동작 상태를 정의
 */
//static void onReceive(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//    CFStringRef nameCFString = (CFStringRef)name;
//    NSString *lockState = (NSString*)CFBridgingRelease(nameCFString);
//
//    //2018.09.06 hmwoo 화면의 꺼졌을 경우
//    if([lockState isEqualToString:@"com.apple.springboard.lockcomplete"])
//    {
//
//    }
//}

/**
 * WKScriptMessageHandler에 의해 생성된 delegate 메소드
 * 자바스크립트에서 ios에 wekkit핸들러를 통해 postMessage함수를 사용한 경우 실행
 *
 * @author  hmwoo
 * @version 1.0
 * @param   message  javascript에서 전달한 파라미터
 */
- (void)userContentController:(WKUserContentController *)javascriptController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *map = (NSDictionary *)message.body;
	
    for (NSString* key in map) {
        NSLog(@"%@%@%@", key, @" : ", map[key]);
    }
	
    if([[[message body] allKeys] count] > 0 && [[message body]objectForKey:@"function"])
    {
        NSString *function = map[@"function"];
		
        if([function isEqualToString:@"reqCamera"])
        {
            if([self cameraPermissionCheck] == true) {
                //2018.09.06 hmwoo 카메라 호출
                [[CameraUtil new] callCamera:self];
            }
        }
        else if([function isEqualToString:@"reqOCRCamera"])
        {
            if([self cameraPermissionCheck] == true) {
                [[CameraUtil new] callCamera:self];
            }
            /*
			DocumentVC *documentVC = [[DocumentVC alloc] init];
            // 스위치에서 자동 촬영 on/off 상태를 가져와서 세팅
            //documentVC.captureMode = [_swAuto isOn] == YES ? DOCUMENT_CAPTURE_AUTO : DOCUMENT_CAPTURE_MANUAL;
			
			if([map[@"auto"] isEqualToString:@"on"])
			{
				documentVC.captureMode =  DOCUMENT_CAPTURE_AUTO;
			}
			else
			{
				documentVC.captureMode =  DOCUMENT_CAPTURE_MANUAL;
			}
			
			if([map[@"imgType"] isEqualToString:@"receipt"])
			{
				documentVC.imageType = DOCUMENT_IMAGE_RECEIPT;
			}
			else
			{
				documentVC.imageType = DOCUMENT_IMAGE_ESTIMATE;
			}
			
            documentVC.recognitionDelegate = self;
			
            // 신분증 촬영 화면으로 이동
            [self presentViewController:documentVC animated:YES completion:NULL];
             */
        }
        else if([function isEqualToString:@"reqPhotoAlbum"])
        {
            if ([self photoElbumPermissionCheck] == true) {
                //2018.09.06 hmwoo 포토앨범 호출
                [[CameraUtil new] callPhotoAlbum:self];
            }
        }
		else if([function isEqualToString:@"reqMultiPhotoAlbum"])
        {
            if ([self photoElbumPermissionCheck] == true) {
                // Create the image picker
                ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
                elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select, defaults to 4
                elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
                elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
                elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
                elcPicker.imagePickerDelegate = self;
                
                //Present modally
                [self presentViewController:elcPicker animated:YES completion:nil];
            }
        }
        else if([function isEqualToString:@"reqAppRunCnt"])
        {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{

				NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
				
				@try
				{
					NSString *runCnt = [defaults stringForKey:@"RUN_CNT"];
				
					NSString *js = [NSString stringWithFormat: @"resAppRunCnt('%@')", runCnt];
					[self.webView evaluateJavaScript:js completionHandler:nil];
				}
				@catch (NSException *exception)
				{
					NSLog(@"Caught %@%@", exception.name, exception.reason);
				}
			}];
		}
		else if([function isEqualToString:@"reqDeviceIP"])
        {
			NSMutableDictionary* ipList = [NSMutableDictionary dictionary];

			NSString *address = nil;
			struct ifaddrs *interfaces = NULL;
			struct ifaddrs *temp_addr = NULL;
			int success = 0;
			// retrieve the current interfaces - returns 0 on success
			success = getifaddrs(&interfaces);
			if (success == 0) {
				// Loop through linked list of interfaces
				temp_addr = interfaces;
				while(temp_addr != NULL) {
					
					if(temp_addr->ifa_addr->sa_family == AF_INET) {
						// Check if interface is en0 which is the wifi connection on the iPhone
                        //if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
								// Get NSString from C String
							address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
							NSLog(@"%@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
							NSLog(@"%@", address);
							[ipList setObject:address forKey:[NSString stringWithUTF8String:temp_addr->ifa_name]];

						
						//}
					}
					temp_addr = temp_addr->ifa_next;
				}
			}
			freeifaddrs(interfaces);
			
			if(ipList[@"en0"] != nil)
			{
				address = ipList[@"en0"];
			}
			else if(ipList[@"pdp_ip0"] != nil)
			{
				address = ipList[@"pdp_ip0"];
			}
			
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				
				NSString *js = [NSString stringWithFormat: @"resDeviceIP('%@')", address];
				[self.webView evaluateJavaScript:js completionHandler:nil];
			}];
//            NSLog(@"%@", address);
        }
        else if([function isEqualToString:@"reqCall"])
        {
            //2018.09.06 hmwoo 전달받은 전화번호로 전화 걸기
            [[TelUtil new] openTelScreen:map[@"telNumber"]];
        }
        else if([function isEqualToString:@"reqMapPermission"])
        {
            NSLog(@"위치 권한 설정");
			//2019.05.08 hmwoo IOS 위치 관련 기능 추가 @START
            
            // 2022-01-27 위치권한 삭제
//			[self locationPermissionCheck];
			
            //2019.05.08 hmwoo IOS 위치 관련 기능 추가 @END
        }
        else if([function isEqualToString:@"reqLocation"])
        {
            NSLog(@"위치 경도 요청 수신");
			
            // 2022-01-27 위치권한 삭제
//			[self locationPermissionCheck];
//
//			CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//
//			if(locationManager != nil && (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse))
//			{
//				[locationManager requestLocation];
//
//				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
//
//					self.latitude = [[NSNumber numberWithDouble:[locationManager location].coordinate.latitude] stringValue];
//					self.longitude = [[NSNumber numberWithDouble:[locationManager location].coordinate.longitude] stringValue];
//
//					NSString *js = [NSString stringWithFormat: @"resLocation('%@','%@')", self.latitude, self.longitude];
//					[self.webView evaluateJavaScript:js completionHandler:nil];
//				}];
//			}
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                NSString *js = [NSString stringWithFormat: @"resLocation('%@','%@')", (int)0, (int)0];
                [self.webView evaluateJavaScript:js completionHandler:nil];
            }];
        }
        else if([function isEqualToString:@"reqDasPage"])
        {
            UIView *statusBar;

            if (@available(iOS 13.0, *))
            {
                statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
            }
            else
            {
                statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            }
            
			NSString *SERVICE_LGTTYPE = @"Y";
			NSString *SERVICE_LOGIN_TYPE = @"0000"; // 2020-10-21 수정 기존 1010
			NSString *VTID_USE_YN = @"Y";
			
			[AccountUtil setDasLibraryConfig:@"OT_SNS_YN" value:@"Y"];
			[AccountUtil setDasLibraryConfig:@"LGT_SNS_YN" value:@"Y"];
			[AccountUtil setDasLibraryConfig:@"IPIN_YN" value:@"Y"];
			[AccountUtil setDasLibraryConfig:@"KMC_YN" value:@"Y"];
			[AccountUtil setDasLibraryConfig:@"SIGNUP_YN" value:@"Y"];
			
			SERVICE_CD = AccountUtil.SERVICE_CD;
			
			NSString *page = map[@"page"];
			
            if([page isEqualToString:@"lgidLoginIdPwd"]) {
                
//                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
//                {
//                    //        statusBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];//set whatever color you like
//                    statusBar.backgroundColor = [UIColor whiteColor];
//                }
//
//                if (@available(iOS 13.0, *))
//                {
//                    [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
//                }
                
                @try
                {
                    [AccountUtil setDasLibraryConfig:@"OT_SNS_YN" value:@"N"];
                    [AccountUtil setDasLibraryConfig:@"LGT_SNS_YN" value:@"N"];
                    
                    NSMutableDictionary *intent = [NSMutableDictionary dictionary];
                    [intent setObject:FUNCTION_LGID_IDPW_LOGIN forKey:@"FUNCTION_NAME"];
                    [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
                    [intent setObject:@"" forKey:@"USER_ID"];
                    [intent setObject:SERVICE_LGTTYPE forKey:@"LGT_TYPE"];
                    [intent setObject:SERVICE_LOGIN_TYPE forKey:@"SERVICE_LOGIN_TYPE"];
                    
                    [Activity startActivityForResult:self class:[HybridWebView new] intent:intent requestCode:1];
                }
                @catch (NSException *exception)
                {
                    NSLog(@"Caught %@%@", exception.name, exception.reason);
                }
                
            } else if([page isEqualToString:@"idPwLogin"])
        	{
                
//                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
//                {
//                    //        statusBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];//set whatever color you like
//                    statusBar.backgroundColor = [UIColor whiteColor];
//                }
//
//                if (@available(iOS 13.0, *))
//                {
//                    [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
//                }
                
        		@try
				{
					[AccountUtil setDasLibraryConfig:@"OT_SNS_YN" value:@"N"];
					[AccountUtil setDasLibraryConfig:@"LGT_SNS_YN" value:@"N"];
					
					NSMutableDictionary *intent = [NSMutableDictionary dictionary];
					[intent setObject:FUNCTION_IDPW_LOGIN forKey:@"FUNCTION_NAME"];
					[intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
					[intent setObject:@"" forKey:@"USER_ID"];
					[intent setObject:SERVICE_LGTTYPE forKey:@"LGT_TYPE"];
					[intent setObject:SERVICE_LOGIN_TYPE forKey:@"SERVICE_LOGIN_TYPE"];
					
					[Activity startActivityForResult:self class:[HybridWebView new] intent:intent requestCode:1];
				}
				@catch (NSException *exception)
				{
					NSLog(@"Caught %@%@", exception.name, exception.reason);
				}
			}
			else if([page isEqualToString:@"ctnLogin"])
        	{
//                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
//                {
//                    //        statusBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];//set whatever color you like
//                    statusBar.backgroundColor = [UIColor whiteColor];
//                }
//                
//                if (@available(iOS 13.0, *))
//                {
//                    [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
//                }
                
				NSMutableDictionary *intent = [NSMutableDictionary dictionary];
				[intent setObject:FUNCTION_CTN_LOGIN_REQUEST forKey:@"FUNCTION_NAME"];
				[intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
				[intent setObject:SERVICE_LOGIN_TYPE forKey:@"SERVICE_LOGIN_TYPE"];
				[intent setObject:@"111" forKey:@"SERVICE_ITEM_CODE"];
				[intent setObject:VTID_USE_YN forKey:@"VTID_USE_YN"];
				
				[Activity startActivityForResult:self class:[HybridWebView new] intent:intent requestCode:1];
			}
            else if([page isEqualToString:@"autoLogin"])
            {
                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
                {
                    //        statusBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];//set whatever color you like
                    statusBar.backgroundColor = [UIColor blackColor];
                }
                
                if (@available(iOS 13.0, *))
                {
                    [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
                }
                
                NSDictionary *dictionary = [AccountUtil getAutoAccount];
                if(dictionary != nil && dictionary[@"USER_ID"] != [NSNull null])
                {
                    [[[AutoAccountLogin alloc] init] executeParameters:[NSArray arrayWithObject:self]];
                }
                else
                {
                    NSString *js = [NSString stringWithFormat: @"resLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
                                                                                         @"", @"", @"", @"", @"", @"", @"", @"",
                                                                                         @"", @"", @"", @""]];
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^
                     {
                         [self.webView evaluateJavaScript:js completionHandler:nil];
                     }];
                }
            }
            
        }
        else if([function isEqualToString:@"reqWebPage"])
        {
			NSMutableURLRequest *request;
			NSString *url = map[@"url"];
			NSString *param = map[@"param"];
			NSString *method = map[@"method"];
			NSString *useBar = (map[@"useBar"] != nil && [map[@"useBar"] isEqualToString:@"true"])?@"TRUE":@"FALSE";
			NSString *useSwipe = (map[@"useSwipe"] != nil && [map[@"useSwipe"] isEqualToString:@"true"])?@"TRUE":@"FALSE";
			
			if(url == nil || param == nil || method == nil)
			{
				return;
			}
			/*
//			url = @"http://www.hanjin.co.kr/Delivery_html/inquiry/result_waybill.jsp";
//			param = @"wbl_num=505944112704";
//			method = @"POST";
	
			//2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
			//NSString *body = [NSString stringWithFormat: @"arg1=%@&arg2=%@", @"val1",@"val2"];
	
			request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, @"?", param]]];
	
			[request setHTTPMethod:method];
	
			//2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
			//[request setHTTPBody:[body dataUsingEncoding: NSUTF8StringEncoding];
			
			NSMutableDictionary *tmpMap = [NSMutableDictionary dictionary];
			[tmpMap setObject:url forKey:@"url"];
			[tmpMap setObject:method==nil?[NSNull null]:method forKey:@"method"];
			[tmpMap setObject:param forKey:@"param"];
			[urlHistory addObject:tmpMap];
			//2018.09.07 hmwoo 페이지 이동 Url 취득을 위해 URL SET @End
			
			rootUrl = webView.URL.absoluteString;
			
			webView.allowsBackForwardNavigationGestures = YES;
			
			//2018.09.06 hmwoo 지정된 웹페이지 로드 @START
			[webView loadRequest:request];
			//2018.09.06 hmwoo 지정된 웹페이지 로드 @END
			*/
			
			NSMutableDictionary *intent = [NSMutableDictionary dictionary];
			[intent setObject:url forKey:@"URL"];
			[intent setObject:param forKey:@"PARAM"];
			[intent setObject:method forKey:@"METHOD"];
			[intent setObject:useBar forKey:@"USE_BAR"];
			[intent setObject:useSwipe forKey:@"USE_SWIPE"];
            
			[Activity startActivityForResult:self class:[SubWebView new] intent:intent requestCode:1];
			
        }
        else if([function isEqualToString:@"reqPgWebPage"])
        {
            
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:map[@"url"]]];
//            [self.webView loadRequest:request];
            
            
            NSString *url = map[@"url"];
            NSString *param = map[@"param"];
            NSString *method = map[@"method"];
            NSString *useBar = (map[@"useBar"] != nil && [map[@"useBar"] isEqualToString:@"true"])?@"TRUE":@"FALSE";
            NSString *useSwipe = (map[@"useSwipe"] != nil && [map[@"useSwipe"] isEqualToString:@"true"])?@"TRUE":@"FALSE";

            NSLog(@"%@%@%@%@%@", url, param, method, useBar, useSwipe);
            
            if(url == nil || param == nil || method == nil)
            {
                return;
            }

            NSMutableDictionary *intent = [NSMutableDictionary dictionary];
            [intent setObject:url forKey:@"URL"];
            [intent setObject:param forKey:@"PARAM"];
            [intent setObject:method forKey:@"METHOD"];
            [intent setObject:useBar forKey:@"USE_BAR"];
            [intent setObject:useSwipe forKey:@"USE_SWIPE"];

            
            PgWebView *pgWebView = [PgWebView new];
            
            pgWebView.wkProcessPool = wkProcessPool;
            pgWebView.ldcWebView = webView;
            
            [Activity startActivityForResult:self class:pgWebView intent:intent requestCode:2];
            
            
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//
//            NSURLSession *session = [NSURLSession sharedSession];
//            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
//                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//            {
//                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//                NSDictionary *fields = [HTTPResponse allHeaderFields];
//                NSString *cookie = [fields valueForKey:@"Cookie"];
//                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//                [request addValue:cookie forHTTPHeaderField:@"Cookie"];
//
//                PgWebView *pgWebView = [PgWebView new];
//                pgWebView.request = request;
//
//                [Activity startActivityForResult:self class:pgWebView intent:intent requestCode:1];
//            }];
//            [dataTask resume];
            
//            [NSURLConnection connectionWithRequest:request delegate:^(NSURLConnection *connection, NSURLResponse *response)
//            {
//                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//                NSDictionary *fields = [HTTPResponse allHeaderFields];
//                NSString *cookie = [fields valueForKey:@"Set-Cookie"];
//                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//                [request addValue:cookie forHTTPHeaderField:@"Cookie"];
//                
//                PgWebView *pgWebView = [PgWebView new];
//                pgWebView.request = request;
//                
//                [Activity startActivityForResult:self class:pgWebView intent:intent requestCode:1];
//            }];
        }
        else if([function isEqualToString:@"reqHttpTest"])
        {
			NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
			
			NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];

			NSURL *url = [NSURL URLWithString:@"https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"];

			NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
			
			[task resume];
			

			/*
			NSMutableArray *items = [NSMutableArray array];

			NSURL *url = [NSURL URLWithString:@"https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"];
			//NSURL *url = [NSURL fileURLWithPath:@"https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"];


			[items addObject:url];
	
			UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
			
    		[self presentViewController:activityViewController animated:YES completion:^{}];
			*/
        	/*
        	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://106.103.189.21:8081/recognize_estimate"]];

			NSString *body = [NSString stringWithFormat:@"{\"image\":%@}", @""];

			//create the Method "GET" or "POST"
			[urlRequest setHTTPMethod:@"POST"];

			//Convert the String to Data
			NSData *convertBody = [body dataUsingEncoding:NSUTF8StringEncoding];

			//Apply the data to the body
			[urlRequest setHTTPBody:convertBody];

			NSURLSession *session = [NSURLSession sharedSession];
			NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
			{
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				if(httpResponse.statusCode == 200)
				{
					NSError *parseError = nil;
					NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
					NSLog(@"The response is - %@",responseDictionary);
					NSInteger status = [[responseDictionary objectForKey:@"status"] integerValue];
			 
					NSLog(@"status = %zd", status);
				}
				else
				{
					NSLog(@"Error");
				}
			}];
			[dataTask resume];
			*/
        }
        else if([function isEqualToString:@"reqExit"])
        {
            exit(0);
        }
        else if([function isEqualToString:@"reqInitReload"])
        {
            WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
            [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                             completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                                 for (WKWebsiteDataRecord *record  in records)
                                 {
                                     //                         if ( [record.displayName containsString:@"facebook"])
                                     //                         {
                                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                               forDataRecords:@[record]
                                                                            completionHandler:^{
                                                                                NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                            }];
                                     //                         }
                                 }
                             }];
            
            NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
            NSError *errors;
            [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
            
            [self logoutSuccess];
            
            [self.webView reload];
            /*
            WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
            
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:@"dummy" forKey:NSHTTPCookieName];
            [cookieProperties setObject:@"dummy" forKey:NSHTTPCookieValue];
            [cookieProperties setObject:@"www.example.com" forKey:NSHTTPCookieDomain];
            [cookieProperties setObject:@"www.example.com" forKey:NSHTTPCookieOriginURL];
            [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
            [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            
            [cookieStore setCookie:cookie completionHandler:^{
                
                [cookieStore getAllCookies:^(NSArray* cookies) {
                    
                    NSLog(@"==========================");
                    for(NSHTTPCookie *cookie in cookies)
                    {
                        
                        NSLog(@"%@ : %@", cookie.name, cookie.value);
                        [cookieStore deleteCookie:cookie completionHandler:nil];
                    }
                    NSLog(@"==========================");
                    
                    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
                    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                                         for (WKWebsiteDataRecord *record  in records)
                                         {
                                             //                         if ( [record.displayName containsString:@"facebook"])
                                             //                         {
                                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                                       forDataRecords:@[record]
                                                                                    completionHandler:^{
                                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                                    }];
                                             //                         }
                                         }
                                     }];
                    
                    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
                    NSError *errors;
                    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
                    
                    [self logoutSuccess];
                    
                    [self.webView reload];
                }];
            }];
             */
        }
        else if([function isEqualToString:@"reqHashConfirm"])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 NSString *confirm = @"";
                 
                 NSString *searchPath = @"/private/var/containers/Bundle/Application/";
                 
                 NSError *error = nil;
                 
                 NSFileManager *filemanager;
                 
                 filemanager = [NSFileManager defaultManager];
                 
                 NSArray *items = [filemanager contentsOfDirectoryAtPath:searchPath error:&error];
                 
                 NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
                 
                 NSString *target = nil;
                 
                 bool endSearch = false;
                 
                 if(error == nil)
                 {
                     for(int i = 0; i < items.count; i++)
                     {
                         NSArray *tmpitems = [filemanager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@", searchPath, [items objectAtIndex:i]] error:&error];
                         
                         for(int j = 0; j < tmpitems.count; j++)
                         {
                             if([[tmpitems objectAtIndex:j] isEqualToString:[NSString stringWithFormat:@"%@%@", appName, @".app"]])
                             {
                                 target = [NSString stringWithFormat:@"%@%@/%@", searchPath, [items objectAtIndex:i], [tmpitems objectAtIndex:j]];
                                 endSearch = true;
                                 break;
                             }
                         }
                         if(endSearch) break;
                     }
                     
                     if(target != nil)
                     {
                         NSMutableData *hashData = [NSMutableData data];
                         
                         NSString *path;
                         
                         NSDirectoryEnumerator *dirEnum = [filemanager enumeratorAtPath:target];
                         
                         while ((path = [dirEnum nextObject]) != nil)
                         {
                             if([path isEqualToString:@".DS_Store"] || [path containsString:@"SC_Info"])
                             {
                                 continue;
                             }
                             
                             NSData *data = [filemanager contentsAtPath:[NSString stringWithFormat:@"%@/%@", target, path]];
                             
                             [hashData appendData:data];
                         }
                         
                         confirm = [TelUtil AES256Encode:[Util createSHA512:[Util createBASE64:hashData]] key:map[@"check"]];
                     }
                 }
                 
                 NSString *webCheck;
                 
                 if(error == nil)
                 {
                     webCheck = confirm;
                 }
                 else
                 {
                     webCheck =
                     [TelUtil AES256Encode:[
                                            Util createSHA512:
                                            [NSString stringWithFormat:@"%@", error == nil?@"":error.localizedDescription]
                                            ] key:map[@"check"]
                     ];
                 }
                 
                 NSString *js = [NSString stringWithFormat: @"resContinueCheck('%@')", webCheck];
                 
                 [self.webView evaluateJavaScript:js completionHandler:nil];
             }];
        }
        /*
		else if([function isEqualToString:@"turnPage"])
        {
            //2018.09.06 hmwoo 더미 페이지 넘기기
            [webView loadRequest:[[NSMutableURLRequest alloc]initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:map[@"page"] ofType:@"html" inDirectory:@""]]]];
        }
        else if([function isEqualToString:@"test"])
        {
            //---------Dummy Web Page Call----------------
            NSString *path = [[NSBundle mainBundle] pathForResource:@"JSTest" ofType:@"html" inDirectory:@""];
            NSURL *url = [NSURL fileURLWithPath:path];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            //---------Dummy Web Page Call----------------
		 
            [webView loadRequest:request];
        }
        */
        else if([function isEqualToString:@"configFido"])
        {
            //            NSDictionary *tmpMap = [AccountUtil getAutoAccount];
            //            if(tmpMap != nil && tmpMap[@"USER_ID"] != [NSNull null] && tmpMap[@"ONEID_KEY"] != [NSNull null])
            //            {
            ////                logoutAuto = [AccountUtil deleteAutoAccount];
            //            }
            NSDictionary *map = [AccountUtil getNormalAccount];
            
            NSString *USER_ID = map[@"USER_ID"];
            if(USER_ID == nil)
            {
                NSString *js = [NSString stringWithFormat: @"onResultConfigFido(false)"];
                [self.webView evaluateJavaScript:js completionHandler:nil];
                return;
            }
            NSString *ONEID_KEY = map[@"ONEID_KEY"];
            if(ONEID_KEY == nil)
            {
                NSString *js = [NSString stringWithFormat: @"onResultConfigFido(false)"];
                [self.webView evaluateJavaScript:js completionHandler:nil];
                return;
            }
            
            
            NSMutableDictionary *intent = [NSMutableDictionary dictionary];
            [intent setObject:FUNCTION_FIDO_CONFIG forKey:@"FUNCTION_NAME"];
            [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
            [intent setObject:USER_ID forKey:@"USER_ID"];
            [intent setObject:ONEID_KEY forKey:@"ONEID_KEY"];
            [intent setObject:@"0000" forKey:@"SERVICE_LOGIN_TYPE"];
            
            [Activity startActivityForResult:self class:[HybridWebView new] intent:intent requestCode:1];
            
            
        } else if ([function isEqualToString:@"checkCameraPermission"]) {
              
            if ([self cameraPermissionCheckOnly] == false) {
      
            } else {

                NSString *js = [NSString stringWithFormat: @"cameraPermissionResult(true)"];
                [self.webView evaluateJavaScript:js completionHandler:nil];

            }
            
            
            
        } else if ([function isEqualToString:@"checkPhotoElbumPermission"]) {
            
                    
            if ([self photoElbumPermissionCheckOnly] == false) {
                
            } else {
                NSString *js = [NSString stringWithFormat: @"photoElbumPermissionResult(true)"];
                [self.webView evaluateJavaScript:js completionHandler:nil];
            }
        
            
        } else {
            NSLog(@"%@%@", @"No Find Method : ", function);
        }
    }
}

-(void)logoutSuccess
{
    NSString *loginID = [AccountUtil getEasyAccount];
    Boolean logoutAuto = false;
    Boolean logoutEasy = false;
    Boolean logoutNormal = false;
    
    if(loginID != nil) {
        [AccountUtil deleteEasyAccount];
    }
    NSDictionary *tmpMap = [AccountUtil getAutoAccount];
    if(tmpMap != nil && tmpMap[@"USER_ID"] != [NSNull null])
    {
        logoutAuto = [AccountUtil deleteAutoAccount];
    }
    NSString *tmpUSER_ID = [AccountUtil getNormalAccount][@"USER_ID"];
    if(tmpUSER_ID != nil)
    {
        logoutNormal = [AccountUtil deleteNormalAccount];
    }
}

/**
 * 자바스크립트에서 Alert 창을 호출할경우 호출내용을 가로채서 대신 처리하는 메소드
 *
 * @author  hmwoo
 * @version 1.0
 * @param   message  Javascript Alert 메시지
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

/**
 * 네비게이션이 완료되었을 경우 호출됨
 *
 * @author  hmwoo
 * @version 1.0
 * @param   navigation  완료된 탐색개체
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation");
    
    /*
    WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
    
    [cookieStore getAllCookies:^(NSArray* cookies) {


NSLog(@"==========================");
        for(NSHTTPCookie *cookie in cookies)
        {
            
            NSLog(@"%@ : %@", cookie.name, cookie.value);
//            [cookieStore deleteCookie:cookie completionHandler:nil];
        }
        NSLog(@"==========================");

    }];
    */
	
// 	WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
//
//	[cookieStore getAllCookies:^(NSArray* cookies) {
//
//		for(NSHTTPCookie *cookie in cookies)
//		{
//			NSLog(@"%@%@", cookie.name, cookie.value);
//		}
//
//	}];
	
//		if (cookies.count == 0) {
//			return ;
//		}

//		NSUInteger index = [cookies indexOfObjectPassingTest:^BOOL(NSHTTPCookie *cookie, NSUInteger idx, BOOL * _Nonnull stop) {
//			return [cookie.name isEqualToString:[WKCookieSyncManager sharedWKCookieSyncManager].domain];
//		}];
//
//		if (index == NSNotFound) {
//			return;
//		}
//
//		NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//		NSString *host = response.URL.host;
//		if (![[WKCookieSyncManager sharedWKCookieSyncManager] loginCookieHasBeenSynced]) {
//			[[WKCookieSyncManager sharedWKCookieSyncManager] setCookies:cookies forDomain:host];
//		}
	

	
    if(webView.canGoBack)
	{
		self.navigationItem.leftBarButtonItem.title = @"←";
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.leftBarButtonItem.title = @"";
		self.navigationItem.leftBarButtonItem.enabled = NO;
	}
	if(webView.canGoForward)
	{
		self.navigationItem.rightBarButtonItem.title = @"→";
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.title = @"";
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self stopIndicator];
//    }];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
//        [self hashCheck];
        
        if(self.splashView != nil)
        {
            [self.splashView removeFromSuperview];
            self.splashView = nil;
        }
        
        // 2024.01.05 권한 허용 최초 실행시 진행하지 안도록. 권한이 있는 기능 사용 할때 권한 허용 요청.
        
        // 데이터 로드
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL myValue = [defaults objectForKey:@"ALLOW_PERMISSION"];
        
        if (myValue != true) {
            [self permissionCheck];
        }
        
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
	NSLog(@"%@", @"didFailNavigation");
    [Util showToastMsg:[NSString stringWithFormat:@"%@", @"데이터 접속이 차단되어 있습니다. Wifi를 연결하거나 데이터 접속을 허용상태로 변경 한 후 이용해주시기 바랍니다."] view:self];
}


/**
 * WKWebView의 웹 컨텐트 로드가 실패될 경우 호출되는 핸들러
 *
 * @author  hmwoo
 * @version 1.0
 * @param   error  웹페이지 로드 실패 정보
 * @param   navigation  ...
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@", @"ProvisionalNavigation");
    NSLog(@"%@", [error description]);
    
    if([error code] == -1009)
    {
        [Util showToastMsg:[NSString stringWithFormat:@"%@", @"데이터 접속이 차단되어 있습니다. Wifi를 연결하거나 데이터 접속을 허용상태로 변경 한 후 이용해주시기 바랍니다."] view:self];
    }
    else if([error code] == -1200)
    {
        [Util showToastMsg:[NSString stringWithFormat:@"%@", @"유효하지 않은 인증서 접속입니다."] view:self];
    }
//    [webView loadRequest:[[NSMutableURLRequest alloc]initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ErrorPage" ofType:@"html" inDirectory:@""]]]];
}



//// 2021.03.22 추가 https 페이지에서 iframe으로 http 호출 안되서 추가
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//
//   if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//
//       NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
//
//       completionHandler(NSURLSessionAuthChallengeUseCredential,card);
//
//   }
//}






/**
 * 앱이 메모리 경고를 받을경우 호출
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 뷰 컨트롤러의 뷰가 윈도우의 뷰 계층에서 제거 되려고 할 때 호출.
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void)viewWillDisappear:(BOOL)animated{
	
    //[(MainActivity *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 1] setResultCode:2];
	
    [super viewWillDisappear:animated];
}

/**
 * 카메라 기능 혹은 포토엘범을 통해 취득한 이미지를 받는 핸들 메소드.
 *
 * @author  hmwoo
 * @version 1.0
 * @param   info  핸들 받은 사진이미지 정보
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
		UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
		//UIImage* autoImage;
		//autoImage = [SelvyImageProcessing processImageAuto:chosenImage]; // ImageCorrection - Auto
		NSData *flatImage = UIImageJPEGRepresentation(chosenImage, 0.1f);
		NSString *base64Str = [flatImage base64EncodedStringWithOptions:0];
		
		NSLog(@"%@", base64Str);
		
		//NSString *js = [NSString stringWithFormat: @"resBase64ImgData('%@')", base64Str];
        
        NSString *js = [NSString stringWithFormat: @"resOCRServerResData('%@','%@','%@')", @"1", @"", base64Str];
		
        [self.webView evaluateJavaScript:js completionHandler:nil];
		
		[picker dismissViewControllerAnimated:YES completion:NULL];
	}];
}

/**
 * 카메라 기능 혹은 포토엘범에서 취소버튼을 눌렀을 경우의 핸들 메소드
 *
 * @author  hmwoo
 * @version 1.0
 * @param   picker  ...
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissViewControllerAnimated:YES completion:NULL];
	
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
	
		NSLog(@"%@", @"picker");
		NSLog(@"%@", info);
		[self dismissViewControllerAnimated:YES completion:nil];
		
		//NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
		
		for(NSDictionary *dict in info)
		{
			UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
			NSData *flatImage = UIImageJPEGRepresentation(image, 0.1f);
			NSString *base64Str = [flatImage base64EncodedStringWithOptions:0];
			//[images addObject:base64Str];
			//[images addObject:image];
			NSString *js = [NSString stringWithFormat: @"resBase64ImgData('%@')", base64Str];
			[self.webView evaluateJavaScript:js completionHandler:nil];
		}
		
		//NSLog(@"%lu", [images count]);
	}];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
	
    NSLog(@"%@", @"cancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidAppear:(BOOL)animated
{

    NSLog(@"%@%d", @"resultCode : ", resultCode);
    NSLog(@"%@%d", @"requestCode : ", requestCode);
    
    // navigation bar hide
    if(self.navigationController.navigationBarHidden == false)
    {
        // Hidden 할 경우 satus bar 의 text color 는 흰색으로 바뀌기 때문에 setNeedsStatusBar로
        // preferredStatusBarStyle 메소드 사용을 하용해준후 텍스트색을 바꾸어준다.
        [self.navigationController setNavigationBarHidden:YES animated:YES];;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    if(resultCode == 0 && requestCode != 2)
    {
        return;
    }
    if(data != nil && requestCode == 1)
    {
        UIView *statusBar;

        if (@available(iOS 13.0, *))
        {
            statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        }
        else
        {
            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        }
        
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
        {
            //        statusBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];//set whatever color you like
            statusBar.backgroundColor = [UIColor blackColor];
        }
        
        if (@available(iOS 13.0, *))
        {
            [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
        }
        
        if([data[@"RESULT"] isEqualToString:RC_LOGIN_RESPONSE])
        {
			/*
            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
                                @"로그인 응답 RT:", data[@"RT"], @",RT_MSG:", data[@"RT_MSG"], @",SSO_KEY:", data[@"SSO_KEY"], @",LOGIN_TYPE:", data[@"LOGIN_TYPE"], @",USER_ID:", data[@"USER_ID"],
                                @",ONEID_KEY:", data[@"ONEID_KEY"], @",SERVICE_KEY:", data[@"SERVICE_KEY"], @",NAME:", data[@"NAME"], @",LGT_TYPE:", data[@"LGT_TYPE"],
                                @",PW_UPDATE_DT:", data[@"PW_UPDATE_DT"], @",TOS_SERVICE_CD:", data[@"TOS_SERVICE_CD"], @",ID_TYPE:", data[@"ID_TYPE"] == nil ? @"" : data[@"ID_TYPE"]] view:self];
			*/
            NSString *AUTH_TYPE = data[@"AUTH_TYPE"];
            NSString *LGID_EMAIL = data[@"LGID_EMAIL"];
            NSString *LGID_CTN = data[@"LGID_CTN"];
            
            
            NSString *js;
            
            if ([AUTH_TYPE isEqualToString:@"U"]) {
                js = [NSString stringWithFormat: @"resLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
                    data[@"RT"], data[@"RT_MSG"], data[@"SSO_KEY"], data[@"LOGIN_TYPE"], data[@"USER_ID"], data[@"ONEID_KEY"], data[@"SERVICE_KEY"], data[@"NAME"],
                    data[@"LGT_TYPE"], data[@"PW_UPDATE_DT"], data[@"TOS_SERVICE_CD"], data[@"ID_TYPE"]]];
            } else {
                js = [NSString stringWithFormat: @"resMyLGIDLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
                    data[@"RT"], data[@"RT_MSG"], data[@"SSO_KEY"], data[@"LOGIN_TYPE"], data[@"USER_ID"], data[@"ONEID_KEY"], data[@"SERVICE_KEY"], data[@"NAME"],
                    data[@"LGT_TYPE"], data[@"PW_UPDATE_DT"], data[@"TOS_SERVICE_CD"], data[@"ID_TYPE"], AUTH_TYPE, LGID_EMAIL, LGID_CTN]];
            }
            
			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			{
				[self.webView evaluateJavaScript:js completionHandler:nil];
			}];
            
//            NSLog(@"%@", [NSString stringWithFormat:@"%@%@", @"ID/PW로그인 응답 : ", js]);
            
            if([data[@"RT"] isEqualToString:RT_NOT_ONEID])
            {
                return;
            }
            if([data[@"LOGIN_TYPE"] isEqualToString:@"2"])
            {
                [AccountUtil setEasyAccount:data[@"USER_ID"]];
                [AccountUtil setAutoAccount:data[@"USER_ID"] SSO_KEY:data[@"SSO_KEY"]];
            }
            else if([data[@"LOGIN_TYPE"] isEqualToString:@"1"])
            {
                [AccountUtil deleteEasyAccount];
                [AccountUtil setAutoAccount:data[@"USER_ID"] SSO_KEY:data[@"SSO_KEY"]];
            }
            else if([data[@"LOGIN_TYPE"] isEqualToString:@"3"])
            {
                [AccountUtil deleteEasyAccount];
                [AccountUtil setAutoAccount:data[@"USER_ID"] SSO_KEY:data[@"SSO_KEY"]];
                [AccountUtil setNormalAccount:data[@"USER_ID"] ONEID_KEY:data[@"ONEID_KEY"]];
            }
            [AccountUtil setNormalAccount:data[@"USER_ID"] ONEID_KEY:data[@"ONEID_KEY"]];
        }
        else if([data[@"RESULT"] isEqualToString:RC_CONVERSION_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpCLOSE_ST = data[@"CLOSE_ST"] == nil?@"":data[@"CLOSE_ST"];
			
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"ONEID_KEY = |", tmpONEID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"CLOSE_ST = |", tmpCLOSE_ST , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", @"전환가입 응답 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",ONEID_KEY:", tmpONEID_KEY, @",USER_ID:", tmpUSER_ID, @",CLOSE_ST:", tmpCLOSE_ST] view:self];
			
        }
        else if([data[@"RESULT"] isEqualToString:RC_CALL_OLD_LOGIN])
        {
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@", @"기존ID로 로그인 요청SERVICE_USER_ID:", data[@"SERVICE_USER_ID"], @", SERVICE_USER_PW:", data[@"SERVICE_USER_PW"], @", LOGIN_TYPE:", data[@"LOGIN_TYPE"]] view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_USER_SIGNUP])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpCLOSE_ST = data[@"CLOSE_ST"] == nil?@"":data[@"CLOSE_ST"];
			
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"회원 가입 요청 결과", @"CLOSE_ST = |", tmpCLOSE_ST , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", @"회원 가입 요청 결과 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",USER_ID:", tmpUSER_ID, @",CLOSE_ST:", tmpCLOSE_ST] view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SERVICE_ID_SEARCH])
        {
//            [Util showToastMsg:@"기존 ID 찾기" view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SERVICE_PASSWORD_RESET])
        {
//            [Util showToastMsg:@"기존 PW 찾기" view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_EASY_LOGIN])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpLOGIN_TYPE = data[@"LOGIN_TYPE"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpSSO_KEY = data[@"SSO_KEY"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpSERVICE_KEY = data[@"SERVICE_KEY"];
            NSString *tmpNAME = data[@"NAME"];
            NSString *tmpLGT_TYPE = data[@"LGT_TYPE"];
            NSString *tmpPW_UPDATE_DT = data[@"PW_UPDATE_DT"];
			
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"SSO_KEY = |", tmpSSO_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"LOGIN_TYPE = |", tmpLOGIN_TYPE , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"ONEID_KEY = |", tmpONEID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"SERVICE_KEY = |", tmpSERVICE_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"NAME = |", tmpNAME , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"LGT_TYPE = |", tmpLGT_TYPE , @"|");
//            NSLog(@"%@%@%@%@", @"간편로그인 결과", @"PW_UPDATE_DT = |", tmpPW_UPDATE_DT , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"간편로그인 결과 RT:",
//                                tmpRT, @",RT_MSG:", tmpRT_MSG,@",SSO_KEY:", tmpSSO_KEY, @",LOGIN_TYPE:", tmpLOGIN_TYPE, @",USER_ID:", tmpUSER_ID,
//                                @",ONEID_KEY:", tmpONEID_KEY, @",SERVICE_KEY:", tmpSERVICE_KEY,  @",NAME:", tmpNAME,  @",LGT_TYPE:", tmpLGT_TYPE,  @",PW_UPDATE_DT:", tmpPW_UPDATE_DT] view:self];
			
            if([RT_SUCCESS isEqualToString:tmpRT])
            {
                [AccountUtil setNormalAccount:tmpUSER_ID ONEID_KEY:tmpONEID_KEY];
            }
            else if([RT_NOT_TOS isEqualToString:tmpRT])
            {
				
            }
        }
        else if([data[@"RESULT"] isEqualToString:RC_LOGOUT])
        {
//            [Util showToastMsg:@"로그아웃" view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_DELETE_ACCOUNT])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
			
//            NSLog(@"%@%@%@%@", @"계정및동기화 삭제 결과", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"계정및동기화 삭제 결과", @"RT_MSG = |", tmpRT_MSG , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@", @"계정및동기화 삭제 결과 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG] view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_COUNT_ACCOUNT])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpCOUNT = data[@"COUNT"];
			
//            NSLog(@"%@%@%@%@", @"계정및동기화 갯수 결과", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"계정및동기화 갯수 결과", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"계정및동기화 갯수 결과", @"COUNT = |", tmpCOUNT , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@", @"계정및동기화 갯수 결과 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",COUNT:", tmpCOUNT] view:self];
			
            if([tmpCOUNT intValue] > 0)
            {
                NSMutableDictionary *intent = [NSMutableDictionary dictionary];
                [intent setObject:FUNCTION_DEFAULT_LOGIN forKey:@"FUNCTION_NAME"];
                [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
                [intent setObject:@"1100" forKey:@"SERVICE_LOGIN_TYPE"];
				
                [Activity startActivityForResult:self class:[HybridWebView new] intent:intent requestCode:1];
            }
        }
        else if([data[@"RESULT"] isEqualToString:RC_CLOSE])
        {
            NSString *functionName = data[@"FUNCTION_NAME"];
            if([functionName isEqualToString:@"FIDO_CONFIG"]) {
                NSLog(@"FIDO_CONFIG");
            }
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@",
//                                @"웹뷰 닫힘 결과 (CLOSE_ST:", data[@"CLOSE_ST"] == nil ? @"" : data[@"CLOSE_ST"], @")"] view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SNS_LOGIN_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpSNSID_KEY = data[@"SNSID_KEY"];
            NSString *tmpSNS_CD = data[@"SNS_CD"];
            NSString *tmpSNS_USER_ID = data[@"SNS_USER_ID"];
            NSString *tmpNAME = data[@"NAME"];
            NSString *tmpEMAIL = data[@"EMAIL"];
            NSString *tmpTOS_SERVICE_CD = data[@"TOS_SERVICE_CD"];
			
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"SNSID_KEY = |", tmpSNSID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"SNS_CD = |", tmpSNS_CD , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"SNS_USER_ID = |", tmpSNS_USER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"NAME = |", tmpNAME , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"EMAIL = |", tmpEMAIL , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그인 응답", @"TOS_SERVICE_CD = |", tmpTOS_SERVICE_CD , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
//                                @"SNS 로그인 응답 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",SNSID_KEY:", tmpSNSID_KEY,
//                                @",SNS_CD:", tmpSNS_CD, @",SNS_USER_ID:", tmpSNS_USER_ID, @",NAME:", tmpNAME, @",EMAIL:", tmpEMAIL, @",TOS_SERVICE_CD:", tmpTOS_SERVICE_CD] view:self];
			
            [AccountUtil setSNSAutoAccount:tmpSNSID_KEY SNS_CD:tmpSNS_CD SNS_USER_ID:tmpSNS_USER_ID];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SNS_LOGOUT])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpSNSID_KEY = data[@"SNSID_KEY"];
			
//            NSLog(@"%@%@%@%@", @"SNS 로그아웃", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그아웃", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 로그아웃", @"SNSID_KEY = |", tmpSNSID_KEY , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@",
//                                @"SNS 로그아웃 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",SNSID_KEY:", tmpSNSID_KEY] view:self];
			
            [AccountUtil deleteSNSAutoAccount];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SNS_REVOKE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
			
//            NSLog(@"%@%@%@%@", @"SNS 탈퇴", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"SNS 탈퇴", @"RT_MSG = |", tmpRT_MSG , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@",
//                                @"SNS 탈퇴 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG] view:self];
			
            [AccountUtil deleteSNSAutoAccount];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SNS_CONVERSION_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpSNSID_KEY = data[@"SNSID_KEY"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpCLOSE_ST = data[@"CLOSE_ST"];
			
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"SNSID_KEY = |", tmpSNSID_KEY, @"|");
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"ONEID_KEY = |", tmpONEID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"SNS ID 전환가입응답", @"CLOSE_ST = |", tmpCLOSE_ST , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",
//                                @"SNS ID 전환가입응답 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",SNSID_KEY:", tmpSNSID_KEY, @",ONEID_KEY:", tmpONEID_KEY, @",USER_ID:", tmpUSER_ID, @",CLOSE_ST:", tmpCLOSE_ST] view:self];
			
            [AccountUtil deleteSNSAutoAccount];
        }
        else if([data[@"RESULT"] isEqualToString:RC_SNS_EXISTED_ONEID_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
			
//            NSLog(@"%@%@%@%@", @"가입 One ID 사용 선택 응답", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"가입 One ID 사용 선택 응답", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"가입 One ID 사용 선택 응답", @"USER_ID = |", tmpUSER_ID , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@",
//                                @"가입 One ID 사용 선택 응답 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",USER_ID:", tmpUSER_ID] view:self];
			
            NSMutableDictionary *intent = [NSMutableDictionary dictionary];
            [intent setObject:FUNCTION_IDPW_LOGIN forKey:@"FUNCTION_NAME"];
            [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
            [intent setObject:tmpUSER_ID forKey:@"USER_ID"];
            [intent setObject:@"1111" forKey:@"SERVICE_LOGIN_TYPE"];
        }
        else if([data[@"RESULT"] isEqualToString:RC_EXISTED_ONEID_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
			
//            NSLog(@"%@%@%@%@", @"서비스 ID/PW 로그인 화면 요청", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"서비스 ID/PW 로그인 화면 요청", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"서비스 ID/PW 로그인 화면 요청", @"USER_ID = |", tmpUSER_ID , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@",
//                                @"서비스 ID/PW 로그인 화면 요청 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",USER_ID:", tmpUSER_ID] view:self];
			
            NSMutableDictionary *intent = [NSMutableDictionary dictionary];
            [intent setObject:FUNCTION_IDPW_LOGIN forKey:@"FUNCTION_NAME"];
            [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
            [intent setObject:tmpUSER_ID forKey:@"USER_ID"];
            [intent setObject:@"1111" forKey:@"SERVICE_LOGIN_TYPE"];
        }
        else if([data[@"RESULT"] isEqualToString:RC_ATHN_USER])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpCLOSE_ST = data[@"CLOSE_ST"];
			
//            NSLog(@"%@%@%@%@", @"간편인증 ONE ID의 정회원 전환 응답", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"간편인증 ONE ID의 정회원 전환 응답", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"간편인증 ONE ID의 정회원 전환 응답", @"ONEID_KEY = |", tmpONEID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"간편인증 ONE ID의 정회원 전환 응답", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"간편인증 ONE ID의 정회원 전환 응답", @"CLOSE_ST= |", tmpCLOSE_ST , @"|");
//
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",
//                                @"간편인증 ONE ID의 정회원 전환 응답 RT:", tmpRT, @",RT_MSG:", tmpRT_MSG, @",ONEID_KEY:", tmpONEID_KEY, @",USER_ID:", tmpUSER_ID, @",CLOSE_ST:", tmpCLOSE_ST] view:self];
			
            NSMutableDictionary *intent = [NSMutableDictionary dictionary];
            [intent setObject:FUNCTION_IDPW_LOGIN forKey:@"FUNCTION_NAME"];
            [intent setObject:SERVICE_CD forKey:@"SERVICE_CD"];
            [intent setObject:tmpUSER_ID forKey:@"USER_ID"];
            [intent setObject:@"1111" forKey:@"SERVICE_LOGIN_TYPE"];
        }
        else if([data[@"RESULT"] isEqualToString:RC_CTN_LOGIN_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpSSO_KEY = data[@"SSO_KEY"];
            NSString *tmpLOGIN_TYPE = data[@"LOGIN_TYPE"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpSERVICE_KEY = data[@"SERVICE_KEY"];
            NSString *tmpNAME = data[@"NAME"];
            NSString *tmpLGT_TYPE = data[@"LGT_TYPE"];
            NSString *tmpPW_UPDATE_DT = data[@"PW_UPDATE_DT"];
            NSString *tmpTOS_SERVICE_CD = data[@"TOS_SERVICE_CD"];
            NSString *tmpID_TYPE = data[@"ID_TYPE"];
            NSString *REQ_LOGIN_CTN = data[@"REQ_LOGIN_CTN"];
            NSString *VTID_YN = data[@"VTID_YN"];
            NSString *VTID_RQST_RSN_CD = data[@"VTID_RQST_RSN_CD"];
            NSString *REQ_LOGIN_TEL = data[@"REQ_LOGIN_TEL"];
			
            
            
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"RT = |", tmpRT , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"RT_MSG = |", tmpRT_MSG , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"SSO_KEY = |", tmpSSO_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"LOGIN_TYPE = |", tmpLOGIN_TYPE , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"USER_ID = |", tmpUSER_ID , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"ONEID_KEY = |", tmpONEID_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"SERVICE_KEY = |", tmpSERVICE_KEY , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"NAME = |", tmpNAME , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"LGT_TYPE = |", tmpLGT_TYPE , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"PW_UPDATE_DT = |", tmpPW_UPDATE_DT , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"TOS_SERVICE_CD = |", tmpTOS_SERVICE_CD , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"ID_TYPE = |", tmpID_TYPE , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"REQ_LOGIN_CTN = |", REQ_LOGIN_CTN , @"|");
//            NSLog(@"%@%@%@%@", @"CTN 로그인 응답", @"REQ_LOGIN_TEL = |", REQ_LOGIN_TEL , @"|");
//
			/*
            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"CTN 로그인 응답 RT:",
                                tmpRT, @",RT_MSG:", tmpRT_MSG,@",SSO_KEY:", tmpSSO_KEY, @",LOGIN_TYPE:", tmpLOGIN_TYPE, @",USER_ID:", tmpUSER_ID,
                                @",ONEID_KEY:", tmpONEID_KEY, @",SERVICE_KEY:", tmpSERVICE_KEY,  @",NAME:", tmpNAME,  @",LGT_TYPE:", tmpLGT_TYPE,  @",PW_UPDATE_DT:", tmpPW_UPDATE_DT,  @",TOS_SERVICE_CD:",
                                tmpTOS_SERVICE_CD, @",ID_TYPE:", tmpID_TYPE, @",REQ_LOGIN_CTN:", REQ_LOGIN_CTN, @",VTID_YN:", VTID_YN, @",VTID_RQST_RSN_CD:", VTID_RQST_RSN_CD, @",REQ_LOGIN_TEL:", REQ_LOGIN_TEL] view:self];
			*/
			
			NSString *js = [NSString stringWithFormat: @"resCtnLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
				data[@"RT"], data[@"RT_MSG"], data[@"SSO_KEY"], data[@"LOGIN_TYPE"], data[@"USER_ID"], data[@"ONEID_KEY"], data[@"SERVICE_KEY"], data[@"NAME"],
				data[@"LGT_TYPE"], data[@"PW_UPDATE_DT"], data[@"TOS_SERVICE_CD"], data[@"ID_TYPE"], data[@"REQ_LOGIN_CTN"], data[@"VTID_YN"],
				data[@"VTID_RQST_RSN_CD"], data[@"REQ_LOGIN_TEL"]]];
		
			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			{
				[self.webView evaluateJavaScript:js completionHandler:nil];
			}];
			
            if([RT_NOT_ONEID isEqualToString:tmpRT]) {
                return;
            }
			
            if([RT_SUCCESS isEqualToString:tmpRT] == false) {
                return;
            }
			
            if([tmpLOGIN_TYPE isEqualToString:@"2"]) {
                [AccountUtil setEasyAccount:tmpUSER_ID];
                [AccountUtil setAutoAccount:tmpUSER_ID SSO_KEY:tmpSSO_KEY];
            }else if([tmpLOGIN_TYPE isEqualToString:@"1"]) {
                [AccountUtil deleteAutoAccount];
                [AccountUtil setAutoAccount:tmpUSER_ID SSO_KEY:tmpSSO_KEY];
            }else if([tmpLOGIN_TYPE isEqualToString:@"3"]) {
				
            }
            [AccountUtil setNormalAccount:tmpUSER_ID ONEID_KEY:tmpONEID_KEY];
        }
        else if([data[@"RESULT"] isEqualToString:RC_PERMISSION_ERROR])
        {
            NSString *tmpRT = data[@"PERMISSION"];
			
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@", @"권한 확인 : ", tmpRT] view:self];
        }
        else if([data[@"RESULT"] isEqualToString:RC_EVENT_NOTI])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpEVENT_CD = data[@"EVENT_CD"];
            NSString *tmpEVENT_PARAM = data[@"EVENT_PARAM"];
			
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", @"이벤트 확인 : ",
//                                tmpRT, @",RT_MSG:", tmpRT_MSG, @",EVENT_CD:", tmpEVENT_CD, @",EVENT_PARAM:", tmpEVENT_PARAM] view:self];
			
        }
        else if([data[@"RESULT"] isEqualToString:RC_2ND_CERTIFY_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
			
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@", @"2차 추가인증 응답 RT : ",
//                                tmpRT, @",RT_MSG:", tmpRT_MSG, @",ONEID_KEY:", tmpONEID_KEY] view:self];
			
        }
        else if([data[@"RESULT"] isEqualToString:RC_VTID_CHANGE_RESPONSE])
        {
            NSString *tmpRT = data[@"RT"];
            NSString *tmpRT_MSG = data[@"RT_MSG"];
            NSString *tmpONEID_KEY = data[@"ONEID_KEY"];
            NSString *tmpUSER_ID = data[@"USER_ID"];
            NSString *tmpCLOSE_ST = data[@"CLOSE_ST"] == nil?@"":data[@"CLOSE_ST"];
			
//            [Util showToastMsg:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", @"임시ID ONE ID 변경 응답 : ",
//                                tmpRT, @",RT_MSG:", tmpRT_MSG, @",ONEID_KEY:", tmpONEID_KEY, @",USER_ID:", tmpUSER_ID, @",CLOSE_ST:", tmpCLOSE_ST] view:self];
			
        }
    }
    else if(data != nil && requestCode == 2)
    {
        if([data[@"FUNCTION"] isEqualToString:@"fnEndPay"])
        {
            NSString *resC = data[@"resC"];
            NSString *resM = data[@"resM"];
            NSString *resK = data[@"resK"];
            NSString *resD = data[@"resD"];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSString *js = [NSString stringWithFormat: @"fnEndPay('%@','%@', '%@', '%@')", resC, resM, resK, resD];
                
                [self.webView evaluateJavaScript:js completionHandler:nil];
                
            }];
        }
        if([data[@"FUNCTION"] isEqualToString:@"resPgBackInfo"])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSString *js = @"resPgBackInfo()";
                [self.webView evaluateJavaScript:js completionHandler:nil];
                
            }];
        }
    }
	
    data = nil;
    resultCode = 0;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) versionCheck
{
    NSMutableURLRequest *urlRequest;
    
//    NSString *reqUrl = [NSString stringWithFormat:@"%@%@%@", @"https://", mainUrl, @":8443/mob/info/version?nativeType=ios"];
    
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@", mainUrl, @"/mob/info/version?nativeType=ios"];
    
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:reqUrl]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if(returnString == nil)
            {
                returnString = @"";
            }
            
            NSDictionary *infoDictionary = [[NSBundle bundleForClass: [LdcWebView class]] infoDictionary];
            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            
            NSDictionary *realVersion = [returnString JSONValue];
            NSLog(@"%@", realVersion[@"version"]);
            
            int clientVersion = [[version stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
            int serverVersion = [[realVersion[@"version"] stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
            
            if(clientVersion < serverVersion)
            {
//                [self showVersionDialog:@"" msg:@"새로운 버전이 출시되었습니다. 마켓으로 이동하시겠습니까?" yesBtn:@"예" noBtn:@"아니오"];
                
                // 2020-11-23 ui thread 오류로 ui thread 에서 처리하도록 변경 했음
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self showVersionDialog:@"" msg:@"새로운 버전이 출시되었습니다. 마켓으로 이동하시겠습니까?" yesBtn:@"예" noBtn:@"아니오"];
                });
            }
            else
            {
                
                
                if (TARGET == PRD) {
                    // 2019.05.29 Das Server 상용 설정
                    [SetServerTarget Server:IntegrationContants.DAS_TARGET_REAL];
                } else {
                    // 2019.05.29 Das Server 검수 설정
                    [SetServerTarget Server:IntegrationContants.DAS_TARGET_STAGE];
                }
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                    // 2019.05.09 ADD hmwoo WebView Page 로드(Webview 관련 설정 가장 마지막에 배치해야함)
                    [self loadWebview];
                 }];
            }
        }
        else
        {

            if(TARGET == DEV) {
                [SetServerTarget Server:IntegrationContants.DAS_TARGET_STAGE];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                    // 2019.05.09 ADD hmwoo WebView Page 로드(Webview 관련 설정 가장 마지막에 배치해야함)
                    [self loadWebview];
                 }];
                return;
            }


            NSLog(@"%@", [error description]);
            
            if([error code] == -1009)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     [Util showToastMsg:[NSString stringWithFormat:@"%@", @"데이터 접속이 차단되어 있습니다. Wifi를 연결하거나 데이터 접속을 허용상태로 변경 한 후 이용해주시기 바랍니다."] view:self];
                 }];
            }
            else if([error code] == -1200)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     [Util showToastMsg:[NSString stringWithFormat:@"%@", @"유효하지 않은 인증서 접속입니다."] view:self];
                 }];
            }
            else    // 2020-11-23 추가함 (디버그 테스트 하다가 버전체크 링크 안될 경우 아무런 동작 안하게 되서)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                {
                    [self loadWebview];
                }];
            }
            
        }
    }];
    [dataTask resume];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if
    (
    	currentLocationStatus == kCLAuthorizationStatusNotDetermined &&
    	(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
	)
    {
    	[self cameraPermissionCheck];
    }

    currentLocationStatus = status;
}

- (Boolean) locationPermissionCheck
{
	Boolean returnValue = false;
	
    NSLog(@"startStandardUpdates");
	
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    NSLog(@"locationServicesEnabled=%d", [CLLocationManager locationServicesEnabled]);
    
    if ([CLLocationManager locationServicesEnabled])
    {
        NSLog(@"location service enabled");
		
        switch([CLLocationManager authorizationStatus])
        {
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"kCLAuthorizationStatusNotDetermined");
                // User has not yet made a choice with regards to this application
				[locationManager requestAlwaysAuthorization];
				
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"kCLAuthorizationStatusRestricted");
                // This application is not authorized to use location services.  Due
                // to active restrictions on location services, the user cannot change
                // this status, and may not have personally denied authorization
				
                    //[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 근처 직영점 조회를 위해 사진에 접근하려고 합니다. '설정 > 일반 > 차단'에서 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusRestricted"];
                    [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 근처 직영점 조회를 위해 위치 정보에 접근하려고 합니다. '설정' 버튼으로 위치 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusRestricted"];
				
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"kCLAuthorizationStatusDenied");
                // User has explicitly denied authorization for this application, or
                // location services are disabled in Settings
                [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 근처 직영점 조회를 위해 위치 정보에 접근하려고 합니다. '설정' 버튼으로 위치 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusDenied"];
				
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
                returnValue = true;
                // User has authorized this application to use location services
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
                returnValue = true;
                // User has authorized this application to use location services
                break;
        }
		
		
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 10; // meters
		
        [locationManager startUpdatingLocation];
    }
    else
    {
        //[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 근처 직영점 조회를 위해 사진에 접근하려고 합니다. '설정' 버튼으로 위치 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:nil];
        [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 근처 직영점 조회를 위해 사진에 접근하려고 합니다. '설정 > 개인 정보 보호 > 위치 서비스'에서 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:nil];
		
    }
	
    return returnValue;
}

-(Boolean) cameraPermissionCheck
{
	Boolean returnValue = false;

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	
	if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
				if(popup != nil)
				{
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					
						[self photoElbumPermissionCheck];
						
					}];
				}
             }
//             else
//             {
//                [
//                    self showDialog:@"" msg:@"Please enable Camera Based Services for better results! We promise to keep your Camera private [설정 -> 일반 -> 차단]" yesBtn:@"Settings" noBtn:@"Cancel" tag:@"kCLAuthorizationStatusRestricted"
//                ];
//             }
         }];
    }
    else if(authStatus == AVAuthorizationStatusAuthorized)
    {
        returnValue = true;
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
    	
		//[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 촬영을 위해 카메라에 접근하려고 합니다. '설정 > 일반 > 차단'에서 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusRestricted"];
        [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 촬영을 위해 카메라에 접근하려고 합니다. '설정' 버튼으로 카메라 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusRestricted"];
		
        returnValue = false;
    }
    else if (authStatus == AVAuthorizationStatusDenied)
    {
    	//[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 촬영을 위해 카메라에 접근하려고 합니다. '설정 > U+휴대폰 분실 파손 보험 > 카메라'에서 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusDenied"];
        [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 촬영을 위해 카메라에 접근하려고 합니다. '설정' 버튼으로 카메라 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusDenied"];
		
        returnValue = false;
    }
	
    return returnValue;
}

-(Boolean) photoElbumPermissionCheck
{
	Boolean returnValue = false;
	
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

	if (status == PHAuthorizationStatusNotDetermined)
	{
		// Access has not been determined.
		[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
		{
			 if (status == PHAuthorizationStatusAuthorized)
			 {
				 if(popup != nil)
				{
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					
						[popup removeFromSuperview];
						
					}];
				}
			 }
//             else
//             {
//                 [
//                    self showDialog:@"" msg:@"Please enable PhotoElbum Based Services for better results! We promise to keep your PhotoElbum private [설정 -> App -> 사진]" yesBtn:@"설정" noBtn:@"닫기" tag:@"PHAuthorizationStatusRestricted"
//                ];
//             }
		 }];
	}
	else if (status == PHAuthorizationStatusAuthorized)
	{
		 returnValue = true;
	}
	else if (status == PHAuthorizationStatusDenied)
	{
		 
        //[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 조회를 위해 사진에 접근하려고 합니다. '설정 > U+휴대폰 분실 파손 보험 > 사진'에서 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"PHAuthorizationStatusRestricted"]
        [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 조회를 위해 사진에 접근하려고 합니다. '설정' 버튼으로 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"PHAuthorizationStatusRestricted"];
		
        returnValue = false;
	}
	else if (status == PHAuthorizationStatusRestricted)
	{
        //[self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 조회를 위해 사진에 접근하려고 합니다. '설정 > 일반 > 차단'에서 사진 권한을 허용해 주세요." yesBtn:@"Settings" noBtn:@"Cancel" tag:@"kCLAuthorizationStatusRestricted"];
        [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 조회를 위해 사진에 접근하려고 합니다. '설정' 버튼으로 사진 권한을 허용해 주세요." yesBtn:@"Settings" noBtn:@"Cancel" tag:@"kCLAuthorizationStatusRestricted"];
        
        returnValue = false;
	}
	
	if(returnValue == true && popup != nil)
	{
		[popup removeFromSuperview];
	}

	return returnValue;
}




-(Boolean) cameraPermissionCheckOnly
{
    Boolean returnValue = false;

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
             if(granted) {

             } else {
                 
             }
            
        }];
        
    }
    else if(authStatus != AVAuthorizationStatusAuthorized) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            NSString *js = [NSString stringWithFormat: @"cameraPermissionResult(false)"];
            [self.webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error){
        
//                if (result != nil) {
                    [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 촬영을 위해 카메라에 접근하려고 합니다. '설정' 버튼으로 카메라 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"kCLAuthorizationStatusDenied"];
//                }
                
            }];
//        }];
   
//        AVAuthorizationStatusRestricted
//        AVAuthorizationStatusRestricted
    }
    else {
                
        returnValue = true;
    }
    
    return returnValue;
}



-(Boolean) photoElbumPermissionCheckOnly
{
    Boolean returnValue = false;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusNotDetermined) {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {

            }
            else {

            }
         }];
    }
    else if (status != PHAuthorizationStatusAuthorized)
    {
        NSString *js = [NSString stringWithFormat: @"cameraPermissionResult(false)"];
        [self.webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error){
        
//            if (result != nil) {
                [self showDialog:@"" msg:@"'U+휴대폰 분실 파손 보험'이 보상 제출용 사진 조회를 위해 사진에 접근하려고 합니다. '설정' 버튼으로 사진 권한을 허용해 주세요." yesBtn:@"설정" noBtn:@"닫기" tag:@"PHAuthorizationStatusRestricted"];
//            }
        }];
        
    }
    else {
        returnValue = true;
    }
    

    return returnValue;
}


- (void)showVersionDialog:(NSString *) title msg:(NSString *)msg yesBtn:(NSString *)yesBtn noBtn:(NSString *)noBtn
{
    UIAlertController *alertController =
    [
     UIAlertController
     alertControllerWithTitle:title
     message:msg
     preferredStyle:UIAlertControllerStyleAlert
     ];
    
    [
     alertController
     addAction:
     [
      UIAlertAction
      actionWithTitle:yesBtn
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *action)
      {
//          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/U-휴대폰-분실-보험/id1467333704?mt=8"]];
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/U-%ED%9C%B4%EB%8C%80%ED%8F%B0-%EB%B6%84%EC%8B%A4-%EB%B3%B4%ED%97%98/id1467333704?mt=8"]];
//          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/jellidaesi/id574226085?mt=8"]];
      }
      ]
     ];
    
    [
     alertController
     addAction:
     [
      UIAlertAction
      actionWithTitle:noBtn
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *action)
      {
          exit(0);
      }
      ]
     ];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)showDialog:(NSString *) title msg:(NSString *)msg yesBtn:(NSString *)yesBtn noBtn:(NSString *)noBtn tag:(NSString *)tag
{
	UIAlertController *alertController =
	[
		UIAlertController
			alertControllerWithTitle:title
			message:msg
			preferredStyle:UIAlertControllerStyleAlert
	];
	
	[
		alertController
			addAction:
			[
				UIAlertAction
					actionWithTitle:yesBtn
					style:UIAlertActionStyleDefault
					handler:^(UIAlertAction *action)
					{
						[alertController dismissViewControllerAnimated:YES completion:nil];
						
						CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
						
						if([tag isEqualToString:@"kCLAuthorizationStatusDenied"])
						{
							NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
							[[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
						}
						else if([tag isEqualToString:@"kCLAuthorizationStatusRestricted"])
						{
							if (systemVersion < 10)
							{
								[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
							}
							else
							{
								[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
							}
						}
						else
						{
							if (systemVersion < 10)
							{
								[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
							}
							else
							{
								[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
							}
						}
					}
			]
	];
	
	[
		alertController
			addAction:
			[
				UIAlertAction
					actionWithTitle:noBtn
					style:UIAlertActionStyleDefault
					handler:^(UIAlertAction *action)
					{
						[alertController dismissViewControllerAnimated:YES completion:nil];
					}
			]
	];
	
	[self presentViewController:alertController animated:YES completion:^{}];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
    NSLog(@"locationManager didUpdateLocations");
	
    NSLog(@"위치 변경");
	
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
		
	  	latitude = [[NSNumber numberWithDouble:location.coordinate.latitude] stringValue];
		longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
    NSLog(@"locationManage didFailWithError");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	progress = 1.0;
	NSLog(@"%@%@", @"completed: error: ", [error localizedDescription]);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	NSLog(@"Finished downloading!");
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSURL *directoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
	
	NSLog(@"%@", directoryURL.absoluteString);
	
	NSURL *docDirectoryURL = [NSURL fileURLWithPath:directoryURL.absoluteString];
	
	NSString *destinationFilename = [downloadTask originalRequest].URL.lastPathComponent;
	
	NSLog(@"%@", destinationFilename);
	
	NSURL *destinationURL = [docDirectoryURL URLByAppendingPathComponent:destinationFilename];
	
	NSLog(@"%@", destinationURL.absoluteString);
	
	NSString *path = destinationURL.path;
	
	if([fileManager fileExistsAtPath:path])
	{
		@try
		{
			[fileManager removeItemAtURL:destinationURL error:nil];
		}
		@catch (NSException *exception)
		{
			NSLog(@"Caught %@%@", exception.name, exception.reason);
		}
		@catch (NSError *err)
		{
			NSLog(@"Caught %@%@", err.debugDescription, err.description);
		}
	}
	
	@try
	{
		[fileManager copyItemAtURL:location toURL:destinationURL error:nil];
	}
	@catch (NSException *exception)
	{
		NSLog(@"Caught %@%@", exception.name, exception.reason);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		[MBProgressHUD hideHUDForView:self.view animated:true];
	});
	
	NSMutableArray *objectsToShare = [NSMutableArray array];

	[objectsToShare addObject:destinationURL];
	
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	
//	[activityVC setValue:@"Video" forKey:@"subject"];
//
//	if (@available(iOS 9.0, *))
//	{
//		activityVC.excludedActivityTypes = [NSArray<UIActivityType> arrayWithObjects:UIActivityTypeAirDrop, UIActivityTypeAddToReadingList,
//			UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeOpenInIBooks,
//			UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, nil];
//	}
//	else
//	{
//		activityVC.excludedActivityTypes = [NSArray<UIActivityType> arrayWithObjects:UIActivityTypeAirDrop, UIActivityTypeAddToReadingList,
//			UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMail, UIActivityTypeMessage,
//			UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, nil];
//	}

//	UIPopoverPresentationController *popoverController = activityVC.popoverPresentationController;
	
//	popoverController.sourceView = self.btnShareVideo;
//	popoverController.sourceRect = self.btnShareVideo.bounds;

	[self presentViewController:activityVC animated:true completion:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	NSLog(@"%@%lld", @"downloaded", (100 * totalBytesWritten/totalBytesExpectedToWrite));
	
	taskTotalBytesWritten = (int)totalBytesWritten;
	taskTotalBytesExpectedToWrite = (int)totalBytesExpectedToWrite;
	percentageWritten = (float)taskTotalBytesWritten / (float)taskTotalBytesExpectedToWrite;

	NSLog(@"%lf", percentageWritten);
	
	NSString *x = [NSString stringWithFormat:@"%.2f", percentageWritten];
	
	NSLog(@"%@", x);
	
	progress = [x floatValue];

	NSLog(@"%lf", progress);
}





- (void) connectedToNetwork {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
   
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
     SCNetworkReachabilityFlags flags;
   
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
   
    if (!didRetrieveFlags)
    {
        NSLog(@"error");
    }
   
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    
    
     if (isReachable && !needsConnection && !nonWiFi) {
          UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:@"Wifi 네크워크에 연결되었습니다."
                                     message:nil
                                     delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"확인",nil];
//          [alert show];
//          [alert release];
         
     }
     else if(isReachable && !needsConnection && nonWiFi){
          UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:@"3G 네트워크 연결"
                                     message:@"3G 네트워크 이용시 데이터 이용료가 부과됩니다.\nWi-Fi로 접속하시면 더욱 원활하게\n서비스를 이용하실 수 있습니다."
                                     delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"확인",nil];
//          [alert show];
//          [alert release];
         
     }
     else {
          UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:@"연결 없음"
                                     message:@"네트워크 연결이 필요합니다.\n사용 가능한 Wifi 네트워크나\n3G 네트워크에 접속해 주세요."
                                     delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"확인",nil];
//          [alert show];
//          [alert release];
         [self showAlertNetworkWarning];
//         [self showAlertCustom];
//         [self myAlertView];
     }
}




- (UIView *)createDemoView
{
//    NSString *imageName = @"20.png";
//
//    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
//    [imageView setImage:[UIImage imageNamed:imageName]];
//
//    [demoView addSubview:imageView];
//    return demoView;
    
    
    
    
//    UIView *uiView = [[NetworkAlertView alloc] init];
//    return uiView;
    
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UIView *uiView = [[NetworkAlertView alloc] init];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
//    [imageView setImage:[UIImage imageNamed:imageName]];
    
    [demoView addSubview:uiView];
    return demoView;
    
}

- (void)myAlertView {
    UIView *uiView = [[NetworkAlertView alloc] init];
    
    [webView addSubview:uiView];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView close];
}

- (void)showAlertCustom {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
//    [alertView setContainerView:customView];
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];

    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"확인", nil]];
    [alertView setDelegate:self];
    
   
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
        exit(0);
    }];
    
    [alertView setUseMotionEffects:true];
    
    [alertView show];

}



- (void)showAlertNetworkWarning {
    NSString *imageName = @"20.png";
    NSString *title = @"U+ 휴대폰 보험";
    NSString *message = @"현재 네트워크에 접속되지 않았습니다.\n3G/LTE나 무선인터넷 연결이 가능하게\n휴대폰의 설정을 확인하시고, 다시 접속하여\n주시기 바랍니다.\n감사합니다.";
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: title
                                  message: message
                                  preferredStyle:UIAlertControllerStyleAlert];
     
    
   
//    [alert setValue:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    
//    UIImage *uiImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [alert setValue:uiImage  forKey:@"image"];
//    [[self view] addSubview: uiImage];

//    UIImage* imgMyImage = [UIImage imageNamed:imageName];
//    UIImageView* ivMyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgMyImage.size.width, imgMyImage.size.height)];
//    [ivMyImageView setImage:imgMyImage];
//
//    [alert setValue: ivMyImageView forKey:@"accessoryView"];
    
    
    
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   exit(0);
                                               }];
    
//    [ok setValue:uiImage forKey:@"image"];

    [alert addAction:ok];
     
    // 정렬 설정
    NSMutableParagraphStyle *paraStyleTitle = [[NSMutableParagraphStyle alloc] init];
    paraStyleTitle.alignment = NSTextAlignmentLeft;

    // 타이틀 속성 설정
    NSMutableAttributedString *atrTitle = [[NSMutableAttributedString alloc] initWithString:[title uppercaseString] attributes:@{NSParagraphStyleAttributeName:paraStyleTitle,NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0]}];
    
    [alert setValue:atrTitle forKey:@"attributedTitle"];
    
    // 정렬 설정
    NSMutableParagraphStyle *paraStyleMessage = [[NSMutableParagraphStyle alloc] init];
    paraStyleMessage.alignment = NSTextAlignmentLeft;
    
    // 메지시 속성 설정
    NSMutableAttributedString *atrMessage = [[NSMutableAttributedString alloc] initWithString:[message uppercaseString] attributes:@{NSParagraphStyleAttributeName:paraStyleMessage,NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    
    [alert setValue:atrMessage forKey:@"attributedMessage"];
     
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

/*
static OSStatus RNSecTrustEvaluateAsX509
(
    SecTrustRef trust,
    SecTrustResultType *result
)
{
    OSStatus status = errSecSuccess;
    
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef newTrust;
    CFIndex numberOfCerts = SecTrustGetCertificateCount(trust);
    CFMutableArrayRef certs;
    certs = CFArrayCreateMutable(NULL,
                                 numberOfCerts,
                                 &kCFTypeArrayCallBacks);
    for (NSUInteger index = 0; index < numberOfCerts; ++index)
    {
        SecCertificateRef cert;
        cert = SecTrustGetCertificateAtIndex(trust, index);
        CFArrayAppendValue(certs, cert);
    }
    
    status = SecTrustCreateWithCertificates(certs,
                                            policy,
                                            &newTrust);
    if (status == errSecSuccess) {
        status = SecTrustEvaluate(newTrust, result);
    }
    
    CFRelease(policy);
    CFRelease(newTrust);
    CFRelease(certs);
    
    return status;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLProtectionSpace *protSpace = challenge.protectionSpace;
    SecTrustRef trust = protSpace.serverTrust;
    SecTrustResultType result = kSecTrustResultFatalTrustFailure;
    
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess &&
        result == kSecTrustResultRecoverableTrustFailure) {
        SecCertificateRef cert = SecTrustGetCertificateAtIndex(trust,
                                                               0);
        CFStringRef subject = SecCertificateCopySubjectSummary(cert);
        
        CFAbsoluteTime start = SecCertificateNotValidBefore(cert);
        CFAbsoluteTime end = SecCertificateNotValidAfter(cert);
        
        NSLog(@"Begin Date: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:start]);
        NSLog(@"End Date: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:end]);
        
        NSLog(@"Trying to access %@. Got %@.", protSpace.host,
              (__bridge id)subject);
        CFRange range = CFStringFind(subject, CFSTR(".google.com"),
                                     kCFCompareAnchored|
                                     kCFCompareBackwards);
        if (range.location != kCFNotFound) {
            status = RNSecTrustEvaluateAsX509(trust, &result);
        }
        CFRelease(subject);
    }
    
    
    if (status == errSecSuccess) {
        switch (result) {
            case kSecTrustResultInvalid:
            case kSecTrustResultDeny:
            case kSecTrustResultFatalTrustFailure:
            case kSecTrustResultOtherError:
                // We've tried everything:
            case kSecTrustResultRecoverableTrustFailure:
                NSLog(@"Failing due to result: %lu", result);
                [challenge.sender cancelAuthenticationChallenge:challenge];
                break;
                
            case kSecTrustResultProceed:
            case kSecTrustResultConfirm:
            case kSecTrustResultUnspecified:
            {
                NSLog(@"Successing with result: %lu", result);
                NSURLCredential *cred;
                cred = [NSURLCredential credentialForTrust:trust];
                [challenge.sender useCredential:cred
                     forAuthenticationChallenge:challenge];
            }
                break;
                
            default:
                NSAssert(NO, @"Unexpected result from trust evaluation:%d",
                         result);
                break;
        }
    }
    else {
        // Something was broken
        NSLog(@"Complete failure with code: %lu", status);
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}
*/


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}
    

// 2024.01.05 추가
- (void) webView:(WKWebView *)webView
     requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
     initiatedByFrame:(WKFrameInfo *)frame type:(WKMediaCaptureType)type
     decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler
     API_AVAILABLE(ios(15.0))
{
    decisionHandler(WKPermissionDecisionGrant);

 
}




@end

@implementation AutoAccountLogin

OrderedDictionary *autoMap = nil;
LdcWebView *view;

- (void) onPreExecute
{
    view = [parameters objectAtIndex:0];
    
    [view startIndicator];
}

- (NSInteger) doInBackground{
    
    NSDictionary *dictionary = [AccountUtil getAutoAccount];
    if(dictionary != nil && dictionary[@"USER_ID"] != [NSNull null])
    {
        SERVICE_CD = AccountUtil.SERVICE_CD;
        
        autoMap = [IntegrationService.getInstance autoLogin:SERVICE_CD USER_ID:dictionary[@"USER_ID"] SSO_KEY:dictionary[@"SSO_KEY"]];
        if(autoMap != nil && [autoMap[@"RT"] isEqualToString:RT_SUCCESS])
        {
            [AccountUtil setNormalAccount:dictionary[@"USER_ID"] ONEID_KEY:dictionary[@"ONEID_KEY"]];
            return 1;
        }
        else if(autoMap != nil && [autoMap[@"RT"] isEqualToString:RT_NOT_TOS])
        {
            //tosRequest
            return 2;
        }
    }
    return 0;
}

- (void) onPostExecute: (NSInteger) result
{
    NSLog(@"%@%ld", @"AutoAccountLogin : ", result);

    if(autoMap != nil)
    {
        NSString *js = [NSString stringWithFormat: @"resLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
                                                                             autoMap[@"RT"], autoMap[@"RT_MSG"], [AccountUtil getAutoAccount][@"SSO_KEY"], @"3", autoMap[@"USER_ID"], autoMap[@"ONEID_KEY"], autoMap[@"SERVICE_KEY"], autoMap[@"NAME"],
                                                                             autoMap[@"LGT_TYPE"], autoMap[@"PW_UPDATE_DT"], autoMap[@"TOS_SERVICE_CD"], autoMap[@"ID_TYPE"]]];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [view.webView evaluateJavaScript:js completionHandler:nil];
         }];
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%@%@", @"자동로그인 응답 : ", js]);
    }
    else
    {
        NSString *js = [NSString stringWithFormat: @"resLoginResponse(%@)", [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",
                                                                             @"", @"", @"", @"", @"", @"", @"", @"",
                                                                             @"", @"", @"", @""]];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [view.webView evaluateJavaScript:js completionHandler:nil];
         }];
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%@%@", @"자동로그인 응답 : ", @"계정 정보 없음"]);
    }
    
    [view stopIndicator];
}



@end
