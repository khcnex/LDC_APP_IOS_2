//
//  RpUrlScheme.h
//  FidoSdkFramework
//
//  Created by h on 2015. 9. 17..
//  Copyright © 2015년 h. All rights reserved.
//

#import "UrlScheme.h"

@interface RpUrlScheme : UrlScheme
{
    NSData *jweKey;
    NSMutableDictionary *savedMessage;
}
- (void)requestFidoClient:(id)json withState:(int)state;
- (void)requestFidoClientDiscovery:(int)state;
- (void)requestFidoClientCompletion:(int)state widthResponseCode:(int)response;
- (void)requestFidoCustomSetting;
- (void)requestFidoClientDiscoveryKT:(int)state;
- (void)requestFidoClientDiscoveryLGU:(int)state;
@property (nonatomic,strong)  NSData *jweKey;
@property (nonatomic,strong)  NSMutableDictionary *savedMessage;


@end
