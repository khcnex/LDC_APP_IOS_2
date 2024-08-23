//
//  AppDelegate.m
//  LdcSampleApp
//
//  Created by Woo HeeMyeong on 2018. 9. 4..
//  Copyright © 2018년 nexgrid. All rights reserved.
//

#import "AppTestDelegate.h"

@interface AppTestDelegate ()

@end

@implementation AppTestDelegate

@synthesize ldcWebView;

- (BOOL)isJailbroken
{
    
    // Check 1 : 탈옥된 장치에 있는 파일 탐색
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }
                                                       
   FILE *f = NULL;
   if ((f = fopen("/bin/bash", "r")) ||
       (f = fopen("/Applications/Cydia.app", "r")) ||
       (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
       (f = fopen("/usr/sbin/sshd", "r")) ||
       (f = fopen("/etc/apt", "r"))) {
       fclose(f);
       return YES;
   }
   fclose(f);
   
   // Check 2 : 시스템 디렉토리 읽고 쓰기 (sandbox violation)
   NSError *error;
   [@"Jailbreak Test" writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
   
   if(error == nil) { // 탈옥된 장치임
       return YES;
   }
   else {
       [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
   }
    
   return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
//    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
//    if ([components.scheme isEqualToString:[self lgidScheme]]) {
  
        //[self lgidApplicationOpenURL:url];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallbackNotification" object:url];

    return YES;
}
                                                       

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lgidCallbackNotification:) name:@"CallbackNotification" object:nil];
    // Override point for customization after application launch.
    
//    if([[JBHelper getInstance] getJBCResult])
//    {
//        NSLog(@"%@", @"탈옥폰 종료");
//        exit(0);
//    }
    if([self isJailbroken])
    {
        NSLog(@"%@", @"탈옥폰 종료");
        exit(0);
    }
    
    ldcWebView = [[LdcWebView alloc] init];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]] ;
    
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
    
    [self.window setRootViewController:[[UINavigationController alloc]initWithRootViewController:ldcWebView]] ;
    
//    self.window.backgroundColor = [UIColor colorWithRed:179.0f/255.0f green:105.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    
    //[self.window setRootViewController:ldcWebView] ;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"Cookies"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookies"];
    if ( [cookiesData length] )
    {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for ( NSHTTPCookie *cookie in cookies )
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)lgidCallbackNotification:(NSNotification *)notification {
    NSLog(@"notification : %@", notification);
    [WebLgViewController webLoad:notification];
}


@end
