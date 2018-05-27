//
//  EditorBottomToolbarControl.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorBottomToolbarControl.h"
#import "BaseViewController.h"

@interface EditorBottomToolbarControl()
@property (nonatomic, strong) UIView *extraBottomView;

@property (nonatomic, strong) UIView *clipBtnBgView;
@property (nonatomic, strong) UIButton *clipNormalBtn;
@property (nonatomic, strong) UIButton *clipBoundsBtn;

@property (nonatomic, strong) UIView *toolBtnBgView;
@property (nonatomic, strong) UIButton *toolPixellateBtn;
@property (nonatomic, strong) UIButton *toolSpaceLineBtn;
@property (nonatomic, strong) UIButton *toolWatermarkBtn;
@property (nonatomic, strong) UIButton *toolPhoneBoundsBtn;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NSDictionary *btnMap;
@end

@implementation EditorBottomToolbarControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.extraBottomView];
        
        [self addSubview:self.clipBtnBgView];
        [self.clipBtnBgView addSubview:self.clipNormalBtn];
        [self.clipBtnBgView addSubview:self.clipBoundsBtn];
        
        [self addSubview:self.toolBtnBgView];
        [self.toolBtnBgView addSubview:self.toolPixellateBtn];
        [self.toolBtnBgView addSubview:self.toolSpaceLineBtn];
        [self.toolBtnBgView addSubview:self.toolWatermarkBtn];
        [self.toolBtnBgView addSubview:self.toolPhoneBoundsBtn];
        
        [self addSubview:self.line];
        
        self.btnMap = @{
            @(EditorToolbarBtnTypeClipNormal): self.clipNormalBtn,
            @(EditorToolbarBtnTypeClipBounds): self.clipBoundsBtn,
            @(EditorToolbarBtnTypeToolPixellate): self.toolPixellateBtn,
            @(EditorToolbarBtnTypeToolSpaceline): self.toolSpaceLineBtn,
            @(EditorToolbarBtnTypeToolWatermark): self.toolWatermarkBtn,
            @(EditorToolbarBtnTypeToolPhoneBounds): self.toolPhoneBoundsBtn
        };
        [self addEventForAllBtn];
    }
    return self;
}

- (void) switchToClip {
    self.clipBtnBgView.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.bounds = CGRectMake(0.f, 0.f, self.width, self.height);
    } completion:^(BOOL finished) {
        self.toolBtnBgView.hidden = YES;
    }];
}

- (void) switchToTool {
    self.toolBtnBgView.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.bounds = CGRectMake(self.width, 0.f, self.width, self.height);
    } completion:^(BOOL finished) {
        self.clipBtnBgView.hidden = YES;
    }];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    BaseViewController *vc = (BaseViewController *)self.viewController;
    
    self.extraBottomView.frame = CGRectMake(0.f, self.height, self.width * 2.f, vc.mergedSafeAreaInsets.bottom);
    self.line.frame = CGRectMake(0.f, 0.f, 2.f * self.width, 0.5f);
    
    self.clipBtnBgView.frame = CGRectMake(0.f, 0.f, self.width, self.height);
    self.clipNormalBtn.frame = CGRectMake(0.f, 0.f, self.width / 2.f, self.height);
    self.clipBoundsBtn.frame = CGRectMake(self.clipNormalBtn.right, 0.f, self.width / 2.f, self.height);
    
    self.toolBtnBgView.frame = CGRectMake(self.width, 0.f, self.width, self.height);
    self.toolPixellateBtn.frame = CGRectMake(0.f, 0.f, self.width / 4.f, self.height);
    self.toolSpaceLineBtn.frame = CGRectMake(self.toolPixellateBtn.right, 0.f, self.width / 4.f, self.height);
    self.toolWatermarkBtn.frame = CGRectMake(self.toolSpaceLineBtn.right, 0.f, self.width / 4.f, self.height);
    self.toolPhoneBoundsBtn.frame = CGRectMake(self.toolWatermarkBtn.right, 0.f, self.width / 4.f, self.height);
}

