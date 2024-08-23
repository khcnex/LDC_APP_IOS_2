//
//  NetworkAlertView.m
//  LdcSampleApp
//
//  Created by KwonHyeChang on 2020/11/23.
//  Copyright © 2020 nexgrid. All rights reserved.
//

#import "NetworkAlertView.h"

@interface NetworkAlertView()
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation NetworkAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//
//    if (self) {
//        [self customInit];
//    }
//
//    return self;
//}
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame: frame];
//
//    if (self) {
//        [self customInit];
//    }
//
//    return self;
//}

- (void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"NetworkAlertView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (instancetype) init {
    self = [super init];
    
    if(self) {
        self = [[NSBundle.mainBundle loadNibNamed:@"NetworkAlertView" owner:self options:nil] firstObject];
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.frame = free;
    }
    return self;
    
//    [self customInit];
    
//    return self;
}

@end
