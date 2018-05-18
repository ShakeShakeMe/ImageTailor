//
//  TailorZoomingFloatEditBtnView.m
//  ImageTailor
//
//  Created by dl on 2018/5/1.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorZoomingFloatEditBtnView.h"

@interface TailorZoomingFloatEditBtnView()
@property (nonatomic, assign, readwrite) TailorZommingFloatEditAlignment alignment;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIView *line;
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
        [self addSubview:self.editBtn];
        
        @weakify(self)
        [self.editBtn bk_addEventHandler:^(id sender) {
            @strongify(self)
            self.editBtn.selected = !self.editBtn.selected;
            if ([self.delegate respondsToSelector:@selector(floatEditBtnView:isEditing:)]) {
                [self.delegate floatEditBtnView:self isEditing:self.editBtn.selected];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        _editBtn.titleLabel.numberOfLines = [self isAlignmentHorizontally] ? 1 : 0;
        [_editBtn setTitle:([self isAlignmentHorizontally] ? @"E\nD\nI\nT" : @"EDIT") forState:UIControlStateNormal];
        [_editBtn setTitle:([self isAlignmentHorizontally] ? @"O\nK" : @"OK") forState:UIControlStateSelected];
    }
    return self;
}

- (void) reset {
    self.editBtn.selected = NO;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat btnSizeBase = MIN(self.height, self.width);
    CGFloat lineSizeValue = 0.1f * btnSizeBase;
    CGSize btnSize = CGSizeMake(([self isAlignmentHorizontally] ? 2.5f : 1.f) * btnSizeBase,
                                ([self isAlignmentHorizontally] ? 1.f : 2.5f) * btnSizeBase);
    
    switch (self.alignment) {
        case TailorZoomingFloatEditAlignVertically:
        {
            self.line.frame = CGRectMake(CGRectGetMidX(self.bounds) - lineSizeValue / 2.f, 0.f, lineSizeValue, self.height);
            self.editBtn.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
        }
            break;
        case TailorZoomingFloatEditAlignHorizontally:
        {
            self.line.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - lineSizeValue / 2.f, self.width, lineSizeValue);
            self.editBtn.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
        }
            break;
        case TailorZoomingFloatEditAlignTop:
        {
            self.line.frame = CGRectMake(0.f, 0.f, self.width, lineSizeValue);
            self.editBtn.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
        }
            break;
        case TailorZoomingFloatEditAlignLeft:
        {
            self.line.frame = CGRectMake(0.f, 0.f, lineSizeValue, self.height);
            self.editBtn.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
        }
            break;
        case TailorZoomingFloatEditAlignBottom:
        {
            self.line.frame = CGRectMake(0.f, self.height - lineSizeValue, self.width, lineSizeValue);
            self.editBtn.frame = CGRectMake(CGRectGetMidX(self.bounds) - btnSize.width / 2.f, 0.f, btnSize.width, btnSize.height);
        }
            break;
        case TailorZoomingFloatEditAlignRight:
        {
            self.line.frame = CGRectMake(CGRectGetMaxX(self.bounds) - lineSizeValue, 0.f, lineSizeValue, self.height);
            self.editBtn.frame = CGRectMake(0.f, CGRectGetMidY(self.bounds) - btnSize.height / 2.f, btnSize.width, btnSize.height);
        }
            break;
        default:
            break;
    }

    _editBtn.titleLabel.font = [UIFont systemFontOfSize:(8 * btnSizeBase / 15.f)];
}

- (BOOL) isAlignmentHorizontally {
    return [@[@(TailorZoomingFloatEditAlignHorizontally),
              @(TailorZoomingFloatEditAlignTop),
              @(TailorZoomingFloatEditAlignBottom)]
            containsObject:@(self.alignment)];
}

LazyPropertyWithInit(UIButton, editBtn, {
    _editBtn.clipsToBounds = YES;
    _editBtn.backgroundColor = [UIColor hex_colorWithHex:0xFFc34c];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:9];
    [_editBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateSelected];
})
LazyPropertyWithInit(UIView, line, {
    _line.backgroundColor = [UIColor hex_colorWithHex:0xFFc34c];
})

@end
