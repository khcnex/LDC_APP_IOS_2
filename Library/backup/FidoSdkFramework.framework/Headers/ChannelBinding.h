//
//  ChannelBinding.h
//  FidoSdkFramework
//
//  Created by h on 2015. 9. 24..
//  Copyright © 2015년 h. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STRING_SERVER_END_POINT @"serverEndPoint"
#define STRING_TLS_SERVER_CERTIFICATE @"tlsServerCertificate"
#define STRING_CHANNEL_BINDING @"channelbindings"


@interface ChannelBinding : NSObject
{
    NSString* serverEndPoint;
    NSString* tlsServerCertificate;
    NSString* tlsUnique;
    NSString* cid_pubkey;
}

-(void) setTLSServerCertificate:(NSData*) derCert;
-(NSString*) toJson;
-(id) toDict ;

@property (nonatomic , strong)NSString* tlsServerCertificate;
@property (nonatomic , strong)NSString* serverEndPoint;

@end
