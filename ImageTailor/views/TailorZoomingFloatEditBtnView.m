//
//  TailorZoomingFloatEditBtnView.m
//  ImageTailor
//
//  Created by dl on 2018/5/1.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorZoomingFloatEditBtnView.h"
#import "UIImage+GIF.h"

@interface TailorZoomingFloatEditBtnView()
@property (nonatomic, assign, readwrite) TailorZommingFloatEditAlignment alignment;
@property (nonatomic, strong) UIView *editBtnView;
@property (nonatomic, strong) UIImageView *btnImageView;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) UIImageView *leftOrTopArrowImageView;
@property (nonatomic, strong) UIImageView *rightOrBottomArrowImageView;
@end

@implementation TailorZoomingFloatEditBtnView

- (instancetype) initWithAlignment:(TailorZommingFloatEditAlignment)alignment {
    self = [super init];
    if (self) {
        self.alignment = alignment;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.line];
        [self addSubview:self.editBtnView];
        [self.editBtnView addSubview:self.btnImageView];
        [self addSubview:self.leftOrTopArrowImageView];
        [self addSubview:self.rightOrBottomArrowImageView];
        
        @weakify(self)
        [self.editBtnView bk_whenTapped:^{
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(floatEditBtnView:isEditing:)]) {
                [self.delegate floatEditBtnView:self isEditing:!self.selected];
            }
        }];
    }
    return self;
}

- (void) setSelected:(BOOL)selected {
    _selected = selected;
    
    if (selected) {
        self.btnImageView.image = [UIImage imageNamed:@"btn_cut_move_use"];
    } else {
        self.btnImageView.image = [UIImage imageNamed:@"btn_cut_move_edit"];
    }
}

- (void) reset {
    self.selected = NO;
    self.leftOrTopArrowImageView.hidden = YES;
    self.rightOrBottomArrowImageView.hidden= YES;
}

- (void) beginEditing {
    self.selected = YES;
    self.alpha = 1.f;
    [self showArrowIfPossiable];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat btnSizeBase = MIN(self.height, self.width);
    CGFloat lineSizeValue = 0.1f * btnSizeBase;
    CGSize btnSize = CGSizeMake(([self isAlignmentHorizontally] ? 2.5f : 1.f) * btnSizeBase,
                                ([self isAlignmentHorizontally] ? 1.f : 2.5f) * btnSizeBase);
    CGFloat enlargeScale = btnSizeBase / 20.f;
    CGSize verticalArrowSize = CGSizeMake(24.f * enlargeScale, 32.f * enlargeScale);
    CGSize horizontalArrowSize = CGSizeMake(32.f * enlargeScale, 24.f * enlargeScale);
    CGFloat extraOffset = 8.f * enlargeScale;
    
    UIRectCorner rectCorner;
    switch (self.alignment) {
        case TailorZoomingFloatEditAlignVertically:
        {
            rectCorner = UIRectCornerAllCorners;
            self.line.frame = CGRectMake(CGRectGetMidX(self.bounds) - lineSizeValue / 2.f, 0.f, lineSizeValue, self.height);
            self.editBtnView.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
            
            self.leftOrTopArrowImageView.size = horizontalArrowSize;
            self.leftOrTopArrowImageView.centerY = self.editBtnView.centerY;
            self.leftOrTopArrowImageView.right = self.editBtnView.left - extraOffset;
            
            self.rightOrBottomArrowImageView.size = horizontalArrowSize;
            self.rightOrBottomArrowImageView.centerY = self.editBtnView.centerY;
            self.rightOrBottomArrowImageView.left = self.editBtnView.right + extraOffset;
        }
            break;
        case TailorZoomingFloatEditAlignHorizontally:
        {
            rectCorner = UIRectCornerAllCorners;
            self.line.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - lineSizeValue / 2.f, self.width, lineSizeValue);
            self.editBtnView.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
            
            self.leftOrTopArrowImageView.size = verticalArrowSize;
            self.leftOrTopArrowImageView.centerX = self.editBtnView.centerX;
            self.leftOrTopArrowImageView.bottom = self.editBtnView.top - extraOffset;
            
            self.rightOrBottomArrowImageView.size = verticalArrowSize;
            self.rightOrBottomArrowImageView.centerX = self.editBtnView.centerX;
            self.rightOrBottomArrowImageView.top = self.editBtnView.bottom + extraOffset;
        }
            break;
        case TailorZoomingFloatEditAlignTop:
        {
            rectCorner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            self.line.frame = CGRectMake(0.f, 0.f, self.width, lineSizeValue);
            self.editBtnView.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
            
            self.rightOrBottomArrowImageView.size = verticalArrowSize;
            self.rightOrBottomArrowImageView.centerX = self.editBtnView.centerX;
            self.rightOrBottomArrowImageView.top = self.editBtnView.bottom + 8.f * enlargeScale;
        }
            break;
        case TailorZoomingFloatEditAlignLeft:
        {
            rectCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
            self.line.frame = CGRectMake(0.f, 0.f, lineSizeValue, self.height);
            self.editBtnView.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
            
            self.rightOrBottomArrowImageView.size = horizontalArrowSize;
            self.rightOrBottomArrowImageView.centerY = self.editBtnView.centerY;
            self.rightOrBottomArrowImageView.left = self.editBtnView.right + extraOffset;
        }
            break;
        case TailorZoomingFloatEditAlignBottom:
        {
            rectCorner = UIRectCornerTopRight | UIRectCornerTopLeft;
            self.line.frame = CGRectMake(0.f, self.height - lineSizeValue, self.width, lineSizeValue);
            self.editBtnView.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
            
            self.leftOrTopArrowImageView.size = verticalArrowSize;
            self.leftOrTopArrowImageView.centerX = self.editBtnView.centerX;
            self.leftOrTopArrowImageView.bottom = self.editBtnView.top - extraOffset;
        }
            break;
        case TailorZoomingFloatEditAlignRight:
        {
            rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
            self.line.frame = CGRectMake(CGRectGetMaxX(self.bounds) - lineSizeValue, 0.f, lineSizeValue, self.height);
            self.editBtnView.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
            
            self.leftOrTopArrowImageView.size = horizontalArrowSize;
            self.leftOrTopArrowImageView.centerY = self.editBtnView.centerY;
            self.leftOrTopArrowImageView.right = self.editBtnView.left - extraOffset;
        }
            break;
        default:
            break;
    }
    CGFloat btnImageViewWidth = btnSizeBase * 12.f / 20.f;
    self.btnImageView.size = CGSizeMake(btnImageViewWidth, btnImageViewWidth);
    self.btnImageView.center = CGPointMake(CGRectGetMidX(self.editBtnView.bounds),
                                           CGRectGetMidY(self.editBtnView.bounds));
    self.maskLayer.frame = self.editBtnView.bounds;
    CGFloat corrnerRadii = btnSizeBase / 2.f;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.editBtnView.bounds
                                                     byRoundingCorners:rectCorner
                                                           cornerRadii:CGSizeMake(corrnerRadii, corrnerRadii)];
    self.maskLayer.path = bezierPath.CGPath;
}