- (void) addEventForAllBtn {
    @weakify(self)
    [self.btnMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *btnTypeValue, UIButton *btn, BOOL * _Nonnull stop) {
        [btn bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self.btnMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (obj == btn) {
                    [self selectBtnType:[key integerValue] selected:!btn.selected];
                    *stop = YES;
                }
            }];
        } forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void) selectBtnType:(EditorToolbarBtnType)btnType selected:(BOOL)selected {
    UIButton *btn = self.btnMap[@(btnType)];
    [self.btnMap.allValues bk_each:^(UIButton *b) {
        b.selected = NO;
    }];
    btn.selected = selected;
    if ([self.delegate respondsToSelector:@selector(toolbarControl:clickBtn:selected:)]) {
        [self.delegate toolbarControl:self clickBtn:btnType selected:selected];
    }
}

#pragma mark - getters
LazyPropertyWithInit(UIView, extraBottomView, {
    _extraBottomView.backgroundColor = self.backgroundColor;
})
LazyPropertyWithInit(UIView, line, {
    _line.backgroundColor = [UIColor hex_colorWithHex:0x000000 alpha:0.1f];
})
LazyProperty(UIView, clipBtnBgView)
LazyPropertyWithInit(UIButton, clipNormalBtn, {
    [_clipNormalBtn setImage:[UIImage imageNamed:@"btn_cut_unit_n"] forState:UIControlStateNormal];
    [_clipNormalBtn setImage:[UIImage imageNamed:@"btn_cut_unit_s"] forState:UIControlStateSelected];
})
LazyPropertyWithInit(UIButton, clipBoundsBtn, {
    [_clipBoundsBtn setImage:[UIImage imageNamed:@"btn_cut_whole_n"] forState:UIControlStateNormal];
    [_clipBoundsBtn setImage:[UIImage imageNamed:@"btn_cut_whole_s"] forState:UIControlStateSelected];
})
LazyProperty(UIView, toolBtnBgView)
LazyPropertyWithInit(UIButton, toolPixellateBtn, {
    [_toolPixellateBtn setImage:[UIImage imageNamed:@"btn_tool_mosaic_n"] forState:UIControlStateNormal];
    [_toolPixellateBtn setImage:[UIImage imageNamed:@"btn_tool_mosaic_s"] forState:UIControlStateSelected];
})
LazyPropertyWithInit(UIButton, toolSpaceLineBtn, {
    [_toolSpaceLineBtn setImage:[UIImage imageNamed:@"btn_tool_frame_n"] forState:UIControlStateNormal];
    [_toolSpaceLineBtn setImage:[UIImage imageNamed:@"btn_tool_frame_s"] forState:UIControlStateSelected];
})
LazyPropertyWithInit(UIButton, toolWatermarkBtn, {
    [_toolWatermarkBtn setImage:[UIImage imageNamed:@"btn_tool_watermark_n"] forState:UIControlStateNormal];
    [_toolWatermarkBtn setImage:[UIImage imageNamed:@"btn_tool_watermark_s"] forState:UIControlStateSelected];
})
LazyPropertyWithInit(UIButton, toolPhoneBoundsBtn, {
    [_toolPhoneBoundsBtn setImage:[UIImage imageNamed:@"btn_tool_mockup_n"] forState:UIControlStateNormal];
    [_toolPhoneBoundsBtn setImage:[UIImage imageNamed:@"btn_tool_mockup_s"] forState:UIControlStateSelected];
})

@end

