#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Util.h"
#import "IntegrationContants.h"
#import "AsyncTask.h"
#import "Activity.h"
#import "AuthenticatorUtil.h"
#import "FidoUtil.h"
#import "RestAPIParameterEnum.h"
#import <WebKit/WebKit.h>

//@interface HybridWebView: UIViewController <UIWebViewDelegate, ManagerControllerDelegate> {
@interface HybridWebView: UIViewController <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler> {
    //UIWebView *webView;
    WKWebView *webView;
    UIActivityIndicatorView *indicator;
    NSMutableDictionary *intent;
}

//@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, strong) NSMutableDictionary *intent;
@property (nonatomic, assign) Boolean chkBackSubmit;

-(void)setResult:(int)resultCode data:(NSDictionary *)data;

@end

@interface StartWebView : AsyncTask
{
    
}

@end

@interface FinishTask : AsyncTask
{
    
}

@end

@interface SetServerTarget : NSObject
{
    
}

+ (void) Server: (NSString *) str;

@end

@interface SetPinSetting : NSObject
{
    
}

+ (void) UsePin: (NSString *) str;

@end
//@interface UIWebView (Javascript)
//- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message     initiatedByFrame:(id *)frame;
//- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame;
//@end
