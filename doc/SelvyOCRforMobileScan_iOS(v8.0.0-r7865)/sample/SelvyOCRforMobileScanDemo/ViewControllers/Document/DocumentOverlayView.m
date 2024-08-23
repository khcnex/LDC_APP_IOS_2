//
//  DocumentOverlayView.m
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import "DocumentOverlayView.h"

#define STROKE_WIDTH 2.0f

@implementation DocumentOverlayView

@synthesize isUseFixedGuide;
@synthesize isDetected;
@synthesize outerRect;
@synthesize innerRect;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// 영역이 검출되면 검출된 영역을 화면에 출력
- (void)drawRect:(CGRect)rect {
    // CGContextClearRect(UIGraphicsGetCurrentContext(), self.bounds);
    
    // 불투명 영역
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:200/255.f] setFill];
    UIRectFill(rect);
    
    // 투명 영역
    [[UIColor clearColor] setFill];
    UIRectFill(outerRect);
    
    // 안쪽 선 테두리(점선) - 수동/자동
    UIBezierPath *innerPath = [UIBezierPath bezierPath];
    [innerPath moveToPoint:CGPointMake(innerRect.origin.x, innerRect.origin.y)];
    [innerPath addLineToPoint:CGPointMake((innerRect.origin.x + innerRect.size.width), innerRect.origin.y)];
    [innerPath addLineToPoint:CGPointMake((innerRect.origin.x + innerRect.size.width), (innerRect.origin.y + innerRect.size.height))];
    [innerPath addLineToPoint:CGPointMake(innerRect.origin.x, (innerRect.origin.y + innerRect.size.height))];
    [innerPath closePath];
    
    innerPath.lineWidth = STROKE_WIDTH;
    
    CGFloat dashPattern[] = {4, 2};
    [innerPath setLineDash:dashPattern count:2 phase:0];
    
    if (isUseFixedGuide) { // 수동
        // 바깥 선 테두리(선)
        UIBezierPath *outerPath = [UIBezierPath bezierPath];
        [outerPath moveToPoint:CGPointMake(outerRect.origin.x, outerRect.origin.y)];
        [outerPath addLineToPoint:CGPointMake((outerRect.origin.x + outerRect.size.width), outerRect.origin.y)];
        [outerPath addLineToPoint:CGPointMake((outerRect.origin.x + outerRect.size.width), (outerRect.origin.y + outerRect.size.height))];
        [outerPath addLineToPoint:CGPointMake(outerRect.origin.x, (outerRect.origin.y + outerRect.size.height))];
        [outerPath closePath];
        
        [[UIColor yellowColor] setStroke];
        
        outerPath.lineWidth = STROKE_WIDTH;
        [outerPath stroke];
        
        [[UIColor whiteColor] setStroke];
    } else {
        if (isDetected) {
            [[UIColor colorWithRed:0 green:255/255.f blue:0 alpha:50/255.f] setFill];
            UIRectFill(innerRect);
            
            [[UIColor yellowColor] setStroke];
        } else {
            [[UIColor clearColor] setFill];
            UIRectFill(innerRect);
            
            [[UIColor whiteColor] setStroke];
        }
    }
    
    [innerPath stroke];
}

- (void)claerOverlay {
    [[UIColor clearColor] setFill];
    UIRectFill(innerRect);
}

@end