@interface EditorBottomToolbarPixellateFloatView()
@property (nonatomic, strong) UIButton *withdrawBtn;
@property (nonatomic, strong) UIButton *largeBtn;
@property (nonatomic, strong) UIButton *middleBtn;
@property (nonatomic, strong) UIButton *smallBtn;
@end
@implementation EditorBottomToolbarPixellateFloatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.withdrawBtn];
        [self addSubview:self.largeBtn];
        [self addSubview:self.middleBtn];
        [self addSubview:self.smallBtn];
        
        [self reset];
    }
    return self;
}
-(void) layoutSubviews {
    [super layoutSubviews];
    self.withdrawBtn.frame = CGRectMake(0.f, 0.f, self.width / 4.f, self.height);
    self.largeBtn.frame = CGRectMake(self.withdrawBtn.right, 0.f, self.width / 4.f, self.height);
    self.middleBtn.frame = CGRectMake(self.largeBtn.right, 0.f, self.width / 4.f, self.height);
    self.smallBtn.frame = CGRectMake(self.middleBtn.right, 0.f, self.width / 4.f, self.height);
}
- (void) setWithdrawEnable:(BOOL)enable {
    self.withdrawBtn.selected = enable;
}
- (ScrawlToolBarPixellateType) currentPixellateType {
    if (self.largeBtn.selected) {
        return ScrawlToolBarPixellateTypeLarge;
    } else if (self.middleBtn.selected) {
        return ScrawlToolBarPixellateTypeMiddle;
    } else if (self.smallBtn.selected) {
        return ScrawlToolBarPixellateTypeSmall;
    }
    return ScrawlToolBarPixellateTypeNone;
}
- (void) reset {
    [@[self.largeBtn, self.middleBtn, self.smallBtn] bk_each:^(UIButton *btn) {
        btn.selected = NO;
    }];
    self.middleBtn.selected = YES;
}
- (void) clearOtherBtnState:(UIButton *)currentBtn {
    [@[self.largeBtn, self.middleBtn, self.smallBtn] bk_each:^(UIButton *btn) {
        if (currentBtn != btn) {
            btn.selected = NO;
        }
    }];
    currentBtn.selected = !currentBtn.selected;
}
LazyPropertyWithInit(UIButton, withdrawBtn, {
    [_withdrawBtn setImage:[UIImage imageNamed:@"btn_edit_revoke_d"] forState:UIControlStateNormal];
    [_withdrawBtn setImage:[UIImage imageNamed:@"btn_edit_revoke_n"] forState:UIControlStateSelected];
    @weakify(self)
    [_withdrawBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(pixellateWithdraw)]) {
            [self.delegate pixellateWithdraw];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, largeBtn, {
    [_largeBtn setImage:[UIImage imageNamed:@"btn_mosaic_1_n"] forState:UIControlStateNormal];
    [_largeBtn setImage:[UIImage imageNamed:@"btn_mosaic_1_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_largeBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(pixellateWithType:)]) {
            [self.delegate pixellateWithType:(!self.largeBtn.selected ? ScrawlToolBarPixellateTypeNone : ScrawlToolBarPixellateTypeLarge)];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, middleBtn, {
    [_middleBtn setImage:[UIImage imageNamed:@"btn_mosaic_2_n"] forState:UIControlStateNormal];
    [_middleBtn setImage:[UIImage imageNamed:@"btn_mosaic_2_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_middleBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(pixellateWithType:)]) {
            [self.delegate pixellateWithType:(!self.middleBtn.selected ? ScrawlToolBarPixellateTypeNone : ScrawlToolBarPixellateTypeMiddle)];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, smallBtn, {
    [_smallBtn setImage:[UIImage imageNamed:@"btn_mosaic_3_n"] forState:UIControlStateNormal];
    [_smallBtn setImage:[UIImage imageNamed:@"btn_mosaic_3_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_smallBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(pixellateWithType:)]) {
            [self.delegate pixellateWithType:(!self.smallBtn.selected ? ScrawlToolBarPixellateTypeNone : ScrawlToolBarPixellateTypeSmall)];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
@end

@interface EditorBottomToolbarSpacelineFloatView()
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *allBoundsBtn;
@property (nonatomic, strong) UIButton *spaceBtn;
@end
@implementation EditorBottomToolbarSpacelineFloatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.clearBtn];
        [self addSubview:self.allBoundsBtn];
        [self addSubview:self.spaceBtn];
        
        [self reset];
    }
    return self;
}
-(void) layoutSubviews {
    [super layoutSubviews];
    self.clearBtn.frame = CGRectMake(0.f, 0.f, self.width / 3.f, self.height);
    self.allBoundsBtn.frame = CGRectMake(self.clearBtn.right, 0.f, self.width / 3.f, self.height);
    self.spaceBtn.frame = CGRectMake(self.allBoundsBtn.right, 0.f, self.width / 3.f, self.height);
}
- (void) reset {
    [@[self.clearBtn, self.allBoundsBtn, self.spaceBtn] bk_each:^(UIButton *btn) {
        btn.selected = NO;
    }];
    self.clearBtn.selected = YES;
}
- (void) clearOtherBtnState:(UIButton *)currentBtn {
    [self reset];
    currentBtn.selected = YES;
}
LazyPropertyWithInit(UIButton, clearBtn, {
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_n"] forState:UIControlStateNormal];
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_clearBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(spacelineWithType:)]) {
            [self.delegate spacelineWithType:EditorToolBarSpacelineTypeNone];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, allBoundsBtn, {
    [_allBoundsBtn setImage:[UIImage imageNamed:@"btn_frame_1_n"] forState:UIControlStateNormal];
    [_allBoundsBtn setImage:[UIImage imageNamed:@"btn_frame_1_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_allBoundsBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(spacelineWithType:)]) {
            [self.delegate spacelineWithType:EditorToolBarSpacelineTypeAllBounds];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, spaceBtn, {
    [_spaceBtn setImage:[UIImage imageNamed:@"btn_frame_2_n"] forState:UIControlStateNormal];
    [_spaceBtn setImage:[UIImage imageNamed:@"btn_frame_2_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_spaceBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(spacelineWithType:)]) {
            [self.delegate spacelineWithType:EditorToolBarSpacelineTypeSpace];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
@end

@interface EditorBottomToolbarWatermarkFloatView()
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *editBtn;
@end
@implementation EditorBottomToolbarWatermarkFloatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.clearBtn];
        [self addSubview:self.centerBtn];
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
        [self addSubview:self.editBtn];
        
        [self reset];
    }
    return self;
}
- (void) layoutSubviews {
    [super layoutSubviews];
    self.clearBtn.frame = CGRectMake(0.f, 0.f, self.width / 5.f, self.height);
    self.centerBtn.frame = CGRectMake(self.clearBtn.right, 0.f, self.width / 5.f, self.height);
    self.leftBtn.frame = CGRectMake(self.centerBtn.right, 0.f, self.width / 5.f, self.height);
    self.rightBtn.frame = CGRectMake(self.leftBtn.right, 0.f, self.width / 5.f, self.height);
    self.editBtn.frame = CGRectMake(self.rightBtn.right, 0.f, self.width / 5.f, self.height);
}
- (void) reset {
    [@[self.clearBtn, self.centerBtn, self.leftBtn, self.rightBtn] bk_each:^(UIButton *btn) {
        btn.selected = NO;
    }];
    self.clearBtn.selected = YES;
}
- (void) clearOtherBtnState:(UIButton *)currentBtn {
    [self reset];
    currentBtn.selected = YES;
}
LazyPropertyWithInit(UIButton, clearBtn, {
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_n"] forState:UIControlStateNormal];
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_clearBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(watermarkWithType:)]) {
            [self.delegate watermarkWithType:EditorToolBarWatermarkTypeNone];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, centerBtn, {
    [_centerBtn setImage:[UIImage imageNamed:@"btn_watermark_1_n"] forState:UIControlStateNormal];
    [_centerBtn setImage:[UIImage imageNamed:@"btn_watermark_1_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_centerBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(watermarkWithType:)]) {
            [self.delegate watermarkWithType:EditorToolBarWatermarkTypeCenter];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, leftBtn, {
    [_leftBtn setImage:[UIImage imageNamed:@"btn_watermark_2_n"] forState:UIControlStateNormal];
    [_leftBtn setImage:[UIImage imageNamed:@"btn_watermark_2_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_leftBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(watermarkWithType:)]) {
            [self.delegate watermarkWithType:EditorToolBarWatermarkTypeLeft];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, rightBtn, {
    [_rightBtn setImage:[UIImage imageNamed:@"btn_watermark_3_n"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"btn_watermark_3_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_rightBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(watermarkWithType:)]) {
            [self.delegate watermarkWithType:EditorToolBarWatermarkTypeRight];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, editBtn, {
    [_editBtn setImage:[UIImage imageNamed:@"btn_word_edit_n"] forState:UIControlStateNormal];
    @weakify(self)
    [_editBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(watermarkEditWord)]) {
            [self.delegate watermarkEditWord];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
@end

@interface EditorBottomToolbarPhoneBoundsFLoatView()
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *silveryBtn;
@property (nonatomic, strong) UIButton *goldBtn;
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIButton *iPhoneXBtn;
@end
@implementation EditorBottomToolbarPhoneBoundsFLoatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.clearBtn];
        [self addSubview:self.silveryBtn];
        [self addSubview:self.goldBtn];
        [self addSubview:self.blackBtn];
        [self addSubview:self.iPhoneXBtn];
        
        [self reset];
    }
    return self;
}
- (void) layoutSubviews {
    [super layoutSubviews];
    self.clearBtn.frame = CGRectMake(0.f, 0.f, self.width / 5.f, self.height);
    self.silveryBtn.frame = CGRectMake(self.clearBtn.right, 0.f, self.width / 5.f, self.height);
    self.goldBtn.frame = CGRectMake(self.silveryBtn.right, 0.f, self.width / 5.f, self.height);
    self.blackBtn.frame = CGRectMake(self.goldBtn.right, 0.f, self.width / 5.f, self.height);
    self.iPhoneXBtn.frame = CGRectMake(self.blackBtn.right, 0.f, self.width / 5.f, self.height);
}
- (void) reset {
    [@[self.clearBtn, self.silveryBtn, self.goldBtn, self.blackBtn, self.iPhoneXBtn] bk_each:^(UIButton *btn) {
        btn.selected = NO;
    }];
    self.clearBtn.selected = YES;
}
- (void) clearOtherBtnState:(UIButton *)currentBtn {
    [self reset];
    currentBtn.selected = YES;
}
LazyPropertyWithInit(UIButton, clearBtn, {
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_n"] forState:UIControlStateNormal];
    [_clearBtn setImage:[UIImage imageNamed:@"btn_edit_default_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_clearBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(phoneBoundsWithType:)]) {
            [self.delegate phoneBoundsWithType:EditorToolBarPhoneBoundsTypeNone];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, silveryBtn, {
    [_silveryBtn setImage:[UIImage imageNamed:@"btn_mockup_1_n"] forState:UIControlStateNormal];
    [_silveryBtn setImage:[UIImage imageNamed:@"btn_mockup_1_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_silveryBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(phoneBoundsWithType:)]) {
            [self.delegate phoneBoundsWithType:EditorToolBarPhoneBoundsTypeSilvery];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, goldBtn, {
    [_goldBtn setImage:[UIImage imageNamed:@"btn_mockup_2_n"] forState:UIControlStateNormal];
    [_goldBtn setImage:[UIImage imageNamed:@"btn_mockup_2_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_goldBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(phoneBoundsWithType:)]) {
            [self.delegate phoneBoundsWithType:EditorToolBarPhoneBoundsTypeGold];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, blackBtn, {
    [_blackBtn setImage:[UIImage imageNamed:@"btn_mockup_3_n"] forState:UIControlStateNormal];
    [_blackBtn setImage:[UIImage imageNamed:@"btn_mockup_3_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_blackBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(phoneBoundsWithType:)]) {
            [self.delegate phoneBoundsWithType:EditorToolBarPhoneBoundsTypeBlack];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, iPhoneXBtn, {
    [_iPhoneXBtn setImage:[UIImage imageNamed:@"btn_mockup_4_n"] forState:UIControlStateNormal];
    [_iPhoneXBtn setImage:[UIImage imageNamed:@"btn_mockup_4_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_iPhoneXBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
        if ([self.delegate respondsToSelector:@selector(phoneBoundsWithType:)]) {
            [self.delegate phoneBoundsWithType:EditorToolBarPhoneBoundsTypeIPhoneX];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
@end