- (BOOL) isAlignmentHorizontally {
    return [@[@(TailorZoomingFloatEditAlignHorizontally),
              @(TailorZoomingFloatEditAlignTop),
              @(TailorZoomingFloatEditAlignBottom)]
            containsObject:@(self.alignment)];
}

- (void)showArrowIfPossiable {
    self.leftOrTopArrowImageView.hidden = NO;
    self.rightOrBottomArrowImageView.hidden= NO;
    switch (self.alignment) {
        case TailorZoomingFloatEditAlignVertically:
        {
            self.leftOrTopArrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.rightOrBottomArrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case TailorZoomingFloatEditAlignHorizontally:
        {
            self.rightOrBottomArrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
            break;
        case TailorZoomingFloatEditAlignTop:
        {
            self.leftOrTopArrowImageView.hidden = YES;
            self.rightOrBottomArrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
            break;
        case TailorZoomingFloatEditAlignLeft:
        {
            self.leftOrTopArrowImageView.hidden = YES;
            self.rightOrBottomArrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case TailorZoomingFloatEditAlignBottom:
        {
            self.rightOrBottomArrowImageView.hidden = YES;
        }
            break;
        case TailorZoomingFloatEditAlignRight:
        {
            self.rightOrBottomArrowImageView.hidden = YES;
            self.leftOrTopArrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        default:
            break;
    }
}

LazyPropertyWithInit(UIView, editBtnView, {
    _editBtnView.clipsToBounds = YES;
    _editBtnView.backgroundColor = [UIColor hex_colorWithHex:0xFFF000];
    _editBtnView.layer.mask = self.maskLayer;
})
LazyPropertyWithInit(UIImageView, btnImageView, {})
LazyPropertyWithInit(UIView, line, {
    _line.backgroundColor = [UIColor hex_colorWithHex:0xFFc34c];
})
LazyProperty(CAShapeLayer, maskLayer)
LazyPropertyWithInit(UIImageView, leftOrTopArrowImageView, {
    _leftOrTopArrowImageView.image = [UIImage sd_animatedGIFNamed:@"img_cut_arrow"];
})
LazyPropertyWithInit(UIImageView, rightOrBottomArrowImageView, {
    _rightOrBottomArrowImageView.image = [UIImage sd_animatedGIFNamed:@"img_cut_arrow"];
})
@end
