//
//  EditorCloseAndSwitchControl.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorCloseAndSwitchControl.h"

@interface EditorCloseAndSwitchControl()
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *switchImageView;
@end

@implementation EditorCloseAndSwitchControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hex_colorWithHex:0x000000 alpha:0.8f];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 20.f;
        
        [self addSubview:self.closeBtn];
        [self addSubview:self.line];
        [self addSubview:self.titleLabel];
        [self addSubview:self.switchImageView];
        
        self.titleLabel.text = @"裁剪";
        
        @weakify(self)
        [self bk_addEventHandler:^(id sender) {
            @strongify(self)
            self.selected = !self.selected;
            self.titleLabel.text = self.selected ? @"工具" : @"裁剪";
            if ([self.delegate respondsToSelector:@selector(editorSwitchToState:)]) {
                [self.delegate editorSwitchToState:!self.selected];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.closeBtn.frame = CGRectMake(0.f, 0.f, 44.f, 40.f);
    self.line.frame = CGRectMake(self.closeBtn.right, 14.f, 0.5f, 12.f);
    self.switchImageView.frame = CGRectMake(self.width - 34.f, 10.f, 20.f, 20.f);
    self.titleLabel.frame = CGRectMake(self.line.right, 0.f, self.switchImageView.left - self.line.right, self.height);
}

LazyPropertyWithInit(UIButton, closeBtn, {
    [_closeBtn setImage:[UIImage imageNamed:@"btn_navbar_close_n"] forState:UIControlStateNormal];
    @weakify(self)
    [_closeBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(editorClose)]) {
            [self.delegate editorClose];
        }
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIView, line, {
    _line.backgroundColor = [UIColor hex_colorWithHex:0xFFFFFF alpha:0.8f];
})
LazyPropertyWithInit(UILabel, titleLabel, {
    if (@available(iOS 9.0, *)) {
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
})
LazyPropertyWithInit(UIImageView, switchImageView, {
    _switchImageView.image = [UIImage imageNamed:@"btn_navbar_switch_n"];
})

@end
