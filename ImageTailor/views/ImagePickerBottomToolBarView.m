//
//  ImagePickerBottomToolBarView.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerBottomToolBarView.h"
#import "BaseViewController.h"

@interface ImagePickerBottomToolBarView()
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *clipBtn;
@property (nonatomic, strong) UIButton *spliceHorizontally;
@property (nonatomic, strong) UIButton *spliceVertically;

@property (nonatomic, strong) UIView *extraBottomView;
@end

@implementation ImagePickerBottomToolBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hex_colorWithHex:0x0036FF];
        self.alpha = 0.f;
        [self addSubview:self.clearBtn];
        [self addSubview:self.clipBtn];
        [self addSubview:self.spliceHorizontally];
        [self addSubview:self.spliceVertically];
        [self addSubview:self.extraBottomView];
    }
    return self;
}

- (void) updateConstraints {
    [super updateConstraints];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(self);
        make.width.equalTo(self.clearBtn.mas_height);
    }];
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.clearBtn.mas_right);
        make.centerY.height.right.equalTo(self);
    }];
    [self.spliceVertically mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.clearBtn.mas_right);
        make.height.centerY.equalTo(self);
        make.right.equalTo(self.spliceHorizontally.mas_left);
    }];
    [self.spliceHorizontally mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.right.equalTo(self);
        make.width.equalTo(self.spliceVertically);
    }];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    BaseViewController *vc = (BaseViewController *)self.viewController;
    
    self.extraBottomView.frame = CGRectMake(0.f, self.height, self.width, vc.mergedSafeAreaInsets.bottom);
}

- (void) show:(BOOL)show onlyClip:(BOOL)onlyClip {
    if (self.alpha == 0.f && show) {
        self.transform = CGAffineTransformMakeTranslation(0.f, self.height + self.extraBottomView.height);
        self.alpha = 1.f;
        [UIView animateWithDuration:0.2f animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }
    if (self.alpha == 1.f && !show) {
        [UIView animateWithDuration:0.2f animations:^{
            self.transform = CGAffineTransformMakeTranslation(0.f, self.height + self.extraBottomView.height);
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            self.alpha = 0.f;
        }];
    }
    
    self.clipBtn.hidden = !onlyClip;
    self.spliceVertically.hidden = onlyClip;
    self.spliceHorizontally.hidden = onlyClip;
}

LazyPropertyWithInit(UIButton, clearBtn, {
    [_clearBtn setImage:[UIImage imageNamed:@"btn_close_n"] forState:UIControlStateNormal];
    @weakify(self)
    [_clearBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(didClickClear:)]) {
            [self.delegate didClickClear:self];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, clipBtn, {
    [_clipBtn setImage:[UIImage imageNamed:@"img_mode_0"] forState:UIControlStateNormal];
    [_clipBtn setImage:[UIImage imageNamed:@"img_mode_0"] forState:UIControlStateHighlighted];
    [_clipBtn setTitle:@"单张编辑" forState:UIControlStateNormal];
    [_clipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _clipBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [_clipBtn setImageEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 3.f)];
    [_clipBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 3.f, 0.f, 0.f)];
    @weakify(self)
    [_clipBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(didClickClip:)]) {
            [self.delegate didClickClip:self];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, spliceVertically, {
    [_spliceVertically setImage:[UIImage imageNamed:@"img_mode_1"] forState:UIControlStateNormal];
    [_spliceVertically setImage:[UIImage imageNamed:@"img_mode_1"] forState:UIControlStateHighlighted];
    [_spliceVertically setTitle:@"竖向拼接" forState:UIControlStateNormal];
    [_spliceVertically setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _spliceVertically.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [_spliceVertically setImageEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 3.f)];
    [_spliceVertically setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 3.f, 0.f, 0.f)];
    @weakify(self)
    [_spliceVertically bk_addEventHandler:^(id sender) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(didClickSpliceVertically:)]) {
            [self.delegate didClickSpliceVertically:self];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, spliceHorizontally, {
    [_spliceHorizontally setImage:[UIImage imageNamed:@"img_mode_2"] forState:UIControlStateNormal];
    [_spliceHorizontally setImage:[UIImage imageNamed:@"img_mode_2"] forState:UIControlStateHighlighted];
    [_spliceHorizontally setTitle:@"横向拼接" forState:UIControlStateNormal];
    [_spliceHorizontally setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _spliceHorizontally.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [_spliceHorizontally setImageEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 3.f)];
    [_spliceHorizontally setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 3.f, 0.f, 0.f)];
    @weakify(self)
    [_spliceHorizontally bk_addEventHandler:^(id sender) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(didClickSpliceHorizontally:)]) {
            [self.delegate didClickSpliceHorizontally:self];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIView, extraBottomView, {
    _extraBottomView.backgroundColor = self.backgroundColor;
})
@end
