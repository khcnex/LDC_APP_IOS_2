//
//  FidoKdf.h
//  FidoSdkFramework
//
//  Created by h on 2016. 3. 28..
//  Copyright © 2016년 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FidoKdf : NSObject
+ (NSData *)pbkdf2:(NSData *)data;
+ (void)clearNSData:(NSData *)data;
+ (NSData *)customPbkdf2:(NSString *)str;
@end
