//
//  TailorBottomToolBarControl.m
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorBottomToolBarControl.h"

@interface TailorBottomToolBarControl()
@property (nonatomic, strong) UIView *firstContainer;
@property (nonatomic, strong) UIButton *normalClipBtn;
@property (nonatomic, strong) UIButton *boundsClipBtn;

@property (nonatomic, strong) UIView *secondContainer;
@end

@implementation TailorBottomToolBarControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.firstContainer];
        [self.firstContainer addSubview:self.normalClipBtn];
        [self.firstContainer addSubview:self.boundsClipBtn];
        
        [self.firstContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.normalClipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.height.equalTo(self);
        }];
        [self.boundsClipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.normalClipBtn.mas_right);
            make.height.right.centerY.equalTo(self);
            make.width.equalTo(self.normalClipBtn);
        }];
    }
    return self;
}

- (void) setActionClip:(TailorToolActionClipState)clipState {
    self.normalClipBtn.selected = clipState == TailorToolActionClipStateNormal;
    self.boundsClipBtn.selected = clipState == TailorToolActionClipStateBounds;
}

#pragma mark - getters
LazyProperty(UIView, firstContainer)
LazyPropertyWithInit(UIButton, normalClipBtn, {
    [_normalClipBtn setTitle:@"NormalClip" forState:UIControlStateNormal];
    [_normalClipBtn setTitleColor:[UIColor hex_colorWithHex:0x666666] forState:UIControlStateNormal];
    [_normalClipBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _normalClipBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    @weakify(self)
    [_normalClipBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        self.normalClipBtn.selected = !self.normalClipBtn.selected;
        TailorToolActionClipState clipState = self.normalClipBtn.selected ? TailorToolActionClipStateNormal : TailorToolActionClipStateNone;
        [self setActionClip:clipState];
        if ([self.delegate respondsToSelector:@selector(toolBarControl:actionClip:)]) {
            [self.delegate toolBarControl:self actionClip:clipState];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, boundsClipBtn, {
    [_boundsClipBtn setTitle:@"BoundsClip" forState:UIControlStateNormal];
    [_boundsClipBtn setTitleColor:[UIColor hex_colorWithHex:0x666666] forState:UIControlStateNormal];
    [_boundsClipBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _boundsClipBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    @weakify(self)
    [_boundsClipBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        self.boundsClipBtn.selected = !self.boundsClipBtn.selected;
        TailorToolActionClipState clipState = self.boundsClipBtn.selected ? TailorToolActionClipStateBounds : TailorToolActionClipStateNone;
        [self setActionClip:clipState];
        if ([self.delegate respondsToSelector:@selector(toolBarControl:actionClip:)]) {
            [self.delegate toolBarControl:self actionClip:clipState];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})

@end
