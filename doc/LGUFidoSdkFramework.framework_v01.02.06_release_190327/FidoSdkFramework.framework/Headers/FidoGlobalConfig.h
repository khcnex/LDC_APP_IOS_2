//
//  FidoGlobalConfig.h
//  FidoSdkFramework
//
//  Created by h on 2015. 9. 24..
//  Copyright © 2015년 h. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChannelBinding.h"
#import "FidoLog.h"


@interface FidoGlobalConfig : NSObject
{
    ChannelBinding *channelBinding;
}
 + (id)sharedInstance ;
@property (nonatomic , strong)ChannelBinding* channelBinding;

@end
