//
//  AppDelegate.h
//  LdcSampleApp
//
//  Created by Woo HeeMyeong on 2018. 9. 4..
//  Copyright © 2018년 nexgrid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainActivity.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MainActivity *mainActivity;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainActivity *mainActivity;

@end

