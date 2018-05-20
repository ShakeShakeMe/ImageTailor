//
//  PhoneBoundsContext.m
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "PhoneBoundsContext.h"

@interface PhoneBoundsContext()
@property (nonatomic, strong, readwrite) UIImageView *phoneBoundsImageView;
@end

@implementation PhoneBoundsContext

- (void) showWithPhoneBoundsType:(EditorToolBarPhoneBoundsType)phoneBoundsType {
    if (phoneBoundsType == EditorToolBarPhoneBoundsTypeNone) {
        [self hide];
        return ;
    }
    NSDictionary *imageNameMap = @{
                                   @(EditorToolBarPhoneBoundsTypeSilvery): @"img_mockup_1",
                                   @(EditorToolBarPhoneBoundsTypeGold): @"img_mockup_2",
                                   @(EditorToolBarPhoneBoundsTypeBlack): @"img_mockup_3",
                                   @(EditorToolBarPhoneBoundsTypeIPhoneX): @"img_mockup_ipx"
                                   };
    UIImage *phoneBoundsImage = [UIImage imageNamed:imageNameMap[@(phoneBoundsType)]];
    self.phoneBoundsImageView.image = phoneBoundsImage;
    [self.imageContainerView addSubview:self.phoneBoundsImageView];

    BOOL isVertical = CGRectGetWidth(self.imageViewsUnionRect) < CGRectGetHeight(self.imageViewsUnionRect);
    
    CGFloat enlargeScale = (1444.f - 200.f) / CGRectGetWidth(self.imageViewsUnionRect);
    if (!isVertical) {
        enlargeScale = (1444.f - 200.f) / CGRectGetHeight(self.imageViewsUnionRect);
    }
    BOOL isIPhoneX = phoneBoundsType == EditorToolBarPhoneBoundsTypeIPhoneX;
    CGFloat leftMargin = 100.f / enlargeScale;
    CGFloat topMargin = isIPhoneX ? 84.f / enlargeScale : 362.f / enlargeScale;
    CGFloat bottomMargin = isIPhoneX ? 90.f / enlargeScale : 362.f / enlargeScale;

    CGFloat width = (CGRectGetWidth(self.imageViewsUnionRect) + 2.f * leftMargin) * enlargeScale;
    CGFloat height = (CGRectGetHeight(self.imageViewsUnionRect) + topMargin + bottomMargin) * enlargeScale;
    if (!isVertical) {
        width = (CGRectGetHeight(self.imageViewsUnionRect) + 2.f * leftMargin) * enlargeScale;
        height = (CGRectGetWidth(self.imageViewsUnionRect) + topMargin + bottomMargin) * enlargeScale;
    }
    self.phoneBoundsImageView.frame = CGRectMake(0.f, 0.f, width, height);
    self.phoneBoundsImageView.center = CGPointMake(CGRectGetMidX(self.imageViewsUnionRect), CGRectGetMidY(self.imageViewsUnionRect));

    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 1000);
    transform = CATransform3DScale(transform, 1.f / enlargeScale, 1.f / enlargeScale, 1);
    if (!isVertical) {
        transform = CATransform3DRotate(transform, -M_PI_2, 0, 0, 1);
    }
    self.phoneBoundsImageView.layer.transform = transform;
    self.phoneBoundsImageView.hidden = NO;
}

- (void) hide {
    [self.phoneBoundsImageView removeFromSuperview];
    self.phoneBoundsImageView.image = nil;
    self.phoneBoundsImageView.hidden = YES;
}

LazyProperty(UIImageView, phoneBoundsImageView)

@end
