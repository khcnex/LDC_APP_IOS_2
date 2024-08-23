#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <Photos/Photos.h>

#import "CameraUtil.h"
//#import <LGUFidoSdkFramework/LGUFidoSdkFramework.h>
#import <LGUSdkFramework/LGUSdkFramework.h>
#import "AccountUtil.h"
#import "TelUtil.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CoreLocation/CoreLocation.h>
#import "SubWebView.h"
#import "PgWebView.h"
#import "CustomAlertView.h"
#import "CustomIOSAlertView.h"
#import "NetworkAlertView.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

@interface LdcWebView: UIViewController
<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, ELCImagePickerControllerDelegate, CLLocationManagerDelegate, NSURLSessionDownloadDelegate
//    ,NSURLConnectionDelegate, NSURLConnectionDataDelegate
>
{
    CLLocationManager *locationManager;
    
    WKWebView *webView;
    
    NSMutableDictionary *data;
    
    NSDictionary *intent;
    
    int requestCode;
    
    int resultCode;
	
    NSString *latitude;
	
    NSString *longitude;
	
    NSURLSessionDownloadTask *task;
	
	UIActivityIndicatorView *activityIndicator;
    
    WKProcessPool *wkProcessPool;
    
    UIView *splashView;
    
    //NSURLConnection *connection;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) int requestCode;
@property (nonatomic, assign) int resultCode;
@property (nonatomic, strong) NSDictionary *intent;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *splashView;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) WKProcessPool *wkProcessPool;
//@property (nonatomic, readwrite, strong) NSURLConnection *connection;

@end

@interface AutoAccountLogin : AsyncTask
{
    
}

@end
