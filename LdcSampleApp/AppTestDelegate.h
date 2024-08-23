//
//  AppDelegate.h
//  LdcSampleApp
//
//  Created by Woo HeeMyeong on 2018. 9. 4..
//  Copyright © 2018년 nexgrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LdcWebView.h"
//#import "JBHelper.h"

@interface AppTestDelegate : UIResponder <UIApplicationDelegate>
{
    LdcWebView *ldcWebView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LdcWebView *ldcWebView;

@end

