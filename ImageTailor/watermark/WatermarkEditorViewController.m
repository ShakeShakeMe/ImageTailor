//
//  WatermarkEditorViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/18.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "WatermarkEditorViewController.h"
#import "UIAlertView+BlocksKit.h"

@interface WatermarkEditorViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurBgView;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UITextField *tf;

@property (nonatomic, assign) CGFloat keybordHeight;

@property (nonatomic, strong) UIView *btnContainerView;
@property (nonatomic, strong) UIButton *defaultStyleBtn;
@property (nonatomic, strong) UIButton *otherStyleBtn;
@property (nonatomic, strong) UIButton *clearBtn;
@end

@implementation WatermarkEditorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurBgView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurBgView.alpha = 0.f;
    [self.view addSubview:self.blurBgView];
    
    self.finishBtn = [[UIButton alloc] init];
    [self.finishBtn setImage:[UIImage imageNamed:@"btn_navbar_use_n"] forState:UIControlStateNormal];
    [self.blurBgView.contentView addSubview:self.finishBtn];
    @weakify(self)
    [self.finishBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        if (self.tf.text.length == 0) {
            [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"请输入水印文案" cancelButtonTitle:nil otherButtonTitles:@[@"OK"] handler:nil];
            return ;
        }
        [self dismissAnimating];
        [self.tf resignFirstResponder];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.tf = [[UITextField alloc] init];
    self.tf.textColor = [UIColor whiteColor];
    self.tf.font = [UIFont systemFontOfSize:20];
    self.tf.textAlignment = NSTextAlignmentCenter;
    self.tf.borderStyle = UITextBorderStyleNone;
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:20],
                            NSForegroundColorAttributeName: [UIColor hex_colorWithHex:0x999999]};
    self.tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入水印文案" attributes:attrs];
    self.tf.clearButtonMode = UITextFieldViewModeNever;
    self.tf.keyboardType = UIKeyboardTypeDefault;
    self.tf.returnKeyType = UIReturnKeyDone;
    [self.tf becomeFirstResponder];
    [self.blurBgView.contentView addSubview:self.tf];
    
    [self.blurBgView.contentView addSubview:self.btnContainerView];
    [self.btnContainerView addSubview:self.defaultStyleBtn];
    [self.btnContainerView addSubview:self.otherStyleBtn];
    [self.btnContainerView addSubview:self.clearBtn];
    
    self.tf.text = self.text;
    if (self.prefixType == EditorWatermarkPrefixTypeNormal) {
        self.defaultStyleBtn.selected = YES;
    } else if (self.prefixType == EditorWatermarkPrefixTypeOther) {
        self.otherStyleBtn.selected = YES;
    } else {
        self.clearBtn.selected = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 1.f;
    }];
}

- (void)dismissAnimating {
    if ([self.delegate respondsToSelector:@selector(didChangeWatermarkText:prefixType:)]) {
        EditorWatermarkPrefixType prefixType = EditorWatermarkPrefixTypeNone;
        if (self.defaultStyleBtn.selected) {
            prefixType = EditorWatermarkPrefixTypeNormal;
        } else if (self.otherStyleBtn.selected) {
            prefixType = EditorWatermarkPrefixTypeOther;
        }
        [self.delegate didChangeWatermarkText:self.tf.text prefixType:prefixType];
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.blurBgView.frame = self.view.bounds;
    
    self.finishBtn.size = CGSizeMake(50.f, 50.f);
    self.finishBtn.right = self.blurBgView.right - 7.f;
    self.finishBtn.top = self.mergedSafeAreaInsets.top;
    
    self.tf.size = CGSizeMake(self.view.width, 40.f);
    self.tf.left = self.view.left;
    self.tf.centerY = self.view.centerY - self.keybordHeight / 2.f;
    
    self.btnContainerView.size = CGSizeMake(self.blurBgView.contentView.width, 44.f);
    self.btnContainerView.centerX = self.blurBgView.contentView.centerX;
    self.btnContainerView.bottom = self.blurBgView.bottom - self.mergedSafeAreaInsets.bottom - self.keybordHeight;
    
    self.clearBtn.frame = CGRectMake(self.btnContainerView.width - 44.f - 6.f, 0.f, 44.f, 44.f);
    self.otherStyleBtn.frame = CGRectMake(self.clearBtn.left - 44.f - 4.f, 0.f, 44.f, 44.f);
    self.defaultStyleBtn.frame = CGRectMake(self.otherStyleBtn.left - 44.f - 4.f, 0.f, 44.f, 44.f);
}

- (void) keybordWillShow:(NSNotification *)noti {
    self.keybordHeight = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.tf.centerY = self.view.centerY - self.keybordHeight / 2.f;
    self.btnContainerView.bottom = self.blurBgView.bottom - self.mergedSafeAreaInsets.bottom - self.keybordHeight;
}

- (void) keybordWillHide:(NSNotification *)noti {
    self.keybordHeight = 0.f;
    self.tf.centerY = self.view.centerY;
    self.btnContainerView.bottom = self.blurBgView.bottom - self.mergedSafeAreaInsets.bottom;
}

- (void) clearOtherBtnState:(UIButton *)btn {
    [@[self.defaultStyleBtn, self.otherStyleBtn, self.clearBtn] bk_each:^(UIButton *b) {
        if (b != btn) {
            b.selected = NO;
        }
    }];
    btn.selected = YES;
}

#pragma mark - getters
LazyProperty(UIView, btnContainerView)
LazyPropertyWithInit(UIButton, defaultStyleBtn, {
    [_defaultStyleBtn setImage:[UIImage imageNamed:@"btn_watermark_label_1_n"] forState:UIControlStateNormal];
    [_defaultStyleBtn setImage:[UIImage imageNamed:@"btn_watermark_label_1_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_defaultStyleBtn bk_addEventHandler:^(UIButton *sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
    } forControlEvents:UIControlEventTouchUpInside];
})

LazyPropertyWithInit(UIButton, otherStyleBtn, {
    [_otherStyleBtn setImage:[UIImage imageNamed:@"btn_watermark_label_2_n"] forState:UIControlStateNormal];
    [_otherStyleBtn setImage:[UIImage imageNamed:@"btn_watermark_label_2_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_otherStyleBtn bk_addEventHandler:^(UIButton *sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
    } forControlEvents:UIControlEventTouchUpInside];
})

LazyPropertyWithInit(UIButton, clearBtn, {
    [_clearBtn setImage:[UIImage imageNamed:@"btn_watermark_label_none_n"] forState:UIControlStateNormal];
    [_clearBtn setImage:[UIImage imageNamed:@"btn_watermark_label_none_s"] forState:UIControlStateSelected];
    @weakify(self)
    [_clearBtn bk_addEventHandler:^(UIButton *sender) {
        @strongify(self)
        [self clearOtherBtnState:sender];
    } forControlEvents:UIControlEventTouchUpInside];
})
@end
