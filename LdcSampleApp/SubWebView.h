
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

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


@interface SubWebView: UIViewController
<WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>
{
    CLLocationManager *locationManager;
	
    WKWebView *webView;
	
    NSMutableDictionary *data;
	
    NSDictionary *intent;
	
    int requestCode;
	
    int resultCode;
}

@property (nonatomic, assign) int requestCode;
@property (nonatomic, assign) int resultCode;
@property (nonatomic, strong) NSDictionary *intent;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) WKWebView *webView;

@end
