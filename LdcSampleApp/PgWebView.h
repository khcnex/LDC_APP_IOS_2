#import <UIKit/UIKit.h>
#import "LdcWebView.h"
#import <WebKit/WebKit.h>
//#import <LGUFidoSdkFramework/LGUFidoSdkFramework.h>
#import <LGUSdkFramework/LGUSdkFramework.h>
@interface PgWebView: UIViewController
<WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate, WKScriptMessageHandler>
{
    CLLocationManager *locationManager;
    
    WKWebView *webView;
    
    NSMutableDictionary *data;
    
    NSDictionary *intent;
    
    int requestCode;
    
    int resultCode;
    
    WKProcessPool *wkProcessPool;
    
    WKWebView *ldcWebView;
}

@property (nonatomic, assign) int requestCode;
@property (nonatomic, assign) int resultCode;
@property (nonatomic, strong) NSDictionary *intent;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebView *ldcWebView;
@property (nonatomic, strong) WKProcessPool *wkProcessPool;

@end
