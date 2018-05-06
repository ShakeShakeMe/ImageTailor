//
//  ScrawlBottomToolBarControl.m
//  ImageTailor
//
//  Created by dl on 2018/5/6.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ScrawlBottomToolBarControl.h"

@interface ScrawlBottomToolBarFLoatView()
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) NSArray<UIButton *> *btns;

@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *unselectedImages;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, assign, readwrite) ScrawlToolBarItemType itemType;
@end

@implementation ScrawlBottomToolBarFLoatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.topLine];
        [self addSubview:self.verticalLine];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.topLine.frame = CGRectMake(0.f, 0.f, self.width, 0.5f);
    self.verticalLine.frame = CGRectMake(self.width * 0.75f, self.height * 0.25f, 0.5f, self.height * 0.5f);
    
    CGFloat btnWidth = self.width * 0.75f / (self.btns.count - 1);
    [self.btns enumerateObjectsUsingBlock:^(UIButton * _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == self.btns.count - 1) {
            btn.frame = CGRectMake(self.verticalLine.right, 0.f, self.width - self.verticalLine.right, self.height);
        } else {
            btn.frame = CGRectMake(btnWidth * idx, 0.f, btnWidth, self.height);
        }
    }];
}

- (void) refreshWithSelectedImages:(NSArray *)selectedImages
                  unselectedImages:(NSArray *)unselectedImages
                            titles:(NSArray *)titles
                          itemType:(ScrawlToolBarItemType)itemType {
    self.itemType = itemType;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        if (v != self.topLine && v != self.verticalLine) {
            [v removeFromSuperview];
        }
    }];
    
    NSMutableArray *btns = [@[] mutableCopy];
    [selectedImages enumerateObjectsUsingBlock:^(NSString *selectedImageName, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:titles[idx] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        btn.selected = self.selectedIndex == idx;
        
//        [btn setImage:[UIImage imageNamed:unselectedImages[idx]] forState:UIControlStateSelected];
//        [btn setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];

        @weakify(self, btn)
        [btn bk_addEventHandler:^(id sender) {
            @strongify(self, btn)
            btn.selected = !btn.selected;
            [self.btns bk_each:^(UIButton *btnL) {
                if (btn != btnL) {
                    btnL.selected = NO;
                }
            }];
            if ([self.delegate respondsToSelector:@selector(floatView:toolBarItem:didSelected:atIndex:)]) {
                [self.delegate floatView:self toolBarItem:self.itemType didSelected:btn.selected atIndex:idx];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btns addObject:btn];
    }];
    
    self.btns = [btns copy];
}

#pragma mark - getters
LazyPropertyWithInit(UIView, topLine, {
    _topLine.backgroundColor = [UIColor hex_colorWithHex:0xF2F4F6];
})
LazyPropertyWithInit(UIView, verticalLine, {
    _verticalLine.backgroundColor = [UIColor hex_colorWithHex:0xF2F4F6];
})
@end

#import "ScrawlBottomToolBarControl.h"

@interface ScrawlBottomToolBarControl()
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIButton *pixellateBtn;
@property (nonatomic, strong) UIButton *watermarkBtn;
@property (nonatomic, strong) UIButton *guideLineBtn;
@property (nonatomic, strong) UIButton *phoneBoundsBtn;
@end

@implementation ScrawlBottomToolBarControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.topLine];
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@0.5f);
        }];
        [self addSubview:self.pixellateBtn];
        [self addSubview:self.watermarkBtn];
        [self addSubview:self.guideLineBtn];
        [self addSubview:self.phoneBoundsBtn];
        
        [self.pixellateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
        }];
        [self.watermarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pixellateBtn.mas_right);
            make.bottom.top.width.equalTo(self.pixellateBtn);
        }];
        [self.guideLineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.watermarkBtn.mas_right);
            make.bottom.top.width.equalTo(self.pixellateBtn);
        }];
        [self.phoneBoundsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.guideLineBtn.mas_right);
            make.bottom.top.width.equalTo(self.pixellateBtn);
            make.right.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - action
- (void) clickPixellateBtn:(UIButton *)sender {
    [self resetWithClickBtn:sender];
    if ([self.delegate respondsToSelector:@selector(toolBarControl:didSelected:toolBarItem:)]) {
        [self.delegate toolBarControl:self didSelected:sender.selected toolBarItem:ScrawlToolBarItemTypePixellate];
    }
}

- (void) clickWatermark:(UIButton *)sender {
    [self resetWithClickBtn:sender];
    if ([self.delegate respondsToSelector:@selector(toolBarControl:didSelected:toolBarItem:)]) {
        [self.delegate toolBarControl:self didSelected:sender.selected toolBarItem:ScrawlToolBarItemTypeWatermark];
    }
}

- (void) clickGuideLine:(UIButton *)sender {
    [self resetWithClickBtn:sender];
    if ([self.delegate respondsToSelector:@selector(toolBarControl:didSelected:toolBarItem:)]) {
        [self.delegate toolBarControl:self didSelected:sender.selected toolBarItem:ScrawlToolBarItemTypeGuideLine];
    }
}

- (void) clickPhoneBounds:(UIButton *)sender {
    [self resetWithClickBtn:sender];
    if ([self.delegate respondsToSelector:@selector(toolBarControl:didSelected:toolBarItem:)]) {
        [self.delegate toolBarControl:self didSelected:sender.selected toolBarItem:ScrawlToolBarItemTypePhoneBounds];
    }
}

- (void) resetWithClickBtn:(UIButton *)clickBtn {
    clickBtn.selected = !clickBtn.selected;
    [@[self.pixellateBtn, self.watermarkBtn, self.guideLineBtn, self.pixellateBtn] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (clickBtn != btn) {
            btn.selected = NO;
        }
    }];
}

#pragma mark - getters
LazyPropertyWithInit(UIView, topLine, {
    _topLine.backgroundColor = [UIColor hex_colorWithHex:0xF2F4F6];
})
LazyPropertyWithInit(UIButton, pixellateBtn, {
    [_pixellateBtn setTitle:@"马赛克" forState:UIControlStateNormal];
    [_pixellateBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
    [_pixellateBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _pixellateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_pixellateBtn addTarget:self action:@selector(clickPixellateBtn:) forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, watermarkBtn, {
    [_watermarkBtn setTitle:@"水印" forState:UIControlStateNormal];
    [_watermarkBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
    [_watermarkBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _watermarkBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_watermarkBtn addTarget:self action:@selector(clickWatermark:) forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, guideLineBtn, {
    [_guideLineBtn setTitle:@"辅助线" forState:UIControlStateNormal];
    [_guideLineBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
    [_guideLineBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _guideLineBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_guideLineBtn addTarget:self action:@selector(clickGuideLine:) forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIButton, phoneBoundsBtn, {
    [_phoneBoundsBtn setTitle:@"边框" forState:UIControlStateNormal];
    [_phoneBoundsBtn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateNormal];
    [_phoneBoundsBtn setTitleColor:[UIColor hex_colorWithHex:0x6597D4] forState:UIControlStateSelected];
    _phoneBoundsBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_phoneBoundsBtn addTarget:self action:@selector(clickPhoneBounds:) forControlEvents:UIControlEventTouchUpInside];
})
@end
