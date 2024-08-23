#import "CustomAlertView.h"

@implementation CustomAlertView

@synthesize btn_allow;
@synthesize btn_denied;
//@synthesize txt_permission;

- (instancetype)init
{
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class])
//                                bundle:bundle];
//    self = [nib instantiateWithOwner:self options:nil][0];
	
    self = [[[NSBundle mainBundle] loadNibNamed:@"PermissionAlertView" owner:self options:nil] lastObject];
    
    btn_allow.layer.borderWidth = 2.0f;
    btn_allow.layer.borderColor = [self colorWithRGBHex:0xEC008C].CGColor;
    
    
    btn_denied.layer.borderWidth = 2.0f;
    btn_denied.layer.borderColor = [self colorWithRGBHex:0xEC008C].CGColor;
	
//    txt_permission.editable = NO;

    return self;
}


- (IBAction)btn_denied_pre:(id)sender
{
    btn_denied.backgroundColor = [self colorWithRGBHex:0xD9D9D9];
    btn_denied.layer.borderColor = [self colorWithRGBHex:0xCD0C7D].CGColor;
}

- (IBAction)btn_denied_nor:(id)sender
{
    btn_denied.backgroundColor = [self colorWithRGBHex:0xFFFFFF];
    btn_denied.layer.borderColor = [self colorWithRGBHex:0xEC008C].CGColor;
}

- (IBAction)btn_allow_pre:(id)sender
{
    btn_allow.backgroundColor = [self colorWithRGBHex:0xCB0C7D];
    btn_allow.layer.borderColor = [self colorWithRGBHex:0xCB0C7D].CGColor;
}

- (IBAction)btn_allow_nor:(id)sender
{
    btn_allow.backgroundColor = [self colorWithRGBHex:0xEC008C];
    btn_allow.layer.borderColor = [self colorWithRGBHex:0xEC008C].CGColor;
}

/*
- (IBAction)btn_allow_foc:(id)sender
{
    NSLog(@"%@", @"up");
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//
//        self.btn_allow.layer.borderColor = [self colorWithRGBHex:0xE95365].CGColor;
//
//    }];
    
}
- (IBAction)btn_allow_pre:(id)sender
{
    NSLog(@"%@", @"up");
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//
//        self.btn_allow.layer.borderColor = [self colorWithRGBHex:0xCD0C7D].CGColor;
//
//    }];
    
}
*/
- (UIColor *)colorWithRGBHex:(NSUInteger)RGBHex
{
    CGFloat red = ((CGFloat)((RGBHex & 0xFF0000) >> 16)) / 255.0f;
    
    CGFloat green = ((CGFloat)((RGBHex & 0xFF00) >> 8)) / 255.0f;
    
    CGFloat blue = ((CGFloat)((RGBHex & 0xFF))) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}



- (UIColor *)colorWithRGBHex:(NSUInteger)RGBHex alpha:(CGFloat)alpha
{
    
    CGFloat red = ((CGFloat)((RGBHex & 0xFF0000) >> 16)) / 255.0f;
    
    CGFloat green = ((CGFloat)((RGBHex & 0xFF00) >> 8)) / 255.0f;
    
    CGFloat blue = ((CGFloat)((RGBHex & 0xFF))) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (IBAction)clickDenied:(id)sender
{
	//NSLog(@"Denied!!!!!!");
//	[self removeFromSuperview];
}

- (IBAction)clickAllow:(id)sender
{
	//NSLog(@"Allow!!!!!!");
}


@end
