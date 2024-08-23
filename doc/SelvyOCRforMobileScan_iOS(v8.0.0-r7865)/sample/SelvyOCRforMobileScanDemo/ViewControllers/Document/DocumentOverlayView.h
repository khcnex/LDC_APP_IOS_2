//
//  DocumentOverlayView.h
//  SelvyOCRforMobileScanDemo
//
//  Created by selvas on 2018. 9. 8..
//  Copyright © 2018년 SelvasAI. All rights reserved.
//

#import <UIKit/UIKit.h>

// 카메라 프리뷰 위에 촬영영역을 표시해주는 뷰
@interface DocumentOverlayView : UIView

@property (atomic, assign) BOOL isUseFixedGuide;
@property (atomic, assign) BOOL isDetected; // 영역 검출 성공 여부

@property (atomic, assign) CGRect outerRect;
@property (atomic, assign) CGRect innerRect;

- (id)initWithFrame:(CGRect)frame;
- (void)claerOverlay;

@end
