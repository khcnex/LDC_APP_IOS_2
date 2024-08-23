#import "PgWebView.h"

@implementation PgWebView

@synthesize webView;
@synthesize ldcWebView;
@synthesize requestCode;
@synthesize resultCode;
@synthesize intent;
@synthesize data;
@synthesize wkProcessPool;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 2019.05.30 ADD Push View 에 대한 스와이프 기능 가능하도록 허용
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    // 2019.05.09 ADD hmwoo 네비게이션 기능 초기화
    [self naviFuncInit];

    // 2019.05.09 ADD hmwoo JavaScript CallBack(Web -> App) 초기화
    [self jsCallBackInit];

    // 2019.05.09 ADD hmwoo WKWebView Basic Setting
    [self wkWebViewInit:true];

    // 2019.05.09 ADD hmwoo WKWeb 스와이프(뒤로가기, 앞으로가기) 핸들러 추가
    [self addSwipehandler];
    
    // 2019.05.09 ADD hmwoo WebView Page 로드(Webview 관련 설정 가장 마지막에 배치해야함)
    [self loadWebview];
}

- (void)userContentController:(WKUserContentController *)javascriptController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *map = (NSDictionary *)message.body;
    
    for (NSString* key in map) {
        
        NSLog(@"%@%@%@", key, @" : ", map[key]);
        
    }
    
    if([[[message body] allKeys] count] > 0 && [[message body]objectForKey:@"function"])
    {
        NSString *function = map[@"function"];
        
        if([function isEqualToString:@"fnEndPay"])
        {
            int cnt = self.navigationController.viewControllers.count < 2 ? 0 : (int)self.navigationController.viewControllers.count - 2;
            
            data = [[NSMutableDictionary alloc] init];
            [data setValue:map[@"function"] forKey:@"FUNCTION"];
            [data setValue:map[@"resC"] forKey:@"resC"];
            [data setValue:map[@"resM"] forKey:@"resM"];
            [data setValue:map[@"resK"] forKey:@"resK"];
            [data setValue:map[@"resD"] forKey:@"resD"];
            
            [self.navigationController.viewControllers[cnt] performSelector:@selector(setData:) withObject:[data mutableCopy]];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
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

- (void) setWebViewSize
{
    CGRect frame = self.view.frame;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    frame.origin.y = statusBarHeight;
    frame.size.height = frame.size.height - statusBarHeight;
    self.view.frame = frame;
}

/**
 * WKWebView 초기 기본 설정
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) wkWebViewInit:(bool)useSwipe
{
    [webView setUIDelegate:self];
    //    [webView setUserInteractionEnabled:NO];
    [webView allowsBackForwardNavigationGestures];
    
    //2018.09.07 hmwoo WKWebView의 웹페이지 이동을 감지하는 핸들러가 동작하기 위하여 필요
    webView.navigationDelegate = self;
    
    //2018.09.07 hmwoo WKWebView에서 뒤로 및 앞으로 스와이프 동작을 설정
    webView.allowsBackForwardNavigationGestures = useSwipe;
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
 * 웹 뷰 로드
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void) loadWebview
{
    
    //2018.09.06 hmwoo IOS 뷰에 WebView 웹뷰 추가
    [self.view addSubview:webView];
    //    self.view = webView;
    
    NSMutableURLRequest *request;
    NSString *url = intent[@"URL"];
    NSString *param = intent[@"PARAM"];
    NSString *method = intent[@"METHOD"];
    
    
    
    if(url == nil || param == nil || method == nil)
    {
        return;
    }
    
    //2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
    //NSString *body = [NSString stringWithFormat: @"arg1=%@&arg2=%@", @"val1",@"val2"];
    
    request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, @"?", param]]];
    
    [request setHTTPMethod:method];
    
    //2018.09.06 hmwoo 바디값도 보내는 경우 주석 해제하여 바디값 변경
    //[request setHTTPBody:[body dataUsingEncoding: NSUTF8StringEncoding];
    
    //2018.09.06 hmwoo 실질적으로 운영하고 있는 웹페이지 정보 취득 @END
    
    //2018.09.06 hmwoo 지정된 웹페이지 로드 @START
    [webView loadRequest:request];
    
    
    
    //2018.09.06 hmwoo 지정된 웹페이지 로드 @END
}

- (void) jsCallBackInit
{
//    WKWebViewConfiguration *javascriptHandler = [[WKWebViewConfiguration alloc] init];
//
//    [javascriptHandler.userContentController addScriptMessageHandler:self name:@"ldc"];
    
    CGRect frame = self.view.frame;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    frame.origin.y = statusBarHeight;
    frame.size.height = frame.size.height - statusBarHeight;
    self.view.frame = frame;
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = true;
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    configuration.processPool = wkProcessPool;
    [configuration.userContentController addScriptMessageHandler:self name:@"ldc"];
    
    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    
//    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:javascriptHandler];
    //    webView.scrollView.contentInset = UIEdgeInsetsMake(0 - statusBarHeight, 0, 0, 0);
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
    NSLog(@"%@", webView.URL.absoluteString);
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
    NSLog(@"%@",webView.URL.absoluteString);
    NSLog(@"%@",[error localizedDescription]);
//    [webView loadRequest:[[NSMutableURLRequest alloc]initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ErrorPage" ofType:@"html" inDirectory:@""]]]];
}

/**
 * 화면에 동작이 인식되었을 경우 동작을 지시하는 CallBack 함수.
 *
 * @author  hmwoo
 * @version 1.0
 * @param   gesture  화면에 동작이 인식되었을 경우 동작에 대한 정보
 */
-(void)recognizerGesture:(UIGestureRecognizer *)gesture{
    
    NSLog(@"%@", @"recognizerGesture");
    
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
        [webView reload];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
        [webView reload];
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
    
    //    if(webView.canGoBack)
    //    {
    self.navigationItem.leftBarButtonItem.title = @"←";
    self.navigationItem.leftBarButtonItem.enabled = YES;
    //    }
    //    else
    //    {
    //        self.navigationItem.leftBarButtonItem.title = @"";
    //        self.navigationItem.leftBarButtonItem.enabled = NO;
    //    }
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
}


/**
 * 앱이 메모리 경고를 받을경우 호출
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 뷰 컨트롤러의 뷰가 윈도우의 뷰 계층에서 제거 되려고 할 때 호출.
 *
 * @author  hmwoo
 * @version 1.0
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@%d", @"resultCode : ", resultCode);
    NSLog(@"%@%d", @"requestCode : ", requestCode);
    
    if(resultCode == 0)
    {
        return;
    }
    
    data = nil;
    resultCode = 0;
}

//- (void)showDialog:(NSString *) title msg:(NSString *)msg yesBtn:(NSString *)yesBtn noBtn:(NSString *)noBtn tag:(NSString *)tag
//{
//    UIAlertController *alertController =
//    [
//     UIAlertController
//     alertControllerWithTitle:title
//     message:msg
//     preferredStyle:UIAlertControllerStyleAlert
//     ];
//    
//    [
//     alertController
//     addAction:
//     [
//      UIAlertAction
//      actionWithTitle:yesBtn
//      style:UIAlertActionStyleDefault
//      handler:^(UIAlertAction *action)
//      {
//          [alertController dismissViewControllerAnimated:YES completion:nil];
//          
//          CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
//          
//          if([tag isEqualToString:@"kCLAuthorizationStatusDenied"])
//          {
//              NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//              [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
//          }
//          else if([tag isEqualToString:@"kCLAuthorizationStatusRestricted"])
//          {
//              if (systemVersion < 10)
//              {
//                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"]];
//              }
//              else
//              {
//                  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"] options:[NSDictionary dictionary] completionHandler:nil];
//              }
//          }
//          else
//          {
//              if (systemVersion < 10)
//              {
//                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"]];
//              }
//              else
//              {
//                  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=LOCATION"] options:[NSDictionary dictionary] completionHandler:nil];
//              }
//          }
//      }
//      ]
//     ];
//    
//    [
//     alertController
//     addAction:
//     [
//      UIAlertAction
//      actionWithTitle:noBtn
//      style:UIAlertActionStyleDefault
//      handler:^(UIAlertAction *action)
//      {
//          [alertController dismissViewControllerAnimated:YES completion:nil];
//      }
//      ]
//     ];
//    
//    [self presentViewController:alertController animated:YES completion:^{}];
//}

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler {
    
    
    NSDictionary *headers = navigationAction.request.allHTTPHeaderFields;
    
    for(NSString *key in headers)
    {
        NSLog(@"%@ : %@", key, headers[key]);
    }
    
    if(navigationAction.navigationType == WKNavigationTypeBackForward)
    {   
        int cnt = self.navigationController.viewControllers.count < 2 ? 0 : (int)self.navigationController.viewControllers.count - 2;
        
        data = [[NSMutableDictionary alloc] init];
        [data setValue:@"resPgBackInfo" forKey:@"FUNCTION"];
        
        [self.navigationController.viewControllers[cnt] performSelector:@selector(setData:) withObject:[data mutableCopy]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"%@", @"뒤로가기, 앞으로가기 아님");
    }
    
    //===============
    
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
        return;
    }
    if ( [reqUrl hasPrefix:hd_appname]){
        NSLog(@"2. 현대 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([reqUrl isEqualToString:sh_url] == YES ){
        NSLog(@"1. 스마트신한 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ( [reqUrl hasPrefix:sh_appname]){
        NSLog(@"2. 스마트신한 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([reqUrl isEqualToString:sh_url2] == YES ){
        NSLog(@"1. 스마트신한앱 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ( [reqUrl hasPrefix:sh_appname2]){
        NSLog(@"2. 신한모바일앱 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ( [reqUrl hasPrefix:lottecard]){
        NSLog(@"롯데카드 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //NH카드 공인인증서  다운로드 url
    NSString  *nh_url = @"https://itunes.apple.com/kr/app/nhansimkeullig/id609410702?mt=8";
    //nh카드 앱 url 스키마
    NSString  *nh_appname = @"nonghyupcardansimclick";
    if ([reqUrl isEqualToString:nh_url] == YES ){
        NSLog(@"NH앱 관련 url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ( [reqUrl hasPrefix:nh_appname]){
        NSLog(@"NH 앱 관련 url 입니다.==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    
    if (![reqUrl hasPrefix:@"http://"] && ![reqUrl hasPrefix:@"https://"]){
        NSLog(@"  앱  url 입니다. ==>%@",reqUrl);
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else{
        NSLog(@"  앱  url 입니다. ==>%@",reqUrl);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
