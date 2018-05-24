//
//  EditorWatermarkContext.m
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorWatermarkContext.h"

@interface EditorWatermarkContext()
// water mark < © >
@property (nonatomic, strong, readwrite) UILabel *watermarkLabel;
@end

@implementation EditorWatermarkContext

- (void) showWatermarkWithType:(EditorToolBarWatermarkType)watermarkType imagesUnionRect:(CGRect)unionRect text:(NSString *)text {
    CGFloat extraOffset = 0.03f * MIN(CGRectGetWidth(unionRect), CGRectGetHeight(unionRect));
    CGFloat fontSize = MAX(10, ceilf(extraOffset));
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor hex_colorWithHex:0x000000 alpha:0.2f];
    shadow.shadowOffset = CGSizeMake(.1f * fontSize, .1f * fontSize);
    shadow.shadowBlurRadius = 0.1f * fontSize;
    self.watermarkLabel.attributedText = [[NSAttributedString alloc] initWithString:(text ?: @"")
                                                                         attributes:@{NSShadowAttributeName: shadow}];
    self.watermarkLabel.hidden = text.length == 0;
    [self.imageContainerView addSubview:self.watermarkLabel];
    self.watermarkLabel.layer.transform = CATransform3DMakeTranslation(0, 0, 100.f);
    
    self.watermarkLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.watermarkLabel sizeToFit];
    
    self.watermarkLabel.frame = CGRectMake(0.f,
                                           CGRectGetMaxY(unionRect) - extraOffset - self.watermarkLabel.height,
                                           self.watermarkLabel.width,
                                           self.watermarkLabel.height);
    if (watermarkType == EditorToolBarWatermarkTypeLeft) {
        self.watermarkLabel.left = CGRectGetMinX(unionRect) + extraOffset;
    } else if(watermarkType == EditorToolBarWatermarkTypeRight) {
        self.watermarkLabel.right = CGRectGetMaxX(unionRect) - extraOffset;
    } else {
        self.watermarkLabel.centerX = CGRectGetMidX(unionRect);
    }
}

- (void) hideWatermark {
    self.watermarkLabel.hidden = YES;
}

- (void) clear {
    self.watermarkLabel.hidden = YES;
}

- (CGRect) visableWaterLabelRect {
    return self.watermarkLabel.frame;
}

LazyPropertyWithInit(UILabel, watermarkLabel, {
    _watermarkLabel.textColor = [UIColor whiteColor];
    _watermarkLabel.hidden = YES;
})
@end
